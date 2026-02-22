#include "_osal_interface.h"
#include "rtthread.h"

_osal_err_t _osal_mq_init(_osal_mq_t mq,
                           const char *name,
                           void *msgpool,
                           _osal_size_t msg_size,
                           _osal_size_t pool_size,
                           _osal_uint8_t flag)
{
    return (_osal_err_t)rt_mq_init(mq, name, msgpool, msg_size, pool_size,flag);
}

_osal_err_t _osal_mq_detach(_osal_mq_t mq)
{
    return (_osal_err_t)rt_mq_detach(mq);
}

_osal_mq_t _osal_mq_create(const char *name,
                            _osal_size_t msg_size,
                            _osal_size_t max_msgs,
                            _osal_uint8_t flag)
{
#ifdef RT_USING_HEAP
    return (_osal_mq_t)rt_mq_create(name, msg_size, max_msgs, flag);
#else
    return RT_NULL;
#endif
}

_osal_err_t _osal_mq_delete(_osal_mq_t mq)
{
#ifdef RT_USING_HEAP
    return (_osal_err_t)rt_mq_delete(mq);
#else
    return -RT_ERROR;
#endif
}

_osal_err_t _osal_mq_send(_osal_mq_t mq, const void *buffer, _osal_size_t size)
{
    return (_osal_err_t)rt_mq_send(mq, buffer, size);
}

_osal_err_t _osal_mq_send_wait(_osal_mq_t mq,
                               const void *buffer,
                               _osal_size_t size,
                               _osal_int32_t timeout)
{
    return (_osal_err_t)rt_mq_send_wait(mq, buffer, size, timeout);
}

_osal_err_t _osal_mq_urgent(_osal_mq_t mq, const void *buffer, _osal_size_t size)
{
    return (_osal_err_t)rt_mq_urgent(mq, buffer, size);
}

_osal_err_t _osal_mq_recv(_osal_mq_t mq,
                           void *buffer,
                           _osal_size_t size,
                           _osal_int32_t timeout)
{
    return (_osal_err_t)rt_mq_recv(mq, buffer, size, timeout);
}

_osal_err_t _osal_mq_control(_osal_mq_t mq, int cmd, void *arg)
{
    return (_osal_err_t)rt_mq_control(mq, cmd, arg);
}
