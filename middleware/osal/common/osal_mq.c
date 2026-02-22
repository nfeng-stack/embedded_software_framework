#include "osal.h"

osal_err_t osal_mq_init(osal_mq_t mq,
                        const char *name,
                        void *msgpool,
                        osal_size_t msg_size,
                        osal_size_t pool_size,
                        osal_uint8_t flag)
{
    return _osal_mq_init(mq, name, msgpool, msg_size, pool_size, flag);
}

osal_err_t osal_mq_detach(osal_mq_t mq)
{
    return _osal_mq_detach(mq);
}

osal_mq_t osal_mq_create(const char *name,
                         osal_size_t msg_size,
                         osal_size_t max_msgs,
                         osal_uint8_t flag)
{
    return _osal_mq_create(name, msg_size, max_msgs, flag);
}

osal_err_t osal_mq_delete(osal_mq_t mq)
{
    return _osal_mq_delete(mq);
}

osal_err_t osal_mq_send(osal_mq_t mq, const void *buffer, osal_size_t size)
{
    return _osal_mq_send(mq, buffer, size);
}

osal_err_t osal_mq_send_wait(osal_mq_t mq,
                             const void *buffer,
                             osal_size_t size,
                             osal_int32_t timeout)
{
    return _osal_mq_send_wait(mq, buffer, size, timeout);
}

osal_err_t osal_mq_urgent(osal_mq_t mq, const void *buffer, osal_size_t size)
{
    return _osal_mq_urgent(mq, buffer, size);
}

osal_err_t osal_mq_recv(osal_mq_t mq,
                         void *buffer,
                         osal_size_t size,
                         osal_int32_t timeout)
{
    return _osal_mq_recv(mq, buffer, size, timeout);
}

osal_err_t osal_mq_control(osal_mq_t mq, int cmd, void *arg)
{
    return _osal_mq_control(mq, cmd, arg);
}
