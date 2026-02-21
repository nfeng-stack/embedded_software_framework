#include "osal_port.h"

void (*osal_system_get_systemtick_handler_callback(void))(void)
{
    return osal_get_need_register_to_systemtick_hander_callback_ll();
}

void osal_register_callback(void (*callback)(void))
{
    osal_register_callback_ll(callback);
}
