#define LOG_TAG "at_cmd"
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "osal.h"
#include "hal.h"
#include "elog.h"


int at_rsp_wait(const char *expected_end, char *buffer, size_t buf_size, uint32_t timeout_ms)
{
    if (!buffer || buf_size == 0)
        return -1;

    memset(buffer, 0, buf_size);
    size_t idx = 0;
    uint32_t start_time = osal_tick_get();

    while (1)
    {
        // 超时判断
        if (osal_tick_get() - start_time > timeout_ms)
        {
            return -1;
        }

        // === 修正：正确读取单个字符 ===
        uint8_t ch;
        if (hal_uart2_read(&ch, 1) != 1)
        {                       // 假设返回读取字节数
            osal_task_delay(1); // 短暂休眠，避免死循环占CPU
            continue;
        }

        // === 修正：正确存入 buffer ===
        if (idx < buf_size - 1 && ch != '\0')
        {
            buffer[idx++] = (char)ch;
            buffer[idx] = '\0';
        }
        else
        {
            return -2; // 缓冲区溢出
        }

        // 检查结束标志（逻辑保持不变）
        if (expected_end)
        {
            if (strstr(buffer, expected_end))
            {
                if (strcmp(expected_end, ">") == 0)
                {
                    // 确保是单独的 '>'
                    if (idx >= 2 && buffer[idx - 2] == '>' &&
                        (buffer[idx - 1] == ' ' || buffer[idx - 1] == '\r' || buffer[idx - 1] == '\n'))
                    {
                        break;
                    }
                }
                else
                {
                    break;
                }
            }
        }
        else
        {
            if (strstr(buffer, "\r\nOK\r\n") ||
                strstr(buffer, "\r\nERROR\r\n") ||
                strstr(buffer, "\r\n+CME ERROR:") ||
                strstr(buffer, "\r\n+CMS ERROR:"))
            {
                break;
            }
        }
    }

    return 0;
}

osal_task_t at_task_t = NULL;
osal_semaphore_t at_sem = NULL;
void at_task(void *param)
{
    hal_uart2_write("ati\r\n");
    char *buffer = (char *)osal_malloc(100);
    if(buffer == NULL)
    {
        log_e("malloc buffer error\n");
        return;
    }
    int8_t res = at_rsp_wait("\r\nOK\r\n", buffer, 100, 1500);
    if(res != 0)
    {
        log_e("at respond error %d\n",res);
        log_e("%s\n",buffer);
        return;
    }
    log_v("%s\n", buffer);
    osal_free(buffer);
    while (1)
    {
        osal_sem_take(at_sem,-1);
    }
}
void at_cmd_task_init(void)
{
    at_task_t = osal_task_create("attask", at_task, NULL, 1024 * 2, 10, 20);
    at_sem = osal_sem_create("at_sem", 0, 0);
    if (at_task_t == NULL || at_sem == NULL)
    {
        log_e("at task creat error\n");
        return;
    }
    osal_task_startup(at_task_t);
}