/**
 * @file    framework_startup.h
 * @brief   Framework Startup and Initialization Interface
 * 
 * This file defines the unified startup and initialization interface for the platform framework.
 * It provides CMSIS-compatible initialization functions that are implemented by the framework.
 * 
 * @note    All hardware-specific implementation is delegated to HAL layer.
 */

#ifndef FRAMEWORK_STARTUP_H
#define FRAMEWORK_STARTUP_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

/*------------------------------------------------------------------------------
 * Framework Startup Configuration
 *----------------------------------------------------------------------------*/

/** Startup mode enumeration */
typedef enum {
    FRAMEWORK_STARTUP_BARE_METAL = 0,   /**< Bare metal (call main()) */
    FRAMEWORK_STARTUP_RTTHREAD,         /**< RT-Thread OS */
    FRAMEWORK_STARTUP_FREERTOS,         /**< FreeRTOS (if supported) */
    FRAMEWORK_STARTUP_CUSTOM            /**< Custom startup function */
} framework_startup_mode_t;

/** Startup configuration structure */
typedef struct {
    framework_startup_mode_t mode;      /**< Startup mode */
    uint32_t core_clock_hz;             /**< Desired core clock frequency (0 for default) */
    uint32_t heap_size;                 /**< Heap size in bytes (0 for default) */
    uint32_t stack_size;                /**< Stack size in bytes (0 for default) */
    bool enable_data_init;              /**< Enable .data/.bss initialization */
    bool enable_clock_init;             /**< Enable system clock initialization */
    void (*custom_startup)(void);       /**< Custom startup function (if mode is CUSTOM) */
} framework_startup_config_t;

/*------------------------------------------------------------------------------
 * Framework Initialization Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Initialize system clock (framework implementation)
 * @note  Calls HAL layer to configure PLL, flash latency, clock dividers, etc.
 *        Should be called early in startup sequence.
 */
void framework_system_clock_init(void);

/**
 * @brief Configure system clock with specific frequency
 * @param freq_hz Desired core clock frequency in Hz
 * @return Actual configured frequency in Hz (0 if error)
 * @note  Can be called before framework_system_clock_init() to set target frequency
 */
uint32_t framework_system_clock_config(uint32_t freq_hz);

/**
 * @brief Initialize data sections (.data and .bss)
 * @note  Copies .data from FLASH to RAM and clears .bss section.
 *        Should be called after framework_system_clock_init().
 */
void framework_data_init(void);

/**
 * @brief Initialize heap memory
 * @note  Sets up heap for dynamic memory allocation.
 *        Optional - can be skipped if not using heap.
 */
void framework_heap_init(void);

/**
 * @brief Get current core clock frequency
 * @return Core clock frequency in Hz
 */
uint32_t framework_get_core_clock(void);

/*------------------------------------------------------------------------------
 * Framework Startup Control
 *----------------------------------------------------------------------------*/

/**
 * @brief Unified startup function (called from Reset_Handler)
 * @note  Determines startup path based on configuration:
 *        - main() for bare metal
 *        - rtthread_startup() for RT-Thread
 *        - Custom function if specified
 *        This function should not return.
 */
void framework_start(void);

/**
 * @brief Set framework startup configuration
 * @param config Startup configuration structure
 * @note  Must be called before framework_start()
 */
void framework_set_startup_config(const framework_startup_config_t* config);

/**
 * @brief Get current startup configuration
 * @return Pointer to current configuration (read-only)
 */
const framework_startup_config_t* framework_get_startup_config(void);

/**
 * @brief Get default startup configuration
 * @return Default configuration suitable for most applications
 */
framework_startup_config_t framework_get_default_startup_config(void);

/*------------------------------------------------------------------------------
 * CMSIS Compatibility Functions (Weak Aliases)
 * 
 * These functions provide compatibility with CMSIS startup code.
 * They are implemented as weak symbols that call framework functions.
 *----------------------------------------------------------------------------*/

/**
 * @brief CMSIS-compatible SystemInit() function
 * @note  Weak alias for framework_system_clock_init()
 *        Can be overridden by application.
 */
void SystemInit(void);

/**
 * @brief CMSIS-compatible data initialization function
 * @note  Weak alias for framework_data_init()
 *        Can be overridden by application.
 */
void _data_init(void);

/*------------------------------------------------------------------------------
 * Interrupt Management (Simplified Interface)
 *----------------------------------------------------------------------------*/

/** Interrupt handler function type */
typedef void (*framework_interrupt_handler_t)(void);

/**
 * @brief Register interrupt handler
 * @param irq_num Interrupt number (0 for WWDG, 1 for PVD, etc.)
 * @param handler Function to call when interrupt occurs
 * @return true if successful, false if error (invalid IRQ or already registered)
 * @note  Simple wrapper around framework_interrupts_register_callback()
 */
bool register_interrupt_handler(uint32_t irq_num, framework_interrupt_handler_t handler);

/**
 * @brief Unregister interrupt handler
 * @param irq_num Interrupt number
 */
void unregister_interrupt_handler(uint32_t irq_num);

/**
 * @brief Get registered interrupt handler
 * @param irq_num Interrupt number
 * @return Registered handler or NULL if not registered
 */
framework_interrupt_handler_t get_interrupt_handler(uint32_t irq_num);

/*------------------------------------------------------------------------------
 * Platform Vector Table Support
 *----------------------------------------------------------------------------*/

/**
 * @brief Get pointer to interrupt vector table
 * @return Pointer to vector table (located at FLASH start)
 * @note  The vector table is defined in startup.c
 */
void* framework_get_vector_table(void);

/**
 * @brief Get vector table size (number of entries)
 * @return Number of entries in vector table
 */
uint32_t framework_get_vector_table_size(void);

/**
 * @brief Set vector table entry
 * @param index Entry index (0 = SP, 1 = Reset_Handler, etc.)
 * @param handler Handler function for this entry
 * @note  Use with caution - vector table is usually in read-only memory
 */
void framework_set_vector_table_entry(uint32_t index, void (*handler)(void));

/**
 * @brief Get vector table entry
 * @param index Entry index
 * @return Handler function at this index
 */
void (*framework_get_vector_table_entry(uint32_t index))(void);

#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_STARTUP_H */