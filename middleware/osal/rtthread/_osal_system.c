#include "_osal_interface.h"
#include "rtthread.h"

_osal_tick_t _osal_tick_get(void)
{
    return (_osal_tick_t)rt_tick_get();
}

_osal_tick_t _osal_tick_from_millisecond(_osal_int32_t ms)
{
    return (_osal_tick_t)rt_tick_from_millisecond(ms);
}

void _osal_enter_critical(void)
{
    rt_enter_critical();
}

void _osal_exit_critical(void)
{
    rt_exit_critical();
}

_osal_base_t _osal_critical_level(void)
{
    return (_osal_base_t)rt_critical_level();
}

extern void rt_os_tick_callback(void);
void (*osal_get_need_register_to_systemtick_hander_callback_ll(void))(void)
{
    return rt_os_tick_callback;
}
extern void rt_register_callback(void (*callback)(void));
void osal_register_callback_ll(void (*callback)(void))
{
    rt_register_callback(callback);
}