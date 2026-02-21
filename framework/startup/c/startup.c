/**
 ******************************************************************************
 * @file      startup.c
 * @author    Embedded Framework
 * @brief     Unified C startup file for ARM Cortex-M processors.
 *            This module performs:
 *                - Set the initial SP (via linker script)
 *                - Set the vector table entries with the exceptions ISR address
 *                - Initialize system clock via framework
 *                - Initialize data sections via framework
 *                - Call framework_start() which decides entry point
 *
 *            This is the only startup file for all configurations.
 *            Different OS configurations use different linker scripts.
 *
 * @note      All initialization functions are provided by framework.
 *            Hardware-specific implementation is in HAL layer.
 ******************************************************************************
 */

#include <stdint.h>

/*------------------------------------------------------------------------------
 * External Symbols (defined in linker script)
 *----------------------------------------------------------------------------*/
extern char _estack[]; /* End of stack (start of heap) */

extern uint32_t _sidata; /* Start of data initial values in FLASH */
extern uint32_t _sdata;  /* Start of data section in RAM */
extern uint32_t _edata;  /* End of data section in RAM */
extern uint32_t _sbss;   /* Start of BSS section in RAM */
extern uint32_t _ebss;   /* End of BSS section in RAM */

/*------------------------------------------------------------------------------
 * Framework Startup Functions (provided by framework)
 *----------------------------------------------------------------------------*/
void framework_system_clock_init(void); /* Initialize system clock */
void framework_data_init(void);         /* Initialize .data and .bss sections */
void framework_start(void);             /* Start application (main or RTOS) */

/* C library initialization function */
extern void __libc_init_array(void);    /* Initialize C library and C++ constructors */

/*------------------------------------------------------------------------------
 * System Exception Handlers (weak symbols)
 *----------------------------------------------------------------------------*/
void Default_Handler(void) __attribute__((weak)); /* Default exception handler */
void NMI_Handler(void) __attribute__((weak));
void HardFault_Handler(void) __attribute__((weak));
void MemManage_Handler(void) __attribute__((weak));
void BusFault_Handler(void) __attribute__((weak));
void UsageFault_Handler(void) __attribute__((weak));
void SecureFault_Handler(void) __attribute__((weak));
void SVC_Handler(void) __attribute__((weak));
void DebugMon_Handler(void) __attribute__((weak));
void PendSV_Handler(void) __attribute__((weak));
void SysTick_Handler(void) __attribute__((weak));

/*------------------------------------------------------------------------------
 * Platform-Specific Configuration
 *----------------------------------------------------------------------------*/
#ifdef HAL_PLATFORM_STM32H5
#include "../platforms/stm32h5/vectors_stm32h5.h"
#include "../platforms/stm32h5/irq_handlers_stm32h5.h"
#endif

#ifndef VECTOR_TABLE_SIZE
#define VECTOR_TABLE_SIZE 16 /* Default: only system exceptions */
#endif

#ifndef PLATFORM_VECTOR_TABLE
#define PLATFORM_VECTOR_TABLE /* empty */
#endif

/*------------------------------------------------------------------------------
 * Interrupt Vector Table
 *
 * The vector table must be placed at the beginning of FLASH (0x08000000).
 * It contains the initial stack pointer and all exception/interrupt handlers.
 *----------------------------------------------------------------------------*/

/* Forward declaration of Reset_Handler */
void Reset_Handler(void);

/* Vector table - placed in .isr_vector section */
#if defined(__APPLE__) && defined(__MACH__)
/* macOS (host compiler) may have different section syntax */
__attribute__((section("__TEXT,.isr_vector")))
#else
/* ARM GCC cross compiler */
__attribute__((section(".isr_vector")))
#endif
void (*const g_pfnVectors[VECTOR_TABLE_SIZE])(void) = {
    [0] = (void (*)(void))&_estack, /* Initial stack pointer */
    [1] = Reset_Handler,            /* Reset handler */
    [2] = NMI_Handler,              /* NMI handler */
    [3] = HardFault_Handler,        /* HardFault handler */
    [4] = MemManage_Handler,        /* MemManage handler */
    [5] = BusFault_Handler,         /* BusFault handler */
    [6] = UsageFault_Handler,       /* UsageFault handler */
    [7] = SecureFault_Handler,      /* SecureFault handler */
    [8] = 0,                        /* Reserved */
    [9] = 0,                        /* Reserved */
    [10] = 0,                       /* Reserved */
    [11] = SVC_Handler,             /* SVC handler */
    [12] = DebugMon_Handler,        /* DebugMon handler */
    [13] = 0,                       /* Reserved */
    [14] = PendSV_Handler,          /* PendSV handler */
    [15] = SysTick_Handler,         /* SysTick handler */

    /* Platform-specific external interrupts */
    PLATFORM_VECTOR_TABLE};

/*------------------------------------------------------------------------------
 * Default Exception Handler Implementations (weak)
 *----------------------------------------------------------------------------*/
void __attribute__((weak)) Default_Handler(void)
{
    while (1)
    {
        /* Infinite loop - override in application */
    }
}

/* Weak default implementations for system exceptions */
void __attribute__((weak)) NMI_Handler(void) { Default_Handler(); }
void __attribute__((weak)) HardFault_Handler(void) { Default_Handler(); }
void __attribute__((weak)) MemManage_Handler(void) { Default_Handler(); }
void __attribute__((weak)) BusFault_Handler(void) { Default_Handler(); }
void __attribute__((weak)) UsageFault_Handler(void) { Default_Handler(); }
void __attribute__((weak)) SecureFault_Handler(void) { Default_Handler(); }
void __attribute__((weak)) SVC_Handler(void) { Default_Handler(); }
void __attribute__((weak)) DebugMon_Handler(void) { Default_Handler(); }
void __attribute__((weak)) PendSV_Handler(void) { Default_Handler(); }
void __attribute__((weak)) SysTick_Handler(void) { Default_Handler(); }

/*------------------------------------------------------------------------------
 * CMSIS Standard Functions (weak compatibility layer)
 *----------------------------------------------------------------------------*/
void __attribute__((weak)) SystemInit(void)
{
    framework_system_clock_init();
}

void __attribute__((weak)) _data_init(void)
{
    framework_data_init();
}

/*------------------------------------------------------------------------------
 * Reset Handler
 *
 * This is the first code executed after reset.
 * It calls framework initialization functions and then framework_start().
 *----------------------------------------------------------------------------*/
void __attribute__((noreturn)) Reset_Handler(void)
{
    /* Note: Stack pointer is already initialized by hardware from vector table */

    /* 1. Initialize system clock using framework */
    framework_system_clock_init();

    /* 2. Initialize data sections using framework */
    framework_data_init();

    /* 3. Initialize C library and C++ constructors */
    __libc_init_array();

    /* 4. Call framework unified startup function */
    framework_start();

    /* Should never reach here */
    while (1)
    {
        /* Infinite loop */
    }
}
