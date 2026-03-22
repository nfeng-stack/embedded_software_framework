#define LOG_TAG "at_cmd"
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "osal.h"
#include "hal.h"
#include "elog.h"

// AT响应状态码
#define AT_RSP_OK 0        // 成功匹配到标准结束标志（OK/ERROR）
#define AT_RSP_TIMEOUT -1  // 超时
#define AT_RSP_OVERFLOW -2 // 缓冲区溢出
#define AT_RSP_ERROR -3    // 命令执行失败（检测到ERROR）

/**
 * @brief 等待AT命令响应，确保在完整响应中匹配结束标志
 * @param expected_end 用户指定的结束字符串（如"CONNECT"），为NULL则只检查标准结束标志
 * @param buffer 输出缓冲区
 * @param buf_size 缓冲区大小
 * @param timeout_ms 超时时间（毫秒）
 * @return AT_RSP_OK(0)：命令执行完成（含OK/ERROR）；AT_RSP_ERROR(-3)：命令失败；AT_RSP_TIMEOUT(-1)：超时；AT_RSP_OVERFLOW(-2)：溢出
 */
static int at_rsp_wait(const char *expected_end, char *buffer, size_t buf_size, uint32_t timeout_ms)
{
    if (!buffer || buf_size == 0)
    {
        log_e("at_rsp_wait: invalid parameters (buffer=%p, size=%zu)", buffer, buf_size);
        return AT_RSP_TIMEOUT;
    }

    memset(buffer, 0, buf_size);
    size_t idx = 0;
    uint32_t start_time = osal_tick_get();

    // 标准结束标志列表
    const char *std_markers[] = {"OK", "ERROR", "+CME ERROR", NULL};

    while (1)
    {
        // 超时检查
        if (osal_tick_get() - start_time > timeout_ms)
        {
            log_w("at_rsp_wait: timeout after %d ms. Received: %.50s...", timeout_ms, buffer);
            return AT_RSP_TIMEOUT;
        }

        // 读取一个字符
        uint8_t ch;
        if (hal_uart2_read(&ch, 1) != 1)
        {
            osal_task_delay(1);
            continue;
        }

        // 过滤非法控制字符（保留 \r \n \t）
        if (ch < 32 && ch != '\r' && ch != '\n' && ch != '\t')
        {
            continue;
        }

        // 存入缓冲区
        if (idx < buf_size - 1)
        {
            buffer[idx++] = (char)ch;
            buffer[idx] = '\0';
        }
        else
        {
            log_e("at_rsp_wait: buffer overflow at %zu/%zu", idx, buf_size);
            return AT_RSP_OVERFLOW;
        }

        // ========== 1. 检查标准结束标志（OK/ERROR/+CME ERROR） ==========
        bool is_standard_match = false;
        for (int i = 0; std_markers[i] != NULL; i++)
        {
            size_t marker_len = strlen(std_markers[i]);
            if (idx >= marker_len && strncmp(buffer + idx - marker_len, std_markers[i], marker_len) == 0)
            {
                // 确保在行首
                bool at_line_start = (idx == marker_len) || (buffer[idx - marker_len - 1] == '\r' || buffer[idx - marker_len - 1] == '\n');
                // 确保后面是换行、空格或字符串结束
                bool next_ok = (idx >= buf_size - 1) || (buffer[idx] == '\r' || buffer[idx] == '\n' || buffer[idx] == ' ' || buffer[idx] == '\0');
                if (at_line_start && next_ok)
                {
                    is_standard_match = true;
                    break;
                }
            }
        }
        if (is_standard_match)
        {
            // 检查是否有错误
            if (strstr(buffer, "ERROR") != NULL || strstr(buffer, "+CME ERROR") != NULL)
            {
                return AT_RSP_ERROR;
            }
            return AT_RSP_OK;
        }

        // ========== 2. 检查用户指定的结束字符串（非标准标志） ==========
        if (expected_end && *expected_end)
        {
            size_t exp_len = strlen(expected_end);
            if (idx >= exp_len && strncmp(buffer + idx - exp_len, expected_end, exp_len) == 0)
            {
                // 确保该字符串在行首
                bool at_line_start = (idx == exp_len) || (buffer[idx - exp_len - 1] == '\r' || buffer[idx - exp_len - 1] == '\n');
                if (at_line_start)
                {
                    // 继续读取直到行尾（'\n'）
                    while (1)
                    {
                        // 超时检查
                        if (osal_tick_get() - start_time > timeout_ms)
                        {
                            log_w("at_rsp_wait: timeout while reading to line end");
                            return AT_RSP_TIMEOUT;
                        }
                        uint8_t ch2;
                        if (hal_uart2_read(&ch2, 1) != 1)
                        {
                            osal_task_delay(1);
                            continue;
                        }
                        // 存入缓冲区
                        if (idx < buf_size - 1)
                        {
                            buffer[idx++] = (char)ch2;
                            buffer[idx] = '\0';
                        }
                        else
                        {
                            log_e("at_rsp_wait: buffer overflow while reading line");
                            return AT_RSP_OVERFLOW;
                        }
                        // 遇到换行符则结束读取
                        if (ch2 == '\n')
                        {
                            // 检查整行中是否包含错误
                            if (strstr(buffer, "ERROR") != NULL || strstr(buffer, "+CME ERROR") != NULL)
                            {
                                return AT_RSP_ERROR;
                            }
                            return AT_RSP_OK;
                        }
                    }
                }
            }
        }
    }
}
/**<at 命令具体实现 */
#define AT_BUFFER_SIZE 500
#define AT_RSP_TIMEOUT 400

