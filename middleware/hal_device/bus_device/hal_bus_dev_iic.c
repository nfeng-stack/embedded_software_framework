#ifdef __cplusplus
extern "C"
{
#endif

#include "hal_bus_dev_iic.h"
#include "elog.h"
#define LOG_TAG     "bus_dev_i2c"

int hal_bus_dev_i2c_init(hal_device_t * selfdev)
{
    log_v("%s\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_open(hal_device_t * selfdev)
{
    log_v("%s\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_close(hal_device_t * selfdev)
{
    log_v("%s\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_deinit(hal_device_t * selfdev)
{
    log_v("%s\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_read(hal_device_t * selfdev,void *buffer,size_t len,uint32_t timeoutms)
{
    log_v("%s\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_write(hal_device_t * selfdev,const void *buf, size_t len, uint32_t timeout_ms)
{
    log_v("%s\n",__func__);
    return 0;
}
int hal_bus_dev_i2c_control(hal_device_t * selfdev,uint32_t cmd, void *arg)
{
    log_v("%s",__func__);
    return 0;
}
int hal_bus_dev_i2c_register_notify(hal_device_t * selfdev, void (*notify_callback)(struct hal_dev *callback_dev))
{
    log_v("%s",__func__);
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
    return hal_dev_register(&i2c_dev);
}





#ifdef __cplusplus
}
#endif