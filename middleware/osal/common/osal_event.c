/**
 * @file    osal_event.c
 * @brief   Event flag group abstraction layer implementation
 * 
 * This file implements the event flag group functions defined in osal.h.
 * It calls RTOS-specific low-level functions through the _osal_event_* interface.
 */

#include "osal_common.h"

/*------------------------------------------------------------------------------
 * Public Event Functions
 *----------------------------------------------------------------------------*/

osal_event_t osal_event_create(void)
{
    /* Call RTOS-specific implementation */
    return _osal_event_create();
}

osal_result_t osal_event_delete(osal_event_t event)
{
    OSAL_CHECK_PARAM_RET(OSAL_EVENT_IS_VALID(event), OSAL_INVALID_PARAM);
    
    /* Call RTOS-specific implementation */
    return _osal_event_delete(event);
}

osal_result_t osal_event_set(osal_event_t event, uint32_t bits)
{
    OSAL_CHECK_PARAM_RET(OSAL_EVENT_IS_VALID(event), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(bits != 0, OSAL_INVALID_PARAM);
    
    /* Call RTOS-specific implementation */
    return _osal_event_set(event, bits);
}

osal_result_t osal_event_wait(osal_event_t event, uint32_t bits, 
                              osal_event_wait_type_t wait_type, 
                              uint32_t timeout_ms)
{
    OSAL_CHECK_PARAM_RET(OSAL_EVENT_IS_VALID(event), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(bits != 0, OSAL_INVALID_PARAM);
    
    /* Convert timeout to RTOS-specific format */
    uint32_t timeout_ticks = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                             OSAL_WAIT_FOREVER : MS_TO_TICKS(timeout_ms);
    
    /* Call RTOS-specific implementation */
    return _osal_event_wait(event, bits, wait_type, timeout_ticks);
}

uint32_t osal_event_get(osal_event_t event)
{
    OSAL_CHECK_PARAM_RET(OSAL_EVENT_IS_VALID(event), 0);
    
    /* Call RTOS-specific implementation */
    return _osal_event_get(event);
}

/*------------------------------------------------------------------------------
 * Extended Event Functions (optional)
 *----------------------------------------------------------------------------*/

#ifdef OSAL_EVENT_EXTENDED_API

osal_result_t osal_event_clear(osal_event_t event, uint32_t bits)
{
    OSAL_CHECK_PARAM_RET(OSAL_EVENT_IS_VALID(event), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(bits != 0, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

osal_result_t osal_event_set_from_isr(osal_event_t event, uint32_t bits, bool *task_woken)
{
    OSAL_CHECK_PARAM_RET(OSAL_EVENT_IS_VALID(event), OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(bits != 0, OSAL_INVALID_PARAM);
    OSAL_CHECK_PARAM_RET(task_woken != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

#endif /* OSAL_EVENT_EXTENDED_API */