/**
 * @file    osal_system_ll.c
 * @brief   RT-Thread system service low-level implementation
 *
 * This file implements the system service low-level functions for RT-Thread.
 * It maps OSAL system functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Private Helper Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Convert RT-Thread tick to milliseconds
 * @param tick RT-Thread tick count
 * @return     Milliseconds
 */
static uint32_t rt_tick_to_ms(rt_tick_t tick)
{
    /* RT-Thread tick rate is RT_TICK_PER_SECOND ticks per second */
    return (tick * 1000) / RT_TICK_PER_SECOND;
}

/**
 * @brief Convert milliseconds to RT-Thread tick
 * @param ms Milliseconds
 * @return   RT-Thread tick count
 */
static rt_tick_t ms_to_rt_tick(uint32_t ms)
{
    return rt_tick_from_millisecond(ms);
}

/*------------------------------------------------------------------------------
 * Public Low-Level System Functions
 *----------------------------------------------------------------------------*/

uint32_t osal_get_system_time(void)
{
    /* Return system time in milliseconds */
    return rt_tick_get_millisecond();
}

uint32_t _osal_get_system_tick(void)
{
    /* Return system tick count */
    return rt_tick_get();
}

uint32_t _osal_get_tick_rate(void)
{
    /* Return tick rate (ticks per second) */
    return RT_TICK_PER_SECOND;
}

void _osal_system_reset(void)
{
    /* Reset the system */
    rt_hw_cpu_reset();
}

void _osal_enter_critical(void)
{
    /* Enter critical section */
    rt_enter_critical();
}

void _osal_exit_critical(void)
{
    /* Exit critical section */
    rt_exit_critical();
}

/*------------------------------------------------------------------------------
 * OSAL Initialization Functions
 *----------------------------------------------------------------------------*/

osal_result_t osal_init(void)
{
    /* RT-Thread initialization is already done before OSAL */
    /* Nothing to do here */
    return OSAL_OK;
}

void osal_start_scheduler(void)
{
    /* RT-Thread scheduler starts automatically */
    /* Nothing to do here */
}
extern void rt_os_tick_callback(void);
void (*osal_get_need_register_to_systemtick_hander_callback_ll(void))(void)
{
    return rt_os_tick_callback;
}
extern void rt_register_callback(void (*callback)(void));
void osal_register_callback_ll(void (*callback)(void))
{
    rt_register_callback(callback);
}
