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
#include "framework_debug.h"
#include "cmsis_compiler.h"
#include <string.h>

/* Platform-specific vector table configuration */
#ifdef HAL_PLATFORM_STM32H5
#include "../startup/platforms/stm32h5/vectors_stm32h5.h"
#endif

/*------------------------------------------------------------------------------
 * Private Definitions
 *----------------------------------------------------------------------------*/

/** Number of system entries in vector table (including reset, excluding initial SP) */
#ifdef VECTOR_TABLE_SIZE
#define FRAMEWORK_SYSTEM_ENTRY_COUNT 15 /* Vector table positions 1-15 (reset + system exceptions) */
#else
#define FRAMEWORK_SYSTEM_ENTRY_COUNT 15 /* Default: positions 1-15 */
#endif

/** Number of external interrupts (IRQs) */
#ifdef VECTOR_TABLE_SIZE
#define FRAMEWORK_EXTERNAL_IRQ_COUNT (VECTOR_TABLE_SIZE - 16) /* IRQs after system exceptions (position 16+) */
#else
#define FRAMEWORK_EXTERNAL_IRQ_COUNT 240 /* Default maximum */
#endif

/** Total number of entries in unified table (system entries + external IRQs) */
#define FRAMEWORK_TOTAL_INTERRUPTS (FRAMEWORK_SYSTEM_ENTRY_COUNT + FRAMEWORK_EXTERNAL_IRQ_COUNT)

/** Offset for external IRQs in the unified table */
#define FRAMEWORK_IRQ_OFFSET FRAMEWORK_SYSTEM_ENTRY_COUNT

/** Unified interrupt entry (callback + handler) */
typedef struct
{
    framework_interrupt_handler_t handler;
} interrupt_entry_t;

/** System exception numbers (Cortex-M) */
#define SYSTICK_IRQ_NUM (14)
#define PENDSV_IRQ_NUM (13)
#define DEBUGMON_IRQ_NUM (11)
#define SVC_IRQ_NUM (10)
#define SECUREFAULT_IRQ_NUM (6)
#define USAGEFAULT_IRQ_NUM (5)
#define BUSFAULT_IRQ_NUM (4)
#define MEMMANAGE_IRQ_NUM (3)
#define HARDFAULT_IRQ_NUM (2)
#define NMI_IRQ_NUM (1)

/*------------------------------------------------------------------------------
 * Private Variables
 *----------------------------------------------------------------------------*/

/* Vector table is defined in startup file */

/** Unified interrupt entry table */
static interrupt_entry_t interrupt_entries[FRAMEWORK_TOTAL_INTERRUPTS] = {0};

/*------------------------------------------------------------------------------
 * Private Function Declarations
 *----------------------------------------------------------------------------*/

void framework_interrupts_init_vector_table(void)
{
    /* Vector table is in flash and already initialized by startup code */
    /* Initialize unified interrupt entry table */
    memset(interrupt_entries, 0, sizeof(interrupt_entries));
}

void framework_interrupts_register_handler(int irq_number, framework_interrupt_handler_t handler)
{
    interrupt_entries[irq_number].handler = handler;
}

framework_interrupt_handler_t framework_interrupts_get_handler(int irq_number)
{
    if (interrupt_entries[irq_number].handler != NULL)
    {
        return interrupt_entries[irq_number].handler;
    }
    return NULL;
}

/*------------------------------------------------------------------------------
 * Interrupt State Management
 *----------------------------------------------------------------------------*/

uint32_t framework_interrupts_save_and_disable(void)
{
    uint32_t state = __get_PRIMASK();
    __disable_irq();
    return state;
}

void framework_interrupts_restore(uint32_t state)
{
    __set_PRIMASK(state);
}

uint32_t framework_interrupts_disable_all(void)
{
    uint32_t state = __get_PRIMASK();
    __disable_irq();
    return state;
}

void framework_interrupts_enable_all(void)
{
    __enable_irq();
}

static void g_interrupt_handler(int irq_number)
{

    if (interrupt_entries[irq_number].handler != NULL)
    {
        interrupt_entries[irq_number].handler();
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
