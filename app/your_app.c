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
#include "driver_mpu6050_basic.h"
#include "driver_mpu6050.h"
#include "hal.h"
#include "osal.h"
/* Traditional main function (used when RTOS is not enabled) */
int main(void)
{
    hal_uart1_init();
    uint8_t res;
    mpu6050_address_t address = MPU6050_ADDRESS_AD0_LOW;
     /* 初始化MPU6050 */
    res = mpu6050_basic_init(address);
    if (res != 0)
    {
        printf("MPU6050 init failed: %d\n", res);
    }
    else
    {
        printf("MPU6050 init success\n");
    }
    while (1)
    {
        printf("tick :%d\n", osal_get_system_tick());
        osal_task_delay(5000);
    }
}
