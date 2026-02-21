/**
 * @file    osal_timer.c
 * @brief   Software timer abstraction layer implementation
 * 
 * This file implements the software timer functions defined in osal.h.
 * It calls RTOS-specific low-level functions through the _osal_timer_* interface.
 */

#include "osal_common.h"

/*------------------------------------------------------------------------------
 * Public Timer Functions
 *----------------------------------------------------------------------------*/

osal_timer_t osal_timer_create(osal_timer_callback_t callback, void *arg,
                               uint32_t period_ms, bool periodic)
{
    OSAL_CHECK_PARAM_RET_NULL(callback != NULL);
    OSAL_CHECK_PARAM_RET_NULL(period_ms > 0);
    
    /* Call RTOS-specific implementation */
    return _osal_timer_create(callback, arg, period_ms, periodic);
}

osal_result_t osal_timer_delete(osal_timer_t timer)
{
    OSAL_CHECK_PARAM_RET(OSAL_TIMER_IS_VALID(timer), OSAL_INVALID_PARAM);
    
    /* Call RTOS-specific implementation */
    return _osal_timer_delete(timer);
}

void osal_timer_start(osal_timer_t timer)
{
    OSAL_CHECK_PARAM(OSAL_TIMER_IS_VALID(timer));
    
    /* Call RTOS-specific implementation */
    _osal_timer_start(timer);
}

void osal_timer_stop(osal_timer_t timer)
{
    OSAL_CHECK_PARAM(OSAL_TIMER_IS_VALID(timer));
    
    /* Call RTOS-specific implementation */
    _osal_timer_stop(timer);
}

uint32_t osal_timer_get_remaining(osal_timer_t timer)
{
    OSAL_CHECK_PARAM_RET(OSAL_TIMER_IS_VALID(timer), 0);
    
    /* Call RTOS-specific implementation */
    return _osal_timer_get_remaining(timer);
}

/*------------------------------------------------------------------------------
 * Extended Timer Functions (optional)
 *----------------------------------------------------------------------------*/

#ifdef OSAL_TIMER_EXTENDED_API

osal_result_t osal_timer_change_period(osal_timer_t timer, uint32_t new_period_ms)
{
    OSAL_CHECK_PARAM_RET(OSAL_TIMER_IS_VALID(timer), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(new_period_ms > 0, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_timer_reset(osal_timer_t timer)
{
    OSAL_CHECK_PARAM_RET(OSAL_TIMER_IS_VALID(timer), OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

#endif /* OSAL_TIMER_EXTENDED_API */