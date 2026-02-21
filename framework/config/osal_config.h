/**
 * @file    osal_config.h
 * @brief   OSAL layer configuration for RT-Thread
 * 
 * This file contains RTOS-specific configuration for the OSAL layer.
 * It defines task parameters, timing constants, and system limits.
 */

#ifndef OSAL_CONFIG_H
#define OSAL_CONFIG_H

/*------------------------------------------------------------------------------
 * Task Configuration
 *----------------------------------------------------------------------------*/

/* Default task stack size in bytes */
#define OSAL_TASK_DEFAULT_STACK_SIZE   512

/* Maximum number of tasks that can be created */
#define OSAL_MAX_TASKS                  16

/* Default task priority */
#define OSAL_TASK_DEFAULT_PRIORITY     10

/* Minimum task priority (higher number = higher priority) */
#define OSAL_TASK_MIN_PRIORITY          1

/* Maximum task priority (higher number = higher priority) */
#define OSAL_TASK_MAX_PRIORITY         31

/*------------------------------------------------------------------------------
 * Timing Configuration
 *----------------------------------------------------------------------------*/

/* System tick rate in Hz */
#define OSAL_TICK_RATE_HZ              1000

/* Milliseconds per tick */
#define OSAL_MS_PER_TICK               (1000 / OSAL_TICK_RATE_HZ)

/* Maximum timeout value in milliseconds */
#define OSAL_MAX_TIMEOUT_MS            0xFFFFFFFFU

/*------------------------------------------------------------------------------
 * Queue Configuration
 *----------------------------------------------------------------------------*/

/* Default queue length */
#define OSAL_QUEUE_DEFAULT_LENGTH      10

/* Maximum queue length */
#define OSAL_QUEUE_MAX_LENGTH          100

/* Maximum item size in bytes */
#define OSAL_QUEUE_MAX_ITEM_SIZE       256

/*------------------------------------------------------------------------------
 * Memory Configuration
 *----------------------------------------------------------------------------*/

/* Memory pool size for dynamic allocation in bytes */
#define OSAL_MEM_POOL_SIZE             (4 * 1024)  /* 4KB */

/* Memory alignment size */
#define OSAL_MEM_ALIGNMENT             8

/* Minimum allocation size */
#define OSAL_MEM_MIN_ALLOC             32

/*------------------------------------------------------------------------------
 * Timer Configuration
 *----------------------------------------------------------------------------*/

/* Maximum number of software timers */
#define OSAL_MAX_TIMERS                10

/* Timer task stack size */
#define OSAL_TIMER_TASK_STACK_SIZE     256

/* Timer task priority */
#define OSAL_TIMER_TASK_PRIORITY       5

/*------------------------------------------------------------------------------
 * Debug Configuration
 *----------------------------------------------------------------------------*/

/* Enable debug asserts */
#define OSAL_DEBUG_ENABLED             1

/* Enable task profiling */
#define OSAL_TASK_PROFILING_ENABLED    0

/* Enable memory leak detection */
#define OSAL_MEM_LEAK_DETECTION_ENABLED 0

/*------------------------------------------------------------------------------
 * RT-Thread Specific Configuration
 *----------------------------------------------------------------------------*/

/* RT-Thread kernel version (auto-detected) */
#define RT_THREAD_VERSION              "nano"

/* Use RT-Thread heap for memory management */
#define OSAL_USE_RT_THREAD_HEAP        1

/* RT-Thread thread name length */
#define RT_THREAD_NAME_MAX             16

#endif /* OSAL_CONFIG_H */