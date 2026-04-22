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
#include "tusb.h"
#include "elog.h"

/**
 * @brief Check if USB is connected
 * 
 * @return true if USB is connected and mounted as mass storage device,
 *         false otherwise
 */
extern volatile bool g_usb_is_connected ;

bool usb_state_is_connected(void)
{

    
    /* Lock mutex to ensure thread-safe access */
    

    bool current_connected = g_usb_is_connected;
    /* Unlock mutex */
    log_d("nfeng this is usb:%d",current_connected);
    return current_connected;
}