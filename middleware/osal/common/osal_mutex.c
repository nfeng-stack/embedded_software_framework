#include "osal.h"

osal_err_t osal_mutex_init(osal_mutex_t mutex,
                           const char *name,
                           osal_uint8_t flag)
{
    return _osal_mutex_init(mutex, name, flag);
}

osal_err_t osal_mutex_detach(osal_mutex_t mutex)
{
    return _osal_mutex_detach(mutex);
}

osal_mutex_t osal_mutex_create(const char *name, osal_uint8_t flag)
{
    return _osal_mutex_create(name, flag);
}

osal_err_t osal_mutex_delete(osal_mutex_t mutex)
{
    return _osal_mutex_delete(mutex);
}

osal_err_t osal_mutex_take(osal_mutex_t mutex, osal_int32_t timeout)
{
    return _osal_mutex_take(mutex, timeout);
}

osal_err_t osal_mutex_trytake(osal_mutex_t mutex)
{
    return _osal_mutex_trytake(mutex);
}

osal_err_t osal_mutex_release(osal_mutex_t mutex)
{
    return _osal_mutex_release(mutex);
}

osal_err_t osal_mutex_control(osal_mutex_t mutex, int cmd, void *arg)
{
    return _osal_mutex_control(mutex, cmd, arg);
}
