/**
 * @file    osal_port.h
 * @brief   FreeRTOS specific type mappings and configurations
 * 
 * This file maps OSAL abstract types to FreeRTOS concrete types and
 * declares low-level functions that are implemented in osal_*_ll.c files.
 */

#ifndef OSAL_PORT_H
#define OSAL_PORT_H

#ifdef __cplusplus
extern "C" {
#endif

/* Include OSAL public interface for type definitions */
#include "../../include/osal.h"

/* Include FreeRTOS headers from third_party directory */
#include "../../third_party/FreeRTOS/include/FreeRTOS.h"
#include "../../third_party/FreeRTOS/include/task.h"
#include "../../third_party/FreeRTOS/include/queue.h"
#include "../../third_party/FreeRTOS/include/semphr.h"
#include "../../third_party/FreeRTOS/include/event_groups.h"
#include "../../third_party/FreeRTOS/include/timers.h"

/*------------------------------------------------------------------------------
 * Type Mappings
 *----------------------------------------------------------------------------*/

/** Map osal_task_t to FreeRTOS task handle (actual type: TaskHandle_t) */
/* typedef TaskHandle_t osal_task_t; */ /* Defined in osal.h as void* */

/** Map osal_queue_t to FreeRTOS queue handle (actual type: QueueHandle_t) */
/* typedef QueueHandle_t osal_queue_t; */ /* Defined in osal.h as void* */

/** Map osal_sem_t to FreeRTOS semaphore handle (actual type: SemaphoreHandle_t) */
/* typedef SemaphoreHandle_t osal_sem_t; */ /* Defined in osal.h as void* */

/** Map osal_mutex_t to FreeRTOS mutex handle (actual type: SemaphoreHandle_t) */
/* typedef SemaphoreHandle_t osal_mutex_t; */ /* Defined in osal.h as void* */

/** Map osal_event_t to FreeRTOS event group handle (actual type: EventGroupHandle_t) */
/* typedef EventGroupHandle_t osal_event_t; */ /* Defined in osal.h as void* */

/** Map osal_timer_t to FreeRTOS timer handle (actual type: TimerHandle_t) */
/* typedef TimerHandle_t osal_timer_t; */ /* Defined in osal.h as void* */

/*------------------------------------------------------------------------------
 * Constant Mappings
 *----------------------------------------------------------------------------*/

/** Map OSAL_WAIT_FOREVER to FreeRTOS constant */
#define OSAL_WAIT_FOREVER       portMAX_DELAY

/** Map OSAL_NO_WAIT to FreeRTOS constant */
#define OSAL_NO_WAIT            0

/** FreeRTOS task creation flags */
#define OSAL_TASK_CREATE_FLAGS  0

/** FreeRTOS queue creation flags */
#define OSAL_QUEUE_CREATE_FLAGS 0

/** FreeRTOS semaphore creation flags */
#define OSAL_SEM_CREATE_FLAGS   0

/*------------------------------------------------------------------------------
 * Low-Level Function Declarations (implemented in osal_*_ll.c)
 *----------------------------------------------------------------------------*/

/* Task management low-level functions */
osal_task_t _osal_task_create(const char* name, void (*func)(void*), 
                              void *arg, int stack_size, int priority);
void _osal_task_delete(osal_task_t task);
void _osal_task_suspend(osal_task_t task);
void _osal_task_resume(osal_task_t task);
int _osal_task_get_priority(osal_task_t task);
void _osal_task_set_priority(osal_task_t task, int priority);
void _osal_task_delay(uint32_t ms);
void _osal_task_delay_until(uint32_t *last_wake_time, uint32_t ms);

/* Queue low-level functions */
osal_queue_t _osal_queue_create(int length, int item_size);
osal_result_t _osal_queue_delete(osal_queue_t queue);
osal_result_t _osal_queue_send(osal_queue_t queue, const void *item, 
                               uint32_t timeout_ms);
osal_result_t _osal_queue_receive(osal_queue_t queue, void *buffer, 
                                  uint32_t timeout_ms);
int _osal_queue_size(osal_queue_t queue);
int _osal_queue_space(osal_queue_t queue);

/* Semaphore low-level functions */
osal_sem_t _osal_sem_create(void);
osal_result_t _osal_sem_delete(osal_sem_t sem);
osal_result_t _osal_sem_take(osal_sem_t sem, uint32_t timeout_ms);
void _osal_sem_give(osal_sem_t sem);
int _osal_sem_get_count(osal_sem_t sem);

/* Mutex low-level functions */
osal_mutex_t _osal_mutex_create(void);
osal_result_t _osal_mutex_delete(osal_mutex_t mutex);
osal_result_t _osal_mutex_lock(osal_mutex_t mutex, uint32_t timeout_ms);
void _osal_mutex_unlock(osal_mutex_t mutex);

/* Event flag group low-level functions */
osal_event_t _osal_event_create(void);
osal_result_t _osal_event_delete(osal_event_t event);
osal_result_t _osal_event_set(osal_event_t event, uint32_t bits);
osal_result_t _osal_event_wait(osal_event_t event, uint32_t bits, 
                               osal_event_wait_type_t wait_type, 
                               uint32_t timeout_ms);
uint32_t _osal_event_get(osal_event_t event);

/* Timer low-level functions */
osal_timer_t _osal_timer_create(void (*callback)(void*), void *arg,
                                uint32_t period_ms, bool periodic);
osal_result_t _osal_timer_delete(osal_timer_t timer);
void _osal_timer_start(osal_timer_t timer);
void _osal_timer_stop(osal_timer_t timer);
uint32_t _osal_timer_get_remaining(osal_timer_t timer);

/* Memory management low-level functions */
void *_osal_malloc(size_t size);
void _osal_free(void *ptr);
void *_osal_calloc(size_t nmemb, size_t size);
void *_osal_realloc(void *ptr, size_t size);
osal_result_t _osal_mem_init(void);

/* System service low-level functions */
uint32_t _osal_get_system_time(void);
uint32_t _osal_get_system_tick(void);
uint32_t _osal_get_tick_rate(void);
void _osal_system_reset(void);
void _osal_enter_critical(void);
void _osal_exit_critical(void);

/* OSAL initialization */
osal_result_t _osal_init(void);
void _osal_start_scheduler(void);

/*------------------------------------------------------------------------------
 * FreeRTOS Version Information
 *----------------------------------------------------------------------------*/

/* FreeRTOS version macros (example) */
#define FREERTOS_MAJOR_VERSION  10
#define FREERTOS_MINOR_VERSION  0
#define FREERTOS_PATCH_VERSION  1

#ifdef __cplusplus
}
#endif

#endif /* OSAL_PORT_H */