#define LOG_TAG "at_task"
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include "osal.h"
#include "hal.h"
#include "elog.h"
#include "at_command.h"

/**
 * @brief AT命令处理任务
 */
void at_task(void *param)
{

    int32_t res = at_check_sim_status_is_ready();
    if (res != 0)
    {
        log_e("sim status no ready :%d\n",res);
        return;
    }
    log_d("sim status is ready\n");
    res = at_check_net_status();
    if(res != 0)
    {
        log_e("sim net no ready :%d",res);
        return;
    }
    log_d("sim net is ready");
    while (1)
    {
        osal_task_delay(1000);
    }
}

/**
 * @brief 初始化AT命令处理任务
 */
void at_cmd_task_init(void)
{
    osal_task_t task = osal_task_create("at_task", at_task, NULL, 1024 * 10, 10, 20);
    if (task == NULL)
    {
        log_e("AT task creation failed");
        return;
    }
    log_i("AT command task initialized successfully");
    osal_task_startup(task);
}