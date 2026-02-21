/**
 * @file    osal_common.h
 * @brief   OSAL common layer internal definitions
 * 
 * This file contains internal definitions and declarations for the OSAL common layer.
 * It is included by OSAL common implementation files and RTOS-specific headers.
 */

#ifndef OSAL_COMMON_H
#define OSAL_COMMON_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

/* Includes OSAL selection */
#include "platform_select.h"

/* Include OSAL public interface */
#include "../../include/osal.h"

/*------------------------------------------------------------------------------
 * RTOS-Specific Includes
 *----------------------------------------------------------------------------*/

#if defined(OSAL_RTOS_RTTHREAD) && OSAL_RTOS_RTTHREAD
#include "../rtthread/osal_port.h"
#elif defined(OSAL_RTOS_FREERTOS) && OSAL_RTOS_FREERTOS
#include "../freertos/osal_port.h"
#else
#error "No valid RTOS selected in platform_select.h"
#endif

/*------------------------------------------------------------------------------
 * Common Macros and Utilities
 *----------------------------------------------------------------------------*/

/** Convert milliseconds to ticks */
#define MS_TO_TICKS(ms)         ((ms) / OSAL_MS_PER_TICK)

/** Convert ticks to milliseconds */
#define TICKS_TO_MS(ticks)      ((ticks) * OSAL_MS_PER_TICK)

/** Maximum timeout value in ticks */
#define OSAL_MAX_TIMEOUT_TICKS  MS_TO_TICKS(OSAL_MAX_TIMEOUT_MS)



/** Validate task handle */
#define OSAL_TASK_IS_VALID(task) ((task) != NULL)

/** Validate queue handle */
#define OSAL_QUEUE_IS_VALID(queue) ((queue) != NULL)

/** Validate semaphore handle */
#define OSAL_SEM_IS_VALID(sem)  ((sem) != NULL)

/** Validate mutex handle */
#define OSAL_MUTEX_IS_VALID(mutex) ((mutex) != NULL)

/** Validate event group handle */
#define OSAL_EVENT_IS_VALID(event) ((event) != NULL)

/** Validate timer handle */
#define OSAL_TIMER_IS_VALID(timer) ((timer) != NULL)

/*------------------------------------------------------------------------------
 * Error Checking Macros
 *----------------------------------------------------------------------------*/

#ifdef OSAL_DEBUG_ENABLED
#define OSAL_ASSERT(expr) \
    do { \
        if (!(expr)) { \
            osal_assert_failed(__FILE__, __LINE__); \
        } \
    } while(0)
#else
#define OSAL_ASSERT(expr) ((void)0)
#endif

#define OSAL_CHECK_PARAM(expr) \
    do { \
        if (!(expr)) { \
            return; \
        } \
    } while(0)

#define OSAL_CHECK_PARAM_RET(expr, ret) \
    do { \
        if (!(expr)) { \
            return (ret); \
        } \
    } while(0)

#define OSAL_CHECK_PARAM_RET_NULL(expr) \
    do { \
        if (!(expr)) { \
            return NULL; \
        } \
    } while(0)

/*------------------------------------------------------------------------------
 * Internal Function Declarations
 *----------------------------------------------------------------------------*/

#ifdef OSAL_DEBUG_ENABLED
/**
 * @brief Assertion failure handler
 * @param file  Source file name where assert failed
 * @param line  Line number where assert failed
 */
void osal_assert_failed(const char* file, uint32_t line);
#endif

/**
 * @brief Convert OSAL result to string
 * @param result OSAL result code
 * @return      Result string
 */
const char* osal_result_to_string(osal_result_t result);

/**
 * @brief Get OSAL version string
 * @return Version string
 */
const char* osal_get_version(void);

/**
 * @brief Get RTOS name
 * @return RTOS name string
 */
const char* osal_get_rtos_name(void);

#ifdef __cplusplus
}
#endif

#endif /* OSAL_COMMON_H */