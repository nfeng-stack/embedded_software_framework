/**
 * @file    hal_usb.c
 * @brief   USB Hardware Abstraction Layer (Common Implementation)
 *
 * This file provides the common HAL implementation for USB functionality.
 * It wraps platform-specific USB driver functions to provide a uniform
 * interface across different hardware platforms.
 */

#include <stdint.h>
#include "platform_driver.h"

/* USB HAL function implementations ------------------------------------------*/

/**
 * @brief Initialize USB peripheral
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_init(void)
{
    return platform_usb_init();
}

/**
 * @brief Deinitialize USB peripheral
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_deinit(void)
{
    return platform_usb_deinit();
}

/**
 * @brief Start USB device (connect to host)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_start(void)
{
    return platform_usb_start();
}

/**
 * @brief Stop USB device (disconnect from host)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_stop(void)
{
    return platform_usb_stop();
}

/**
 * @brief Get USB device state
 * @return USB device state
 */
uint32_t hal_usb_get_state(void)
{
    return platform_usb_get_state();
}

/**
 * @brief Check if USB device is connected
 * @return 1 if connected, 0 otherwise
 */
uint32_t hal_usb_is_connected(void)
{
    return platform_usb_is_connected();
}

/**
 * @brief Set USB device address
 * @param address Device address to set (0-127)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_set_address(uint8_t address)
{
    return platform_usb_set_address(address);
}

/**
 * @brief Open USB endpoint
 * @param ep_addr Endpoint address (direction included)
 * @param ep_type Endpoint type
 * @param ep_mps Endpoint maximum packet size
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_open(uint8_t ep_addr, uint8_t ep_type, uint16_t ep_mps)
{
    return platform_usb_ep_open(ep_addr, ep_type, ep_mps);
}

/**
 * @brief Close USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_close(uint8_t ep_addr)
{
    return platform_usb_ep_close(ep_addr);
}

/**
 * @brief Receive data on USB endpoint
 * @param ep_addr Endpoint address
 * @param pbuf Pointer to receive buffer
 * @param len Length of data to receive
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_receive(uint8_t ep_addr, uint8_t *pbuf, uint32_t len)
{
    return platform_usb_ep_receive(ep_addr, pbuf, len);
}

/**
 * @brief Transmit data on USB endpoint
 * @param ep_addr Endpoint address
 * @param pbuf Pointer to transmit buffer
 * @param len Length of data to transmit
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_transmit(uint8_t ep_addr, uint8_t *pbuf, uint32_t len)
{
    return platform_usb_ep_transmit(ep_addr, pbuf, len);
}

/**
 * @brief Stall USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_stall(uint8_t ep_addr)
{
    return platform_usb_ep_stall(ep_addr);
}

/**
 * @brief Clear stall on USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_clear_stall(uint8_t ep_addr)
{
    return platform_usb_ep_clear_stall(ep_addr);
}

/**
 * @brief Flush USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_flush(uint8_t ep_addr)
{
    return platform_usb_ep_flush(ep_addr);
}

/**
 * @brief Set USB device callback functions
 * @param callbacks Structure containing callback function pointers
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_set_callbacks(const void *callbacks)
{
    return platform_usb_set_callbacks(callbacks);
}