#include "driver_mpu6050.h"
#include "driver_mpu6050_basic.h"
#include "stdio.h"

void mpu6050_board_init()
{
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
    
}