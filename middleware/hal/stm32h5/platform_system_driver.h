/**
 * @file    hal_system.h
 * @brief   HAL System-Level Functions
 *
 * This file defines system-level hardware abstraction functions for clock,
 * interrupts, debug, and system control. These functions are required by
 * the platform framework for CMSIS-standard initialization.
 */

#ifndef PLATFORM_SYSTEM_DRIVER_H
#define PLATFORM_SYSTEM_DRIVER_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stdbool.h>

    /*------------------------------------------------------------------------------
     * System Clock
     *----------------------------------------------------------------------------*/

    /**
     * @brief Early system initialization (before ICACHE is enabled)
     * @note Must be called before platform_system_clock_init() on STM32H5
     *       to read UID before ICACHE is enabled (hardware errata workaround)
     */
    void platform_early_init(void);
    
    /**
     * @brief Initialize system clock to desired frequency
     * @param target_hz Target core clock frequency in Hz
     * @return Actual configured frequency in Hz (0 if error)
     * @note  This function configures PLL, flash latency, and clock dividers.
     */
    uint32_t platform_system_clock_init();
    void platform_system_clock_pre_init();
    void platform_sdk_init();

    /**
     * @brief Get current core clock frequency
     * @return Core clock frequency in Hz
     */
    uint32_t hal_system_clock_get(void);

    /**
     * @brief Get system tick frequency (SysTick)
     * @return SysTick frequency in Hz (0 if SysTick not configured)
     */
    uint32_t hal_system_tick_freq_get(void);

    /**
     * @brief Configure SysTick timer
     * @param tick_hz Desired tick frequency in Hz
     * @param enable_interrupt Enable SysTick interrupt (true) or polling (false)
     * @return Actual configured frequency in Hz (0 if error)
     * @note  If enable_interrupt is false, the application must poll SysTick.
     */
    uint32_t hal_system_tick_init(uint32_t tick_hz, bool enable_interrupt);

    /*------------------------------------------------------------------------------
     * System Interrupts (NVIC)
     *----------------------------------------------------------------------------*/

    /**
     * @brief Enable specific interrupt in NVIC
     * @param irq_number IRQ number (0 for SysTick, positive for peripheral IRQs)
     */
    void hal_system_interrupt_enable(int irq_number);

    /**
     * @brief Disable specific interrupt in NVIC
     * @param irq_number IRQ number
     */
    void hal_system_interrupt_disable(int irq_number);

    /**
     * @brief Set interrupt priority in NVIC
     * @param irq_number IRQ number
     * @param priority Priority value (0-255, lower = higher priority)
     */
    void hal_system_interrupt_set_priority(int irq_number, uint32_t priority);

    /**
     * @brief Get interrupt priority from NVIC
     * @param irq_number IRQ number
     * @return Priority value (0-255)
     */
    uint32_t hal_system_interrupt_get_priority(int irq_number);

    /**
     * @brief Check if interrupt is enabled in NVIC
     * @param irq_number IRQ number
     * @return true if enabled, false otherwise
     */
    bool hal_system_interrupt_is_enabled(int irq_number);

    /**
     * @brief Check if interrupt is pending in NVIC
     * @param irq_number IRQ number
     * @return true if pending, false otherwise
     */
    bool hal_system_interrupt_is_pending(int irq_number);

    /**
     * @brief Clear pending interrupt in NVIC
     * @param irq_number IRQ number
     */
    void hal_system_interrupt_clear_pending(int irq_number);

    /**
     * @brief Set pending interrupt in NVIC
     * @param irq_number IRQ number
     */
    void hal_system_interrupt_set_pending(int irq_number);

    /*------------------------------------------------------------------------------
     * System Control
     *----------------------------------------------------------------------------*/

    /**
     * @brief Perform system reset (soft reset)
     * @note  This function does not return
     */
    void hal_system_reset(void);

    /**
     * @brief Enter low-power mode (sleep)
     * @note  Wakeup via interrupt
     */
    void hal_system_sleep(void);

    /**
     * @brief Enter deep sleep mode
     * @note  Wakeup via external event or RTC
     */
    void hal_system_deepsleep(void);

    /*------------------------------------------------------------------------------
     * Debug Hardware (UART/SWO/Semihosting)
     *----------------------------------------------------------------------------*/

    /** Debug output modes */
    typedef enum
    {
        HAL_DEBUG_DISABLED = 0, /**< Debug output disabled */
        HAL_DEBUG_UART,         /**< Debug via UART */
        HAL_DEBUG_SWO,          /**< Debug via SWO (Serial Wire Output) */
        HAL_DEBUG_SEMIHOSTING,  /**< Debug via semihosting */
        HAL_DEBUG_RTT           /**< Debug via SEGGER RTT */
    } hal_debug_mode_t;

    /** Debug configuration structure */
    typedef struct
    {
        hal_debug_mode_t mode; /**< Debug output mode */
        uint32_t baud_rate;    /**< Baud rate for UART mode */
        uint32_t swo_freq;     /**< SWO frequency for SWO mode */
    } hal_debug_config_t;

    /**
     * @brief Initialize debug hardware
     * @param config Debug configuration (NULL for defaults)
     * @return true if successful, false otherwise
     */
    bool hal_system_debug_init(const hal_debug_config_t *config);

    /**
     * @brief Output a single character via debug hardware
     * @param c Character to output
     */
    void hal_system_debug_putc(char c);

    /**
     * @brief Input a single character from debug hardware (non-blocking)
     * @return Character received, or 0 if no character available
     */
    char hal_system_debug_getc(void);

    /**
     * @brief Check if debug input character is available
     * @return true if character available, false otherwise
     */
    bool hal_system_debug_kbhit(void);

    /**
     * @brief Flush debug output buffer
     */
    void hal_system_debug_flush(void);

    /*------------------------------------------------------------------------------
     * System Information
     *----------------------------------------------------------------------------*/

    /**
     * @brief Get unique device identifier
     * @param buffer Buffer to store identifier (minimum 12 bytes)
     * @param size   Buffer size in bytes
     * @return Number of bytes written to buffer
     */
    uint32_t hal_system_get_uid(uint8_t *buffer, uint32_t size);

    /**
     * @brief Get device revision identifier
     * @return Revision code (platform-specific)
     */
    uint32_t hal_system_get_revision(void);

    /**
     * @brief Get flash size in bytes
     * @return Flash size in bytes
     */
    uint32_t hal_system_get_flash_size(void);

    /**
     * @brief Get RAM size in bytes
     * @return RAM size in bytes
     */
    uint32_t hal_system_get_ram_size(void);
    void (*platform_get_sytemtick_handler(void))(void);

#ifdef __cplusplus
}
#endif

#endif /* HAL_SYSTEM_H */