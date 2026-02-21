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

#include <stdint.h>
#include <stdbool.h>

/*------------------------------------------------------------------------------
 * Interrupt Vector Table
 *----------------------------------------------------------------------------*/

/** Maximum number of interrupt vectors (Cortex-M typical) */
#define FRAMEWORK_MAX_INTERRUPTS 256

    /** Interrupt vector table entry type */
    typedef void (*framework_interrupt_handler_t)(void);

    /**
     * @brief Interrupt vector table structure
     * @note  This matches Cortex-M vector table layout
     */
    typedef struct
    {
        void *initial_sp;                                                          /**< Initial stack pointer */
        framework_interrupt_handler_t reset_handler;                               /**< Reset handler */
        framework_interrupt_handler_t nmi_handler;                                 /**< NMI handler */
        framework_interrupt_handler_t hardfault_handler;                           /**< HardFault handler */
        framework_interrupt_handler_t memmanage_handler;                           /**< MemManage handler */
        framework_interrupt_handler_t busfault_handler;                            /**< BusFault handler */
        framework_interrupt_handler_t usagefault_handler;                          /**< UsageFault handler */
        framework_interrupt_handler_t securefault_handler;                         /**< SecureFault handler */
        void *reserved[4];                                                         /**< Reserved entries */
        framework_interrupt_handler_t svc_handler;                                 /**< SVC handler */
        framework_interrupt_handler_t debugmon_handler;                            /**< DebugMon handler */
        void *reserved2;                                                           /**< Reserved */
        framework_interrupt_handler_t pendsv_handler;                              /**< PendSV handler */
        framework_interrupt_handler_t systick_handler;                             /**< SysTick handler */
        framework_interrupt_handler_t irq_handlers[FRAMEWORK_MAX_INTERRUPTS - 16]; /**< IRQ handlers */
    } framework_vector_table_t;

    /*------------------------------------------------------------------------------
     * Vector Table Management
     *----------------------------------------------------------------------------*/

    /**
     * @brief Get pointer to vector table
     * @return Pointer to vector table
     * @note   The vector table is located at FLASH start (0x08000000)
     */
    framework_vector_table_t *framework_interrupts_get_vector_table(void);

    /**
     * @brief Initialize vector table with default handlers
     * @note  Sets all handlers to default (infinite loop)
     */
    void framework_interrupts_init_vector_table(void);

    /**
     * @brief Set interrupt handler for specific IRQ number
     * @param irq_number IRQ number (0 for SysTick, 1 for PendSV, etc.)
     * @param handler    Handler function
     * @note  For Cortex-M system exceptions (negative numbers):
     *        -1 = SysTick, -2 = PendSV, -3 = SVC, etc.
     */
    void framework_interrupts_set_handler(int irq_number, framework_interrupt_handler_t handler);

    /**
     * @brief Get interrupt handler for specific IRQ number
     * @param irq_number IRQ number
     * @return Handler function or NULL if not set
     */
    framework_interrupt_handler_t framework_interrupts_get_handler(int irq_number);

    /*------------------------------------------------------------------------------
     * Interrupt Control
     *----------------------------------------------------------------------------*/

    /**
     * @brief Enable specific interrupt
     * @param irq_number IRQ number
     */
    void framework_interrupts_enable(int irq_number);

    /**
     * @brief Disable specific interrupt
     * @param irq_number IRQ number
     */
    void framework_interrupts_disable(int irq_number);

    /**
     * @brief Set interrupt priority
     * @param irq_number IRQ number
     * @param priority   Priority (0-255, lower = higher priority)
     */
    void framework_interrupts_set_priority(int irq_number, uint32_t priority);

    /**
     * @brief Get interrupt priority
     * @param irq_number IRQ number
     * @return Priority value (0-255)
     */
    uint32_t framework_interrupts_get_priority(int irq_number);

    /**
     * @brief Check if interrupt is enabled
     * @param irq_number IRQ number
     * @return true if enabled, false otherwise
     */
    bool framework_interrupts_is_enabled(int irq_number);

    /**
     * @brief Check if interrupt is pending
     * @param irq_number IRQ number
     * @return true if pending, false otherwise
     */
    bool framework_interrupts_is_pending(int irq_number);

    /**
     * @brief Clear pending interrupt
     * @param irq_number IRQ number
     */
    void framework_interrupts_clear_pending(int irq_number);

    /**
     * @brief Set pending interrupt
     * @param irq_number IRQ number
     */
    void framework_interrupts_set_pending(int irq_number);

    /*------------------------------------------------------------------------------
     * System Exception Handlers (Weak Symbols)
     *----------------------------------------------------------------------------*/

    /**
     * @brief Default exception handler (weak symbol)
     * @note  Infinite loop - should be overridden by application
     */
    void Default_Handler(void);

    /**
     * @brief NMI handler (weak symbol)
     */
    void NMI_Handler(void);

    /**
     * @brief HardFault handler (weak symbol)
     */
    void HardFault_Handler(void);

    /**
     * @brief MemManage handler (weak symbol)
     */
    void MemManage_Handler(void);

    /**
     * @brief BusFault handler (weak symbol)
     */
    void BusFault_Handler(void);

    /**
     * @brief UsageFault handler (weak symbol)
     */
    void UsageFault_Handler(void);

    /**
     * @brief SecureFault handler (weak symbol)
     */
    void SecureFault_Handler(void);

    /**
     * @brief SVC handler (weak symbol)
     */
    void SVC_Handler(void);

    /**
     * @brief DebugMon handler (weak symbol)
     */
    void DebugMon_Handler(void);

    /**
     * @brief PendSV handler (weak symbol)
     */
    void PendSV_Handler(void);

    /**
     * @brief SysTick handler (weak symbol)
     */
    void SysTick_Handler(void);

    /*------------------------------------------------------------------------------
     * Interrupt State Management
     *----------------------------------------------------------------------------*/

    /**
     * @brief Save interrupt enable state and disable interrupts
     * @return Saved interrupt state (to be passed to restore function)
     */
    uint32_t framework_interrupts_save_and_disable(void);

    /**
     * @brief Restore interrupt enable state
     * @param state State returned by save_and_disable()
     */
    void framework_interrupts_restore(uint32_t state);

    /**
     * @brief Disable all interrupts
     * @return Previous interrupt state
     */
    uint32_t framework_interrupts_disable_all(void);

    /**
     * @brief Enable all interrupts
     */
    void framework_interrupts_enable_all(void);

    /*------------------------------------------------------------------------------
     * Interrupt Callback System (for RTOS integration)
     *----------------------------------------------------------------------------*/

    /** Interrupt callback function type */
    typedef void (*framework_interrupt_callback_t)(void *context);

    /**
     * @brief Register callback for interrupt
     * @param irq_number IRQ number
     * @param callback   Callback function
     * @param context    Context passed to callback
     * @return true if successful, false if IRQ already has callback
     * @note  Only one callback per IRQ is supported
     */
    bool framework_interrupts_register_callback(int irq_number,
                                                framework_interrupt_callback_t callback,
                                                void *context);

    /**
     * @brief Unregister callback for interrupt
     * @param irq_number IRQ number
     */
    void framework_interrupts_unregister_callback(int irq_number);
    void framework_interrupts_register_handler(int irq_number, framework_interrupt_handler_t handler);

    /**
     * @brief Get callback for interrupt
     * @param irq_number IRQ number
     * @return Callback function or NULL if not registered
     */
    framework_interrupt_callback_t framework_interrupts_get_callback(int irq_number);

#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_INTERRUPTS_H */