#include "osal_interface.h"

osal_tick_t osal_tick_get(void)
{
    return _osal_tick_get();
}

osal_tick_t osal_tick_from_millisecond(osal_int32_t ms)
{
    return _osal_tick_from_millisecond(ms);
}

void osal_enter_critical(void)
{
    _osal_enter_critical();
}

void osal_exit_critical(void)
{
    _osal_exit_critical();
}

osal_base_t osal_critical_level(void)
{
    return _osal_critical_level();
}

void (*osal_system_get_systemtick_handler_callback(void))(void)
{
    return osal_get_need_register_to_systemtick_hander_callback_ll();
}

void osal_register_callback(void (*callback)(void))
{
    osal_register_callback_ll(callback);
}

