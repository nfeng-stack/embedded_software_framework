/**
 * @file    osal.h
 * @brief   Operating System Abstraction Layer (OSAL) public interface
 *
 * This file defines the operating system abstraction layer interface for embedded systems.
 * It provides a RTOS-independent API for task management, inter-process communication,
 * synchronization, timing, and memory management. Application code should only include this header.
 *
 * @note    This is the public interface - implementations are in osal/common and osal/<rtos>
 */

#ifndef OSAL_H
#define OSAL_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdarg.h>

/* Includes OSAL configuration */
#include "../framework/config/osal_config.h"

    /*------------------------------------------------------------------------------
     * Common Type Definitions
     *----------------------------------------------------------------------------*/

    /** Task handle (opaque type) */
    typedef void *osal_task_t;

    /** Queue handle (opaque type) */
    typedef void *osal_queue_t;

    /** Semaphore handle (opaque type) */
    typedef void *osal_sem_t;

    /** Mutex handle (opaque type) */
    typedef void *osal_mutex_t;

    /** Event flag group handle (opaque type) */
    typedef void *osal_event_t;

    /** Software timer handle (opaque type) */
    typedef void *osal_timer_t;

    /** Function pointer type for task entry functions */
    typedef void (*osal_task_func_t)(void *arg);

    /** Function pointer type for timer callback functions */
    typedef void (*osal_timer_callback_t)(void *arg);

    /** Event wait type for event flag groups */
    typedef enum
    {
        OSAL_EVENT_WAIT_ANY = 0, /**< Wait for any of the specified bits */
        OSAL_EVENT_WAIT_ALL      /**< Wait for all of the specified bits */
    } osal_event_wait_type_t;

    /** Return code type */
    typedef int osal_result_t;

/** Common return codes */
#define OSAL_OK 0             /**< Operation successful */
#define OSAL_ERROR -1         /**< General error */
#define OSAL_TIMEOUT -2       /**< Operation timeout */
#define OSAL_INVALID_PARAM -3 /**< Invalid parameter */
#define OSAL_NO_MEMORY -4     /**< Insufficient memory */
#define OSAL_NOT_SUPPORTED -5 /**< Feature not supported */

