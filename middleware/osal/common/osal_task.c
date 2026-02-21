/**
 * @file    osal_task.c
 * @brief   Task management abstraction layer implementation
 * 
 * This file implements the task management functions defined in osal.h.
 * It calls RTOS-specific low-level functions through the _osal_task_* interface.
 */

#include "osal_common.h"

/*------------------------------------------------------------------------------
 * Public Task Functions
 *----------------------------------------------------------------------------*/

osal_task_t osal_task_create(const char* name, osal_task_func_t func, 
                             void *arg, int stack_size, int priority)
{
    OSAL_CHECK_PARAM_RET_NULL(name != NULL);
    OSAL_CHECK_PARAM_RET_NULL(func != NULL);
    OSAL_CHECK_PARAM_RET_NULL(stack_size > 0);
    OSAL_CHECK_PARAM_RET_NULL(priority >= OSAL_TASK_MIN_PRIORITY && 
                              priority <= OSAL_TASK_MAX_PRIORITY);
    
    /* Call RTOS-specific implementation */
    return _osal_task_create(name, func, arg, stack_size, priority);
}

void osal_task_delete(osal_task_t task)
{
    OSAL_CHECK_PARAM(OSAL_TASK_IS_VALID(task));
    
    /* Call RTOS-specific implementation */
    _osal_task_delete(task);
}

void osal_task_suspend(osal_task_t task)
{
    OSAL_CHECK_PARAM(OSAL_TASK_IS_VALID(task));
    
    /* Call RTOS-specific implementation */
    _osal_task_suspend(task);
}

void osal_task_resume(osal_task_t task)
{
    OSAL_CHECK_PARAM(OSAL_TASK_IS_VALID(task));
    
    /* Call RTOS-specific implementation */
    _osal_task_resume(task);
}

int osal_task_get_priority(osal_task_t task)
{
    OSAL_CHECK_PARAM_RET(OSAL_TASK_IS_VALID(task), OSAL_ERROR);
    
    /* Call RTOS-specific implementation */
    return _osal_task_get_priority(task);
}

void osal_task_set_priority(osal_task_t task, int priority)
{
    OSAL_CHECK_PARAM(OSAL_TASK_IS_VALID(task));
    OSAL_CHECK_PARAM(priority >= OSAL_TASK_MIN_PRIORITY && 
                     priority <= OSAL_TASK_MAX_PRIORITY);
    
    /* Call RTOS-specific implementation */
    _osal_task_set_priority(task, priority);
}

void osal_task_delay(uint32_t ms)
{
    OSAL_CHECK_PARAM(ms > 0 || ms == OSAL_WAIT_FOREVER);
    
    /* Convert milliseconds to ticks */
    uint32_t ticks = MS_TO_TICKS(ms);
    if (ticks == 0 && ms > 0) {
        ticks = 1; /* Ensure at least 1 tick delay */
    }
    
    /* Call RTOS-specific implementation */
    _osal_task_delay(ticks);
}

void osal_task_delay_until(uint32_t *last_wake_time, uint32_t ms)
{
    OSAL_CHECK_PARAM(last_wake_time != NULL);
    OSAL_CHECK_PARAM(ms > 0);
    
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
        osal_task_delay(delay_ms);
    } else {
        /* We're already late, skip this period */
        osal_task_delay(1); /* Minimum delay */
    }
    
    /* Update last wake time */
    *last_wake_time = next_wake_time;
}

/*------------------------------------------------------------------------------
 * Extended Task Functions (optional)
 *----------------------------------------------------------------------------*/

#ifdef OSAL_TASK_EXTENDED_API

osal_result_t osal_task_get_info(osal_task_t task, osal_task_info_t *info)
{
    OSAL_CHECK_PARAM_RET(OSAL_TASK_IS_VALID(task), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(info != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_task_yield(void)
{
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

#endif /* OSAL_TASK_EXTENDED_API */