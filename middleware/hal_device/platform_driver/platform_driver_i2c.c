#include "stdio.h"
#include "hal_device.h"
int32_t platform_driver_i2c_init(hal_bus_dev_i2c_init_config_t *init_cfg)
{
    uint16_t addr =  init_cfg->addr;
    hal_i2c_addr_mode_e mode = init_cfg->mode;
    uint32_t speed = init_cfg->speed;
    /**< 需要检测相关参数平台是否支持 */

    // printf("%s addr:%#x\n",__func__,addr);
    // printf("%s mode:%d\n",__func__,mode);
    // printf("%s speed:%d\n",__func__,speed);
    // printf("%s runing...\n",__func__);
    return 0;
}