#include "osal.h"

void osal_heap_init(void *begin_addr, void *end_addr)
{
    _osal_heap_init(begin_addr, end_addr);
}

void *osal_malloc(osal_size_t nbytes)
{
    return _osal_malloc(nbytes);
}

void osal_free(void *ptr)
{
    _osal_free(ptr);
}

void *osal_realloc(void *ptr, osal_size_t nbytes)
{
    return _osal_realloc(ptr, nbytes);
}

void *osal_calloc(osal_size_t count, osal_size_t size)
{
    return _osal_calloc(count, size);
}
