#include "osal_interface.h"

osal_err_t osal_sem_init(osal_semaphore_t sem,
                         const char *name,
                         osal_uint32_t value,
                         osal_uint8_t flag)
{
    return _osal_sem_init(sem, name, value, flag);
}

osal_err_t osal_sem_detach(osal_semaphore_t sem)
{
    return _osal_sem_detach(sem);
}

osal_semaphore_t osal_sem_create(const char *name,
                                 osal_uint32_t value,
                                 osal_uint8_t flag)
{
    return _osal_sem_create(name, value, flag);
}

osal_err_t osal_sem_delete(osal_semaphore_t sem)
{
    return _osal_sem_delete(sem);
}

osal_err_t osal_sem_take(osal_semaphore_t sem, osal_int32_t timeout)
{
    return _osal_sem_take(sem, timeout);
}

osal_err_t osal_sem_trytake(osal_semaphore_t sem)
{
    return _osal_sem_trytake(sem);
}

osal_err_t osal_sem_release(osal_semaphore_t sem)
{
    return _osal_sem_release(sem);
}

osal_err_t osal_sem_control(osal_semaphore_t sem, int cmd, void *arg)
{
    return _osal_sem_control(sem, cmd, arg);
}
