#ifndef OSAL_H
#define OSAL_H

#include "osal_common_def.h"
#include "_osal_interface.h"

#ifdef __cplusplus
extern "C" {
#endif

/*------------------------------------------------------------------------------
 * Task Management Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_task_init(osal_task_t thread,
                          const char *name,
                          void (*entry)(void *parameter),
                          void *parameter,
                          void *stack_start,
                          osal_uint32_t stack_size,
                          osal_uint8_t priority,
                          osal_uint32_t tick);

osal_err_t osal_task_detach(osal_task_t thread);

osal_task_t osal_task_create(const char *name,
                              void (*entry)(void *parameter),
                              void *parameter,
                              osal_uint32_t stack_size,
                              osal_uint8_t priority,
                              osal_uint32_t tick);

osal_err_t osal_task_delete(osal_task_t thread);

osal_task_t osal_task_self(void);

osal_task_t osal_task_find(const char *name);

osal_err_t osal_task_startup(osal_task_t thread);

osal_err_t osal_task_yield(void);

osal_err_t osal_task_delay(osal_tick_t tick);

osal_err_t osal_task_mdelay(osal_int32_t ms);

osal_err_t osal_task_suspend(osal_task_t thread);

osal_err_t osal_task_resume(osal_task_t thread);

osal_err_t osal_task_control(osal_task_t thread, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Semaphore Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_sem_init(osal_semaphore_t sem,
                         const char *name,
                         osal_uint32_t value,
                         osal_uint8_t flag);

osal_err_t osal_sem_detach(osal_semaphore_t sem);

osal_semaphore_t osal_sem_create(const char *name,
                                 osal_uint32_t value,
                                 osal_uint8_t flag);

osal_err_t osal_sem_delete(osal_semaphore_t sem);

osal_err_t osal_sem_take(osal_semaphore_t sem, osal_int32_t timeout);

osal_err_t osal_sem_trytake(osal_semaphore_t sem);

osal_err_t osal_sem_release(osal_semaphore_t sem);

osal_err_t osal_sem_control(osal_semaphore_t sem, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Mutex Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_mutex_init(osal_mutex_t mutex,
                           const char *name,
                           osal_uint8_t flag);

osal_err_t osal_mutex_detach(osal_mutex_t mutex);

osal_mutex_t osal_mutex_create(const char *name, osal_uint8_t flag);

osal_err_t osal_mutex_delete(osal_mutex_t mutex);

osal_err_t osal_mutex_take(osal_mutex_t mutex, osal_int32_t timeout);

osal_err_t osal_mutex_trytake(osal_mutex_t mutex);

osal_err_t osal_mutex_release(osal_mutex_t mutex);

osal_err_t osal_mutex_control(osal_mutex_t mutex, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Event Flag Group Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_event_init(osal_event_t event,
                           const char *name,
                           osal_uint8_t flag);

osal_err_t osal_event_detach(osal_event_t event);

osal_event_t osal_event_create(const char *name, osal_uint8_t flag);

osal_err_t osal_event_delete(osal_event_t event);

osal_err_t osal_event_send(osal_event_t event, osal_uint32_t set);

osal_err_t osal_event_recv(osal_event_t event,
                           osal_uint32_t set,
                           osal_uint8_t opt,
                           osal_int32_t timeout,
                           osal_uint32_t *recved);

osal_err_t osal_event_control(osal_event_t event, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Mailbox Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_mb_init(osal_mb_t mb,
                        const char *name,
                        void *msgpool,
                        osal_size_t size,
                        osal_uint8_t flag);

osal_err_t osal_mb_detach(osal_mb_t mb);

osal_mb_t osal_mb_create(const char *name, osal_size_t size, osal_uint8_t flag);

osal_err_t osal_mb_delete(osal_mb_t mb);

osal_err_t osal_mb_send(osal_mb_t mb, osal_ubase_t value);

osal_err_t osal_mb_send_wait(osal_mb_t mb,
                              osal_ubase_t value,
                              osal_int32_t timeout);

osal_err_t osal_mb_urgent(osal_mb_t mb, osal_ubase_t value);

osal_err_t osal_mb_recv(osal_mb_t mb,
                        osal_ubase_t *value,
                        osal_int32_t timeout);

osal_err_t osal_mb_control(osal_mb_t mb, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Message Queue Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_mq_init(osal_mq_t mq,
                        const char *name,
                        void *msgpool,
                        osal_size_t msg_size,
                        osal_size_t pool_size,
                        osal_uint8_t flag);

osal_err_t osal_mq_detach(osal_mq_t mq);

osal_mq_t osal_mq_create(const char *name,
                         osal_size_t msg_size,
                         osal_size_t max_msgs,
                         osal_uint8_t flag);

osal_err_t osal_mq_delete(osal_mq_t mq);

osal_err_t osal_mq_send(osal_mq_t mq, const void *buffer, osal_size_t size);

osal_err_t osal_mq_send_wait(osal_mq_t mq,
                             const void *buffer,
                             osal_size_t size,
                             osal_int32_t timeout);

osal_err_t osal_mq_urgent(osal_mq_t mq, const void *buffer, osal_size_t size);

osal_err_t osal_mq_recv(osal_mq_t mq,
                         void *buffer,
                         osal_size_t size,
                         osal_int32_t timeout);

osal_err_t osal_mq_control(osal_mq_t mq, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Software Timer Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_timer_init(osal_timer_t timer,
                           const char *name,
                           void (*timeout)(void *parameter),
                           void *parameter,
                           osal_tick_t time,
                           osal_uint8_t flag);

osal_err_t osal_timer_detach(osal_timer_t timer);

osal_timer_t osal_timer_create(const char *name,
                               void (*timeout)(void *parameter),
                               void *parameter,
                               osal_tick_t time,
                               osal_uint8_t flag);

osal_err_t osal_timer_delete(osal_timer_t timer);

osal_err_t osal_timer_start(osal_timer_t timer);

osal_err_t osal_timer_stop(osal_timer_t timer);

osal_err_t osal_timer_control(osal_timer_t timer, int cmd, void *arg);

/*------------------------------------------------------------------------------
 * Memory Management Functions
 *----------------------------------------------------------------------------*/
void osal_heap_init(void *begin_addr, void *end_addr);

void *osal_malloc(osal_size_t nbytes);

void osal_free(void *ptr);

void *osal_realloc(void *ptr, osal_size_t nbytes);

void *osal_calloc(osal_size_t count, osal_size_t size);

/*------------------------------------------------------------------------------
 * Memory Pool Functions
 *----------------------------------------------------------------------------*/
osal_err_t osal_mp_init(osal_mp_t mp,
                        const char *name,
                        void *start,
                        osal_size_t size,
                        osal_size_t block_size);

osal_err_t osal_mp_detach(osal_mp_t mp);

osal_mp_t osal_mp_create(const char *name,
                         osal_size_t block_count,
                         osal_size_t block_size);

osal_err_t osal_mp_delete(osal_mp_t mp);

void *osal_mp_alloc(osal_mp_t mp, osal_int32_t time);

void osal_mp_free(void *block);

/*------------------------------------------------------------------------------
 * System Service Functions
 *----------------------------------------------------------------------------*/
osal_tick_t osal_tick_get(void);

osal_tick_t osal_tick_from_millisecond(osal_int32_t ms);

void osal_enter_critical(void);

void osal_exit_critical(void);

osal_base_t osal_critical_level(void);


void (*osal_system_get_systemtick_handler_callback(void))(void);
    
void osal_register_callback(void (*callback)(void));

#ifdef __cplusplus
}
#endif

#endif
