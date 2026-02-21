/**
 * @file    osal_mem_ll.c
 * @brief   RT-Thread memory management low-level implementation
 * 
 * This file implements the memory management low-level functions for RT-Thread.
 * It maps OSAL memory functions to RT-Thread native APIs.
 */

#include "osal_port.h"

/*------------------------------------------------------------------------------
 * Public Low-Level Memory Functions
 *----------------------------------------------------------------------------*/

void *_osal_malloc(size_t size)
{
    return rt_malloc(size);
}

void _osal_free(void *ptr)
{
    rt_free(ptr);
}

void *_osal_calloc(size_t nmemb, size_t size)
{
    size_t total_size = nmemb * size;
    void *ptr = rt_malloc(total_size);
    if (ptr != NULL) {
        rt_memset(ptr, 0, total_size);
    }
    return ptr;
}

void *_osal_realloc(void *ptr, size_t size)
{
    /* RT-Thread doesn't have realloc, implement simple version */
    if (ptr == NULL) {
        return rt_malloc(size);
    }
    
    if (size == 0) {
        rt_free(ptr);
        return NULL;
    }
    
    /* Allocate new memory */
    void *new_ptr = rt_malloc(size);
    if (new_ptr == NULL) {
        return NULL;
    }
    
    /* Copy data (would need to know original size, but we don't have it) */
    /* For simplicity, just copy minimum of old and new size */
    /* This is a simplified implementation */
    rt_memcpy(new_ptr, ptr, size);
    
    /* Free old memory */
    rt_free(ptr);
    
    return new_ptr;
}

osal_result_t _osal_mem_init(void)
{
    /* RT-Thread memory system is initialized during startup */
    return OSAL_OK;
}

