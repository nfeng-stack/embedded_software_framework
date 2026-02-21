/**
 * @file    framework_port.h
 * @brief   Framework Port Interface
 * 
 * This file defines the interface that must be implemented by OS ports.
 * Each port provides OS-specific initialization and startup functions.
 */

#ifndef FRAMEWORK_PORT_H
#define FRAMEWORK_PORT_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>

/*------------------------------------------------------------------------------
 * Port Initialization Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Early port-specific initialization
 * @note  Called before framework_init() for early hardware setup
 */
void framework_port_early_init(void);

/**
 * @brief Port-specific initialization
 * @note  Called after framework_init() for OS-specific setup
 */
void framework_port_init(void);

/**
 * @brief Start the OS scheduler or application entry point
 * @note  This function should not return for RTOS ports
 */
void framework_port_start(void);

/**
 * @brief Get port-specific system tick count
 * @return System tick count (port-specific units)
 * @note   For RTOS ports, this should return RTOS tick count
 */
uint32_t framework_port_get_tick(void);

/**
 * @brief Get port-specific tick rate
 * @return Tick rate in Hz
 */
uint32_t framework_port_get_tick_rate(void);

/**
 * @brief Port-specific system reset
 * @note  This function does not return
 */
void framework_port_system_reset(void);

/**
 * @brief Enter port-specific critical section
 */
void framework_port_enter_critical(void);

/**
 * @brief Exit port-specific critical section
 */
void framework_port_exit_critical(void);

/*------------------------------------------------------------------------------
 * Port Configuration
 *----------------------------------------------------------------------------*/

/** Port configuration structure */
typedef struct {
    uint32_t heap_size;          /**< Heap size in bytes (0 = use default) */
    uint32_t stack_size;         /**< Stack size in bytes (0 = use default) */
    uint32_t tick_rate_hz;       /**< Desired tick rate in Hz */
    bool enable_debug_output;    /**< Enable debug output */
} framework_port_config_t;

/**
 * @brief Set port configuration
 * @param config Configuration structure
 * @note  Must be called before framework_port_init()
 */
void framework_port_set_config(const framework_port_config_t* config);

/**
 * @brief Get port configuration
 * @return Pointer to current configuration (read-only)
 */
const framework_port_config_t* framework_port_get_config(void);

#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_PORT_H */