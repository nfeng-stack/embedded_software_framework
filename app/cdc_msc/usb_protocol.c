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


/* 添加磁盘锁控制函数声明 */

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
static uint32_t last_state_change_tick = 0;
static uint32_t last_connect_attempt_tick = 0;

/* Forward declarations */
static int usb_hardware_init(void);
static int usb_hardware_deinit(void);
static void usb_protocol_update_connection_state(void);
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
    
    while (1) {
        /* Process USB events - this handles all USB communication */
        tud_task();
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


