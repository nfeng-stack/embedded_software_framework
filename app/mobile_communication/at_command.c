#define LOG_TAG "at_cmd"
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "osal.h"
#include "hal.h"
#include "elog.h"

// AT响应状态码
#define AT_RSP_OK 0
#define AT_RSP_TIMEOUT -1
#define AT_RSP_OVERFLOW -2
#define AT_RSP_ERROR -3

#define AT_BUFFER_SIZE 2000
#define AT_CMD_TIMEOUT 10000
#define AT_HTTP_TIMEOUT 30000

/**
 * @brief 等待AT命令响应，确保在完整响应中匹配结束标志
 * @param expected_end 用户指定的结束字符串（如"CONNECT"），为NULL则只检查标准结束标志
 * @param buffer 输出缓冲区
 * @param buf_size 缓冲区大小
 * @param timeout_ms 超时时间（毫秒）
 * @return AT_RSP_OK/ERROR/TIMEOUT/OVERFLOW
 */
static int at_rsp_wait(const char *expected_end, char *buffer, size_t buf_size, uint32_t timeout_ms)
{
    if (!buffer || buf_size == 0)
        return AT_RSP_TIMEOUT;
    memset(buffer, 0, buf_size);
    size_t idx = 0;
    uint32_t start_time = osal_tick_get();
    const char *std_markers[] = {"OK", "ERROR", "+CME ERROR", NULL};

    while (1)
    {
        if (osal_tick_get() - start_time > timeout_ms)
        {
            log_w("at_rsp_wait timeout");
            return AT_RSP_TIMEOUT;
        }
        uint8_t ch;
        if (hal_uart2_read(&ch, 1) != 1)
        {
            osal_task_delay(1);
            continue;
        }
        if (ch < 32 && ch != '\r' && ch != '\n' && ch != '\t')
            continue;
        if (idx < buf_size - 1)
        {
            buffer[idx++] = (char)ch;
            buffer[idx] = '\0';
        }
        else
        {
            log_e("buffer overflow");
            return AT_RSP_OVERFLOW;
        }

        // 检查标准结束标志
        for (int i = 0; std_markers[i]; i++)
        {
            size_t len = strlen(std_markers[i]);
            if (idx >= len && strncmp(buffer + idx - len, std_markers[i], len) == 0)
            {
                bool line_start = (idx == len) || (idx > len && (buffer[idx - len - 1] == '\r' || buffer[idx - len - 1] == '\n'));
                if (line_start)
                {
                    if (strstr(buffer, "ERROR") || strstr(buffer, "+CME ERROR"))
                        return AT_RSP_ERROR;
                    return AT_RSP_OK;
                }
            }
        }

        // 检查用户指定结束字符串
        if (expected_end && *expected_end)
        {
            size_t exp_len = strlen(expected_end);
            if (idx >= exp_len && strncmp(buffer + idx - exp_len, expected_end, exp_len) == 0)
            {
                bool line_start = (idx == exp_len) || (idx > exp_len && (buffer[idx - exp_len - 1] == '\r' || buffer[idx - exp_len - 1] == '\n'));
                if (line_start)
                {
                    // 继续读到行尾
                    while (1)
                    {
                        if (osal_tick_get() - start_time > timeout_ms)
                            return AT_RSP_TIMEOUT;
                        if (hal_uart2_read(&ch, 1) != 1)
                        {
                            osal_task_delay(1);
                            continue;
                        }
                        if (idx < buf_size - 1)
                        {
                            buffer[idx++] = (char)ch;
                            buffer[idx] = '\0';
                        }
                        else
                            return AT_RSP_OVERFLOW;
                        if (ch == '\n')
                            break;
                    }
                    if (strstr(buffer, "ERROR") || strstr(buffer, "+CME ERROR"))
                        return AT_RSP_ERROR;
                    return AT_RSP_OK;
                }
            }
        }
    }
}

static int at_send_cmd(const char *cmd, char *rsp_buf, int buf_size, int timeout)
{
    hal_uart2_write(cmd);
    return at_rsp_wait(NULL, rsp_buf, buf_size, timeout);
}

static int at_send_and_check_ok(const char *cmd)
{
    char *buffer = (char *)osal_malloc(256);
    if (!buffer)
        return -1;
    int ret = at_send_cmd(cmd, buffer, 256, AT_CMD_TIMEOUT);
    int result = (ret == AT_RSP_OK && strstr(buffer, "OK")) ? 0 : -1;
    osal_free(buffer);
    return result;
}

static int at_send_and_wait_for(const char *cmd, const char *expected, char *rsp_buf, int buf_size, int timeout)
{
    hal_uart2_write(cmd);
    return at_rsp_wait(expected, rsp_buf, buf_size, timeout);
}

// ==================== 网络初始化 ====================
/**
 * @brief 初始化网络连接（SIM卡、注册、PDP激活）
 * @return 0成功，-1失败
 */
