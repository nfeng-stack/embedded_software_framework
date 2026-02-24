#ifndef  FRAMEWORK_RIGISTER_DEVICE_H
#define  FRAMEWORK_RIGISTER_DEVICE_H

#ifdef __cplusplus
extern "C"
{
#endif



typedef struct list
{
    struct  list *next;
    void *dev;  
}list_t;

typedef struct framework_obj
{
    uint32_t obj_num;
    list_t *obj_tail;
    list_t *obj_head;
}framework_obj_t;




int32_t framework_register_device(const void *device);
int32_t framework_unregister_device(const void *device);
void * framework_find_device(const char *name);



#ifdef __cplusplus
}
#endif
#endif