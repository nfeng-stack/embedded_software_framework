#include "_osal_interface.h"
#include "rtthread.h"

_osal_err_t _osal_mb_init(_osal_mb_t mb,
                           const char *name,
                           void *msgpool,
                           _osal_size_t size,
                           _osal_uint8_t flag)
{
    return (_osal_err_t)rt_mb_init(mb, name, msgpool, size);
}

_osal_err_t _osal_mb_detach(_osal_mb_t mb)
{
    return (_osal_err_t)rt_mb_detach(mb);
}

_osal_mb_t _osal_mb_create(const char *name, _osal_size_t size, _osal_uint8_t flag)
{
#ifdef RT_USING_HEAP
    return (_osal_mb_t)rt_mb_create(name, size, flag);
#else
    return RT_NULL;
#endif
}

_osal_err_t _osal_mb_delete(_osal_mb_t mb)
{
#ifdef RT_USING_HEAP
    return (_osal_err_t)rt_mb_delete(mb);
#else
    return -RT_ERROR;
#endif
}

_osal_err_t _osal_mb_send(_osal_mb_t mb, _osal_ubase_t value)
{
    return (_osal_err_t)rt_mb_send(mb, value);
}

_osal_err_t _osal_mb_send_wait(_osal_mb_t mb,
                                _osal_ubase_t value,
                                _osal_int32_t timeout)
{
    return (_osal_err_t)rt_mb_send_wait(mb, value, timeout);
}

_osal_err_t _osal_mb_urgent(_osal_mb_t mb, _osal_ubase_t value)
{
    return (_osal_err_t)rt_mb_urgent(mb, value);
}

_osal_err_t _osal_mb_recv(_osal_mb_t mb,
                           _osal_ubase_t *value,
                           _osal_int32_t timeout)
{
    return (_osal_err_t)rt_mb_recv(mb, value, timeout);
}

_osal_err_t _osal_mb_control(_osal_mb_t mb, int cmd, void *arg)
{
    return (_osal_err_t)rt_mb_control(mb, cmd, arg);
}