int32_t at_check_sim_status_is_ready(void)
{
    char *buffer = (char *)osal_malloc(AT_BUFFER_SIZE);
    if (buffer == NULL)
    {
        log_e("%s malloc buffer error\n", __func__);
        return -1;
    }
    hal_uart2_write("AT+CPIN?\r\n");
    int32_t res = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_RSP_TIMEOUT);
    if (res != AT_RSP_OK)
    {
        osal_free(buffer);
        log_e("%s at rsp wait error :%d", __func__, res);
        return -1;
    }
    if (strstr(buffer, "READY") != NULL)
    {
        res = 0;
    }
    else if (strstr(buffer, "SIM PIN") != NULL)
    {
        res = -1;
    }
    // log_d("%s\n",buffer);
    osal_free(buffer);
    return res;
}
/**
 * @brief 检查模块是否可以发送短信
 */
int32_t at_check_sms_status(void)
{
    char *buffer = (char *)osal_malloc(AT_BUFFER_SIZE);
    if (buffer == NULL)
    {
        log_e("%s malloc buffer error\n", __func__);
        return -1;
    }
    hal_uart2_write("AT+CREG?\r\n");
    int32_t res = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_RSP_TIMEOUT);
    if (res != AT_RSP_OK)
    {
        osal_free(buffer);
        log_e("%s at rsp wait error :%d", __func__, res);
        return -1;
    }
    char *p = strstr(buffer, "+CREG:");
    if (p != NULL)
    {
        p = p + strlen("+CREG: ");
        char mode = *p++;
        if (*p++ != ',')
        {
            log_e("%s para error", __func__);
            osal_free(buffer);
            return -1;
        }
        char status = *p;
        if (mode == '0' || status == '1')
        {
            res = 0;
        }
    }
    // log_d("%s\n", buffer);
    osal_free(buffer);
    return res;
}

/**
 * @brief  检查模块是否可以上网
 */

