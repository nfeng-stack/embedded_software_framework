/**
 * @file    your_app.c
 * @brief   Application layer example for embedded framework
 *
 * This file demonstrates how to use the HAL and OSAL layers in an embedded application.
 * It shows the recommended initialization sequence and provides example tasks.
 */


#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdlib.h>
#include "hal.h"
#include "osal.h"
#include "mpu6050_wrap.h"
/* Traditional main function (used when RTOS is not enabled) */
int main(void)
{
    hal_uart1_init();
    mpu6050_board_init();

    while (1)
    {
        printf("tick :%d\n", osal_tick_get());
        osal_task_delay(5000);
    }
}
