#ifndef XX_OSEXTENSION_DEF_H
#define XX_OSEXTENSION_DEF_H

#include "_os_common_def.h"

typedef _osal_uint8_t osal_obj_type_t;

#define OSAL_OBJ_TYPE_THREAD        RT_Object_Class_Thread
#define OSAL_OBJ_TYPE_SEMAPHORE    RT_Object_Class_Semaphore
#define OSAL_OBJ_TYPE_MUTEX        RT_Object_Class_Mutex
#define OSAL_OBJ_TYPE_EVENT        RT_Object_Class_Event
#define OSAL_OBJ_TYPE_MAILBOX      RT_Object_Class_MailBox
#define OSAL_OBJ_TYPE_MESSAGEQUEUE RT_Object_Class_MessageQueue
#define OSAL_OBJ_TYPE_MEMHEAP      RT_Object_Class_MemHeap
#define OSAL_OBJ_TYPE_MEMPOOL      RT_Object_Class_MemPool
#define OSAL_OBJ_TYPE_DEVICE       RT_Object_Class_Device
#define OSAL_OBJ_TYPE_TIMER        RT_Object_Class_Timer
#define OSAL_OBJ_TYPE_UNKNOWN      RT_Object_Class_Unknown

typedef void * osal_object_t;

#endif