int32_t at_check_net_status(void)
{
    char *buffer = (char *)osal_malloc(AT_BUFFER_SIZE);
    if (buffer == NULL)
    {
        log_e("%s malloc buffer error\n", __func__);
        return -1;
    }
    hal_uart2_write("AT+CGREG?\r\n");
    int32_t res = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_RSP_TIMEOUT);
    if (res != AT_RSP_OK)
    {
        osal_free(buffer);
        log_e("%s at rsp wait error :%d\n", __func__, res);
        return -1;
    }
    char *p = strstr(buffer, "+CGREG:");
    if (p != NULL)
    {
        p = p + strlen("+CGREG: ");
        char mode = *p++;
        if (*p++ != ',')
        {
            log_e("%s para error\n", __func__);
            osal_free(buffer);
            return -1;
        }
        char status = *p;
        if (mode == '0' || status == '1')
        {
            res = 0;
        }
    }
    // log_d("%s\n", buffer);
    osal_free(buffer);
    return res;
}

#define UNICOM_APN "3gnet" // 联通通用APN，如果是特殊专网卡可能需要改为 "cuiot" 或 "uninet"
#define PDP_CID 1          // 使用上下文ID 1

/**
 * @brief 辅助函数：检查字符串中是否包含子串
 */
static int contains_str(const char *haystack, const char *needle)
{
    if (haystack == NULL || needle == NULL)
        return 0;
    return (strstr(haystack, needle) != NULL) ? 1 : 0;
}

/**
 * @brief 设置并激活联通物联卡的 APN
 *
 * 流程:
 * 1. 查询当前 APN 配置
 * 2. 如果 CID 1 不是 "3gnet"，则重新配置
 * 3. 激活 PDP 上下文
 * 4. 验证是否获取到 IP
 *
 * @return 0: 成功 (已配置且激活), -1: 失败
 */
