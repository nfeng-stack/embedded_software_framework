/**
 * @file    hal_config.h
 * @brief   HAL layer configuration for STM32H5 platform
 * 
 * This file contains hardware-specific configuration for the STM32H5 platform.
 * It defines clock frequencies, peripheral enables, and other hardware parameters.
 */

#ifndef HAL_CONFIG_H
#define HAL_CONFIG_H

/*------------------------------------------------------------------------------
 * Clock Configuration
 *----------------------------------------------------------------------------*/

/* External high-speed oscillator (HSE) value */
#ifndef HSE_VALUE
#define HSE_VALUE               8000000UL   /**< 8 MHz external crystal */
#endif

/* System clock frequency */
#define SYSCLK_FREQ             250000000UL /**< 250 MHz system clock (STM32H5) */

/* AHB clock frequency */
#define HCLK_FREQ               (SYSCLK_FREQ / 1)   /**< AHB clock = system clock */

/* APB1 clock frequency */
#define PCLK1_FREQ              (HCLK_FREQ / 2)     /**< APB1 clock = AHB/2 */

/* APB2 clock frequency */
#define PCLK2_FREQ              (HCLK_FREQ / 2)     /**< APB2 clock = AHB/2 */

/*------------------------------------------------------------------------------
 * Peripheral Module Enables
 *----------------------------------------------------------------------------*/

/* Uncomment to enable specific HAL modules */
#define HAL_GPIO_MODULE_ENABLED
#define HAL_UART_MODULE_ENABLED
#define HAL_TIMER_MODULE_ENABLED
/* #define HAL_I2C_MODULE_ENABLED */
/* #define HAL_SPI_MODULE_ENABLED */
/* #define HAL_ADC_MODULE_ENABLED */
/* #define HAL_DMA_MODULE_ENABLED */
/* #define HAL_RTC_MODULE_ENABLED */

/*------------------------------------------------------------------------------
 * GPIO Configuration
 *----------------------------------------------------------------------------*/

/* Default GPIO speed */
#define HAL_GPIO_DEFAULT_SPEED  HAL_GPIO_SPEED_HIGH

/* Default GPIO pull configuration */
#define HAL_GPIO_DEFAULT_PULL   HAL_GPIO_PULL_NONE

/*------------------------------------------------------------------------------
 * UART Configuration
 *----------------------------------------------------------------------------*/

/* Default UART configuration */
#define HAL_UART_DEFAULT_BAUD   115200      /**< Default baud rate */
#define HAL_UART_DEFAULT_PARITY HAL_UART_PARITY_NONE
#define HAL_UART_DEFAULT_STOPBITS HAL_UART_STOPBITS_1

/* UART buffer sizes */
#define HAL_UART_TX_BUFFER_SIZE 256         /**< Transmit buffer size */
#define HAL_UART_RX_BUFFER_SIZE 256         /**< Receive buffer size */

/*------------------------------------------------------------------------------
 * Timer Configuration
 *----------------------------------------------------------------------------*/

/* Microsecond delay timer selection */
#define HAL_DELAY_US_TIMER      HAL_TIMER_2 /**< Timer used for hal_delay_us() */

/* Timer interrupt priority */
#define HAL_TIMER_IRQ_PRIORITY  5           /**< Timer interrupt priority (lower = higher) */

/*------------------------------------------------------------------------------
 * Board-specific Definitions
 *----------------------------------------------------------------------------*/

/* LED pin definitions (example for NUCLEO-H563ZI board) */
#define LED_PIN                 5  /**< PA5 on NUCLEO-H563ZI */
#define LED_PORT                0  /**< GPIO Port A (0 = HAL_GPIO_PORT_A) */

/* GPIO pin macro (matching hal_platform.h) */
#define HAL_GPIO_MAKE(port, pin) ((((port) & 0xFF) << 8) | ((pin) & 0xFF))
#define HAL_GPIO_LED_PIN        HAL_GPIO_MAKE(LED_PORT, LED_PIN)

/* UART port for console output */
#define CONSOLE_UART            0      /**< USART1 on NUCLEO-H563ZI (HAL_UART_1) */

#endif /* HAL_CONFIG_H */