#include "stdio.h"
#include "hal_device.h"
#include "platform_driver_clock.h"
// #include "stm32h5xx_hal.h"

int platform_driver_clock_ctr_i2c1(char is_enable)
{
    if(is_enable)
    {
        // printf("%s enable i2c1 clock ...\n",__func__);
    }
    else 
    {
        // printf("%s disable i2c1 clock ...\n",__func__);
    }
    return 0;
}