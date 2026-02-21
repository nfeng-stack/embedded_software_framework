/**
 * @file    hal_system_ll.c
 * @brief   STM32H5 System-Level Hardware Abstraction Layer
 *
 * This file implements system-level HAL functions for STM32H5 platform.
 * It uses STM32 HAL drivers for clock, interrupts, and debug hardware.
 */
#include "stm32h5xx_hal.h"
#include "stm32h5xx_hal_rcc.h"
#include "stm32h5xx_hal_cortex.h"
#include <stddef.h>

void platform_sdk_init()
{
    HAL_Init();
}

void (*platform_get_sytemtick_handler(void))(void)
{
    return HAL_IncTick;
}

/*------------------------------------------------------------------------------
 * System Clock
 *----------------------------------------------------------------------------*/

void platform_system_clock_pre_init()
{
    SystemInit();
}

uint32_t platform_system_clock_init()
{

    RCC_OscInitTypeDef RCC_OscInitStruct = {0};
    RCC_ClkInitTypeDef RCC_ClkInitStruct = {0};

    /** Configure the main internal regulator output voltage
     */
    __HAL_PWR_VOLTAGESCALING_CONFIG(PWR_REGULATOR_VOLTAGE_SCALE0);

    while (!__HAL_PWR_GET_FLAG(PWR_FLAG_VOSRDY))
    {
    }

    /** Initializes the RCC Oscillators according to the specified parameters
     * in the RCC_OscInitTypeDef structure.
     */
    RCC_OscInitStruct.OscillatorType = RCC_OSCILLATORTYPE_CSI;
    RCC_OscInitStruct.CSIState = RCC_CSI_ON;
    RCC_OscInitStruct.CSICalibrationValue = RCC_CSICALIBRATION_DEFAULT;
    RCC_OscInitStruct.PLL.PLLState = RCC_PLL_ON;
    RCC_OscInitStruct.PLL.PLLSource = RCC_PLL1_SOURCE_CSI;
    RCC_OscInitStruct.PLL.PLLM = 2;
    RCC_OscInitStruct.PLL.PLLN = 250;
    RCC_OscInitStruct.PLL.PLLP = 2;
    RCC_OscInitStruct.PLL.PLLQ = 2;
    RCC_OscInitStruct.PLL.PLLR = 2;
    RCC_OscInitStruct.PLL.PLLRGE = RCC_PLL1_VCIRANGE_1;
    RCC_OscInitStruct.PLL.PLLVCOSEL = RCC_PLL1_VCORANGE_WIDE;
    RCC_OscInitStruct.PLL.PLLFRACN = 0;
    if (HAL_RCC_OscConfig(&RCC_OscInitStruct) != HAL_OK)
    {
        // Error_Handler();
    }

    /** Initializes the CPU, AHB and APB buses clocks
     */
    RCC_ClkInitStruct.ClockType = RCC_CLOCKTYPE_HCLK | RCC_CLOCKTYPE_SYSCLK | RCC_CLOCKTYPE_PCLK1 | RCC_CLOCKTYPE_PCLK2 | RCC_CLOCKTYPE_PCLK3;
    RCC_ClkInitStruct.SYSCLKSource = RCC_SYSCLKSOURCE_PLLCLK;
    RCC_ClkInitStruct.AHBCLKDivider = RCC_SYSCLK_DIV1;
    RCC_ClkInitStruct.APB1CLKDivider = RCC_HCLK_DIV1;
    RCC_ClkInitStruct.APB2CLKDivider = RCC_HCLK_DIV1;
    RCC_ClkInitStruct.APB3CLKDivider = RCC_HCLK_DIV1;

    if (HAL_RCC_ClockConfig(&RCC_ClkInitStruct, FLASH_LATENCY_5) != HAL_OK)
    {
        // Error_Handler();
    }

    /** Configure the programming delay
     */
    __HAL_FLASH_SET_PROGRAM_DELAY(FLASH_PROGRAMMING_DELAY_2);

    /* GPIO Ports Clock Enable */
    __HAL_RCC_GPIOH_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();

    if (HAL_ICACHE_ConfigAssociativityMode(ICACHE_1WAY) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_ICACHE_Enable() != HAL_OK)
    {
        // Error_Handler();
    }
    /* USER CODE BEGIN ICACHE_Init 2 */

    /* USER CODE END ICACHE_Init 2 */
    return 0;
}

