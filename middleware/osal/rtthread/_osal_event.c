#include "_osal_interface.h"
#include "rtthread.h"

_osal_err_t _osal_event_init(_osal_event_t event,
                              const char *name,
                              _osal_uint8_t flag)
{
    return (_osal_err_t)rt_event_init(event, name, flag);
}

_osal_err_t _osal_event_detach(_osal_event_t event)
{
    return (_osal_err_t)rt_event_detach(event);
}

_osal_event_t _osal_event_create(const char *name, _osal_uint8_t flag)
{
#ifdef RT_USING_HEAP
    return (_osal_event_t)rt_event_create(name, flag);
#else
    return RT_NULL;
#endif
}

_osal_err_t _osal_event_delete(_osal_event_t event)
{
#ifdef RT_USING_HEAP
    return (_osal_err_t)rt_event_delete(event);
#else
    return -RT_ERROR;
#endif
}

_osal_err_t _osal_event_send(_osal_event_t event, _osal_uint32_t set)
{
    return (_osal_err_t)rt_event_send(event, set);
}

_osal_err_t _osal_event_recv(_osal_event_t event,
                              _osal_uint32_t set,
                              _osal_uint8_t opt,
                              _osal_int32_t timeout,
                              _osal_uint32_t *recved)
{
    return (_osal_err_t)rt_event_recv(event, set, opt, timeout, recved);
}

_osal_err_t _osal_event_control(_osal_event_t event, int cmd, void *arg)
{
    return (_osal_err_t)rt_event_control(event, cmd, arg);
}
