/**
 * @file    framework_interrupts.c
 * @brief   Interrupt Management Implementation
 *
 * This file implements static vector table management with callback registration.
 * It provides interrupt control functions and default exception handlers.
 *
 * @note    Static vector table only (不支持运行时注册)
 */

#include "framework_interrupts.h"
#include "stdio.h"
#include "string.h"
#include "stdint.h"


/*------------------------------------------------------------------------------
 * Private Variables
 *----------------------------------------------------------------------------*/

/* Vector table is defined in startup file */

/** Unified interrupt entry table */
static framework_interrupt_handler_t interrupt_entries[FRAMEWORK_TOTAL_INTERRUPTS] = {0};

/*------------------------------------------------------------------------------
 * Private Function Declarations
 *----------------------------------------------------------------------------*/

void framework_interrupts_init_vector_table(void)
{

    memset(interrupt_entries, 0, sizeof(interrupt_entries));
}

void framework_interrupts_register_handler(int irq_number, framework_interrupt_handler_t handler)
{
    interrupt_entries[irq_number] = handler;
}


static void g_interrupt_handler(int irq_number)
{

    if (interrupt_entries[irq_number] != NULL)
    {
        interrupt_entries[irq_number]();
    }
}

void framework_irq_handler(uint32_t irq_num)
{
    g_interrupt_handler(irq_num);
}

/*------------------------------------------------------------------------------
 * System Exception Handlers (Strong Symbols)
 *
 * These are the actual interrupt handlers that get called by the hardware.
 * They check for registered callbacks and call them if available.
 *----------------------------------------------------------------------------*/

__attribute__((weak)) void NMI_Handler(void)
{
    g_interrupt_handler(NMI_IRQ_NUM);
}

__attribute__((weak)) void HardFault_Handler(void)
{
    g_interrupt_handler(HARDFAULT_IRQ_NUM);
}

__attribute__((weak)) void MemManage_Handler(void)
{
    g_interrupt_handler(MEMMANAGE_IRQ_NUM);
}

__attribute__((weak)) void BusFault_Handler(void)
{
    g_interrupt_handler(BUSFAULT_IRQ_NUM);
}

__attribute__((weak)) void UsageFault_Handler(void)
{
    g_interrupt_handler(USAGEFAULT_IRQ_NUM);
}

__attribute__((weak)) void SecureFault_Handler(void)
{
    g_interrupt_handler(SECUREFAULT_IRQ_NUM);
}

__attribute__((weak)) void SVC_Handler(void)
{
    g_interrupt_handler(SVC_IRQ_NUM);
}

__attribute__((weak)) void DebugMon_Handler(void)
{
    g_interrupt_handler(DEBUGMON_IRQ_NUM);
}

__attribute__((weak)) void PendSV_Handler(void)
{
    g_interrupt_handler(PENDSV_IRQ_NUM);
}

void SysTick_Handler(void)
{
    g_interrupt_handler(SYSTICK_IRQ_NUM);
}
