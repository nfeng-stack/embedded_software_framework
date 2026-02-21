/**
 * @file    osal_queue.c
 * @brief   Queue abstraction layer implementation
 * 
 * This file implements the queue functions defined in osal.h.
 * It calls RTOS-specific low-level functions through the _osal_queue_* interface.
 */

#include "osal_common.h"

/*------------------------------------------------------------------------------
 * Public Queue Functions
 *----------------------------------------------------------------------------*/

osal_queue_t osal_queue_create(int length, int item_size)
{
    OSAL_CHECK_PARAM_RET_NULL(length > 0 && length <= OSAL_QUEUE_MAX_LENGTH);
    OSAL_CHECK_PARAM_RET_NULL(item_size > 0 && item_size <= OSAL_QUEUE_MAX_ITEM_SIZE);
    
    /* Call RTOS-specific implementation */
    return _osal_queue_create(length, item_size);
}

osal_result_t osal_queue_delete(osal_queue_t queue)
{
    OSAL_CHECK_PARAM_RET(OSAL_QUEUE_IS_VALID(queue), OSAL_INVALID_PARAM);
    
    /* Call RTOS-specific implementation */
    return _osal_queue_delete(queue);
}

osal_result_t osal_queue_send(osal_queue_t queue, const void *item, 
                              uint32_t timeout_ms)
{
    OSAL_CHECK_PARAM_RET(OSAL_QUEUE_IS_VALID(queue), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(item != NULL, OSAL_INVALID_PARAM);
    
    /* Convert milliseconds to ticks */
    uint32_t ticks = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                     OSAL_WAIT_FOREVER : MS_TO_TICKS(timeout_ms);
    
    /* Call RTOS-specific implementation */
    return _osal_queue_send(queue, item, ticks);
}

osal_result_t osal_queue_receive(osal_queue_t queue, void *buffer, 
                                 uint32_t timeout_ms)
{
    OSAL_CHECK_PARAM_RET(OSAL_QUEUE_IS_VALID(queue), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(buffer != NULL, OSAL_INVALID_PARAM);
    
    /* Convert milliseconds to ticks */
    uint32_t ticks = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                     OSAL_WAIT_FOREVER : MS_TO_TICKS(timeout_ms);
    
    /* Call RTOS-specific implementation */
    return _osal_queue_receive(queue, buffer, ticks);
}

int osal_queue_size(osal_queue_t queue)
{
    OSAL_CHECK_PARAM_RET(OSAL_QUEUE_IS_VALID(queue), OSAL_ERROR);
    
    /* Call RTOS-specific implementation */
    return _osal_queue_size(queue);
}

int osal_queue_space(osal_queue_t queue)
{
    OSAL_CHECK_PARAM_RET(OSAL_QUEUE_IS_VALID(queue), OSAL_ERROR);
    
    /* Call RTOS-specific implementation */
    return _osal_queue_space(queue);
}

/*------------------------------------------------------------------------------
 * Extended Queue Functions (optional)
 *----------------------------------------------------------------------------*/

#ifdef OSAL_QUEUE_EXTENDED_API

osal_result_t osal_queue_reset(osal_queue_t queue)
{
    OSAL_CHECK_PARAM_RET(OSAL_QUEUE_IS_VALID(queue), OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_queue_peek(osal_queue_t queue, void *buffer, 
                              uint32_t timeout_ms)
{
    OSAL_CHECK_PARAM_RET(OSAL_QUEUE_IS_VALID(queue), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(buffer != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

#endif /* OSAL_QUEUE_EXTENDED_API */