#include "_osal_interface.h"
#include "rtthread.h"

_osal_object_t _osal_object_find(const char *name, _osal_uint8_t type)
{
    return (_osal_object_t)rt_object_find(name, type);
}