int32_t at_set_apn(void)
{
    char *buffer = (char *)osal_malloc(AT_BUFFER_SIZE);
    if (buffer == NULL)
    {
        log_e("%s malloc buffer error\n", __func__);
        return -1;
    }

    // 清空缓冲区，防止脏数据
    memset(buffer, 0, AT_BUFFER_SIZE);

    log_i("[%s] Start checking APN configuration...", __func__);

    // ---------------------------------------------------------
    // 第一步：查询当前 APN 配置
    // ---------------------------------------------------------
    hal_uart2_write("AT+CGDCONT?\r\n");
    // 注意：这里假设 at_rsp_wait 会将响应存入 buffer，并以 \0 结尾
    // 如果你的驱动需要传入期望的结束符，请自行调整
    int32_t res = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_RSP_TIMEOUT);

    if (res != AT_RSP_OK)
    {
        log_e("%s Query CGDCONT failed: %d\n", __func__, res);
        osal_free(buffer);
        return -1;
    }

    log_i("%s Query Result:\n%s", __func__, buffer);

    // ---------------------------------------------------------
    // 第二步：智能判断是否需要配置
    // 我们寻找是否存在: +CGDCONT: 1,"IP","3gnet"
    // 为了容错，只要看到 CID 1 和 3gnet 在一起即可
    // ---------------------------------------------------------
    char target_pattern[64];
    sprintf(target_pattern, "+CGDCONT: %d,", PDP_CID);

    int need_config = 1; // 默认假设需要配置

    // 简单的解析逻辑：
    // 1. 找到对应 CID 的行
    // 2. 检查该行是否包含 "3gnet"
    char *line_start = strstr(buffer, target_pattern);
    if (line_start != NULL)
    {
        // 在这一行里找 APN 名称
        // 格式通常是 +CGDCONT: 1,"IP","3gnet",...
        // 我们检查后面是否紧跟 "3gnet"
        if (strstr(line_start, UNICOM_APN) != NULL)
        {
            log_i("[%s] APN already configured correctly for CID %d (%s). Skip setting.",
                  __func__, PDP_CID, UNICOM_APN);
            need_config = 0;
        }
        else
        {
            log_w("[%s] CID %d exists but APN is incorrect. Will reconfigure.", __func__, PDP_CID);
        }
    }
    else
    {
        log_w("[%s] CID %d not found. Will create new configuration.", __func__, PDP_CID);
    }

    // ---------------------------------------------------------
    // 第三步：如果需要，执行配置命令
    // ---------------------------------------------------------
    if (need_config)
    {
        log_i("[%s] Setting APN: AT+CGDCONT=%d,\"IP\",\"%s\"", __func__, PDP_CID, UNICOM_APN);

        char cmd_buf[64];
        sprintf(cmd_buf, "AT+CGDCONT=%d,\"IP\",\"%s\"\r\n", PDP_CID, UNICOM_APN);

        hal_uart2_write(cmd_buf);
        res = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_RSP_TIMEOUT);

        if (res != AT_RSP_OK)
        {
            log_e("%s Set CGDCONT failed: %d\n", __func__, res);
            osal_free(buffer);
            return -1;
        }
        log_i("[%s] APN Set successfully.", __func__);

        // 可选：部分模块需要保存配置到 Flash (如 SIM800系列用 AT+CSAS)
        // 大多数 4G Cat1 模块 (如 EC200U, L610) 自动保存，此处省略以防兼容性问题
    }

    // ---------------------------------------------------------
    // 第四步：激活 PDP 上下文 (拨号)
    // ---------------------------------------------------------
    log_i("[%s] Activating PDP Context (CID %d)...", __func__, PDP_CID);
    memset(buffer, 0, AT_BUFFER_SIZE);

    char act_cmd[32];
    sprintf(act_cmd, "AT+CGACT=1,%d\r\n", PDP_CID);
    hal_uart2_write(act_cmd);

    // 激活可能需要更长时间，特别是信号弱时，可适当延长超时
    res = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_RSP_TIMEOUT * 2);

    if (res != AT_RSP_OK)
    {
        log_e("%s Activate CGACT failed: %d. Response: %s", __func__, res, buffer);
        // 激活失败不一定代表彻底失败，可能是网络拥塞，但此处先返回错误
        osal_free(buffer);
        return -1;
    }
    log_i("[%s] PDP Context Activated.", __func__);

    // ---------------------------------------------------------
    // 第五步：验证是否获取到 IP 地址
    // ---------------------------------------------------------
    log_i("[%s] Checking IP address...", __func__);
    memset(buffer, 0, AT_BUFFER_SIZE);

    char ip_cmd[32];
    sprintf(ip_cmd, "AT+CGPADDR=%d\r\n", PDP_CID);
    hal_uart2_write(ip_cmd);

    res = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_RSP_TIMEOUT);
    if (res == AT_RSP_OK)
    {
        // 检查返回中是否有 IP 地址 (简单判断是否包含数字和点)
        // 正常返回: +CGPADDR: 1,"10.156.23.101"
        if (strstr(buffer, "+CGPADDR") != NULL && strstr(buffer, ".") != NULL)
        {
            log_i("[%s] Network Ready! Got IP: %s", __func__, buffer);
            osal_free(buffer);
            return 0; // 成功
        }
        else
        {
            log_w("[%s] Activated but no valid IP returned yet: %s", __func__, buffer);
            // 有时激活后需要稍等片刻再查 IP，这里视情况可重试或直接返回
        }
    }

    log_e("%s Final verification failed.", __func__);
    osal_free(buffer);
    return -1;
}

#define AT_BUFFER_SIZE 2000

/* 超时定义（毫秒） */
#define AT_CMD_TIMEOUT 10000  /* AT命令基本超时 */
#define AT_RSP_TIMEOUT 30000  /* 响应等待超时 */
#define AT_HTTP_TIMEOUT 30000 /* HTTP操作超时 */

/**
 * @brief 发送AT命令并等待响应
 * @param cmd         AT命令（含\r\n）
 * @param rsp_buf     响应缓冲区
 * @param buf_size    缓冲区大小
 * @param timeout     超时时间（毫秒）
 * @return AT_RSP_OK/ERROR/TIMEOUT
 */
static int at_send_cmd(const char *cmd, char *rsp_buf, int buf_size, int timeout)
{
    hal_uart2_write(cmd);
    return at_rsp_wait(NULL, rsp_buf, buf_size, timeout);
}