int at_module_config(void)
{
    char buffer[256];
    int ret;

    // 1. 测试AT通信
    if (at_send_and_check_ok("AT\r\n") != 0)
    {
        log_e("AT communication failed");
        return -1;
    }

    // 2. 检查SIM卡
    ret = at_send_cmd("AT+CPIN?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "+CPIN: READY") == NULL)
    {
        log_e("SIM not ready");
        return -1;
    }

    // 3. 查询信号强度
    ret = at_send_cmd("AT+CSQ\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "+CSQ:") == NULL)
    {
        log_e("CSQ query failed");
        return -1;
    }

    // 4. 检查网络注册
    ret = at_send_cmd("AT+CGREG?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("CGREG query failed");
        return -1;
    }
    char *p = strstr(buffer, "+CGREG:");
    if (!p)
        return -1;
    p += 8; // skip "+CGREG: "
    if (p[0] != '0' || p[2] != '1')
    {
        log_e("Network not registered, mode=%c status=%c", p[0], p[2]);
        return -1;
    }

    // 5. 检查PS域附着
    ret = at_send_cmd("AT+CGATT?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "+CGATT: 1") == NULL)
    {
        log_e("PS not attached");
        return -1;
    }

    // 6. 配置PDP上下文（使用联通APN，可根据实际修改）
    if (at_send_and_check_ok("AT+QICSGP=1,1,\"UNINET\",\"\",\"\",1\r\n") != 0)
    {
        log_e("PDP config failed");
        return -1;
    }

    // 7. 激活PDP（先查询是否已激活）
    ret = at_send_cmd("AT+QIACT?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret == AT_RSP_OK && strstr(buffer, "+QIACT: 1,1,1,"))
    {
        log_i("PDP already active");
    }
    else
    {
        if (at_send_and_check_ok("AT+QIACT=1\r\n") != 0)
        {
            log_e("PDP activation failed");
            return -1;
        }
    }

    // 8. 获取IP（调试）
    ret = at_send_cmd("AT+QIACT?\r\n", buffer, sizeof(buffer), AT_CMD_TIMEOUT);
    if (ret == AT_RSP_OK && strstr(buffer, "+QIACT:"))
    {
        log_d("IP obtained: %s", buffer);
    }

    return 0;
}

// ==================== HTTP(S) 辅助函数 ====================
static int parse_url(const char *url, char *host, size_t host_size, char *path, size_t path_size)
{
    if (!url || !host || host_size == 0 || !path || path_size == 0)
        return -1;

    const char *p = url;
    if (strncmp(p, "https://", 8) == 0)
    {
        p += 8;
    }
    else
    {
        log_e("Only HTTPS supported");
        return -1;
    }
    const char *host_start = p;
    while (*p && *p != '/')
        p++;
    size_t host_len = p - host_start;
    if (host_len == 0 || host_len >= host_size)
        return -1;
    memcpy(host, host_start, host_len);
    host[host_len] = '\0';

    if (*p == '/')
    {
        size_t path_len = strlen(p);
        size_t copy_len = (path_len < path_size - 1) ? path_len : (path_size - 1);
        memcpy(path, p, copy_len);
        path[copy_len] = '\0';
    }
    else
    {
        if (path_size > 1)
        {
            path[0] = '/';
            path[1] = '\0';
        }
        else
        {
            return -1;
        }
    }
    return 0;
}

static size_t build_http_request(const char *host, const char *path, char *buffer, size_t buf_size)
{
    const char *fmt = "GET %s HTTP/1.1\r\n"
                      "Host: %s\r\n"
                      "\r\n";
    int len = snprintf(buffer, buf_size, fmt, path, host);
    if (len < 0 || (size_t)len >= buf_size)
        return 0;
    return (size_t)len;
}

// ==================== HTTPS GET 核心函数 ====================
/**
 * @brief 执行HTTPS GET请求，自动配置SSL/TLS
 * @param url         完整URL（必须为https://开头）
 * @param response_buf 接收响应数据的缓冲区（仅HTTP正文，不含头）
 * @param buf_size     缓冲区大小
 * @return 0成功，-1失败
 */
int https_get(const char *url, char *response_buf, size_t buf_size)
{
    if (!url || !response_buf || buf_size == 0)
    {
        log_e("Invalid parameters");
        return -1;
    }

    char *host = (char *)osal_malloc(128);
    char *path = (char *)osal_malloc(256);
    char *buffer = (char *)osal_malloc(AT_BUFFER_SIZE);
    char *cmd = (char *)osal_malloc(64);
    char *http_header = (char *)osal_malloc(512);

    if (!host || !path || !buffer || !cmd || !http_header)
    {
        log_e("Memory allocation failed");
        if (host) osal_free(host);
        if (path) osal_free(path);
        if (buffer) osal_free(buffer);
        if (cmd) osal_free(cmd);
        if (http_header) osal_free(http_header);
        return -1;
    }

    memset(host, 0, 128);
    memset(path, 0, 256);

    if (parse_url(url, host, 128, path, 256) != 0)
    {
        log_e("URL parse failed");
        goto cleanup;
    }

    int ret = -1;

    if (at_send_and_check_ok("AT+QHTTPCFG=\"contextid\",1\r\n") != 0 ||
        at_send_and_check_ok("AT+QHTTPCFG=\"sslctxid\",1\r\n") != 0 ||
        at_send_and_check_ok("AT+QHTTPCFG=\"requestheader\",1\r\n") != 0 ||
        at_send_and_check_ok("AT+QHTTPCFG=\"responseheader\",1\r\n") != 0)
    {
        log_e("HTTP config failed");
        goto cleanup;
    }

    if (at_send_and_check_ok("AT+QSSLCFG=\"sslversion\",1,3\r\n") != 0 ||
        at_send_and_check_ok("AT+QSSLCFG=\"ciphersuite\",1,0xFFFF\r\n") != 0 ||
        at_send_and_check_ok("AT+QSSLCFG=\"seclevel\",1,0\r\n") != 0)
    {
        log_e("SSL config failed");
        goto cleanup;
    }

    size_t url_len = strlen(url);
    snprintf(cmd, 64, "AT+QHTTPURL=%zu,30000\r\n", url_len);
    ret = at_send_and_wait_for(cmd, "CONNECT", buffer, AT_BUFFER_SIZE, AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("CONNECT not received");
        goto cleanup;
    }
    hal_uart2_write(url);
    hal_uart2_write("\r\n");
    ret = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "OK") == NULL)
    {
        log_e("URL not accepted");
        goto cleanup;
    }

    size_t header_len = build_http_request(host, path, http_header, 512);
    if (header_len == 0)
    {
        log_e("Build HTTP request failed");
        goto cleanup;
    }

    snprintf(cmd, 64, "AT+QHTTPGET=80,%zu\r\n", header_len);
    ret = at_send_and_wait_for(cmd, "CONNECT", buffer, AT_BUFFER_SIZE, AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("QHTTPGET CONNECT failed");
        goto cleanup;
    }
    hal_uart2_write(http_header);
    ret = at_rsp_wait(NULL, buffer, AT_BUFFER_SIZE, AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "OK") == NULL)
    {
        log_e("Request not acknowledged");
        goto cleanup;
    }

    ret = at_rsp_wait("+QHTTPGET:", buffer, AT_BUFFER_SIZE, AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("QHTTPGET URC failed");
        goto cleanup;
    }

    char *p = strstr(buffer, "+QHTTPGET:");
    if (!p)
    {
        log_e("+QHTTPGET not found in response");
        ret = -1;
        goto cleanup;
    }

    int err_code = -1, http_status = -1, data_len = -1;
    int matched = sscanf(p, "+QHTTPGET: %d,%d,%d", &err_code, &http_status, &data_len);
    if (matched < 2)
    {
        log_e("Parse +QHTTPGET failed, raw: %s", p);
        ret = -1;
        goto cleanup;
    }
    if (err_code != 0)
    {
        log_e("HTTP error: err=%d", err_code);
        ret = -1;
        goto cleanup;
    }
    if (http_status != 200)
    {
        log_e("HTTP status: %d", http_status);
        ret = -1;
        goto cleanup;
    }

    hal_uart2_write("AT+QHTTPREAD=80\r\n");
    ret = at_rsp_wait("+QHTTPREAD:", response_buf, buf_size, AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK)
    {
        log_e("at read rsp error\n%s\n", response_buf);
        ret = -1;
        goto cleanup;
    }

    char *p1 = strstr(response_buf, "CONNECT");
    if (!p1)
    {
        log_e("CONNECT not found");
        ret = -1;
        goto cleanup;
    }
    p1 += strlen("CONNECT");

    char *body_start = strchr(p1, '{');
    if (!body_start)
    {
        log_e("JSON start not found");
        ret = -1;
        goto cleanup;
    }

    if (data_len <= 0)
    {
        log_e("Invalid data_len");
        ret = -1;
        goto cleanup;
    }
    if ((size_t)data_len > buf_size)
    {
        log_e("Body too large: %d > %zu", data_len, buf_size);
        ret = -1;
        goto cleanup;
    }

    memmove(response_buf, body_start, data_len);
    response_buf[data_len] = '\0';
    log_d("HTTPS GET success, received %d bytes, copy %zu bytes", data_len, strlen(response_buf));
    ret = 0;

cleanup:
    osal_free(host);
    osal_free(path);
    osal_free(buffer);
    osal_free(cmd);
    osal_free(http_header);
    return ret;
}

// ==================== 以下为原始测试函数，未改动 ====================
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