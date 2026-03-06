#ifdef __cplusplus
extern "C"
{
#endif
#define LOG_TAG         "bus_dev_i2c"
#include "stdio.h"
#include "elog.h"
#include "hal_device.h"
#include "platform_driver_i2c.h"


int hal_bus_dev_i2c_init(hal_device_t * selfdev,struct hal_dev *parent_dev)
{
    if(selfdev->state.state == HAL_DEV_NO_INIT)
    {
        /**< 此时i2c这个设备属于parent_dev */
        selfdev->state.owner = parent_dev;/**< 父设备应该根据返回值自动认为当前设备是他拥有的设备类 */

        log_e("%s success ...\n",__func__);
        /**< 使用clock设备提供的接口来打开i2c的时钟 */
        hal_device_t *rcc_dev = hal_dev_find("rcc");
        if(rcc_dev == NULL)
        {
            log_e("%s i2c1 rcc find failed ...\n",__func__);
        }
        rcc_dev->opts.control(rcc_dev,NULL,PERIPHERAL_CONTROL_I2C1_CMD,(void *)0x01);
        /**< 使用io设备的接口来初始化配置i2c控制器所需要的io */

        /**< 使用dma设备提供的接口来配置i2c控制器的dma设置 */

        /**< 初始化i2c控制器，但是对于时钟，io，中断，dma等设备还未初始化 */
        int32_t res = platform_driver_i2c_init(selfdev->config.init_config);
    }
    return 0;
}
int hal_bus_dev_i2c_open(hal_device_t * selfdev,struct hal_dev *parent_dev)
{
    log_e("%s success ...\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_close(hal_device_t * selfdev,struct hal_dev *parent_dev)
{
    log_e("%s success ...\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_deinit(hal_device_t * selfdev,struct hal_dev *parent_dev)
{
    log_e("%s success ...\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_read(hal_device_t * selfdev,struct hal_dev *parent_dev,void *buffer,size_t len,uint32_t timeoutms)
{
    log_e("%s success ...\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_write(hal_device_t * selfdev,struct hal_dev *parent_dev,const void *buf, size_t len, uint32_t timeout_ms)
{
    log_e("%s success ...\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_control(hal_device_t * selfdev,struct hal_dev *parent_dev,uint32_t cmd, void *arg)
{
    log_e("%s success ...\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_register_notify(hal_device_t * selfdev,struct hal_dev *parent_dev, void (*notify_callback)(struct hal_dev *callback_dev))
{
    log_e("%s success ...\n",__func__);
    return 0;
}

static hal_bus_dev_i2c_init_config_t i2c1_init_config ;
static hal_device_t i2c_dev = {
    .dev_name = "i2c1",
    .device_class = HAL_DEV_TYPE_BUS ,
    .config.init_config = (void *)&i2c1_init_config,
    .config.notify_callback = NULL,
    .config.notify_dev = NULL,
    .config.read_buffer_size = 0,
    .config.write_buffer_size = 0,
    .state.state = HAL_DEV_NO_INIT,
    .state.owner = NULL,
    .state.hold_count = 0,
    .state.hold_head.holder = NULL,
    .state.hold_head.next = NULL,
    .opts.open = hal_bus_dev_i2c_open,
    .opts.init = hal_bus_dev_i2c_init,
    .opts.close = hal_bus_dev_i2c_close,
    .opts.deinit = hal_bus_dev_i2c_deinit,
    .opts.read = hal_bus_dev_i2c_read,
    .opts.write = hal_bus_dev_i2c_write,
    .opts.notify_register = hal_bus_dev_i2c_register_notify,
    .opts.control = hal_bus_dev_i2c_control,
    .opts.extend_ops = NULL,
    .read_buffer = NULL,
    .write_buffer = NULL
};




int32_t hal_bus_dev_i2c_register()
{
    return hal_dev_register(i2c_dev.dev_name,&i2c_dev);
}





#ifdef __cplusplus
}
#endif