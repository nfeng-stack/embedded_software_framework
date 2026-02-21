/**
 * @file    hal_platform.h
 * @brief   i.MX RT1064 platform-specific definitions (stub)
 * 
 * This file contains i.MX RT1064-specific definitions for the HAL layer.
 * It defines pin mappings, peripheral enumerations, and declares low-level
 * functions. This is a stub file for compilation; actual implementation
 * would require i.MX RT1064 SDK.
 */

#ifndef HAL_PLATFORM_H
#define HAL_PLATFORM_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

/* Include HAL public types */
#include "../../include/hal.h"

/*------------------------------------------------------------------------------
 * GPIO Definitions (stub)
 *----------------------------------------------------------------------------*/

/** GPIO port identifiers */
typedef enum {
    HAL_GPIO_PORT_A = 0,
    HAL_GPIO_PORT_B,
    HAL_GPIO_PORT_C,
    HAL_GPIO_PORT_D,
    HAL_GPIO_PORT_E,
    HAL_GPIO_PORT_COUNT
} hal_gpio_port_t;

/** GPIO pin identifiers */
typedef enum {
    HAL_GPIO_PIN_0 = 0,
    HAL_GPIO_PIN_1,
    HAL_GPIO_PIN_2,
    HAL_GPIO_PIN_3,
    HAL_GPIO_PIN_4,
    HAL_GPIO_PIN_5,
    HAL_GPIO_PIN_6,
    HAL_GPIO_PIN_7,
    HAL_GPIO_PIN_8,
    HAL_GPIO_PIN_9,
    HAL_GPIO_PIN_10,
    HAL_GPIO_PIN_11,
    HAL_GPIO_PIN_12,
    HAL_GPIO_PIN_13,
    HAL_GPIO_PIN_14,
    HAL_GPIO_PIN_15,
    HAL_GPIO_PIN_16,
    HAL_GPIO_PIN_17,
    HAL_GPIO_PIN_18,
    HAL_GPIO_PIN_19,
    HAL_GPIO_PIN_20,
    HAL_GPIO_PIN_21,
    HAL_GPIO_PIN_22,
    HAL_GPIO_PIN_23,
    HAL_GPIO_PIN_24,
    HAL_GPIO_PIN_25,
    HAL_GPIO_PIN_26,
    HAL_GPIO_PIN_27,
    HAL_GPIO_PIN_28,
    HAL_GPIO_PIN_29,
    HAL_GPIO_PIN_30,
    HAL_GPIO_PIN_31,
    HAL_GPIO_PIN_COUNT
} hal_gpio_pin_t;

/** Combined GPIO identifier (port << 8 | pin) */
typedef uint32_t hal_gpio_t;

/** Macro to create GPIO identifier from port and pin */
#define HAL_GPIO_MAKE(port, pin) ((((port) & 0xFF) << 8) | ((pin) & 0xFF))

/** Macro to extract port from GPIO identifier */
#define HAL_GPIO_GET_PORT(gpio) (((gpio) >> 8) & 0xFF)

/** Macro to extract pin from GPIO identifier */
#define HAL_GPIO_GET_PIN(gpio)  ((gpio) & 0xFF)

/*------------------------------------------------------------------------------
 * UART Definitions (stub)
 *----------------------------------------------------------------------------*/

/** UART peripheral identifiers */
typedef enum {
    HAL_UART_1 = 0,
    HAL_UART_2,
    HAL_UART_3,
    HAL_UART_4,
    HAL_UART_5,
    HAL_UART_6,
    HAL_UART_7,
    HAL_UART_8,
    HAL_UART_COUNT
} hal_uart_id_t;

typedef uint32_t hal_uart_t;

/*------------------------------------------------------------------------------
 * Timer Definitions (stub)
 *----------------------------------------------------------------------------*/

/** Timer peripheral identifiers */
typedef enum {
    HAL_TIMER_1 = 0,
    HAL_TIMER_2,
    HAL_TIMER_3,
    HAL_TIMER_4,
    HAL_TIMER_5,
    HAL_TIMER_6,
    HAL_TIMER_7,
    HAL_TIMER_8,
    HAL_TIMER_COUNT
} hal_timer_id_t;

typedef uint32_t hal_timer_t;

/*------------------------------------------------------------------------------
 * Low-Level Function Declarations (stub)
 *----------------------------------------------------------------------------*/

/* GPIO low-level functions */
void _hal_gpio_init(hal_gpio_t pin, hal_gpio_mode_t mode);
void _hal_gpio_write(hal_gpio_t pin, bool value);
bool _hal_gpio_read(hal_gpio_t pin);
void _hal_gpio_toggle(hal_gpio_t pin);
void _hal_gpio_set(hal_gpio_t pin);
void _hal_gpio_reset(hal_gpio_t pin);

/* UART low-level functions */
void _hal_uart_init(hal_uart_t uart, uint32_t baud);
void _hal_uart_putc(hal_uart_t uart, char c);
char _hal_uart_getc(hal_uart_t uart);
bool _hal_uart_tx_ready(hal_uart_t uart);
bool _hal_uart_rx_ready(hal_uart_t uart);
void _hal_uart_puts(hal_uart_t uart, const char *str);
int _hal_uart_printf(hal_uart_t uart, const char *format, ...);

/* Timer low-level functions */
void _hal_timer_init(hal_timer_t timer, uint32_t period_us);
void _hal_timer_start(hal_timer_t timer);
void _hal_timer_stop(hal_timer_t timer);
void _hal_timer_set_callback(hal_timer_t timer, void (*callback)(void));
void _hal_delay_us(uint32_t us);

/* System low-level functions */
void _hal_init(void);
void _hal_board_init(void);

#ifdef __cplusplus
}
#endif

#endif /* HAL_PLATFORM_H */