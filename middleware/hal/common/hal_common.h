/**
 * @file    hal_common.h
 * @brief   HAL common layer internal definitions
 *
 * This file contains internal definitions and declarations for the HAL common layer.
 * It is included by HAL common implementation files and platform-specific headers.
 */

#ifndef HAL_COMMON_H
#define HAL_COMMON_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stdbool.h>

/* Includes platform selection */
#include "platform_select.h"

    /*------------------------------------------------------------------------------
     * Platform-Specific Includes
     *----------------------------------------------------------------------------*/

#if defined(HAL_PLATFORM_STM32H5) && HAL_PLATFORM_STM32H5
#include "../stm32h5/platform_driver.h"
#elif defined(HAL_PLATFORM_STM32F4) && HAL_PLATFORM_STM32F4
#include "../stm32f4/hal_platform.h"
#elif defined(HAL_PLATFORM_IMXRT1064) && HAL_PLATFORM_IMXRT1064
#include "../imxrt1064/hal_platform.h"
#else
#error "No valid platform selected in platform_select.h"
#endif

/*------------------------------------------------------------------------------
 * Common Macros and Utilities
 *----------------------------------------------------------------------------*/

/** Convert milliseconds to microseconds */
#define MS_TO_US(ms) ((ms) * 1000UL)

/** Convert microseconds to milliseconds */
#define US_TO_MS(us) ((us) / 1000UL)

/** Minimum timer period in microseconds */
#define HAL_TIMER_MIN_PERIOD_US 1

/** Maximum timer period in microseconds */
#define HAL_TIMER_MAX_PERIOD_US 0xFFFFFFFFU

/** Validate GPIO pin identifier */
#define HAL_GPIO_IS_VALID(pin) ((pin) < HAL_GPIO_PIN_COUNT)

/** Validate UART peripheral identifier */
#define HAL_UART_IS_VALID(uart) ((uart) < HAL_UART_COUNT)

/** Validate Timer peripheral identifier */
#define HAL_TIMER_IS_VALID(timer) ((timer) < HAL_TIMER_COUNT)

    /*------------------------------------------------------------------------------
     * Error Checking Macros
     *----------------------------------------------------------------------------*/

#ifdef HAL_DEBUG_ENABLED
#define HAL_ASSERT(expr)                           \
    do                                             \
    {                                              \
        if (!(expr))                               \
        {                                          \
            hal_assert_failed(__FILE__, __LINE__); \
        }                                          \
    } while (0)
#else
#define HAL_ASSERT(expr) ((void)0)
#endif

#define HAL_CHECK_PARAM(expr) \
    do                        \
    {                         \
        if (!(expr))          \
        {                     \
            return;           \
        }                     \
    } while (0)

#define HAL_CHECK_PARAM_RET(expr, ret) \
    do                                 \
    {                                  \
        if (!(expr))                   \
        {                              \
            return (ret);              \
        }                              \
    } while (0)

    /*------------------------------------------------------------------------------
     * Internal Function Declarations
     *----------------------------------------------------------------------------*/

#ifdef HAL_DEBUG_ENABLED
    /**
     * @brief Assertion failure handler
     * @param file  Source file name where assert failed
     * @param line  Line number where assert failed
     */
    void hal_assert_failed(const char *file, uint32_t line);
#endif

    /**
     * @brief Convert HAL error to string
     * @param error HAL error code
     * @return      Error string
     */
    const char *hal_error_to_string(int error);

    /**
     * @brief Get HAL version string
     * @return Version string
     */
    const char *hal_get_version(void);

    /**
     * @brief Get platform name
     * @return Platform name string
     */
    const char *hal_get_platform_name(void);

#ifdef __cplusplus
}
#endif

#endif /* HAL_COMMON_H */