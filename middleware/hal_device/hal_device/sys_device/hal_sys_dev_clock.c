#include "hal_device.h"
#define LOG_TAG     "sys_dev_clk"
#include "elog.h"
#include "hal_device.h"
#include "platform_driver_clock.h"

int hal_sys_dev_clock_control(hal_device_t * selfdev,struct hal_dev *parent_dev,uint32_t cmd, void *arg)
{
    switch (cmd)
    {
    case PERIPHERAL_CONTROL_I2C1_CMD:
        char is_enable = (char)arg;
        platform_driver_clock_ctr_i2c1(is_enable);
        log_e("%s ...\n",__func__);
        /* code */
        break;
    
    default:
        break;
    }
    return 0;
}
static hal_device_t clock_dev = {
    .dev_name = "rcc",
    .device_class = HAL_DEV_TYPE_SYS,
    .config.init_config = NULL,/*暂时未定义*/
    .config.notify_callback = NULL,
    .config.notify_dev = NULL,
    .config.read_buffer_size = 0,
    .config.write_buffer_size = 0,
    .state.owner = NULL,
    .state.state = HAL_DEV_NO_INIT,
    .state.hold_count = 0,
    .state.hold_head.holder = NULL,
    .state.hold_head.next = NULL,
    .opts.init = NULL,
    .opts.open = NULL,
    .opts.control = hal_sys_dev_clock_control,
    .opts.close = NULL,
    .opts.deinit = NULL,
    .opts.read = NULL,
    .opts.write = NULL,
    .opts.notify_register = NULL,
    .opts.extend_ops = NULL,
    .read_buffer = 0,
    .write_buffer = 0
};

int32_t hal_sys_dev_clock_register()
{
    return hal_dev_register(clock_dev.dev_name,&clock_dev);
}