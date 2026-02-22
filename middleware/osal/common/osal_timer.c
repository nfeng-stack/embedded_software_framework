#include "osal.h"

osal_err_t osal_timer_init(osal_timer_t timer,
                           const char *name,
                           void (*timeout)(void *parameter),
                           void *parameter,
                           osal_tick_t time,
                           osal_uint8_t flag)
{
    return _osal_timer_init(timer, name, timeout, parameter, time, flag);
}

osal_err_t osal_timer_detach(osal_timer_t timer)
{
    return _osal_timer_detach(timer);
}

osal_timer_t osal_timer_create(const char *name,
                               void (*timeout)(void *parameter),
                               void *parameter,
                               osal_tick_t time,
                               osal_uint8_t flag)
{
    return _osal_timer_create(name, timeout, parameter, time, flag);
}

osal_err_t osal_timer_delete(osal_timer_t timer)
{
    return _osal_timer_delete(timer);
}

osal_err_t osal_timer_start(osal_timer_t timer)
{
    return _osal_timer_start(timer);
}

osal_err_t osal_timer_stop(osal_timer_t timer)
{
    return _osal_timer_stop(timer);
}

osal_err_t osal_timer_control(osal_timer_t timer, int cmd, void *arg)
{
    return _osal_timer_control(timer, cmd, arg);
}
