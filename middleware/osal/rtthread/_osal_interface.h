#ifndef _OSAL_INTERFACE_H
#define _OSAL_INTERFACE_H

#include "_os_common_def.h"

#ifdef __cplusplus
extern "C" {
#endif

/*------------------------------------------------------------------------------
 * Task Management Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_task_init(_osal_task_t thread,
                            const char *name,
                            void (*entry)(void *parameter),
                            void *parameter,
                            void *stack_start,
                            _osal_uint32_t stack_size,
                            _osal_uint8_t priority,
                            _osal_uint32_t tick);

_osal_err_t _osal_task_detach(_osal_task_t thread);

_osal_task_t _osal_task_create(const char *name,
                               void (*entry)(void *parameter),
                               void *parameter,
                               _osal_uint32_t stack_size,
                               _osal_uint8_t priority,
                               _osal_uint32_t tick);

_osal_err_t _osal_task_delete(_osal_task_t thread);

_osal_task_t _osal_task_self(void);

_osal_task_t _osal_task_find(const char *name);

_osal_err_t _osal_task_startup(_osal_task_t thread);

_osal_err_t _osal_task_yield(void);

_osal_err_t _osal_task_delay(_osal_tick_t tick);

_osal_err_t _osal_task_mdelay(_osal_int32_t ms);

_osal_err_t _osal_task_suspend(_osal_task_t thread);

_osal_err_t _osal_task_resume(_osal_task_t thread);

_osal_err_t _osal_task_control(_osal_task_t thread, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Semaphore Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_sem_init(_osal_semaphore_t sem,
                            const char *name,
                            _osal_uint32_t value,
                            _osal_uint8_t flag);

_osal_err_t _osal_sem_detach(_osal_semaphore_t sem);

_osal_semaphore_t _osal_sem_create(const char *name,
                                   _osal_uint32_t value,
                                   _osal_uint8_t flag);

_osal_err_t _osal_sem_delete(_osal_semaphore_t sem);

_osal_err_t _osal_sem_take(_osal_semaphore_t sem, _osal_int32_t timeout);

_osal_err_t _osal_sem_trytake(_osal_semaphore_t sem);

_osal_err_t _osal_sem_release(_osal_semaphore_t sem);

_osal_err_t _osal_sem_control(_osal_semaphore_t sem, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Mutex Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_mutex_init(_osal_mutex_t mutex,
                              const char *name,
                              _osal_uint8_t flag);

_osal_err_t _osal_mutex_detach(_osal_mutex_t mutex);

_osal_mutex_t _osal_mutex_create(const char *name, _osal_uint8_t flag);

_osal_err_t _osal_mutex_delete(_osal_mutex_t mutex);

_osal_err_t _osal_mutex_take(_osal_mutex_t mutex, _osal_int32_t timeout);

_osal_err_t _osal_mutex_trytake(_osal_mutex_t mutex);

_osal_err_t _osal_mutex_release(_osal_mutex_t mutex);

_osal_err_t _osal_mutex_control(_osal_mutex_t mutex, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Event Flag Group Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_event_init(_osal_event_t event,
                              const char *name,
                              _osal_uint8_t flag);

_osal_err_t _osal_event_detach(_osal_event_t event);

_osal_event_t _osal_event_create(const char *name, _osal_uint8_t flag);

_osal_err_t _osal_event_delete(_osal_event_t event);

_osal_err_t _osal_event_send(_osal_event_t event, _osal_uint32_t set);

_osal_err_t _osal_event_recv(_osal_event_t event,
                              _osal_uint32_t set,
                              _osal_uint8_t opt,
                              _osal_int32_t timeout,
                              _osal_uint32_t *recved);

_osal_err_t _osal_event_control(_osal_event_t event, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Mailbox Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_mb_init(_osal_mb_t mb,
                           const char *name,
                           void *msgpool,
                           _osal_size_t size,
                           _osal_uint8_t flag);

_osal_err_t _osal_mb_detach(_osal_mb_t mb);

_osal_mb_t _osal_mb_create(const char *name, _osal_size_t size, _osal_uint8_t flag);

_osal_err_t _osal_mb_delete(_osal_mb_t mb);

_osal_err_t _osal_mb_send(_osal_mb_t mb, _osal_ubase_t value);

_osal_err_t _osal_mb_send_wait(_osal_mb_t mb,
                                _osal_ubase_t value,
                                _osal_int32_t timeout);

_osal_err_t _osal_mb_urgent(_osal_mb_t mb, _osal_ubase_t value);

_osal_err_t _osal_mb_recv(_osal_mb_t mb,
                           _osal_ubase_t *value,
                           _osal_int32_t timeout);

_osal_err_t _osal_mb_control(_osal_mb_t mb, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Message Queue Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_mq_init(_osal_mq_t mq,
                           const char *name,
                           void *msgpool,
                           _osal_size_t msg_size,
                           _osal_size_t pool_size,
                           _osal_uint8_t flag);

_osal_err_t _osal_mq_detach(_osal_mq_t mq);

_osal_mq_t _osal_mq_create(const char *name,
                            _osal_size_t msg_size,
                            _osal_size_t max_msgs,
                            _osal_uint8_t flag);

_osal_err_t _osal_mq_delete(_osal_mq_t mq);

_osal_err_t _osal_mq_send(_osal_mq_t mq, const void *buffer, _osal_size_t size);

_osal_err_t _osal_mq_send_wait(_osal_mq_t mq,
                               const void *buffer,
                               _osal_size_t size,
                               _osal_int32_t timeout);

_osal_err_t _osal_mq_urgent(_osal_mq_t mq, const void *buffer, _osal_size_t size);

_osal_err_t _osal_mq_recv(_osal_mq_t mq,
                           void *buffer,
                           _osal_size_t size,
                           _osal_int32_t timeout);

_osal_err_t _osal_mq_control(_osal_mq_t mq, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Software Timer Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_timer_init(_osal_timer_t timer,
                              const char *name,
                              void (*timeout)(void *parameter),
                              void *parameter,
                              _osal_tick_t time,
                              _osal_uint8_t flag);

_osal_err_t _osal_timer_detach(_osal_timer_t timer);

_osal_timer_t _osal_timer_create(const char *name,
                                 void (*timeout)(void *parameter),
                                 void *parameter,
                                 _osal_tick_t time,
                                 _osal_uint8_t flag);

_osal_err_t _osal_timer_delete(_osal_timer_t timer);

_osal_err_t _osal_timer_start(_osal_timer_t timer);

_osal_err_t _osal_timer_stop(_osal_timer_t timer);

_osal_err_t _osal_timer_control(_osal_timer_t timer, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Memory Management Functions
 *----------------------------------------------------------------------------*/
void _osal_heap_init(void *begin_addr, void *end_addr);

void *_osal_malloc(_osal_size_t nbytes);

void _osal_free(void *ptr);

void *_osal_realloc(void *ptr, _osal_size_t nbytes);

void *_osal_calloc(_osal_size_t count, _osal_size_t size);

/*------------------------------------------------------------------------------
 * Memory Pool Functions
 *----------------------------------------------------------------------------*/
_osal_err_t _osal_mp_init(_osal_mp_t mp,
                           const char *name,
                           void *start,
                           _osal_size_t size,
                           _osal_size_t block_size);

_osal_err_t _osal_mp_detach(_osal_mp_t mp);

_osal_mp_t _osal_mp_create(const char *name,
                           _osal_size_t block_count,
                           _osal_size_t block_size);

_osal_err_t _osal_mp_delete(_osal_mp_t mp);

void *_osal_mp_alloc(_osal_mp_t mp, _osal_int32_t time);

void _osal_mp_free(void *block);

/*------------------------------------------------------------------------------
 * System Service Functions
 *----------------------------------------------------------------------------*/
_osal_tick_t _osal_tick_get(void);

_osal_tick_t _osal_tick_from_millisecond(_osal_int32_t ms);

void _osal_enter_critical(void);

void _osal_exit_critical(void);

_osal_base_t _osal_critical_level(void);
_osal_object_t _osal_object_find(const char *name, _osal_uint8_t type);
void osal_register_callback_ll(void (*callback)(void));
void (*osal_get_need_register_to_systemtick_hander_callback_ll(void))(void);

#ifdef __cplusplus
}
#endif

#endif
