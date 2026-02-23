/**
 * @file    your_app.c
 * @brief   Application layer example for embedded framework
 *
 * This file demonstrates how to use the HAL and OSAL layers in an embedded application.
 * It shows the recommended initialization sequence and provides example tasks.
 */
#define     LOG_TAG     "main"
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdlib.h>
#include "hal.h"
#include "osal.h"
#include "mpu6050_wrap.h"
#include "elog.h"

/* Traditional main function (used when RTOS is not enabled) */

void log_strategy(void)
{
    elog_init();
    // elog_set_fmt(ELOG_LVL_ASSERT, ELOG_FMT_ALL);
    // elog_set_fmt(ELOG_LVL_ERROR, ELOG_FMT_ALL);
    // elog_set_fmt(ELOG_LVL_WARN, ELOG_FMT_ALL);
    // elog_set_fmt(ELOG_LVL_INFO, ELOG_FMT_ALL);
    // elog_set_fmt(ELOG_LVL_DEBUG, ELOG_FMT_ALL);
    // elog_set_fmt(ELOG_LVL_VERBOSE, ELOG_FMT_ALL);
    elog_start();
}

int main(void)
{
    hal_uart1_init();
    log_strategy();
    mpu6050_init_task();
    while(1)
    {
        osal_task_delay(10000);
        log_v("os is runing ...\n");
        // printf("os is runing\n");
    }
}
