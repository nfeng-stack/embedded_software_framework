/**
 * @file    osal_sem.c
 * @brief   Semaphore abstraction layer implementation
 * 
 * This file implements the semaphore functions defined in osal.h.
 * It calls RTOS-specific low-level functions through the _osal_sem_* interface.
 */

#include "osal_common.h"

/*------------------------------------------------------------------------------
 * Public Semaphore Functions
 *----------------------------------------------------------------------------*/

osal_sem_t osal_sem_create(void)
{
    /* Call RTOS-specific implementation */
    return _osal_sem_create();
}

osal_result_t osal_sem_delete(osal_sem_t sem)
{
    OSAL_CHECK_PARAM_RET(OSAL_SEM_IS_VALID(sem), OSAL_INVALID_PARAM);
    
    /* Call RTOS-specific implementation */
    return _osal_sem_delete(sem);
}

osal_result_t osal_sem_take(osal_sem_t sem, uint32_t timeout_ms)
{
    OSAL_CHECK_PARAM_RET(OSAL_SEM_IS_VALID(sem), OSAL_INVALID_PARAM);
    
    /* Convert timeout to RTOS-specific format */
    uint32_t timeout_ticks = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                             OSAL_WAIT_FOREVER : MS_TO_TICKS(timeout_ms);
    
    /* Call RTOS-specific implementation */
    return _osal_sem_take(sem, timeout_ticks);
}

void osal_sem_give(osal_sem_t sem)
{
    OSAL_CHECK_PARAM(OSAL_SEM_IS_VALID(sem));
    
    /* Call RTOS-specific implementation */
    _osal_sem_give(sem);
}

int osal_sem_get_count(osal_sem_t sem)
{
    OSAL_CHECK_PARAM_RET(OSAL_SEM_IS_VALID(sem), OSAL_ERROR);
    
    /* Call RTOS-specific implementation */
    return _osal_sem_get_count(sem);
}

/*------------------------------------------------------------------------------
 * Extended Semaphore Functions (optional)
 *----------------------------------------------------------------------------*/

#ifdef OSAL_SEM_EXTENDED_API

osal_result_t osal_sem_create_counting(uint32_t max_count, uint32_t initial_count)
{
    OSAL_CHECK_PARAM_RET(max_count > 0, OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(initial_count <= max_count, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_sem_take_from_isr(osal_sem_t sem, bool *task_woken)
{
    OSAL_CHECK_PARAM_RET(OSAL_SEM_IS_VALID(sem), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(task_woken != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_sem_give_from_isr(osal_sem_t sem, bool *task_woken)
{
    OSAL_CHECK_PARAM_RET(OSAL_SEM_IS_VALID(sem), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(task_woken != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

#endif /* OSAL_SEM_EXTENDED_API */