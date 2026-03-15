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
 * @param expected_end 用户指定的结束字符串（如">"），为NULL则只检查标准结束标志
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

    // 标准结束标志的长度
    const size_t ok_len = 2;         // "OK"
    const size_t error_len = 5;      // "ERROR"
    const size_t cme_error_len = 10; // "+CME ERROR"

    // 用于跟踪完整响应的结束位置
    size_t complete_rsp_end = 0;

    while (1)
    {
        // 超时判断
        if (osal_tick_get() - start_time > timeout_ms)
        {
            log_w("at_rsp_wait: timeout after %d ms. Received: %.50s...", timeout_ms, buffer);
            return AT_RSP_TIMEOUT;
        }

        // 读取单个字符
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

        // =============== 1. 检查标准结束标志（OK/ERROR） ===============
        bool is_complete_rsp = false;

        // 检查 "OK"
        if (idx >= ok_len &&
            strncmp(buffer + idx - ok_len, "OK", ok_len) == 0)
        {
            // 确保前面有换行或这是第一个字符
            bool prev_ok = (idx == ok_len) ||
                           (buffer[idx - ok_len - 1] == '\r' ||
                            buffer[idx - ok_len - 1] == '\n');
            // 确保后面是换行、空格或字符串结束
            bool next_ok = (idx >= buf_size - 1) ||
                           (buffer[idx] == '\r' || buffer[idx] == '\n' ||
                            buffer[idx] == ' ' || buffer[idx] == '\0');

            if (prev_ok && next_ok)
            {
                is_complete_rsp = true;
                complete_rsp_end = idx; // 记录完整响应结束位置
                // log_v("at_rsp_wait: complete response detected (OK) at pos %zu", idx);
            }
        }

        // 检查 "+CME ERROR"
        if (!is_complete_rsp && idx >= cme_error_len &&
            strncmp(buffer + idx - cme_error_len, "+CME ERROR", cme_error_len) == 0)
        {
            // 确保前面有换行
            bool prev_ok = (idx == cme_error_len) ||
                           (buffer[idx - cme_error_len - 1] == '\r' ||
                            buffer[idx - cme_error_len - 1] == '\n');
            // 确保后面是换行、空格或字符串结束
            bool next_ok = (idx >= buf_size - 1) ||
                           (buffer[idx] == '\r' || buffer[idx] == '\n' ||
                            buffer[idx] == ' ' || buffer[idx] == '\0');

            if (prev_ok && next_ok)
            {
                is_complete_rsp = true;
                complete_rsp_end = idx;
                // log_w("at_rsp_wait: complete response detected (CME ERROR) at pos %zu", idx);
            }
        }

        // 检查 "ERROR"
        if (!is_complete_rsp && idx >= error_len &&
            strncmp(buffer + idx - error_len, "ERROR", error_len) == 0)
        {
            // 确保前面有换行
            bool prev_ok = (idx == error_len) ||
                           (buffer[idx - error_len - 1] == '\r' ||
                            buffer[idx - error_len - 1] == '\n');
            // 确保后面是换行、空格或字符串结束
            bool next_ok = (idx >= buf_size - 1) ||
                           (buffer[idx] == '\r' || buffer[idx] == '\n' ||
                            buffer[idx] == ' ' || buffer[idx] == '\0');

            if (prev_ok && next_ok)
            {
                is_complete_rsp = true;
                complete_rsp_end = idx;
                // log_w("at_rsp_wait: complete response detected (ERROR) at pos %zu", idx);
            }
        }

        // =============== 2. 如果检测到完整响应，检查用户指定字符串 ===============
        if (is_complete_rsp && expected_end && *expected_end)
        {
            // 检查整个完整响应中是否包含用户指定的字符串
            // 注意：只检查从开始到complete_rsp_end的范围
            char *found = strstr(buffer, expected_end);
            if (found && found < buffer + complete_rsp_end)
            {
                // log_v("at_rsp_wait: user-specified string '%s' found in response", expected_end);
                // 但不提前返回，等待标准结束标志确认
            }
            else
            {
                log_w("at_rsp_wait: user-specified string '%s' NOT found in response", expected_end);
            }
        }

        // =============== 3. 如果检测到完整响应，返回结果 ===============
        if (is_complete_rsp)
        {
            // 检查是否是错误响应
            if (idx >= error_len &&
                strncmp(buffer + idx - error_len, "ERROR", error_len) == 0)
            {
                return AT_RSP_ERROR;
            }
            if (idx >= cme_error_len &&
                strncmp(buffer + idx - cme_error_len, "+CME ERROR", cme_error_len) == 0)
            {
                return AT_RSP_ERROR;
            }
            return AT_RSP_OK;
        }
    }
}

/**<at 命令具体实现 */
#define AT_BUFFER_SIZE 100
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
        if(mode == '0' || status == '1')
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
        if(mode == '0' || status == '1')
        {
            res = 0;
        }
    }
    // log_d("%s\n", buffer);
    osal_free(buffer);
    return res;
 }