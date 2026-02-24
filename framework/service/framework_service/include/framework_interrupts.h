/**
 * @file    framework_interrupts.h
 * @brief   Interrupt Management for Platform Framework
 *
 * This file defines the interrupt management interface for the platform framework.
 * It provides static vector table management with callback registration.
 *
 * @note    Static vector table only (不支持运行时注册)
 */

#ifndef FRAMEWORK_INTERRUPTS_H
#define FRAMEWORK_INTERRUPTS_H

#ifdef __cplusplus
extern "C"
{
#endif

typedef void (*framework_interrupt_handler_t)(void);

#define FRAMEWORK_TOTAL_INTERRUPTS     146
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

void framework_interrupts_init_vector_table(void);
void framework_interrupts_register_handler(int irq_number, framework_interrupt_handler_t handler);


#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_INTERRUPTS_H */