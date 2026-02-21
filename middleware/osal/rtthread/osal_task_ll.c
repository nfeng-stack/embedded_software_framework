/**
 * @file    osal_task_ll.c
 * @brief   RT-Thread task management low-level implementation
 * 
 * This file implements the task management low-level functions for RT-Thread.
 * It maps OSAL task functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Private Helper Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Convert OSAL priority to RT-Thread priority
 * @param osal_priority OSAL priority (higher number = higher priority)
 * @return             RT-Thread priority
 */
static rt_int32_t convert_priority_to_rtthread(int osal_priority)
{
    /* RT-Thread: higher number = higher priority (same as OSAL) */
    /* Map OSAL priority range to RT-Thread range */
    rt_int32_t rt_priority = osal_priority;
    
    /* Clamp to valid RT-Thread range */
    if (rt_priority < OSAL_TASK_MIN_PRIORITY) {
        rt_priority = OSAL_TASK_MIN_PRIORITY;
    } else if (rt_priority > OSAL_TASK_MAX_PRIORITY) {
        rt_priority = OSAL_TASK_MAX_PRIORITY;
    }
    
    return rt_priority;
}

/**
 * @brief RT-Thread thread entry wrapper
 * @param parameter Thread parameter (contains OSAL function and argument)
 */
static void rt_thread_entry_wrapper(void *parameter)
{
    /* Extract OSAL function and argument */
    struct {
        void (*func)(void*);
        void *arg;
    } *wrapper = parameter;
    
    if (wrapper && wrapper->func) {
        wrapper->func(wrapper->arg);
    }
    
    /* Thread exit - RT-Thread will handle cleanup */
}

/*------------------------------------------------------------------------------
 * Public Low-Level Task Functions
 *----------------------------------------------------------------------------*/

osal_task_t _osal_task_create(const char* name, void (*func)(void*), 
                              void *arg, int stack_size, int priority)
{
    rt_thread_t thread;
    rt_err_t result;
    
    /* Allocate memory for wrapper structure */
    struct {
        void (*func)(void*);
        void *arg;
    } *wrapper = rt_malloc(sizeof(*wrapper));
    
    if (wrapper == NULL) {
        return NULL;
    }
    
    /* Setup wrapper */
    wrapper->func = func;
    wrapper->arg = arg;
    
    /* Convert priority */
    rt_int32_t rt_priority = convert_priority_to_rtthread(priority);
    
    /* Create RT-Thread */
    thread = rt_thread_create(name,
                             rt_thread_entry_wrapper,
                             wrapper,
                             stack_size,
                             rt_priority,
                             10); /* Default time slice */
    
    if (thread == NULL) {
        rt_free(wrapper);
        return NULL;
    }
    
    /* Start the thread */
    result = rt_thread_startup(thread);
    if (result != RT_EOK) {
        rt_thread_delete(thread);
        rt_free(wrapper);
        return NULL;
    }
    
    return thread;
}

void _osal_task_delete(osal_task_t task)
{
    if (task == NULL) {
        return;
    }
    
    /* Delete RT-Thread */
    rt_thread_delete((rt_thread_t)task);
}

void _osal_task_suspend(osal_task_t task)
{
    if (task == NULL) {
        return;
    }
    
    /* Suspend RT-Thread */
    rt_thread_suspend((rt_thread_t)task);
}

void _osal_task_resume(osal_task_t task)
{
    if (task == NULL) {
        return;
    }
    
    /* Resume RT-Thread */
    rt_thread_resume((rt_thread_t)task);
}

int _osal_task_get_priority(osal_task_t task)
{
    if (task == NULL) {
        return OSAL_ERROR;
    }
    
    /* Get RT-Thread priority */
    /* Note: RT-Thread API doesn't directly provide priority getter */
    /* This is a simplified implementation */
    return OSAL_TASK_DEFAULT_PRIORITY;
}

void _osal_task_set_priority(osal_task_t task, int priority)
{
    if (task == NULL) {
        return;
    }
    
    /* Convert priority */
    rt_int32_t rt_priority = convert_priority_to_rtthread(priority);
    (void)rt_priority;
    
    /* Set RT-Thread priority */
    /* Note: RT-Thread API doesn't directly provide priority setter */
    /* This is a placeholder for actual implementation */
}

void _osal_task_delay(uint32_t ms)
{
    /* Convert milliseconds to ticks */
    rt_tick_t ticks = rt_tick_from_millisecond(ms);
    
    /* Delay RT-Thread */
    rt_thread_delay(ticks);
}

void _osal_task_delay_until(uint32_t *last_wake_time, uint32_t ms)
{
    if (last_wake_time == NULL) {
        return;
    }
    
    /* Calculate next wake time */
    uint32_t next_wake_time = *last_wake_time + ms;
    uint32_t current_time = osal_get_system_time();
    
    /* Handle time overflow */
    if (current_time < *last_wake_time) {
        *last_wake_time = current_time;
        next_wake_time = current_time + ms;
    }
    
    /* Check if we need to delay */
    if (current_time < next_wake_time) {
        uint32_t delay_ms = next_wake_time - current_time;
        _osal_task_delay(delay_ms);
    } else {
        /* We're already late, skip this period */
        _osal_task_delay(1); /* Minimum delay */
    }
    
    /* Update last wake time */
    *last_wake_time = next_wake_time;
}