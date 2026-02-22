#include "_osal_interface.h"
#include "rtthread.h"

_osal_err_t _osal_task_init(_osal_task_t thread,
                            const char *name,
                            void (*entry)(void *parameter),
                            void *parameter,
                            void *stack_start,
                            _osal_uint32_t stack_size,
                            _osal_uint8_t priority,
                            _osal_uint32_t tick)
{
    return (_osal_err_t)rt_thread_init(thread, name, entry, parameter,
                                      stack_start, stack_size, priority, tick);
}

_osal_err_t _osal_task_detach(_osal_task_t thread)
{
    return (_osal_err_t)rt_thread_detach(thread);
}

_osal_task_t _osal_task_create(const char *name,
                               void (*entry)(void *parameter),
                               void *parameter,
                               _osal_uint32_t stack_size,
                               _osal_uint8_t priority,
                               _osal_uint32_t tick)
{
    return (_osal_task_t)rt_thread_create(name, entry, parameter,
                                         stack_size, priority, tick);
}

_osal_err_t _osal_task_delete(_osal_task_t thread)
{
    return (_osal_err_t)rt_thread_delete(thread);
}

_osal_task_t _osal_task_self(void)
{
    return (_osal_task_t)rt_thread_self();
}

_osal_task_t _osal_task_find(const char *name)
{
    return (_osal_task_t)rt_thread_find((char *)name);
}

_osal_err_t _osal_task_startup(_osal_task_t thread)
{
    return (_osal_err_t)rt_thread_startup(thread);
}

_osal_err_t _osal_task_yield(void)
{
    return (_osal_err_t)rt_thread_yield();
}

_osal_err_t _osal_task_delay(_osal_tick_t tick)
{
    return (_osal_err_t)rt_thread_delay(tick);
}

_osal_err_t _osal_task_mdelay(_osal_int32_t ms)
{
    return (_osal_err_t)rt_thread_mdelay(ms);
}

_osal_err_t _osal_task_suspend(_osal_task_t thread)
{
    return (_osal_err_t)rt_thread_suspend(thread);
}

_osal_err_t _osal_task_resume(_osal_task_t thread)
{
    return (_osal_err_t)rt_thread_resume(thread);
}

_osal_err_t _osal_task_control(_osal_task_t thread, int cmd, void *arg)
{
    return (_osal_err_t)rt_thread_control(thread, cmd, arg);
}
