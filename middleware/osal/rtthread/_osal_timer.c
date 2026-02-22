#include "_osal_interface.h"
#include "rtthread.h"

_osal_err_t _osal_timer_init(_osal_timer_t timer,
                              const char *name,
                              void (*timeout)(void *parameter),
                              void *parameter,
                              _osal_tick_t time,
                              _osal_uint8_t flag)
{
    rt_timer_init(timer, name, timeout, parameter, time, flag);
    return OSAL_EOK;
}

_osal_err_t _osal_timer_detach(_osal_timer_t timer)
{
    return (_osal_err_t)rt_timer_detach(timer);
}

_osal_timer_t _osal_timer_create(const char *name,
                                   void (*timeout)(void *parameter),
                                   void *parameter,
                                   _osal_tick_t time,
                                   _osal_uint8_t flag)
{
#ifdef RT_USING_HEAP
    return (_osal_timer_t)rt_timer_create(name, timeout, parameter, time, flag);
#else
    return RT_NULL;
#endif
}

_osal_err_t _osal_timer_delete(_osal_timer_t timer)
{
#ifdef RT_USING_HEAP
    return (_osal_err_t)rt_timer_delete(timer);
#else
    return -RT_ERROR;
#endif
}

_osal_err_t _osal_timer_start(_osal_timer_t timer)
{
    return (_osal_err_t)rt_timer_start(timer);
}

_osal_err_t _osal_timer_stop(_osal_timer_t timer)
{
    return (_osal_err_t)rt_timer_stop(timer);
}

_osal_err_t _osal_timer_control(_osal_timer_t timer, int cmd, void *arg)
{
    return (_osal_err_t)rt_timer_control(timer, cmd, arg);
}
