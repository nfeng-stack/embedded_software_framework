#include "osal_interface.h"

osal_err_t osal_event_init(osal_event_t event,
                           const char *name,
                           osal_uint8_t flag)
{
    return _osal_event_init(event, name, flag);
}

osal_err_t osal_event_detach(osal_event_t event)
{
    return _osal_event_detach(event);
}

osal_event_t osal_event_create(const char *name, osal_uint8_t flag)
{
    return _osal_event_create(name, flag);
}

osal_err_t osal_event_delete(osal_event_t event)
{
    return _osal_event_delete(event);
}

osal_err_t osal_event_send(osal_event_t event, osal_uint32_t set)
{
    return _osal_event_send(event, set);
}

osal_err_t osal_event_recv(osal_event_t event,
                           osal_uint32_t set,
                           osal_uint8_t opt,
                           osal_int32_t timeout,
                           osal_uint32_t *recved)
{
    return _osal_event_recv(event, set, opt, timeout, recved);
}

osal_err_t osal_event_control(osal_event_t event, int cmd, void *arg)
{
    return _osal_event_control(event, cmd, arg);
}
