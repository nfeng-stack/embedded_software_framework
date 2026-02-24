#ifdef __cplusplus
extern "C"
{
#endif

#include "stdio.h"
#include <string.h>
#include "hal_device.h"
#include "osal.h"
#include "framework_register_device.h"
#include "elog.h"
#define     LOG_TAG     "framework"
list_t device_obj = {0};
framework_obj_t obj = {
    .obj_num = 0 ,
    .obj_head = &device_obj,
    .obj_tail = &device_obj,
};

int32_t framework_register_device(const void *device)
{
    list_t * p = (list_t*)osal_malloc(sizeof(list_t));
    if(p != NULL)
    {
        p->dev = device;
        p->next = NULL;
        /* 查找设备obj中没有该设备后放入*/
        obj.obj_tail->next = p;
        obj.obj_tail = p;
        obj.obj_num++;
        return 0;
    }
    log_e("%s,register_error\n",__func__);
    return -1;
}
int32_t framework_unregister_device(const void *device)
{
    list_t *p = obj.obj_head->next ;
    while(p != NULL)
    {
        if(device == p->dev)
        {
            /* 移除这个设备注册信息 */
            return 0;
        }
        p = p->next;
    }
    return 0;
}
void * framework_find_device(const char *name)
{
    list_t *p = obj.obj_head->next ;
    while(p != NULL)
    {
        void *dev = p->dev;
        char ** dev_name_p = (char **)dev;
        char * dev_name = *dev_name_p;
        if(strcmp(dev_name,name) == 0)
        {
            return dev;
        }
    }
    return NULL;
}



#ifdef __cplusplus
}
#endif