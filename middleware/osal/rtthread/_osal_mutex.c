#include "_osal_interface.h"
#include "rtthread.h"

/*------------------------------------------------------------------------------
 * Mutex Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_mutex_init(_osal_mutex_t mutex,
                              const char *name,
                              _osal_uint8_t flag)
{
    return (_osal_err_t)rt_mutex_init(mutex, name, flag);
}

_osal_err_t _osal_mutex_detach(_osal_mutex_t mutex)
{
    return (_osal_err_t)rt_mutex_detach(mutex);
}

_osal_mutex_t _osal_mutex_create(const char *name, _osal_uint8_t flag)
{
#ifdef RT_USING_HEAP
    return (_osal_mutex_t)rt_mutex_create(name, flag);
#else
    return RT_NULL;
#endif
}

_osal_err_t _osal_mutex_delete(_osal_mutex_t mutex)
{
#ifdef RT_USING_HEAP
    return (_osal_err_t)rt_mutex_delete(mutex);
#else
    return -RT_ERROR;
#endif
}

_osal_err_t _osal_mutex_take(_osal_mutex_t mutex, _osal_int32_t timeout)
{
    return (_osal_err_t)rt_mutex_take(mutex, timeout);
}

_osal_err_t _osal_mutex_trytake(_osal_mutex_t mutex)
{
    return (_osal_err_t)rt_mutex_take(mutex, 0);
}

_osal_err_t _osal_mutex_release(_osal_mutex_t mutex)
{
    return (_osal_err_t)rt_mutex_release(mutex);
}

_osal_err_t _osal_mutex_control(_osal_mutex_t mutex, int cmd, void *arg)
{
    return (_osal_err_t)rt_mutex_control(mutex, cmd, arg);
}
