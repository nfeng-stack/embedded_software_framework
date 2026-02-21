/**
 * @file    platform_select.h
 * @brief   Platform and RTOS selection configuration
 * 
 * This file selects the target hardware platform and RTOS for the framework.
 * Only one platform and one RTOS should be enabled at a time.
 */

#ifndef PLATFORM_SELECT_H
#define PLATFORM_SELECT_H

/*------------------------------------------------------------------------------
 * Hardware Platform Selection (select only one)
 *----------------------------------------------------------------------------*/

/* STM32F4 platform (reserved) */
#define HAL_PLATFORM_STM32F4      0

/* i.MX RT1064 platform (reserved) */
#define HAL_PLATFORM_IMXRT1064    0

/* STM32H5 platform (default) */
#define HAL_PLATFORM_STM32H5      1

/*------------------------------------------------------------------------------
 * RTOS Selection (select only one)
 *----------------------------------------------------------------------------*/

/* FreeRTOS (reserved) */
#define OSAL_RTOS_FREERTOS         0

/* RT-Thread (default) */
#define OSAL_RTOS_RTTHREAD         1

/*------------------------------------------------------------------------------
 * Derived Configuration (do not modify manually)
 *----------------------------------------------------------------------------*/

/* Platform selection validation */
#if (HAL_PLATFORM_STM32F4 + HAL_PLATFORM_IMXRT1064 + HAL_PLATFORM_STM32H5) != 1
#error "Exactly one hardware platform must be selected"
#endif

/* RTOS selection validation */
#if (OSAL_RTOS_FREERTOS + OSAL_RTOS_RTTHREAD) != 1
#error "Exactly one RTOS must be selected"
#endif

/* Platform-specific includes */
#if HAL_PLATFORM_STM32H5
#define HAL_PLATFORM_NAME "STM32H5"
#endif

/* RTOS-specific includes */
#if OSAL_RTOS_RTTHREAD
#define OSAL_RTOS_NAME "RT-Thread"
#endif

#endif /* PLATFORM_SELECT_H */