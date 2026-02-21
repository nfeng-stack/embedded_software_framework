/**
 * @file    osal_queue_ll.c
 * @brief   RT-Thread queue low-level implementation
 * 
 * This file implements the queue low-level functions for RT-Thread.
 * It maps OSAL queue functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Public Low-Level Queue Functions
 *----------------------------------------------------------------------------*/

osal_queue_t _osal_queue_create(int length, int item_size)
{
    /* RT-Thread message queue creation */
    rt_mq_t mq = rt_malloc(sizeof(struct rt_messagequeue));
    if (mq == NULL) {
        return NULL;
    }
    
    /* Calculate total size */
    rt_size_t queue_size = length * item_size;
    
    /* Initialize message queue */
    rt_err_t result = rt_mq_init(mq, "osal_mq", 
                                 rt_malloc(queue_size), item_size,
                                 queue_size, RT_IPC_FLAG_FIFO);
    if (result != RT_EOK) {
        rt_free(mq);
        return NULL;
    }
    
    return mq;
}

osal_result_t _osal_queue_delete(osal_queue_t queue)
{
    if (queue == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_mq_t mq = (rt_mq_t)queue;
    
    /* Detach and free message queue */
    rt_err_t result = rt_mq_detach(mq);
    if (result == RT_EOK) {
        rt_free(mq->msg_pool);
        rt_free(mq);
        return OSAL_OK;
    }
    
    return OSAL_ERROR;
}

osal_result_t _osal_queue_send(osal_queue_t queue, const void *item, 
                               uint32_t timeout_ms)
{
    if (queue == NULL || item == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_mq_t mq = (rt_mq_t)queue;
    rt_tick_t timeout = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                        RT_WAITING_FOREVER : rt_tick_from_millisecond(timeout_ms);
    (void)timeout; /* Not used in rt_mq_send */
    
    rt_err_t result = rt_mq_send(mq, item, mq->msg_size);
    if (result == RT_EOK) {
        return OSAL_OK;
    } else if (result == -RT_ETIMEOUT) {
        return OSAL_TIMEOUT;
    }
    
    return OSAL_ERROR;
}

osal_result_t _osal_queue_receive(osal_queue_t queue, void *buffer, 
                                  uint32_t timeout_ms)
{
    if (queue == NULL || buffer == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_mq_t mq = (rt_mq_t)queue;
    rt_tick_t timeout = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                        RT_WAITING_FOREVER : rt_tick_from_millisecond(timeout_ms);
    
    rt_err_t result = rt_mq_recv(mq, buffer, mq->msg_size, timeout);
    if (result == RT_EOK) {
        return OSAL_OK;
    } else if (result == -RT_ETIMEOUT) {
        return OSAL_TIMEOUT;
    }
    
    return OSAL_ERROR;
}

int _osal_queue_size(osal_queue_t queue)
{
    if (queue == NULL) {
        return OSAL_ERROR;
    }
    
    rt_mq_t mq = (rt_mq_t)queue;
    (void)mq;
    /* RT-Thread doesn't provide direct API for current queue size */
    /* Return 0 as placeholder */
    return 0;
}

int _osal_queue_space(osal_queue_t queue)
{
    if (queue == NULL) {
        return OSAL_ERROR;
    }
    
    rt_mq_t mq = (rt_mq_t)queue;
    /* RT-Thread doesn't provide direct API for free space */
    /* Return length as placeholder */
    return mq->max_msgs;
}