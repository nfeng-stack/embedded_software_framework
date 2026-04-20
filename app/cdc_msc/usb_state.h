/**
 * @file    usb_state.h
 * @brief   USB Connection State Management
 *
 * This module provides thread-safe USB connection state management.
 * It allows different components (e.g., logging, file system) to check
 * if USB is connected to a host and mounted as a mass storage device.
 */

#ifndef USB_STATE_H
#define USB_STATE_H

#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initialize USB state management
 * 
 * This function initializes the internal mutex for thread-safe state access.
 * Should be called during system initialization.
 */
void usb_state_init(void);

/**
 * @brief Set USB connection state
 * 
 * Updates the internal USB connection state. Should be called by the
 * USB protocol layer when connection status changes.
 * 
 * @param connected true if USB is connected and mounted, false otherwise
 */
void usb_state_set_connected(bool connected);

/**
 * @brief Check if USB is connected
 * 
 * Returns the current USB connection state in a thread-safe manner.
 * 
 * @return true if USB is connected and mounted as mass storage device,
 *         false otherwise
 */
bool usb_state_is_connected(void);

#ifdef __cplusplus
}
#endif

#endif /* USB_STATE_H */