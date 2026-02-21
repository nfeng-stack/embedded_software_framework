/**
 * @file    osal_mutex.c
 * @brief   Mutex abstraction layer implementation
 * 
 * This file implements the mutex functions defined in osal.h.
 * It calls RTOS-specific low-level functions through the _osal_mutex_* interface.
 */

#include "osal_common.h"

/*------------------------------------------------------------------------------
 * Public Mutex Functions
 *----------------------------------------------------------------------------*/

osal_mutex_t osal_mutex_create(void)
{
    /* Call RTOS-specific implementation */
    return _osal_mutex_create();
}

osal_result_t osal_mutex_delete(osal_mutex_t mutex)
{
    OSAL_CHECK_PARAM_RET(OSAL_MUTEX_IS_VALID(mutex), OSAL_INVALID_PARAM);
    
    /* Call RTOS-specific implementation */
    return _osal_mutex_delete(mutex);
}

osal_result_t osal_mutex_lock(osal_mutex_t mutex, uint32_t timeout_ms)
{
    OSAL_CHECK_PARAM_RET(OSAL_MUTEX_IS_VALID(mutex), OSAL_INVALID_PARAM);
    
    /* Convert timeout to RTOS-specific format */
    uint32_t timeout_ticks = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                             OSAL_WAIT_FOREVER : MS_TO_TICKS(timeout_ms);
    
    /* Call RTOS-specific implementation */
    return _osal_mutex_lock(mutex, timeout_ticks);
}

void osal_mutex_unlock(osal_mutex_t mutex)
{
    OSAL_CHECK_PARAM(OSAL_MUTEX_IS_VALID(mutex));
    
    /* Call RTOS-specific implementation */
    _osal_mutex_unlock(mutex);
}

/*------------------------------------------------------------------------------
 * Extended Mutex Functions (optional)
 *----------------------------------------------------------------------------*/

#ifdef OSAL_MUTEX_EXTENDED_API

osal_result_t osal_mutex_get_holder(osal_mutex_t mutex, osal_task_t *holder)
{
    OSAL_CHECK_PARAM_RET(OSAL_MUTEX_IS_VALID(mutex), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(holder != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_mutex_lock_from_isr(osal_mutex_t mutex, bool *task_woken)
{
    OSAL_CHECK_PARAM_RET(OSAL_MUTEX_IS_VALID(mutex), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(task_woken != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_mutex_unlock_from_isr(osal_mutex_t mutex, bool *task_woken)
{
    OSAL_CHECK_PARAM_RET(OSAL_MUTEX_IS_VALID(mutex), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(task_woken != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

#endif /* OSAL_MUTEX_EXTENDED_API */