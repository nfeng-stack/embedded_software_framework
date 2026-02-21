/**
 * @file    osal_mem.c
 * @brief   Memory management abstraction layer implementation
 * 
 * This file implements the memory management functions defined in osal.h.
 * It calls RTOS-specific low-level functions through the _osal_mem_* interface.
 */

#include "osal_common.h"

/*------------------------------------------------------------------------------
 * Public Memory Functions
 *----------------------------------------------------------------------------*/

void *osal_malloc(size_t size)
{
    OSAL_CHECK_PARAM_RET_NULL(size > 0);
    
    /* Call RTOS-specific implementation */
    return _osal_malloc(size);
}

void osal_free(void *ptr)
{
    /* Allow NULL pointer (free does nothing) */
    if (ptr == NULL) {
        return;
    }
    
    /* Call RTOS-specific implementation */
    _osal_free(ptr);
}

void *osal_calloc(size_t nmemb, size_t size)
{
    OSAL_CHECK_PARAM_RET_NULL(nmemb > 0);
    OSAL_CHECK_PARAM_RET_NULL(size > 0);
    
    /* Call RTOS-specific implementation */
    return _osal_calloc(nmemb, size);
}

void *osal_realloc(void *ptr, size_t size)
{
    /* If ptr is NULL, equivalent to malloc */
    if (ptr == NULL) {
        return osal_malloc(size);
    }
    
    /* If size is 0, equivalent to free and return NULL */
    if (size == 0) {
        osal_free(ptr);
        return NULL;
    }
    
    /* Call RTOS-specific implementation */
    return _osal_realloc(ptr, size);
}

osal_result_t osal_mem_init(void)
{
    /* Call RTOS-specific implementation */
    return _osal_mem_init();
}

/*------------------------------------------------------------------------------
 * Extended Memory Functions (optional)
 *----------------------------------------------------------------------------*/

#ifdef OSAL_MEM_EXTENDED_API

size_t osal_mem_get_free_size(void)
{
    /* RTOS-specific implementation would be needed */
    return 0;
}

size_t osal_mem_get_minimum_free_size(void)
{
    /* RTOS-specific implementation would be needed */
    return 0;
}

osal_result_t osal_mem_get_info(osal_mem_info_t *info)
{
    OSAL_CHECK_PARAM_RET(info != NULL, OSAL_INVALID_PARAM);
    
    /* RTOS-specific implementation would be needed */
    return OSAL_NOT_SUPPORTED;
}

#endif /* OSAL_MEM_EXTENDED_API */