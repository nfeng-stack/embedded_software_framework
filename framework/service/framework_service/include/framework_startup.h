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
 * @brief Initialize data sections (.data and .bss)
 * @note  Copies .data from FLASH to RAM and clears .bss section.
 *        Should be called after framework_system_clock_init().
 */
void framework_data_init(void);

/**
 * @brief Unified startup function (called from Reset_Handler)
 * @note  Determines startup path based on configuration:
 *        - main() for bare metal
 *        - rtthread_startup() for RT-Thread
 *        - Custom function if specified
 *        This function should not return.
 */
void framework_start(void);



#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_STARTUP_H */