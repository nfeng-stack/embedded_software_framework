/**
 * @file    framework_rtos.c
 * @brief   RTOS Interface Implementation
 * 
 * This file implements the RTOS interface for the platform framework.
 * RTOS implementations register their callback functions through these APIs.
 */

#include "framework_rtos.h"
#include "framework_interrupts.h"
#include "framework_debug.h"
#include <string.h>

/*------------------------------------------------------------------------------
 * Private Definitions
 *----------------------------------------------------------------------------*/

/** Default RTOS configuration */
static const framework_rtos_config_t default_rtos_config = {
    .tick_rate_hz = 1000,           /* 1 kHz default */
    .systick_priority = 0xFF,       /* Lowest priority */
    .pendsv_priority = 0xFF,        /* Lowest priority */
    .svc_priority = 0xFF,           /* Lowest priority */
    .enable_preemption = true,
    .enable_time_slicing = true
};

/*------------------------------------------------------------------------------
 * Private Variables
 *----------------------------------------------------------------------------*/

/** Registered callbacks */
static struct {
    framework_systick_callback_t systick_callback;
    framework_pendsv_callback_t pendsv_callback;
    framework_svc_callback_t svc_callback;
    framework_debug_putc_t debug_putc;
    framework_debug_getc_t debug_getc;
} rtos_callbacks = {
    .systick_callback = NULL,
    .pendsv_callback = NULL,
    .svc_callback = NULL,
    .debug_putc = NULL,
    .debug_getc = NULL
};

/** Current RTOS configuration */
static framework_rtos_config_t current_rtos_config = {0};

/* Current OS port is determined at compile time via FRAMEWORK_PORT_* macros */

/*------------------------------------------------------------------------------
 * Private Function Declarations
 *----------------------------------------------------------------------------*/

static void systick_handler_callback(void* context);
static void pendsv_handler_callback(void* context);
static void svc_handler_callback(void* context);

/*------------------------------------------------------------------------------
 * RTOS Interface Registration Functions
 *----------------------------------------------------------------------------*/

void framework_rtos_register_systick(framework_systick_callback_t callback)
{
    rtos_callbacks.systick_callback = callback;
    
    if (callback != NULL) {
        /* Register our callback wrapper with the interrupt system */
        framework_interrupts_register_callback(-1, systick_handler_callback, NULL);
        framework_debug_trace("Registered SysTick callback");
    } else {
        /* Unregister callback */
        framework_interrupts_unregister_callback(-1);
        framework_debug_trace("Unregistered SysTick callback");
    }
}

void framework_rtos_register_pendsv(framework_pendsv_callback_t callback)
{
    rtos_callbacks.pendsv_callback = callback;
    
    if (callback != NULL) {
        /* Register our callback wrapper with the interrupt system */
        framework_interrupts_register_callback(-2, pendsv_handler_callback, NULL);
        framework_debug_trace("Registered PendSV callback");
    } else {
        /* Unregister callback */
        framework_interrupts_unregister_callback(-2);
        framework_debug_trace("Unregistered PendSV callback");
    }
}

void framework_rtos_register_svc(framework_svc_callback_t callback)
{
    rtos_callbacks.svc_callback = callback;
    
    if (callback != NULL) {
        /* Register our callback wrapper with the interrupt system */
        framework_interrupts_register_callback(-3, svc_handler_callback, NULL);
        framework_debug_trace("Registered SVC callback");
    } else {
        /* Unregister callback */
        framework_interrupts_unregister_callback(-3);
        framework_debug_trace("Unregistered SVC callback");
    }
}

void framework_rtos_register_debug(framework_debug_putc_t putc, framework_debug_getc_t getc)
{
    rtos_callbacks.debug_putc = putc;
    rtos_callbacks.debug_getc = getc;
    
    if (putc != NULL) {
        framework_debug_trace("Registered debug output callback");
    }
    if (getc != NULL) {
        framework_debug_trace("Registered debug input callback");
    }
}

framework_systick_callback_t framework_rtos_get_systick_callback(void)
{
    return rtos_callbacks.systick_callback;
}

framework_pendsv_callback_t framework_rtos_get_pendsv_callback(void)
{
    return rtos_callbacks.pendsv_callback;
}

framework_svc_callback_t framework_rtos_get_svc_callback(void)
{
    return rtos_callbacks.svc_callback;
}

/*------------------------------------------------------------------------------
 * OS Port Management
 *----------------------------------------------------------------------------*/

framework_port_t framework_port_get_current(void)
{
#ifdef OSAL_RTOS_RTTHREAD
    return FRAMEWORK_PORT_RTTHREAD;
#else
    return FRAMEWORK_PORT_GENERIC;
#endif
}

bool framework_port_is_rtos(void)
{
#ifdef OSAL_RTOS_RTTHREAD
    return true;
#else
    return false;
#endif
}

/*------------------------------------------------------------------------------
 * RTOS Configuration
 *----------------------------------------------------------------------------*/

void framework_rtos_set_config(const framework_rtos_config_t* config)
{
    if (config == NULL) {
        memcpy(&current_rtos_config, &default_rtos_config, sizeof(framework_rtos_config_t));
    } else {
        memcpy(&current_rtos_config, config, sizeof(framework_rtos_config_t));
    }
}

const framework_rtos_config_t* framework_rtos_get_config(void)
{
    return &current_rtos_config;
}

/*------------------------------------------------------------------------------
 * Private Callback Wrappers
 *----------------------------------------------------------------------------*/

static void systick_handler_callback(void* context)
{
    (void)context;
    
    if (rtos_callbacks.systick_callback != NULL) {
        rtos_callbacks.systick_callback();
    } else {
        /* Default SysTick handling for generic port */
        /* This could update a system tick counter, etc. */
    }
}

static void pendsv_handler_callback(void* context)
{
    (void)context;
    
    if (rtos_callbacks.pendsv_callback != NULL) {
        rtos_callbacks.pendsv_callback();
    }
    /* No default handling for PendSV */
}

static void svc_handler_callback(void* context)
{
    (void)context;
    
    if (rtos_callbacks.svc_callback != NULL) {
        rtos_callbacks.svc_callback();
    }
    /* No default handling for SVC */
}

/*------------------------------------------------------------------------------
 * Debug Output/Input Wrappers (for framework_debug.c)
 *----------------------------------------------------------------------------*/

/**
 * @brief Debug output via registered RTOS callback or default
 */
void framework_rtos_debug_putc(char c)
{
    if (rtos_callbacks.debug_putc != NULL) {
        rtos_callbacks.debug_putc(c);
    } else {
        /* Default debug output (to be implemented in HAL) */
        /* hal_system_debug_putc(c); */
    }
}

/**
 * @brief Debug input via registered RTOS callback or default
 */
char framework_rtos_debug_getc(void)
{
    if (rtos_callbacks.debug_getc != NULL) {
        return rtos_callbacks.debug_getc();
    } else {
        /* Default debug input (to be implemented in HAL) */
        /* return hal_system_debug_getc(); */
        return 0;
    }
}