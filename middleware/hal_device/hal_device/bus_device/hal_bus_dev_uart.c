#define LOG_TAG "bus_dev_uart"
#include "stdio.h"
#include "string.h"
#include "elog.h"
#include "hal_device.h"

int hal_bus_dev_uart_init(hal_device_t *selfdev, struct hal_dev *parent_dev)
{
    log_v("%s\n", __func__);
    if (selfdev->state.state == HAL_DEV_NO_INIT)
    {
        /**< 串口未初始化，需要初始化串口 */
        /**< 1.打开串口时钟 */

        /**< 2.配置设备dma相关 */

        /**< 3.配置系统io */

        /**< 4.配置系统uart控制器 目前所有都用sdk的庄函数实现*/
        if (strcmp(selfdev->dev_name, "uart1"))
        {
            platform_driver_uart_init(selfdev->config.init_config, HAL_UART_INSTANCE_UART1);
        }
        else if (strcmp(selfdev->dev_name, "uart2"))
        {
            platform_driver_uart_init(selfdev->config.init_config, HAL_UART_INSTANCE_UART2);
        }
        selfdev->state.owner = parent_dev;
        selfdev->state.state = HAL_DEV_INITED;
    }
}
int hal_bus_dev_uart_open(hal_device_t *selfdev, struct hal_dev *parent_dev)
{
    if (selfdev->state.owner == parent_dev && selfdev->state.state == HAL_DEV_INITED)
    {
        if (strcmp(selfdev->dev_name, "uart1"))
        {
            plaform_driver_uart_open(HAL_UART_INSTANCE_UART1);
        }
        else if (strcmp(selfdev->dev_name, "uart2"))
        {
            plaform_driver_uart_open(HAL_UART_INSTANCE_UART2);
        }
    }
    log_v("%s %s success ...\n", __func__,selfdev->dev_name);
    return 0;
}
int hal_bus_dev_uart_close(hal_device_t *selfdev, struct hal_dev *parent_dev)
{
    if (selfdev->state.owner == parent_dev && selfdev->state.state != HAL_DEV_USING)
    {
        if (strcmp(selfdev->dev_name, "uart1"))
        {
            plaform_driver_uart_close(HAL_UART_INSTANCE_UART1);
        }
        else if (strcmp(selfdev->dev_name, "uart2"))
        {
            plaform_driver_uart_close(HAL_UART_INSTANCE_UART2);
        }
    }
    log_v("%s %s success ...\n", __func__,selfdev->dev_name);
    return 0;
}
int hal_bus_dev_uart_deinit(hal_device_t *selfdev, struct hal_dev *parent_dev)
{
    log_v("%s success ...\n", __func__);
    return 0;
}
int hal_bus_dev_uart_read(hal_device_t *selfdev, struct hal_dev *parent_dev, void *buffer, size_t len, uint32_t timeoutms)
{
    
    log_v("%s success ...\n", __func__);
    return 0;
}
int hal_bus_dev_uart_write(hal_device_t *selfdev, struct hal_dev *parent_dev, const void *buf, size_t len, uint32_t timeout_ms)
{
    log_v("%s success ...\n", __func__);
    return 0;
}
int hal_bus_dev_uart_control(hal_device_t *selfdev, struct hal_dev *parent_dev, uint32_t cmd, void *arg)
{
    log_v("%s success ...\n", __func__);
    return 0;
}
int hal_bus_dev_uart_register_notify(hal_device_t *selfdev, struct hal_dev *parent_dev, void (*notify_callback)(struct hal_dev *callback_dev))
{
    log_v("%s success ...\n", __func__);
    return 0;
}

static hal_bus_dev_uart_init_config_t uart1_init_config;
static hal_device_t uart1_dev = {
    .dev_name = "uart1",
    .device_class = HAL_DEV_TYPE_BUS,
    .config.init_config = (void *)&uart1_init_config,
    .config.notify_callback = NULL,
    .config.notify_dev = NULL,
    .config.read_buffer_size = 0,
    .config.write_buffer_size = 0,
    .state.state = HAL_DEV_NO_INIT,
    .state.owner = NULL,
    .state.hold_count = 0,
    .state.hold_head.holder = NULL,
    .state.hold_head.next = NULL,
    .opts.open = hal_bus_dev_uart_open,
    .opts.init = hal_bus_dev_uart_init,
    .opts.close = hal_bus_dev_uart_close,
    .opts.deinit = hal_bus_dev_uart_deinit,
    .opts.read = hal_bus_dev_uart_read,
    .opts.write = hal_bus_dev_uart_write,
    .opts.notify_register = hal_bus_dev_uart_register_notify,
    .opts.control = hal_bus_dev_uart_control,
    .opts.extend_ops = NULL,
    .read_buffer = NULL,
    .write_buffer = NULL};
static hal_bus_dev_uart_init_config_t uart2_init_config;
static hal_device_t uart2 = {
    .dev_name = "uart2",
    .device_class = HAL_DEV_TYPE_BUS,
    .config.init_config = (void *)&uart2_init_config,
    .config.notify_callback = NULL,
    .config.notify_dev = NULL,
    .config.read_buffer_size = 0,
    .config.write_buffer_size = 0,
    .state.state = HAL_DEV_NO_INIT,
    .state.owner = NULL,
    .state.hold_count = 0,
    .state.hold_head.holder = NULL,
    .state.hold_head.next = NULL,
    .opts.open = hal_bus_dev_uart_open,
    .opts.init = hal_bus_dev_uart_init,
    .opts.close = hal_bus_dev_uart_close,
    .opts.deinit = hal_bus_dev_uart_deinit,
    .opts.read = hal_bus_dev_uart_read,
    .opts.write = hal_bus_dev_uart_write,
    .opts.notify_register = hal_bus_dev_uart_register_notify,
    .opts.control = hal_bus_dev_uart_control,
    .opts.extend_ops = NULL,
    .read_buffer = NULL,
    .write_buffer = NULL};

int32_t hal_bus_dev_uart_register()
{
    int32_t res = hal_dev_register(uart1_dev.dev_name, &uart1_dev);
    if (res != 0)
    {
        log_e("%s uart1 register failed ...\n", __func__);
    }
    res = hal_dev_register(uart2_dev.dev_name, &uart2_dev);
    if (res !=)
    {
        log_e("%s uart2 register failed ...\n", __func__);
    }
    return 0;
}