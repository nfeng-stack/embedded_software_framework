/**
 * @file    framework_port_generic.c
 * @brief   Generic (bare-metal) port implementation
 * 
 * This file implements the generic port for bare-metal applications.
 * It provides simple implementations that use framework services.
 */

#include "framework_port.h"
#include "framework.h"
#include "framework_debug.h"
#include <stddef.h>

/*------------------------------------------------------------------------------
 * Private Variables
 *----------------------------------------------------------------------------*/

/** Port configuration */
static framework_port_config_t port_config = {
    .heap_size = 0,             /* Use linker script default */
    .stack_size = 0,            /* Use linker script default */
    .tick_rate_hz = 1000,       /* 1 kHz default */
    .enable_debug_output = true
};

/*------------------------------------------------------------------------------
 * Port Initialization Functions
 *----------------------------------------------------------------------------*/

void framework_port_early_init(void)
{
    /* Generic port has no early hardware requirements beyond framework */
}

void framework_port_init(void)
{
    /* Generic port initialization */
    framework_debug_trace("Generic port initialized");
    
    /* Configure system tick if not already configured */
    if (framework_get_tick_rate() == 0) {
        /* Set default tick rate */
        framework_config_t config = {
            .core_clock_hz = framework_get_core_clock(),
            .tick_rate_hz = port_config.tick_rate_hz,
            .enable_debug_output = port_config.enable_debug_output,
            .enable_assertions = true,
            .heap_size = port_config.heap_size,
            .stack_size = port_config.stack_size
        };
        framework_set_config(&config);
    }
}

void framework_port_start(void)
{
    /* For generic port, we call main() which is already called by startup code */
    /* This function should not be called unless startup code is customized */
    framework_debug_warning("framework_port_start called for generic port");
}

uint32_t framework_port_get_tick(void)
{
    /* Use framework system ticks */
    return framework_get_system_ticks();
}

uint32_t framework_port_get_tick_rate(void)
{
    /* Use framework tick rate */
    return framework_get_tick_rate();
}

void framework_port_system_reset(void)
{
    framework_debug_error("System reset requested");
    framework_system_reset();
}

void framework_port_enter_critical(void)
{
    framework_enter_critical();
}

void framework_port_exit_critical(void)
{
    framework_exit_critical();
}

/*------------------------------------------------------------------------------
 * Port Configuration
 *----------------------------------------------------------------------------*/

void framework_port_set_config(const framework_port_config_t* config)
{
    if (config != NULL) {
        port_config = *config;
        framework_debug_trace("Generic port configuration updated");
    }
}

const framework_port_config_t* framework_port_get_config(void)
{
    return &port_config;
}