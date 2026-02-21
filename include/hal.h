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

#ifdef __cplusplus
}
#endif

#endif /* HAL_H */