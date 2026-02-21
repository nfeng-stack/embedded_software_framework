/**
 * @file    framework_rtos.h
 * @brief   RTOS Interface for Platform Framework
 * 
 * This file defines the RTOS interface for the platform framework.
 * RTOS implementations should register their callback functions through
 * these APIs to integrate with the framework's interrupt handling.
 * 
 * @note    Hardware operations are implemented in HAL layer
 */

#ifndef FRAMEWORK_RTOS_H
#define FRAMEWORK_RTOS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

/*------------------------------------------------------------------------------
 * RTOS Callback Function Types
 *----------------------------------------------------------------------------*/

/**
 * @brief SysTick interrupt callback function type
 * @note  Called from SysTick_Handler() interrupt
 */
typedef void (*framework_systick_callback_t)(void);

/**
 * @brief PendSV interrupt callback function type  
 * @note  Called from PendSV_Handler() interrupt
 */
typedef void (*framework_pendsv_callback_t)(void);

/**
 * @brief SVC (Supervisor Call) interrupt callback function type
 * @note  Called from SVC_Handler() interrupt
 */
typedef void (*framework_svc_callback_t)(void);

/**
 * @brief Debug character output function type
 * @param c Character to output
 */
typedef void (*framework_debug_putc_t)(char c);

/**
 * @brief Debug character input function type
 * @return Received character
 */
typedef char (*framework_debug_getc_t)(void);

/*------------------------------------------------------------------------------
 * RTOS Interface Registration Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Register SysTick interrupt callback
 * @param callback Callback function (NULL to disable)
 * @note  The callback will be called from SysTick_Handler()
 */
void framework_rtos_register_systick(framework_systick_callback_t callback);

/**
 * @brief Register PendSV interrupt callback
 * @param callback Callback function (NULL to disable)
 * @note  The callback will be called from PendSV_Handler()
 */
void framework_rtos_register_pendsv(framework_pendsv_callback_t callback);

/**
 * @brief Register SVC interrupt callback
 * @param callback Callback function (NULL to disable)
 * @note  The callback will be called from SVC_Handler()
 */
void framework_rtos_register_svc(framework_svc_callback_t callback);

/**
 * @brief Register debug output/input functions
 * @param putc Character output function (NULL to use HAL default)
 * @param getc Character input function (NULL to use HAL default)
 */
void framework_rtos_register_debug(framework_debug_putc_t putc, framework_debug_getc_t getc);

/**
 * @brief Get registered SysTick callback
 * @return Registered callback or NULL if not registered
 */
framework_systick_callback_t framework_rtos_get_systick_callback(void);

/**
 * @brief Get registered PendSV callback
 * @return Registered callback or NULL if not registered
 */
framework_pendsv_callback_t framework_rtos_get_pendsv_callback(void);

/**
 * @brief Get registered SVC callback
 * @return Registered callback or NULL if not registered
 */
framework_svc_callback_t framework_rtos_get_svc_callback(void);

/*------------------------------------------------------------------------------
 * OS Port Management
 *----------------------------------------------------------------------------*/

/** OS port types */
typedef enum {
    FRAMEWORK_PORT_GENERIC = 0,      /**< Generic/bare-metal port */
    FRAMEWORK_PORT_RTTHREAD,         /**< RT-Thread port */
    FRAMEWORK_PORT_FREERTOS,         /**< FreeRTOS port (reserved) */
    FRAMEWORK_PORT_ZEPHYR,           /**< Zephyr port (reserved) */
    FRAMEWORK_PORT_COUNT
} framework_port_t;

/* Port initialization and start are implemented by each port (see framework_port.h) */

/**
 * @brief Get current OS port type
 * @return Current port type (determined at compile time)
 */
framework_port_t framework_port_get_current(void);

/**
 * @brief Check if running with RTOS
 * @return true if using RTOS port, false for generic port
 */
bool framework_port_is_rtos(void);

/*------------------------------------------------------------------------------
 * RTOS-Specific Configuration
 *----------------------------------------------------------------------------*/

/** RTOS configuration structure */
typedef struct {
    uint32_t tick_rate_hz;           /**< RTOS tick rate (Hz) */
    uint32_t systick_priority;       /**< SysTick interrupt priority */
    uint32_t pendsv_priority;        /**< PendSV interrupt priority */
    uint32_t svc_priority;           /**< SVC interrupt priority */
    bool enable_preemption;          /**< Enable task preemption */
    bool enable_time_slicing;        /**< Enable time slicing */
} framework_rtos_config_t;

/**
 * @brief Set RTOS configuration
 * @param config Configuration structure
 * @note  Must be called before framework_port_init()
 */
void framework_rtos_set_config(const framework_rtos_config_t* config);

/**
 * @brief Get RTOS configuration
 * @return Pointer to current configuration (read-only)
 */
const framework_rtos_config_t* framework_rtos_get_config(void);

/**
 * @brief Debug output via registered RTOS callback or default
 * @param c Character to output
 */
void framework_rtos_debug_putc(char c);

/**
 * @brief Debug input via registered RTOS callback or default
 * @return Character received, or 0 if no character available
 */
char framework_rtos_debug_getc(void);

#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_RTOS_H */