uint32_t hal_system_clock_get(void)
{
    return HAL_RCC_GetSysClockFreq();
}

uint32_t hal_system_tick_freq_get(void)
{
    /* SysTick frequency is derived from core clock */
    return HAL_RCC_GetSysClockFreq() / 8; /* Assume SysTick uses HCLK/8 */
}

uint32_t hal_system_tick_init()
{
    HAL_Init();
    return 0;
}

/*------------------------------------------------------------------------------
 * System Interrupts (NVIC)
 *----------------------------------------------------------------------------*/

void hal_system_interrupt_enable(int irq_number)
{
    if (irq_number >= 0)
    {
        NVIC_EnableIRQ(irq_number);
    }
}

void hal_system_interrupt_disable(int irq_number)
{
    if (irq_number >= 0)
    {
        NVIC_DisableIRQ(irq_number);
    }
}

void hal_system_interrupt_set_priority(int irq_number, uint32_t priority)
{
    if (irq_number >= 0)
    {
        NVIC_SetPriority(irq_number, priority);
    }
    else
    {
        /* System exceptions: SysTick, PendSV, etc. */
        uint32_t exception_number = -irq_number;
        /* STM32 uses CMSIS functions for system exception priority */
        switch (exception_number)
        {
        case 1: /* SysTick */
            NVIC_SetPriority(SysTick_IRQn, priority);
            break;
        case 2: /* PendSV */
            NVIC_SetPriority(PendSV_IRQn, priority);
            break;
        case 3: /* SVC */
            NVIC_SetPriority(SVCall_IRQn, priority);
            break;
        default:
            break;
        }
    }
}

uint32_t hal_system_interrupt_get_priority(int irq_number)
{
    if (irq_number >= 0)
    {
        return NVIC_GetPriority(irq_number);
    }
    else
    {
        uint32_t exception_number = -irq_number;
        switch (exception_number)
        {
        case 1:
            return NVIC_GetPriority(SysTick_IRQn);
        case 2:
            return NVIC_GetPriority(PendSV_IRQn);
        case 3:
            return NVIC_GetPriority(SVCall_IRQn);
        default:
            return 0xFF;
        }
    }
}

/*------------------------------------------------------------------------------
 * System Control
 *----------------------------------------------------------------------------*/

void hal_system_reset(void)
{
    NVIC_SystemReset();
}

void hal_system_sleep(void)
{
    /* Enter sleep mode (wait for interrupt) */
    __WFI();
}

void hal_system_deepsleep(void)
{
    /* TODO: Implement deep sleep for STM32H5 */
    __WFI();
}

/*------------------------------------------------------------------------------
 * Debug Hardware (UART/SWO/Semihosting)
 *----------------------------------------------------------------------------*/

void hal_system_debug_putc(char c)
{
    /* TODO: Implement debug output via UART or SWO */
    /* For now, do nothing */
    (void)c;
}

char hal_system_debug_getc(void)
{
    /* TODO: Implement debug input */
    return 0;
}

void hal_system_debug_kbhit(void)
{
    /* TODO: Check if input character available */
    return;
}

void hal_system_debug_flush(void)
{
    /* Nothing to flush */
}

/*------------------------------------------------------------------------------
 * System Information
 *----------------------------------------------------------------------------*/

uint32_t hal_system_get_uid(uint8_t *buffer, uint32_t size)
{
    /* STM32H5 unique device identifier */
    if (buffer == NULL || size < 12)
    {
        return 0;
    }

    /* TODO: Read from UID registers */
    /* For now, fill with zeros */
    for (uint32_t i = 0; i < 12 && i < size; i++)
    {
        buffer[i] = 0;
    }

    return 12;
}

uint32_t hal_system_get_revision(void)
{
    /* TODO: Read DBGMCU_IDCODE register */
    return 0;
}

uint32_t hal_system_get_flash_size(void)
{
    /* Read from FLASH_SIZE register */
    return (*((uint16_t *)0x1FF1E880)) * 1024; /* KB to bytes */
}

uint32_t hal_system_get_ram_size(void)
{
    /* STM32H5 has multiple RAM banks, return total */
    return 512 * 1024; /* Assume 512KB for now */
}