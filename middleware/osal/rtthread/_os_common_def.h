#ifndef _OS_COMMON_DEF_H
#define _OS_COMMON_DEF_H

#include "rtthread.h"

/*------------------------------------------------------------------------------
 * Base Type Definitions
 *----------------------------------------------------------------------------*/
typedef rt_uint32_t _osal_uint32_t;
typedef rt_uint8_t  _osal_uint8_t;
typedef rt_uint16_t _osal_uint16_t;
typedef rt_int32_t  _osal_int32_t;
typedef rt_base_t   _osal_base_t;
typedef rt_err_t    _osal_err_t;
typedef rt_tick_t   _osal_tick_t;
typedef rt_size_t   _osal_size_t;
typedef rt_ubase_t  _osal_ubase_t;
typedef rt_bool_t   _osal_bool_t;


#define _OSAL_EOK                          RT_EOK               /**< There is no error */
#define _OSAL_ERROR                        RT_ERROR               /**< A generic error happens */
#define _OSAL_ETIMEOUT                     RT_ETIMEOUT               /**< Timed out */
#define _OSAL_EFULL                        RT_EFULL               /**< The resource is full */
#define _OSAL_EEMPTY                       RT_EEMPTY               /**< The resource is empty */
#define _OSAL_ENOMEM                       RT_ENOMEM               /**< No memory */
#define _OSAL_ENOSYS                       RT_ENOSYS               /**< No system */
#define _OSAL_EBUSY                        RT_EBUSY               /**< Busy */
#define _OSAL_EIO                          RT_EIO               /**< IO error */
#define _OSAL_EINTR                        RT_EINTR               /**< Interrupted system call */
#define _OSAL_EINVAL                       RT_EINVAL              /**< Invalid argument */


/*------------------------------------------------------------------------------
 * Task Management Types
 *----------------------------------------------------------------------------*/
typedef struct rt_thread _osal_task;
typedef struct rt_thread * _osal_task_t;


/*------------------------------------------------------------------------------
 * Semaphore Types
 *----------------------------------------------------------------------------*/
typedef struct rt_semaphore _osal_semaphore;
typedef struct rt_semaphore * _osal_semaphore_t;


/*------------------------------------------------------------------------------
 * Mutex Types
 *----------------------------------------------------------------------------*/
typedef struct rt_mutex _osal_mutex;
typedef struct rt_mutex * _osal_mutex_t;

/*------------------------------------------------------------------------------
 * Event Flag Group Types
 *----------------------------------------------------------------------------*/
typedef struct rt_event _osal_event;
typedef struct rt_event * _osal_event_t;

/*------------------------------------------------------------------------------
 * Mailbox Types
 *----------------------------------------------------------------------------*/
typedef struct rt_mailbox _osal_mb;
typedef struct rt_mailbox * _osal_mb_t;


/*------------------------------------------------------------------------------
 * Message Queue Types
 *----------------------------------------------------------------------------*/
typedef struct rt_messagequeue _osal_mq;
typedef struct rt_messagequeue * _osal_mq_t;

/*------------------------------------------------------------------------------
 * Timer Types
 *----------------------------------------------------------------------------*/
typedef struct rt_timer _osal_timer;
typedef struct rt_timer * _osal_timer_t;


/*------------------------------------------------------------------------------
 * Memory Pool Types
 *----------------------------------------------------------------------------*/
typedef struct rt_mempool _osal_mp;
typedef struct rt_mempool * _osal_mp_t;

/*------------------------------------------------------------------------------
 * Object Find Types
 *----------------------------------------------------------------------------*/
typedef struct rt_object _osal_object;
typedef struct rt_object * _osal_object_t;

/*------------------------------------------------------------------------------
 * Memory Management Types
 *----------------------------------------------------------------------------*/
typedef void* _osal_mem_t;

#endif /* _OS_COMMON_DEF_H */
