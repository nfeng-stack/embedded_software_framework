/**
 * @file    usb_protocol.c
 * @brief   USB Protocol Stack Implementation
 *
 * This module implements USB protocol stack initialization and management.
 * It uses HAL for hardware initialization (clocks, GPIO, interrupts) and
 * TinyUSB for the protocol stack. The USB stack runs in its own RTOS thread.
 */

#include <stdbool.h>
#include <string.h>
#include "elog.h"
#include "hal.h"
#include "osal.h"
#include "tusb.h"
#include "usb_protocol.h"
#include "board_api.h"
#include "usb_state.h"
/* USB task configuration */
#define USB_TASK_STACK_SIZE      (2048)
#define USB_TASK_PRIORITY        (8)     /* Higher number = lower priority */
#define USB_TASK_TICK            (1)     /* 1 system tick delay */

/* Static variables */
static bool usb_initialized = false;
static osal_task_t usb_task = NULL;

/* Forward declarations */
static int usb_hardware_init(void);
static int usb_hardware_deinit(void);

/**
 * @brief Initialize USB hardware (clocks, GPIO, interrupts) via HAL
 */
static int usb_hardware_init(void)
{
    log_d("Initializing USB hardware via HAL...");
    
    /* Initialize USB clocks, GPIO, and interrupts */
    hal_usb_clock_io_init();
    
    /* Note: USB interrupt handler is already implemented in family.c
     * and will call tusb_int_handler(0, true) when USB interrupts occur.
     * The interrupt is enabled by hal_usb_clock_io_init().
     */
    
    log_d("USB hardware initialized");
    return 0;
}

/**
 * @brief Deinitialize USB hardware
 */
static int usb_hardware_deinit(void)
{
    log_d("Deinitializing USB hardware...");
    
    /* USB stop and deinit handled by TinyUSB protocol stack */
    
    log_d("USB hardware deinitialized");
    return 0;
}

/**
 * @brief USB protocol task entry function
 * 
 * This function runs in a separate thread and calls tud_task() periodically
 * to handle USB events. It also monitors USB connection state and updates
 * the shared state for other components (e.g., logging, file system).
 */
void usb_protocol_task_entry(void *arg)
{
    (void)arg;
    log_d("USB protocol task started");
    
    bool last_connected_state = false;
    
    while (1) {
        /* Process USB events - this handles all USB communication */
        tud_task();
        
        /* Monitor USB connection state */
        /* Check both physical connection and mount status for MSC */
        bool current_connected = tud_connected() && tud_mounted();
        
        /* Update shared state if changed */
        if (current_connected != last_connected_state) {
            usb_state_set_connected(current_connected);
            last_connected_state = current_connected;
            
            /* Log state change for debugging */
            if (current_connected) {
                log_i("USB connected and mounted as mass storage");
            } else {
                log_i("USB disconnected or unmounted");
            }
        }
        
        /* Optional: Add CDC/MSC specific task handling here */
        /* For example: cdc_task(); if CDC is enabled */
        
        /* Delay to yield to other threads */
        // osal_task_delay(USB_TASK_TICK);
    }
}

/**
 * @brief Initialize USB protocol stack
 */
int usb_protocol_init(void)
{
    int ret = 0;
    
    if (usb_initialized) {
        log_w("USB protocol already initialized");
        return 0;
    }
    
    log_d("Initializing USB protocol stack...");
    
    /* Step 1: Initialize USB hardware via HAL */
    ret = usb_hardware_init();
    if (ret != 0) {
        log_e("USB hardware initialization failed: %d", ret);
        return ret;
    }
    
    /* Initialize USB state management */
    usb_state_init();
    
    // board_init();
    /* Step 2: Initialize TinyUSB protocol stack */
    tusb_rhport_init_t dev_init = {
        .role = TUSB_ROLE_DEVICE,
        .speed = TUSB_SPEED_AUTO
    };
    
    if (!tusb_init(BOARD_TUD_RHPORT, &dev_init)) {
        log_e("TinyUSB initialization failed");
        usb_hardware_deinit();
        return -1;
    }
    
    /* Step 3: Create USB protocol task thread */
    usb_task = osal_task_create("usb_task",
                                usb_protocol_task_entry,
                                NULL,
                                USB_TASK_STACK_SIZE,
                                USB_TASK_PRIORITY,
                                0);
    
    if (usb_task == NULL) {
        log_e("Failed to create USB task");
        usb_hardware_deinit();
        return -1;
    }
    
    /* Step 5: Start USB task thread */
    ret = osal_task_startup(usb_task);
    if (ret != 0) {
        log_e("Failed to start USB task: %d", ret);
        osal_task_delete(usb_task);
        usb_hardware_deinit();
        return ret;
    }
    
    usb_initialized = true;
    log_d("USB protocol stack initialized successfully");
    
    return 0;
}

/**
 * @brief Deinitialize USB protocol stack
 */
int usb_protocol_deinit(void)
{
    if (!usb_initialized) {
        log_w("USB protocol not initialized");
        return 0;
    }
    
    log_d("Deinitializing USB protocol stack...");
    
    /* Stop USB task */
    if (usb_task != NULL) {
        osal_task_delete(usb_task);
        usb_task = NULL;
    }
    
    /* Deinitialize hardware */
    usb_hardware_deinit();
    
    usb_initialized = false;
    log_d("USB protocol stack deinitialized");
    
    return 0;
}

/**
 * @brief Check if USB protocol stack is initialized
 */
bool usb_protocol_is_initialized(void)
{
    return usb_initialized;
}

/**
 * @brief Start USB device connection
 */
int usb_protocol_start(void)
{
    if (!usb_initialized) {
        log_e("USB protocol not initialized");
        return -1;
    }
    
    log_d("USB connection managed by TinyUSB protocol stack");
    return 0;
}

/**
 * @brief Stop USB device connection
 */
int usb_protocol_stop(void)
{
    if (!usb_initialized) {
        log_e("USB protocol not initialized");
        return -1;
    }
    
    log_d("USB disconnection managed by TinyUSB protocol stack");
    return 0;
}

/**
 * @brief Get USB device connection state
 */
bool usb_protocol_is_connected(void)
{
    if (!usb_initialized) {
        return false;
    }
    
    /* Use the shared USB state managed by the USB task */
    return usb_state_is_connected();
}