/**
 * @brief 发送AT命令并检查返回OK
 * @param cmd AT命令（含\r\n）
 * @return 0成功，-1失败
 */
static int at_send_and_check_ok(const char *cmd)
{
    char buffer[256];
    int ret = at_send_cmd(cmd, buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK)
        return -1;
    if (strstr(buffer, "OK") == NULL)
        return -1;
    return 0;
}

/**
 * @brief 发送AT命令并等待特定字符串
 * @param cmd         AT命令（含\r\n）
 * @param expected    期望出现的字符串（如"CONNECT"）
 * @param rsp_buf     响应缓冲区
 * @param buf_size    缓冲区大小
 * @param timeout     超时时间（毫秒）
 * @return AT_RSP_OK/ERROR/TIMEOUT
 */
static int at_send_and_wait_for(const char *cmd, const char *expected, char *rsp_buf, int buf_size, int timeout)
{
    hal_uart2_write(cmd);
    return at_rsp_wait(expected, rsp_buf, buf_size, timeout);
}

/**
 * @brief 执行完整的HTTP GET请求
 * @return 0成功，-1失败
 */
int at_do_http_request(void)
{
    char buffer[AT_BUFFER_SIZE];
    int ret;
    char *p;

    /* ========== 1. 基本AT通信测试 ========== */
    ret = at_send_and_check_ok("AT\r\n");
    if (ret != 0)
    {
        log_e("AT command failed\n");
        return -1;
    }

    /* ========== 2. 检查SIM卡状态 ========== */
    ret = at_send_cmd("AT+CPIN?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "+CPIN: READY") == NULL)
    {
        log_e("SIM card not ready\n");
        return -1;
    }

    /* ========== 3. 查询信号强度 ========== */
    ret = at_send_cmd("AT+CSQ\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "+CSQ:") == NULL)
    {
        log_e("CSQ query failed\n");
        return -1;
    }

    /* ========== 4. 检查网络注册状态 ========== */
    ret = at_send_cmd("AT+CGREG?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("CGREG query failed\n");
        return -1;
    }
    p = strstr(buffer, "+CGREG:");
    if (p == NULL)
    {
        log_e("CGREG parse error\n");
        return -1;
    }
    p += strlen("+CGREG: ");
    char mode = *p++;
    if (*p++ != ',')
    {
        log_e("CGREG format error\n");
        return -1;
    }
    char status = *p;
    if (mode != '0' || status != '1')
    {
        log_e("Not registered, mode=%c status=%c\n", mode, status);
        return -1;
    }

    /* ========== 5. 检查PS域附着 ========== */
    ret = at_send_cmd("AT+CGATT?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "+CGATT: 1") == NULL)
    {
        log_e("Not attached\n");
        return -1;
    }

    /* ========== 6. 配置PDP上下文 ========== */
    ret = at_send_and_check_ok("AT+QICSGP=1,1,\"UNINET\",\"\",\"\",1\r\n");
    if (ret != 0)
    {
        log_e("QICSGP config failed\n");
        return -1;
    }

    /* ========== 7. 激活PDP上下文 ========== */
    ret = at_send_and_check_ok("AT+QIACT=1\r\n");
    if (ret != 0)
    {
        log_e("QIACT failed\n");
        return -1;
    }

    /* ========== 8. 获取IP地址（可选，用于调试） ========== */
    ret = at_send_cmd("AT+QIACT?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "+QIACT:") == NULL)
    {
        log_w("QIACT query failed, but continue\n");
    }
    else
    {
        log_d("IP obtained: %s\n", buffer);
    }

    /* ========== 9. SSL/TLS配置 ========== */
    ret = at_send_and_check_ok("AT+QSSLCFG=\"sslversion\",1,1\r\n");
    if (ret != 0)
        return -1;
    ret = at_send_and_check_ok("AT+QSSLCFG=\"ciphersuite\",1,0xFFFF\r\n");
    if (ret != 0)
        return -1;
    ret = at_send_and_check_ok("AT+QSSLCFG=\"seclevel\",1,0\r\n");
    if (ret != 0)
        return -1;

    /* ========== 10. HTTP配置 ========== */
    ret = at_send_and_check_ok("AT+QHTTPCFG=\"contextid\",1\r\n");
    if (ret != 0)
        return -1;
    ret = at_send_and_check_ok("AT+QHTTPCFG=\"sslctxid\",1\r\n");
    if (ret != 0)
        return -1;
    ret = at_send_and_check_ok("AT+QHTTPCFG=\"responseheader\",1\r\n");
    if (ret != 0)
        return -1;
    ret = at_send_and_check_ok("AT+QHTTPCFG=\"requestheader\",1\r\n");
    if (ret != 0)
        return -1;

    /* ========== 11. 设置URL ========== */
    /* 发送AT+QHTTPURL，等待CONNECT */
    ret = at_send_and_wait_for("AT+QHTTPURL=109,300\r\n", "CONNECT", buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("QHTTPURL CONNECT not received\n");
        return -1;
    }
    /* 发送URL数据 */
    const char *url = "https://restapi.amap.com/v3/geocode/regeo?location=116.481488,39.990464&key=4f70fd02d9bc904c99e6a341eb0f3d94";
    hal_uart2_write(url);
    hal_uart2_write("\r\n");
    /* 等待OK确认 */
    ret = at_rsp_wait(NULL, buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "OK") == NULL)
    {
        log_e("URL data not accepted\n");
        return -1;
    }

    /* ========== 12. 发起GET请求 ========== */
    /* 发送AT+QHTTPGET并等待CONNECT */
    /* 构造符合HTTP/1.1规范的请求头 */
    const char *http_request =
        "GET /v3/geocode/regeo?location=116.481488,39.990464&key=4f70fd02d9bc904c99e6a341eb0f3d94 HTTP/1.1\r\n"
        "Host: restapi.amap.com\r\n"
        "\r\n";
    /* 3. 动态计算实际长度 */

    size_t head_len = strlen(http_request); // 精确计算，包含所有\r\n

    /* 4. 发送QHTTPGET命令 */
    char cmd[64];
    snprintf(cmd, sizeof(cmd), "AT+QHTTPGET=80,%zu\r\n", head_len);
    ret = at_send_and_wait_for(cmd, "CONNECT", buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("QHTTPGET CONNECT not received\n");
        return -1;
    }

    /* 发送HTTP请求 */
    hal_uart2_write(http_request);

    /* 第一步：等待数据接收确认（OK） */
    ret = at_rsp_wait(NULL, buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "OK") == NULL)
    {
        log_e("HTTP request not acknowledged\n");
        return -1;
    }

    /* 第二步：等待HTTP响应结果（+QHTTPGET: ...） */
    ret = at_rsp_wait("+QHTTPGET:", buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("HTTP response status not received\n");
        return -1;
    }

    /* 检查状态码是否为200 */
    if (strstr(buffer, "+QHTTPGET: 0,200,") == NULL)
    {
        log_e("HTTP response status not 200\n");
        return -1;
    }

    /* ========== 13. 读取响应数据 ========== */
    hal_uart2_write("AT+QHTTPREAD=80\r\n");
    /* 读取数据（包含HTTP头和JSON正文） */
    ret = at_rsp_wait("+QHTTPREAD: 0", buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("QHTTPREAD data read failed\n");
        return -1;
    }

    /* 打印或处理响应数据 */
    log_e("HTTP response:\n%s\n", buffer);

    /* ========== 14. 去激活PDP上下文 ========== */
    ret = at_send_and_check_ok("AT+QIDEACT=1\r\n");
    if (ret != 0)
    {
        log_e("QIDEACT failed\n");
        return -1;
    }

    log_i("HTTP request completed successfully\n");
    return 0;
}
