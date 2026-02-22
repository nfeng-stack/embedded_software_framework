#ifndef XX_OSEXTENSION_INTERFACE_H
#define XX_OSEXTENSION_INTERFACE_H

#include "xx_osExtension_def.h"
#include "../../rt_thread/_osal_interface.h"

#ifdef __cplusplus
extern "C" {
#endif

osal_object_t osal_object_find(const char *name, osal_obj_type_t type);

#ifdef __cplusplus
}
#endif

#endif
