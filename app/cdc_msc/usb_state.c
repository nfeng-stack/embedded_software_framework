/**
 * @file    usb_state.c
 * @brief   USB Connection State Management Implementation
 *
 * This module implements thread-safe USB connection state management.
 * It uses a mutex to protect the state variable from concurrent access.
 */

#include <stdbool.h>
#include <stdint.h>
#include <stddef.h>  /* for NULL */
#include "osal.h"
#include "usb_state.h"

/* Internal state variables */
static bool usb_connected = false;
static osal_mutex_t usb_state_mutex = NULL;

/**
 * @brief Initialize USB state management
 */
void usb_state_init(void)
{
    /* Create mutex for thread-safe state access */
    usb_state_mutex = osal_mutex_create("usb_state", 0);
    
    /* Initial state: USB not connected */
    usb_connected = false;
}

/**
 * @brief Set USB connection state
 * 
 * @param connected true if USB is connected and mounted, false otherwise
 */
void usb_state_set_connected(bool connected)
{
    /* Check if mutex is initialized */
    if (usb_state_mutex == NULL) {
        return;
    }
    
    /* Lock mutex to ensure thread-safe access */
    osal_mutex_take(usb_state_mutex, -1);  /* -1 = wait forever */
    
    /* Update state */
    usb_connected = connected;
    
    /* Unlock mutex */
    osal_mutex_release(usb_state_mutex);
}

/**
 * @brief Check if USB is connected
 * 
 * @return true if USB is connected and mounted as mass storage device,
 *         false otherwise
 */
bool usb_state_is_connected(void)
{
    bool connected;
    
    /* Check if mutex is initialized */
    if (usb_state_mutex == NULL) {
        return false;
    }
    
    /* Lock mutex to ensure thread-safe access */
    osal_mutex_take(usb_state_mutex, -1);  /* -1 = wait forever */
    
    /* Copy state to local variable */
    connected = usb_connected;
    
    /* Unlock mutex */
    osal_mutex_release(usb_state_mutex);
    
    return connected;
}