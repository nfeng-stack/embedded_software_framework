/**
 * @file    framework_port_rtthread.c
 * @brief   RT-Thread port implementation
 *
 * This file implements the RT-Thread port for the platform framework.
 * It integrates RT-Thread with framework interrupt handling and debug output.
 */

#include "framework_port.h"
#include "framework.h"
#include "framework_debug.h"
#include "framework_rtos.h"
#include <rtthread.h>
#include <rthw.h>
#include <stddef.h>
#include <stdint.h>

/*------------------------------------------------------------------------------
 * RT-Thread Board Initialization
 *----------------------------------------------------------------------------*/

/**
 * @brief RT-Thread board initialization function
 * @note Called by rtthread_startup() to initialize hardware
 */
void rt_hw_board_init(void);

#ifndef RT_TICK_PER_SECOND
#define RT_TICK_PER_SECOND 1000
#endif

/*------------------------------------------------------------------------------
 * Private Variables
 *----------------------------------------------------------------------------*/

/** Port configuration */
static framework_port_config_t port_config = {
    .heap_size = 0,  /* Use RT-Thread heap */
    .stack_size = 0, /* Use RT-Thread default */
    .tick_rate_hz = RT_TICK_PER_SECOND,
    .enable_debug_output = true};

/** RT-Thread tick callback reference */

/*------------------------------------------------------------------------------
 * Private Function Declarations
 *----------------------------------------------------------------------------*/

static void rtthread_systick_callback(void);
static void rtthread_debug_putc(char c);
static char rtthread_debug_getc(void);

/*------------------------------------------------------------------------------
 * Port Initialization Functions
 *----------------------------------------------------------------------------*/

void framework_port_early_init(void)
{
    /* RT-Thread early initialization is done by rtthread_startup() */
}

void framework_port_init(void)
{
    framework_debug_trace("RT-Thread port initializing");

    /* Register RT-Thread callbacks with framework */
    framework_rtos_register_systick(rtthread_systick_callback);
    framework_rtos_register_debug(rtthread_debug_putc, rtthread_debug_getc);

    /* Set RT-Thread configuration */
    framework_rtos_config_t rtos_config = {
        .tick_rate_hz = port_config.tick_rate_hz,
        .systick_priority = 0xFF, /* Lowest priority */
        .pendsv_priority = 0xFF,
        .svc_priority = 0xFF,
        .enable_preemption = true,
        .enable_time_slicing = true};
    framework_rtos_set_config(&rtos_config);

    /* RT-Thread port initialization done */

    framework_debug_trace("RT-Thread port initialized");
}

void framework_port_start(void)
{
    /* RT-Thread startup is handled by rtthread_startup() called from startup code */
    /* This function should not be called */
    framework_debug_warning("framework_port_start called for RT-Thread port");
}

uint32_t framework_port_get_tick(void)
{
    /* Return RT-Thread tick count */
    return rt_tick_get();
}

uint32_t framework_port_get_tick_rate(void)
{
    /* Return RT-Thread tick rate */
    return RT_TICK_PER_SECOND;
}

void framework_port_system_reset(void)
{
    /* Use framework system reset */
    framework_system_reset();
}

void framework_port_enter_critical(void)
{
    rt_enter_critical();
}

void framework_port_exit_critical(void)
{
    rt_exit_critical();
}

/*------------------------------------------------------------------------------
 * Port Configuration
 *----------------------------------------------------------------------------*/

void framework_port_set_config(const framework_port_config_t *config)
{
    if (config != NULL)
    {
        port_config = *config;
        framework_debug_trace("RT-Thread port configuration updated");
    }
}

const framework_port_config_t *framework_port_get_config(void)
{
    return &port_config;
}

/*------------------------------------------------------------------------------
 * RT-Thread Callback Functions
 *----------------------------------------------------------------------------*/

static void rtthread_systick_callback(void)
{
    /* Call RT-Thread tick increment */
    rt_tick_increase();
}

static void rtthread_debug_putc(char c)
{
    /* Output character via RT-Thread console */
    char buf[2] = {c, '\0'};
    rt_hw_console_output(buf);
}

static char rtthread_debug_getc(void)
{
    /* Input character via RT-Thread console (non-blocking) */
    /* This is a simplified implementation */
    /* TODO: implement proper console input */
    return 0;
}

/*------------------------------------------------------------------------------
 * RT-Thread Board Initialization
 *----------------------------------------------------------------------------*/
