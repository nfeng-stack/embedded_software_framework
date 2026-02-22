#include "_osal_interface.h"
#include "rtthread.h"

_osal_err_t _osal_mp_init(_osal_mp_t mp,
                           const char *name,
                           void *start,
                           _osal_size_t size,
                           _osal_size_t block_size)
{
    return (_osal_err_t)rt_mp_init(mp, name, start, size, block_size);
}

_osal_err_t _osal_mp_detach(_osal_mp_t mp)
{
    return (_osal_err_t)rt_mp_detach(mp);
}

_osal_mp_t _osal_mp_create(const char *name,
                            _osal_size_t block_count,
                            _osal_size_t block_size)
{
#ifdef RT_USING_HEAP
    return (_osal_mp_t)rt_mp_create(name, block_count, block_size);
#else
    return RT_NULL;
#endif
}

_osal_err_t _osal_mp_delete(_osal_mp_t mp)
{
#ifdef RT_USING_HEAP
    return (_osal_err_t)rt_mp_delete(mp);
#else
    return -RT_ERROR;
#endif
}

void *_osal_mp_alloc(_osal_mp_t mp, _osal_int32_t time)
{
    return rt_mp_alloc(mp, time);
}

void _osal_mp_free(void *block)
{
    rt_mp_free(block);
}
