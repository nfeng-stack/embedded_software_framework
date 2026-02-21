/**
 * @file    framework_init.c
 * @brief   Platform Framework Core Initialization
 *
 * This file implements the CMSIS-standard initialization flow for the platform framework.
 * It performs system initialization in the correct order:
 * 1. System clock initialization (via HAL)
 * 2. Data and BSS section initialization
 * 3. Interrupt vector table setup
 * 4. OS port initialization (if using RTOS)
 * 5. Jump to main() or RTOS entry point
 */

#include "framework.h"
#include "framework_rtos.h"
#include "framework_interrupts.h"
#include "framework_debug.h"
#include <string.h>
#include <stdio.h>
#include <stdint.h>

#ifdef HAL_PLATFORM_STM32H5
#include "hal.h"
#include "osal.h"
#endif

/*------------------------------------------------------------------------------
 * External Symbols (defined in linker script)
 *----------------------------------------------------------------------------*/

extern uint32_t _sidata; /* Start of data initial values in FLASH */
extern uint32_t _sdata;  /* Start of data section in RAM */
extern uint32_t _edata;  /* End of data section in RAM */
extern uint32_t _sbss;   /* Start of BSS section in RAM */
extern uint32_t _ebss;   /* End of BSS section in RAM */
extern uint32_t _estack; /* End of stack (start of heap) */

/* RAM code section symbols */
extern uint32_t _siramcode; /* Start of RAM code initial values in FLASH */
extern uint32_t _sramcode;  /* Start of RAM code section in RAM */
extern uint32_t _eramcode;  /* End of RAM code section in RAM */

/*------------------------------------------------------------------------------
 * Framework Startup Functions (interface defined in framework_startup.h)
 *----------------------------------------------------------------------------*/

void framework_system_clock_init(void)
{
    /* Call HAL layer to configure system clock */
#ifdef HAL_PLATFORM_STM32H5
    hal_system_clock_pre_init();
#else
    /* For generic platforms, assume clock is already configured by startup code */
#endif
}

void framework_data_init(void)
{

    /* Copy .data section from FLASH to RAM */
    uint32_t *src = (uint32_t *)&_sidata;
    uint32_t *dst = (uint32_t *)&_sdata;
    uint32_t *end = (uint32_t *)&_edata;

    while (dst < end)
    {
        *dst++ = *src++;
    }

    /* Copy .ram_code section from FLASH to RAM */
    src = (uint32_t *)&_siramcode;
    dst = (uint32_t *)&_sramcode;
    end = (uint32_t *)&_eramcode;

    while (dst < end)
    {
        *dst++ = *src++;
    }

    /* Clear .bss section */
    uint32_t *bss_start = (uint32_t *)&_sbss;
    uint32_t *bss_end = (uint32_t *)&_ebss;

    while (bss_start < bss_end)
    {
        *bss_start++ = 0;
    }

    /* Initialize MSP stack protection region with magic pattern */
    extern uint32_t _msp_stack_protection_start;
    extern uint32_t _msp_stack_protection_end;
    uint32_t *prot_start = &_msp_stack_protection_start;
    uint32_t *prot_end = &_msp_stack_protection_end;
    
    while (prot_start < prot_end)
    {
        *prot_start++ = 0xDEADBEEF;  /* Magic pattern for stack overflow detection */
    }
}

/**
 * @brief this function is interrupt function , it will hanler system tick
 */
typedef void (*system_tick_inc_fun)(void);
static system_tick_inc_fun system_tick_callback[2];
void framework_system_tick_handler()
{
    for (uint8_t i = 0; i < 2; i++)
    {
        if (system_tick_callback[i] != NULL)
        {
            system_tick_callback[i]();
        }
    }
}

void framework_system_tick_callback_register(system_tick_inc_fun callback)
{
    for (uint8_t i = 0; i < 2; i++)
    {
        if (system_tick_callback[i] == NULL)
        {
            system_tick_callback[i] = callback;
            break;
        }
    }
}

void framework_register_os_tick_handler(void)
{
    framework_system_tick_callback_register(osal_system_get_systemtick_handler_callback());
}

void framework_sdk_base_init(void)
{
    /* 此处主要初始化sdk驱动*/
    framework_interrupts_init_vector_table();
    framework_interrupts_register_handler(14, framework_system_tick_handler);
    framework_system_tick_callback_register(hal_system_get_systemhandler());
    hal_system_sdk_init();
    /* 系统的基础时钟*/
    hal_system_clock_init();
    /* 配置基本的内核级别的硬件，如内存，数据总线，mpu，flash，内核电源等*/
}

void framework_os_base_init(void)
{
    /* there will init rtos need hardware exampel uart ...*/
    osal_register_callback(framework_register_os_tick_handler);
}

void framework_init_os(void)
{
    /* there will init os kernel*/
    extern void rtthread_startup(void);
    rtthread_startup();
}

void framework_start(void)
{
    framework_sdk_base_init();
#if OSAL_RTOS_RTTHREAD == 1
    framework_os_base_init();
    framework_init_os();
#else
    extern int main(void);
    main();
#endif
}
