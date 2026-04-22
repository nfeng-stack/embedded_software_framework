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

 
bool usb_state_is_connected(void);

#ifdef __cplusplus
}
#endif

#endif /* USB_STATE_H */