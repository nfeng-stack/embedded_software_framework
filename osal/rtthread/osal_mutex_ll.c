/**
 * @file    osal_mutex_ll.c
 * @brief   RT-Thread mutex low-level implementation
 * 
 * This file implements the mutex low-level functions for RT-Thread.
 * It maps OSAL mutex functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Public Low-Level Mutex Functions
 *----------------------------------------------------------------------------*/

osal_mutex_t _osal_mutex_create(void)
{
    /* Create RT-Thread mutex */
    rt_mutex_t mutex = rt_mutex_create("osal_mutex", RT_IPC_FLAG_FIFO);
    return mutex;
}

osal_result_t _osal_mutex_delete(osal_mutex_t mutex)
{
    if (mutex == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_err_t result = rt_mutex_delete((rt_mutex_t)mutex);
    return (result == RT_EOK) ? OSAL_OK : OSAL_ERROR;
}

osal_result_t _osal_mutex_lock(osal_mutex_t mutex, uint32_t timeout_ms)
{
    if (mutex == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_tick_t timeout = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                        RT_WAITING_FOREVER : rt_tick_from_millisecond(timeout_ms);
    
    rt_err_t result = rt_mutex_take((rt_mutex_t)mutex, timeout);
    if (result == RT_EOK) {
        return OSAL_OK;
    } else if (result == -RT_ETIMEOUT) {
        return OSAL_TIMEOUT;
    }
    
    return OSAL_ERROR;
}

void _osal_mutex_unlock(osal_mutex_t mutex)
{
    if (mutex == NULL) {
        return;
    }
    
    rt_mutex_release((rt_mutex_t)mutex);
}