#ifndef PLATFORM__DRIVER_UART_H
#define PLATFORM_DRIVER_UART_H

#ifdef __cplusplus
extern "C"
{
#endif


int32_t platform_driver_uart_init(hal_bus_dev_uart_init_config_t *init_cfg,hal_uart_instance_e uart);
int32_t plaform_driver_uart_open(hal_uart_instance_e uart);
int32_t plaform_driver_uart_close(hal_uart_instance_e uart);


#ifdef __cplusplus
}
#endif
#endif