#include "_osal_interface.h"
#include "rtthread.h"

_osal_err_t _osal_sem_init(_osal_semaphore_t sem,
                            const char *name,
                            _osal_uint32_t value,
                            _osal_uint8_t flag)
{
    return (_osal_err_t)rt_sem_init(sem, name, value,flag);
}

_osal_err_t _osal_sem_detach(_osal_semaphore_t sem)
{
    return (_osal_err_t)rt_sem_detach(sem);
}

_osal_semaphore_t _osal_sem_create(const char *name,
                                   _osal_uint32_t value,
                                   _osal_uint8_t flag)
{
#ifdef RT_USING_HEAP
    return (_osal_semaphore_t)rt_sem_create(name, value,flag);
#else
    return RT_NULL;
#endif
}

_osal_err_t _osal_sem_delete(_osal_semaphore_t sem)
{
#ifdef RT_USING_HEAP
    return (_osal_err_t)rt_sem_delete(sem);
#else
    return -RT_ERROR;
#endif
}

_osal_err_t _osal_sem_take(_osal_semaphore_t sem, _osal_int32_t timeout)
{
    return (_osal_err_t)rt_sem_take(sem, timeout);
}

_osal_err_t _osal_sem_trytake(_osal_semaphore_t sem)
{
    return (_osal_err_t)rt_sem_trytake(sem);
}

_osal_err_t _osal_sem_release(_osal_semaphore_t sem)
{
    return (_osal_err_t)rt_sem_release(sem);
}

_osal_err_t _osal_sem_control(_osal_semaphore_t sem, int cmd, void *arg)
{
    return (_osal_err_t)rt_sem_control(sem, cmd, arg);
}
