/**
 * @file    framework.h
 * @brief   Platform Framework Public Interface
 * 
 * This file defines the unified platform initialization framework interface.
 * It provides CMSIS-standard initialization flow and platform abstraction APIs.
 * 
 * @note    This is the public interface - implementations are in framework/src
 */

#ifndef FRAMEWORK_H
#define FRAMEWORK_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

/*------------------------------------------------------------------------------
 * Framework Initialization
 *----------------------------------------------------------------------------*/

/**
 * @brief Initialize the platform framework (CMSIS-standard flow)
 * @note  This function performs:
 *        1. System clock initialization (via HAL)
 *        2. Data and BSS section initialization (if needed)
 *        3. Interrupt vector table setup
 *        4. OS port initialization (if using RTOS)
 *        
 *        It should be called from startup code before main() or RTOS entry.
 */
void framework_init(void);

/**
 * @brief Early system initialization (minimal setup)
 * @note  This function performs minimal initialization required for
 *        basic system operation. It's called before framework_init()
 *        in special cases.
 */
void framework_early_init(void);

/**
 * @brief Get framework version string
 * @return Version string in format "major.minor.patch"
 */
const char* framework_get_version(void);

/**
 * @brief Get framework build timestamp
 * @return Build timestamp string
 */
const char* framework_get_build_timestamp(void);

/*------------------------------------------------------------------------------
 * System Information
 *----------------------------------------------------------------------------*/

/**
 * @brief Get system core clock frequency
 * @return Core clock frequency in Hz
 */
uint32_t framework_get_core_clock(void);

/**
 * @brief Get system tick count (since startup)
 * @return System tick count (incremented at framework tick rate)
 */
uint32_t framework_get_system_ticks(void);

/**
 * @brief Internal SysTick handler (called from interrupt)
 * @note  This function increments the system tick counter
 */
void framework_systick_handler(void);

/**
 * @brief Get system tick rate (ticks per second)
 * @return System tick rate in Hz
 */
uint32_t framework_get_tick_rate(void);

/**
 * @brief Get system uptime in milliseconds
 * @return Uptime in milliseconds since startup
 */
uint32_t framework_get_uptime_ms(void);

/*------------------------------------------------------------------------------
 * System Control
 *----------------------------------------------------------------------------*/

/**
 * @brief Perform system reset
 * @note  This function does not return
 */
void framework_system_reset(void);

/**
 * @brief Enter critical section (disable interrupts)
 */
void framework_enter_critical(void);

/**
 * @brief Exit critical section (enable interrupts)
 */
void framework_exit_critical(void);

/*------------------------------------------------------------------------------
 * Framework Configuration
 *----------------------------------------------------------------------------*/

/**
 * @brief Framework configuration structure
 */
typedef struct {
    uint32_t core_clock_hz;           /**< Core clock frequency in Hz */
    uint32_t tick_rate_hz;            /**< System tick rate in Hz */
    bool enable_debug_output;         /**< Enable debug output */
    bool enable_assertions;           /**< Enable framework assertions */
    uint32_t heap_size;               /**< Heap size in bytes (0 = use default) */
    uint32_t stack_size;              /**< Stack size in bytes (0 = use default) */
} framework_config_t;

/**
 * @brief Set framework configuration
 * @param config Configuration structure
 * @note  Must be called before framework_init()
 */
void framework_set_config(const framework_config_t* config);

/**
 * @brief Get current framework configuration
 * @return Pointer to current configuration (read-only)
 */
const framework_config_t* framework_get_config(void);

/*------------------------------------------------------------------------------
 * Framework Status and Error Handling
 *----------------------------------------------------------------------------*/

/** Framework status codes */
typedef enum {
    FRAMEWORK_OK = 0,                 /**< Operation successful */
    FRAMEWORK_ERROR = -1,             /**< General error */
    FRAMEWORK_ERROR_INIT = -2,        /**< Initialization error */
    FRAMEWORK_ERROR_CONFIG = -3,      /**< Configuration error */
    FRAMEWORK_ERROR_CLOCK = -4,       /**< Clock configuration error */
    FRAMEWORK_ERROR_MEMORY = -5,      /**< Memory allocation error */
    FRAMEWORK_ERROR_INTERRUPT = -6,   /**< Interrupt configuration error */
} framework_status_t;

/**
 * @brief Get last framework error code
 * @return Last error code (0 = no error)
 */
framework_status_t framework_get_last_error(void);

/**
 * @brief Get last error message
 * @return Error message string (empty if no error)
 */
const char* framework_get_last_error_message(void);

/**
 * @brief Clear error state
 */
void framework_clear_error(void);

/*------------------------------------------------------------------------------
 * Framework Startup Interface (Unified Initialization)
 *----------------------------------------------------------------------------*/
#include "framework_startup.h"

#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_H */