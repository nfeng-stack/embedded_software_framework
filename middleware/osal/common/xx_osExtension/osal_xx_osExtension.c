#include "xx_osExtension_interface.h"

osal_object_t osal_object_find(const char *name, osal_obj_type_t type)
{
    return (osal_object_t)_osal_object_find(name, (_osal_uint8_t)type);
}
