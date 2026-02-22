#include "osal.h"

osal_err_t osal_mb_init(osal_mb_t mb,
                        const char *name,
                        void *msgpool,
                        osal_size_t size,
                        osal_uint8_t flag)
{
    return _osal_mb_init(mb, name, msgpool, size, flag);
}

osal_err_t osal_mb_detach(osal_mb_t mb)
{
    return _osal_mb_detach(mb);
}

osal_mb_t osal_mb_create(const char *name, osal_size_t size, osal_uint8_t flag)
{
    return _osal_mb_create(name, size, flag);
}

osal_err_t osal_mb_delete(osal_mb_t mb)
{
    return _osal_mb_delete(mb);
}

osal_err_t osal_mb_send(osal_mb_t mb, osal_ubase_t value)
{
    return _osal_mb_send(mb, value);
}

osal_err_t osal_mb_send_wait(osal_mb_t mb,
                              osal_ubase_t value,
                              osal_int32_t timeout)
{
    return _osal_mb_send_wait(mb, value, timeout);
}

osal_err_t osal_mb_urgent(osal_mb_t mb, osal_ubase_t value)
{
    return _osal_mb_urgent(mb, value);
}

osal_err_t osal_mb_recv(osal_mb_t mb,
                        osal_ubase_t *value,
                        osal_int32_t timeout)
{
    return _osal_mb_recv(mb, value, timeout);
}

osal_err_t osal_mb_control(osal_mb_t mb, int cmd, void *arg)
{
    return _osal_mb_control(mb, cmd, arg);
}
