#include "osal.h"

osal_err_t osal_task_init(osal_task_t thread,
                          const char *name,
                          void (*entry)(void *parameter),
                          void *parameter,
                          void *stack_start,
                          osal_uint32_t stack_size,
                          osal_uint8_t priority,
                          osal_uint32_t tick)
{
    return _osal_task_init(thread, name, entry, parameter,
                          stack_start, stack_size, priority, tick);
}

osal_err_t osal_task_detach(osal_task_t thread)
{
    return _osal_task_detach(thread);
}

osal_task_t osal_task_create(const char *name,
                              void (*entry)(void *parameter),
                              void *parameter,
                              osal_uint32_t stack_size,
                              osal_uint8_t priority,
                              osal_uint32_t tick)
{
    return _osal_task_create(name, entry, parameter,
                            stack_size, priority, tick);
}

osal_err_t osal_task_delete(osal_task_t thread)
{
    return _osal_task_delete(thread);
}

osal_task_t osal_task_self(void)
{
    return _osal_task_self();
}

osal_task_t osal_task_find(const char *name)
{
    return _osal_task_find(name);
}

osal_err_t osal_task_startup(osal_task_t thread)
{
    return _osal_task_startup(thread);
}

osal_err_t osal_task_yield(void)
{
    return _osal_task_yield();
}

osal_err_t osal_task_delay(osal_tick_t tick)
{
    return _osal_task_delay(tick);
}

osal_err_t osal_task_mdelay(osal_int32_t ms)
{
    return _osal_task_mdelay(ms);
}

osal_err_t osal_task_suspend(osal_task_t thread)
{
    return _osal_task_suspend(thread);
}

osal_err_t osal_task_resume(osal_task_t thread)
{
    return _osal_task_resume(thread);
}

osal_err_t osal_task_control(osal_task_t thread, int cmd, void *arg)
{
    return _osal_task_control(thread, cmd, arg);
}
