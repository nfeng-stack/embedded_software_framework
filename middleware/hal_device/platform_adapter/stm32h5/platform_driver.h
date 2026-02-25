#ifndef PLATFORM_DRIVER_H
#define PLATFORM_DRIVER_H


#include <stdint.h>
void platform_uart1_init(void);
void platform_iic_init(void); /* 所有的驱动函数应该具备参数，这里为了开发方便就省略了*/
uint8_t platform_iic_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
uint8_t platform_iic_write(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
void platform_gpio_set_int(void);
void platform_gpio_clean_it(void);

#endif