/**
 * @file    usb_protocol.h
 * @brief   USB Protocol Stack Initialization and Management
 *
 * This module provides a clean interface to initialize and manage the USB
 * protocol stack using TinyUSB as the protocol layer and HAL for hardware
 * initialization. The USB stack runs in its own RTOS thread.
 */

#ifndef USB_PROTOCOL_H
#define USB_PROTOCOL_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Initialize USB hardware and protocol stack
 * 
 * This function performs:
 * 1. USB hardware initialization via HAL (clocks, GPIO, interrupts)
 * 2. TinyUSB protocol stack initialization
 * 3. Creation of USB task thread
 * 
 * @return 0 on success, negative error code on failure
 */
int usb_protocol_init(void);

/**
 * @brief Deinitialize USB protocol stack
 * 
 * Stops USB device, deinitializes protocol stack, and cleans up resources.
 * 
 * @return 0 on success, negative error code on failure
 */
int usb_protocol_deinit(void);

/**
 * @brief Check if USB protocol stack is initialized
 * 
 * @return true if initialized, false otherwise
 */
bool usb_protocol_is_initialized(void);

/**
 * @brief Start USB device connection
 * 
 * Enables USB pull-up to connect to host.
 * 
 * @return 0 on success, negative error code on failure
 */
int usb_protocol_start(void);

/**
 * @brief Stop USB device connection
 * 
 * Disables USB pull-up to disconnect from host.
 * 
 * @return 0 on success, negative error code on failure
 */
int usb_protocol_stop(void);

/**
 * @brief Get USB device connection state
 * 
 * @return true if connected to host, false otherwise
 */
bool usb_protocol_is_connected(void);

/**
 * @brief USB protocol task function (for internal use)
 * 
 * This function runs in the USB thread and calls tud_task() periodically.
 * 
 * @param arg Thread argument (unused)
 */
void usb_protocol_task_entry(void *arg);

#ifdef __cplusplus
}
#endif

#endif /* USB_PROTOCOL_H */