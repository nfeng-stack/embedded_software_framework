/**
 * @file    osal_timer_ll.c
 * @brief   RT-Thread software timer low-level implementation
 * 
 * This file implements the software timer low-level functions for RT-Thread.
 * It maps OSAL timer functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Private Helper Structures
 *----------------------------------------------------------------------------*/

typedef struct {
    osal_timer_callback_t callback;
    void *arg;
    rt_timer_t rt_timer;
} osal_timer_wrapper_t;

/*------------------------------------------------------------------------------
 * Private Helper Functions
 *----------------------------------------------------------------------------*/

static void rt_timer_callback_wrapper(void *parameter)
{
    osal_timer_wrapper_t *wrapper = (osal_timer_wrapper_t *)parameter;
    if (wrapper && wrapper->callback) {
        wrapper->callback(wrapper->arg);
    }
}

/*------------------------------------------------------------------------------
 * Public Low-Level Timer Functions
 *----------------------------------------------------------------------------*/

osal_timer_t _osal_timer_create(void (*callback)(void*), void *arg,
                                uint32_t period_ms, bool periodic)
{
    if (callback == NULL || period_ms == 0) {
        return NULL;
    }
    
    /* Allocate wrapper */
    osal_timer_wrapper_t *wrapper = rt_malloc(sizeof(osal_timer_wrapper_t));
    if (wrapper == NULL) {
        return NULL;
    }
    
    wrapper->callback = callback;
    wrapper->arg = arg;
    
    /* Create RT-Thread timer */
    rt_tick_t ticks = rt_tick_from_millisecond(period_ms);
    rt_timer_t rt_timer = rt_timer_create("osal_timer",
                                          rt_timer_callback_wrapper,
                                          wrapper,
                                          ticks,
                                          periodic ? RT_TIMER_FLAG_PERIODIC : RT_TIMER_FLAG_ONE_SHOT);
    if (rt_timer == NULL) {
        rt_free(wrapper);
        return NULL;
    }
    
    wrapper->rt_timer = rt_timer;
    return wrapper;
}

osal_result_t _osal_timer_delete(osal_timer_t timer)
{
    if (timer == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    osal_timer_wrapper_t *wrapper = (osal_timer_wrapper_t *)timer;
    
    /* Delete RT-Thread timer */
    rt_err_t result = rt_timer_delete(wrapper->rt_timer);
    
    /* Free wrapper */
    rt_free(wrapper);
    
    return (result == RT_EOK) ? OSAL_OK : OSAL_ERROR;
}

void _osal_timer_start(osal_timer_t timer)
{
    if (timer == NULL) {
        return;
    }
    
    osal_timer_wrapper_t *wrapper = (osal_timer_wrapper_t *)timer;
    rt_timer_start(wrapper->rt_timer);
}

void _osal_timer_stop(osal_timer_t timer)
{
    if (timer == NULL) {
        return;
    }
    
    osal_timer_wrapper_t *wrapper = (osal_timer_wrapper_t *)timer;
    rt_timer_stop(wrapper->rt_timer);
}

uint32_t _osal_timer_get_remaining(osal_timer_t timer)
{
    if (timer == NULL) {
        return 0;
    }
    
    osal_timer_wrapper_t *wrapper = (osal_timer_wrapper_t *)timer;
    
    /* Get remaining ticks using rt_timer_control */
    rt_tick_t remaining_ticks;
    rt_timer_control(wrapper->rt_timer, RT_TIMER_CTRL_GET_TIME, &remaining_ticks);
    
    /* Convert ticks to milliseconds */
    return (remaining_ticks * 1000) / RT_TICK_PER_SECOND;
}