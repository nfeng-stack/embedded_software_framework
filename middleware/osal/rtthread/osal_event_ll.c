/**
 * @file    osal_event_ll.c
 * @brief   RT-Thread event flag group low-level implementation
 * 
 * This file implements the event flag group low-level functions for RT-Thread.
 * It maps OSAL event functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Public Low-Level Event Functions
 *----------------------------------------------------------------------------*/

osal_event_t _osal_event_create(void)
{
    /* Create RT-Thread event flag group */
    rt_event_t event = rt_event_create("osal_event", RT_IPC_FLAG_FIFO);
    return event;
}

osal_result_t _osal_event_delete(osal_event_t event)
{
    if (event == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_err_t result = rt_event_delete((rt_event_t)event);
    return (result == RT_EOK) ? OSAL_OK : OSAL_ERROR;
}

osal_result_t _osal_event_set(osal_event_t event, uint32_t bits)
{
    if (event == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_err_t result = rt_event_send((rt_event_t)event, bits);
    return (result == RT_EOK) ? OSAL_OK : OSAL_ERROR;
}

osal_result_t _osal_event_wait(osal_event_t event, uint32_t bits, 
                               osal_event_wait_type_t wait_type, 
                               uint32_t timeout_ms)
{
    if (event == NULL) {
        return OSAL_INVALID_PARAM;
    }
    
    rt_tick_t timeout = (timeout_ms == OSAL_WAIT_FOREVER) ? 
                        RT_WAITING_FOREVER : rt_tick_from_millisecond(timeout_ms);
    
    rt_uint8_t option;
    if (wait_type == OSAL_EVENT_WAIT_ANY) {
        option = RT_EVENT_FLAG_OR | RT_EVENT_FLAG_CLEAR;
    } else {
        option = RT_EVENT_FLAG_AND | RT_EVENT_FLAG_CLEAR;
    }
    
    rt_err_t result = rt_event_recv((rt_event_t)event, bits, option, timeout, NULL);
    if (result == RT_EOK) {
        return OSAL_OK;
    } else if (result == -RT_ETIMEOUT) {
        return OSAL_TIMEOUT;
    }
    
    return OSAL_ERROR;
}

uint32_t _osal_event_get(osal_event_t event)
{
    if (event == NULL) {
        return 0;
    }
    
    /* RT-Thread doesn't provide direct API to get current event bits */
    /* Return 0 as placeholder */
    return 0;
}