/** Special timeout values */
#define OSAL_WAIT_FOREVER 0xFFFFFFFFU /**< Wait indefinitely */
#define OSAL_NO_WAIT 0                /**< Do not wait */

    /*------------------------------------------------------------------------------
     * Task Management Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Create a new task
     * @param name          Task name (for debugging)
     * @param func          Task entry function
     * @param arg           Argument passed to task function
     * @param stack_size    Stack size in bytes
     * @param priority      Task priority (higher number = higher priority)
     * @return              Task handle, or NULL on failure
     */
    osal_task_t osal_task_create(const char *name, osal_task_func_t func,
                                 void *arg, int stack_size, int priority);

    /**
     * @brief Delete a task
     * @param task          Task handle to delete
     */
    void osal_task_delete(osal_task_t task);

    /**
     * @brief Suspend a task
     * @param task          Task handle to suspend
     */
    void osal_task_suspend(osal_task_t task);

    /**
     * @brief Resume a suspended task
     * @param task          Task handle to resume
     */
    void osal_task_resume(osal_task_t task);

    /**
     * @brief Get task priority
     * @param task          Task handle
     * @return              Current priority of the task, or negative error code
     */
    int osal_task_get_priority(osal_task_t task);

    /**
     * @brief Set task priority
     * @param task          Task handle
     * @param priority      New priority for the task
     */
    void osal_task_set_priority(osal_task_t task, int priority);

    /**
     * @brief Delay task execution
     * @param ms            Delay time in milliseconds
     */
    void osal_task_delay(uint32_t ms);

    /**
     * @brief Delay task execution until specified time
     * @param last_wake_time Pointer to variable storing last wake time
     * @param ms            Period in milliseconds
     * @note                This function maintains fixed period execution and
     *                      compensates for drift
     */
    void osal_task_delay_until(uint32_t *last_wake_time, uint32_t ms);

    /*------------------------------------------------------------------------------
     * Queue Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Create a queue
     * @param length        Maximum number of items in the queue
     * @param item_size     Size of each item in bytes
     * @return              Queue handle, or NULL on failure
     */
    osal_queue_t osal_queue_create(int length, int item_size);

    /**
     * @brief Delete a queue
     * @param queue         Queue handle to delete
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_queue_delete(osal_queue_t queue);

    /**
     * @brief Send an item to a queue
     * @param queue         Queue handle
     * @param item          Pointer to item to send
     * @param timeout_ms    Timeout in milliseconds (OSAL_WAIT_FOREVER or OSAL_NO_WAIT)
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_queue_send(osal_queue_t queue, const void *item,
                                  uint32_t timeout_ms);

    /**
     * @brief Receive an item from a queue
     * @param queue         Queue handle
     * @param buffer        Pointer to buffer to receive item
     * @param timeout_ms    Timeout in milliseconds (OSAL_WAIT_FOREVER or OSAL_NO_WAIT)
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_queue_receive(osal_queue_t queue, void *buffer,
                                     uint32_t timeout_ms);

    /**
     * @brief Get number of items currently in the queue
     * @param queue         Queue handle
     * @return              Number of items in queue, or negative error code
     */
    int osal_queue_size(osal_queue_t queue);

    /**
     * @brief Get number of free spaces in the queue
     * @param queue         Queue handle
     * @return              Number of free spaces, or negative error code
     */
    int osal_queue_space(osal_queue_t queue);

    /*------------------------------------------------------------------------------
     * Semaphore Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Create a binary semaphore
     * @return              Semaphore handle, or NULL on failure
     */
    osal_sem_t osal_sem_create(void);

    /**
     * @brief Delete a semaphore
     * @param sem           Semaphore handle to delete
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_sem_delete(osal_sem_t sem);

    /**
     * @brief Take (acquire) a semaphore
     * @param sem           Semaphore handle
     * @param timeout_ms    Timeout in milliseconds (OSAL_WAIT_FOREVER or OSAL_NO_WAIT)
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_sem_take(osal_sem_t sem, uint32_t timeout_ms);

    /**
     * @brief Give (release) a semaphore
     * @param sem           Semaphore handle
     */
    void osal_sem_give(osal_sem_t sem);

    /**
     * @brief Get current semaphore count
     * @param sem           Semaphore handle
     * @return              Current count, or negative error code
     */
    int osal_sem_get_count(osal_sem_t sem);

    /*------------------------------------------------------------------------------
     * Mutex Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Create a mutex
     * @return              Mutex handle, or NULL on failure
     */
    osal_mutex_t osal_mutex_create(void);

    /**
     * @brief Delete a mutex
     * @param mutex         Mutex handle to delete
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_mutex_delete(osal_mutex_t mutex);

    /**
     * @brief Lock a mutex
     * @param mutex         Mutex handle
     * @param timeout_ms    Timeout in milliseconds (OSAL_WAIT_FOREVER or OSAL_NO_WAIT)
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_mutex_lock(osal_mutex_t mutex, uint32_t timeout_ms);

    /**
     * @brief Unlock a mutex
     * @param mutex         Mutex handle
     */
    void osal_mutex_unlock(osal_mutex_t mutex);

    /*------------------------------------------------------------------------------
     * Event Flag Group Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Create an event flag group
     * @return              Event group handle, or NULL on failure
     */
    osal_event_t osal_event_create(void);

    /**
     * @brief Delete an event flag group
     * @param event         Event group handle to delete
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_event_delete(osal_event_t event);

    /**
     * @brief Set bits in an event flag group
     * @param event         Event group handle
     * @param bits          Bits to set (bitmask)
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_event_set(osal_event_t event, uint32_t bits);

    /**
     * @brief Wait for bits in an event flag group
     * @param event         Event group handle
     * @param bits          Bits to wait for (bitmask)
     * @param wait_type     Wait type (OSAL_EVENT_WAIT_ANY or OSAL_EVENT_WAIT_ALL)
     * @param timeout_ms    Timeout in milliseconds (OSAL_WAIT_FOREVER or OSAL_NO_WAIT)
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_event_wait(osal_event_t event, uint32_t bits,
                                  osal_event_wait_type_t wait_type,
                                  uint32_t timeout_ms);

    /**
     * @brief Get current bits in an event flag group
     * @param event         Event group handle
     * @return              Current event bits
     */
    uint32_t osal_event_get(osal_event_t event);

    /*------------------------------------------------------------------------------
     * Software Timer Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Create a software timer
     * @param callback      Timer callback function
     * @param arg           Argument passed to callback function
     * @param period_ms     Timer period in milliseconds
     * @param periodic      true for periodic timer, false for one-shot
     * @return              Timer handle, or NULL on failure
     */
    osal_timer_t osal_timer_create(osal_timer_callback_t callback, void *arg,
                                   uint32_t period_ms, bool periodic);

    /**
     * @brief Delete a software timer
     * @param timer         Timer handle to delete
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_timer_delete(osal_timer_t timer);

    /**
     * @brief Start a software timer
     * @param timer         Timer handle to start
     */
    void osal_timer_start(osal_timer_t timer);

    /**
     * @brief Stop a software timer
     * @param timer         Timer handle to stop
     */
    void osal_timer_stop(osal_timer_t timer);

    /**
     * @brief Get remaining time until timer expiration
     * @param timer         Timer handle
     * @return              Remaining time in milliseconds
     */
    uint32_t osal_timer_get_remaining(osal_timer_t timer);

    /*------------------------------------------------------------------------------
     * Memory Management Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Allocate dynamic memory
     * @param size          Number of bytes to allocate
     * @return              Pointer to allocated memory, or NULL on failure
     */
    void *osal_malloc(size_t size);

    /**
     * @brief Free dynamic memory
     * @param ptr           Pointer to memory block to free
     */
    void osal_free(void *ptr);

    /**
     * @brief Allocate and zero-initialize dynamic memory
     * @param nmemb         Number of elements to allocate
     * @param size          Size of each element in bytes
     * @return              Pointer to allocated memory, or NULL on failure
     */
    void *osal_calloc(size_t nmemb, size_t size);

    /**
     * @brief Reallocate dynamic memory
     * @param ptr           Pointer to previously allocated memory block
     * @param size          New size in bytes
     * @return              Pointer to reallocated memory, or NULL on failure
     */
    void *osal_realloc(void *ptr, size_t size);

    /**
     * @brief Initialize memory management system
     * @return              OSAL_OK on success, or error code
     */
    osal_result_t osal_mem_init(void);

    /*------------------------------------------------------------------------------
     * System Service Functions
     *----------------------------------------------------------------------------*/

    /**
     * @brief Get system time in milliseconds
     * @return              System time in milliseconds since startup
     */
    uint32_t osal_get_system_time(void);

    /**
     * @brief Get system tick count
     * @return              System tick count (incremented at OSAL_TICK_RATE_HZ)
     */
    uint32_t osal_get_system_tick(void);

    /**
     * @brief Get system tick rate (ticks per second)
     * @return              System tick rate in Hz
     */
    uint32_t osal_get_tick_rate(void);

    /**
     * @brief Perform system reset
     * @note                This function does not return
     */
    void osal_system_reset(void);

    /**
     * @brief Enter critical section
     * @note                Disables interrupts/scheduler
     */
    void osal_enter_critical(void);

    /**
     * @brief Exit critical section
     * @note                Re-enables interrupts/scheduler
     */
    void osal_exit_critical(void);

    /**
     * @brief Initialize OSAL layer
     * @return              OSAL_OK on success, or error code
     * @note                Must be called before using any other OSAL function
     */
    osal_result_t osal_init(void);

    /**
     * @brief Start the scheduler
     * @note                This function does not return on success
     */
    void osal_start_scheduler(void);

    void (*osal_system_get_systemtick_handler_callback(void))(void);
    void osal_register_callback(void (*callback)(void));

#ifdef __cplusplus
}
#endif

#endif /* OSAL_H */