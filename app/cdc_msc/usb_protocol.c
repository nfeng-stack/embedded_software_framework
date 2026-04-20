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

/* Function declarations */
void tud_sof_cb(uint32_t frame_count);
void usb_protocol_request_disconnect(void);
static void usb_protocol_check_sof_timeout(void);
static void usb_protocol_update_connection_state(void);

/* USB task configuration */
#define USB_TASK_STACK_SIZE      (2048)
#define USB_TASK_PRIORITY        (8)     /* Higher number = lower priority */
#define USB_TASK_TICK            (1)     /* 1 system tick delay */

/* USB ejection and reconnect state machine */
typedef enum {
    USB_STATE_CONNECTED,      /* Normal connected state */
    USB_STATE_EJECTED,        /* Safe ejected, waiting for disconnect */
    USB_STATE_DISCONNECTED,   /* Actively disconnected (after tud_disconnect()) */
    USB_STATE_WAIT_RECONNECT  /* Waiting for physical reconnection */
} usb_state_t;

/* SOF monitoring configuration */
#define SOF_TIMEOUT_MS          100     /* 100ms timeout for SOF detection (10 SOF frames) */
#define RECONNECT_DETECT_MS     10      /* 10ms continuous SOF to detect physical reconnect */
#define MIN_RECONNECT_INTERVAL_MS 500   /* Minimum interval between reconnect attempts */

/* Static variables */
static bool usb_initialized = false;
static osal_task_t usb_task = NULL;
static volatile uint32_t last_sof_tick = 0;
static usb_state_t usb_state = USB_STATE_CONNECTED;
static uint32_t last_state_change_tick = 0;
static uint32_t last_connect_attempt_tick = 0;

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
    
    bool last_shared_state = false;
    uint32_t last_check_tick = osal_tick_get();
    
    while (1) {
        /* Process USB events - this handles all USB communication */
        tud_task();
        
        /* Check SOF timeout and update USB state machine */
        usb_protocol_check_sof_timeout();
        
        /* Update shared connection state for other components */
        usb_protocol_update_connection_state();
        
        /* Log state changes for debugging */
        bool current_shared_state = usb_state_is_connected();
        if (current_shared_state != last_shared_state) {
            last_shared_state = current_shared_state;
            if (current_shared_state) {
                log_i("USB: Connected and mounted as mass storage");
            } else {
                log_i("USB: Disconnected or unmounted");
            }
        }
        
        /* Optional: Add CDC/MSC specific task handling here */
        /* For example: cdc_task(); if CDC is enabled */
        
        /* Delay to yield to other threads */
        /* Reduced delay for more responsive SOF timeout detection */
        osal_task_delay(1);
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

    /* Enable SOF callback for physical disconnect detection */
    tud_sof_cb_enable(true);
    log_d("SOF callback enabled for disconnect detection");
    
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

/*--------------------------------------------------------------------------*/
/* SOF and State Machine Implementation */
/*--------------------------------------------------------------------------*/

/**
 * @brief SOF callback function
 * 
 * Called by TinyUSB on each SOF (Start of Frame) interrupt.
 * Updates the last SOF timestamp for disconnect detection.
 */
void tud_sof_cb(uint32_t frame_count)
{
    (void)frame_count;
    last_sof_tick = osal_tick_get();
}

/**
 * @brief Request USB disconnect after safe eject
 * 
 * Called by MSC layer when host safely ejects the disk.
 * This function disconnects the USB device to prevent auto-reconnection.
 */
void usb_protocol_request_disconnect(void)
{
    if (!usb_initialized) {
        return;
    }
    
    if (usb_state == USB_STATE_CONNECTED) {
        log_i("USB: Safe eject detected, disconnecting USB device");
        tud_disconnect();
        usb_state = USB_STATE_DISCONNECTED;
        last_state_change_tick = osal_tick_get();
        last_connect_attempt_tick = last_state_change_tick;
    }
}

/**
 * @brief Check SOF timeout and update USB state
 * 
 * This function should be called periodically to detect physical
 * disconnection based on SOF timeout.
 */
static void usb_protocol_check_sof_timeout(void)
{
    uint32_t now = osal_tick_get();
    uint32_t sof_elapsed = now - last_sof_tick;
    
    switch (usb_state) {
        case USB_STATE_CONNECTED:
            /* Check for SOF timeout indicating physical disconnect */
            if (sof_elapsed > osal_tick_from_millisecond(SOF_TIMEOUT_MS)) {
                log_i("USB: SOF timeout, physical disconnect detected");
                usb_state = USB_STATE_WAIT_RECONNECT;
                last_state_change_tick = now;
            }
            break;
            
        case USB_STATE_DISCONNECTED:
            /* After safe eject, wait for physical disconnect detection */
            if (sof_elapsed > osal_tick_from_millisecond(SOF_TIMEOUT_MS)) {
                log_i("USB: Physical disconnect confirmed after safe eject");
                usb_state = USB_STATE_WAIT_RECONNECT;
                last_state_change_tick = now;
            }
            break;
            
        case USB_STATE_WAIT_RECONNECT:
            /* Check for SOF recovery indicating physical reconnection */
            if (sof_elapsed <= osal_tick_from_millisecond(RECONNECT_DETECT_MS)) {
                /* SOF detected, check if enough time has passed since last attempt */
                if ((now - last_connect_attempt_tick) > osal_tick_from_millisecond(MIN_RECONNECT_INTERVAL_MS)) {
                    log_i("USB: Physical reconnect detected, attempting to connect");
                    tud_connect();
                    usb_state = USB_STATE_CONNECTED;
                    last_state_change_tick = now;
                    last_connect_attempt_tick = now;
                }
            }
            break;
            
        case USB_STATE_EJECTED:
            /* Should not happen, but handle gracefully */
            usb_state = USB_STATE_DISCONNECTED;
            break;
    }
}

/**
 * @brief Update USB connection state based on TinyUSB state
 * 
 * This function updates the shared USB state for other components.
 */
static void usb_protocol_update_connection_state(void)
{
    bool current_connected = tud_connected() && tud_mounted();
    
    /* Only update shared state if we're in CONNECTED state */
    if (usb_state == USB_STATE_CONNECTED) {
        usb_state_set_connected(current_connected);
    } else {
        /* In other states, force disconnected state */
        usb_state_set_connected(false);
    }
}