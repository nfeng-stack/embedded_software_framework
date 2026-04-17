/**
 * @file    hal.h
 * @brief   Hardware Abstraction Layer (HAL) public interface
 *
 * This file defines the hardware abstraction layer interface for embedded systems.
 * It provides a platform-independent API for accessing GPIO, UART, Timer, and
 * system initialization functions. Application code should only include this header.
 *
 * @note    This is the public interface - implementations are in hal/common and hal/<platform>
 */

#ifndef HAL_H
#define HAL_H

#ifdef __cplusplus
extern "C"
{
#endif

    void hal_system_clock_pre_init();
    void hal_system_clock_init();
    void hal_system_sdk_init();
    void (*hal_system_get_systemhandler(void))(void);
    void hal_uart1_init(void);
    void hal_common_iic_init(void); /* To do need add miaosu*/
    uint8_t hal_common_iic_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
    uint8_t hal_common_iic_write(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
    void hal_gpio_init_int(void);
    void hal_clean_it(void);
    void hal_uart2_init(void);
uint16_t hal_uart2_read(uint8_t *buffer, uint16_t max_len);
void hal_uart2_write(uint8_t *buffer);
void hal_gpio_led_audio_on(void);
void hal_gpio_led_audio_off(void);
uint8_t hal_xspi_write_read(uint8_t instruction, uint8_t instruction_line,\
                                             uint32_t address, uint8_t address_line, uint8_t address_len, \
                                             uint32_t alternate, uint8_t alternate_line, uint8_t alternate_len,\
                                             uint8_t dummy, uint8_t *in_buf, uint32_t in_len,\
                                             uint8_t *out_buf, uint32_t out_len, uint8_t data_line);
int32_t hal_xspi_init(void);
#ifdef __cplusplus
}
#endif

#endif /* HAL_H */