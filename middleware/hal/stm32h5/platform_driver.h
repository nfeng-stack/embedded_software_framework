#ifndef PLATFORM_DRIVER_H
#define PLATFORM_DRIVER_H


#include <stdint.h>
void platform_uart1_init(void);
void platform_uart2_init(void);
void platform_iic_init(void); /* 所有的驱动函数应该具备参数，这里为了开发方便就省略了*/
uint8_t platform_iic_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
uint8_t platform_iic_write(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
void platform_gpio_set_int(void);
void platform_gpio_clean_it(void);
uint16_t platform_uart2_read(uint8_t *buffer, uint16_t max_len);
void platform_uart2_write(uint8_t *buffer,uint8_t len);
void platform_gpio_set_hight_spec(void);
void platform_gpio_set_low_spec(void) ;
int32_t platform_xspi_init(void) ;
int32_t platform_xspi_single_read(uint8_t instruction, uint32_t addr, uint8_t *data,
                                   uint32_t size);
int32_t platform_xspi_single_write(uint8_t instruction,uint32_t addr, uint8_t *data,
                                    uint32_t size);
int32_t platform_xspi_quad_read(uint8_t instruction,uint32_t addr, uint8_t *data, uint32_t size);
int32_t platform_xspi_quad_write(uint8_t instruction,uint32_t addr, uint8_t *data, uint32_t size);
uint8_t platform_xspi_write_read(uint8_t instruction, uint8_t instruction_line,\
                                              uint32_t address, uint8_t address_line, uint8_t address_len,\
                                              uint32_t alternate, uint8_t alternate_line, uint8_t alternate_len,\
                                              uint8_t dummy, uint8_t *in_buf, uint32_t in_len,\
                                              uint8_t *out_buf, uint32_t out_len, uint8_t data_line);

/* USB Driver Functions */
int32_t platform_usb_init(void);
int32_t platform_usb_deinit(void);
int32_t platform_usb_start(void);
int32_t platform_usb_stop(void);
uint32_t platform_usb_get_state(void);
uint32_t platform_usb_is_connected(void);
int32_t platform_usb_set_address(uint8_t address);
int32_t platform_usb_ep_open(uint8_t ep_addr, uint8_t ep_type, uint16_t ep_mps);
int32_t platform_usb_ep_close(uint8_t ep_addr);
int32_t platform_usb_ep_receive(uint8_t ep_addr, uint8_t *pbuf, uint32_t len);
int32_t platform_usb_ep_transmit(uint8_t ep_addr, uint8_t *pbuf, uint32_t len);
int32_t platform_usb_ep_stall(uint8_t ep_addr);
int32_t platform_usb_ep_clear_stall(uint8_t ep_addr);
int32_t platform_usb_ep_flush(uint8_t ep_addr);
int32_t platform_usb_set_callbacks(const void *callbacks);

void platform_usb_clock_io_init(void);
#endif