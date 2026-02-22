#include "_osal_interface.h"
#include "rtthread.h"

void _osal_heap_init(void *begin_addr, void *end_addr)
{
}

void *_osal_malloc(_osal_size_t nbytes)
{
    return rt_malloc(nbytes);
}

void _osal_free(void *ptr)
{
    rt_free(ptr);
}

void *_osal_realloc(void *ptr, _osal_size_t nbytes)
{
    return rt_realloc(ptr, nbytes);
}

void *_osal_calloc(_osal_size_t count, _osal_size_t size)
{
    void *ptr = rt_malloc(count * size);
    if (ptr != RT_NULL)
    {
        rt_memset(ptr, 0, count * size);
    }
    return ptr;
}
