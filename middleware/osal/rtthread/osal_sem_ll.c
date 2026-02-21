/**
 * @file    osal_sem_ll.c
 * @brief   RT-Thread semaphore low-level implementation
 * 
 * This file implements the semaphore low-level functions for RT-Thread.
 * It maps OSAL semaphore functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Public Low-Level Semaphore Functions
 *----------------------------------------------------------------------------*/

osal_sem_t _osal_sem_create(void)
{
    /* Create RT-Thread semaphore */
    rt_sem_t sem = rt_sem_create("osal_sem", 0, RT_IPC_FLAG_FIFO);
    return sem;
}

osal_result_t _osal_sem_delete(osal_sem_t sem)
{
    if (sem == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_err_t result = rt_sem_delete((rt_sem_t)sem);
    return (result == RT_EOK) ? OSAL_OK : OSAL_ERROR;
}

osal_result_t _osal_sem_take(osal_sem_t sem, uint32_t timeout_ms)
{
    if (sem == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_tick_t timeout = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                        RT_WAITING_FOREVER : rt_tick_from_millisecond(timeout_ms);
    
    rt_err_t result = rt_sem_take((rt_sem_t)sem, timeout);
    if (result == RT_EOK) {
        return OSAL_OK;
    } else if (result == -RT_ETIMEOUT) {
        return OSAL_TIMEOUT;
    }
    
    return OSAL_ERROR;
}

void _osal_sem_give(osal_sem_t sem)
{
    if (sem == NULL) {
        return;
    }
    
    rt_sem_release((rt_sem_t)sem);
}

int _osal_sem_get_count(osal_sem_t sem)
{
    if (sem == NULL) {
        return OSAL_ERROR;
    }
    
    /* RT-Thread doesn't provide direct API for semaphore count */
    /* Return 0 as placeholder */
    return 0;
}