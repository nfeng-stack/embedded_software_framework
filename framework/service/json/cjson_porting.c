/**
 * @file cjson_porting.c
 * @brief cJSON 嵌入式平台适配层实现
 */
#define LOG "json"
#include "cjson_porting.h"
#include "cJSON.h"
#include <stdlib.h>
#include "osal.h"
#include "elog.h"
static int is_init = 0;

static void* cjson_malloc(size_t size)
{
    void *ptr = osal_malloc(size);
    if (ptr == NULL)
    {
        log_e("[cJSON] malloc failed, size: %d\n", size);
    }
    return ptr;

}

static void cjson_free(void *ptr)
{
    if (ptr != NULL)
    {
        osal_free(ptr);
    }
}

void cJSON_Porting_Init(void)
{
    cJSON_Hooks hooks = {
        .malloc_fn = cjson_malloc,
        .free_fn = cjson_free
    };
    
    cJSON_InitHooks(&hooks);
    is_init = 1;
    log_d("cjson init ok\n");
}

int cJSON_Is_Init(void)
{
    return is_init;
}
