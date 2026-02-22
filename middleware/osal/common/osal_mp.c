#include "osal.h"

osal_err_t osal_mp_init(osal_mp_t mp,
                        const char *name,
                        void *start,
                        osal_size_t size,
                        osal_size_t block_size)
{
    return _osal_mp_init(mp, name, start, size, block_size);
}

osal_err_t osal_mp_detach(osal_mp_t mp)
{
    return _osal_mp_detach(mp);
}

osal_mp_t osal_mp_create(const char *name,
                         osal_size_t block_count,
                         osal_size_t block_size)
{
    return _osal_mp_create(name, block_count, block_size);
}

osal_err_t osal_mp_delete(osal_mp_t mp)
{
    return _osal_mp_delete(mp);
}

void *osal_mp_alloc(osal_mp_t mp, osal_int32_t time)
{
    return _osal_mp_alloc(mp, time);
}

void osal_mp_free(void *block)
{
    _osal_mp_free(block);
}
