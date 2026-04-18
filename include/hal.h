/**
 * @file    hal.h
 * @brief   Hardware Abstraction Layer (HAL) public interface
 *
 * This file defines the hardware abstraction layer interface for embedded systems.
 * It provides a platform-independent API for accessing GPIO, UART, Timer, and
 * system initialization functions. Application code should only include this header.
 *
 * @note    This is the public interface - implementations are in hal/common and hal/<platform>
 */

#ifndef HAL_H
#define HAL_H

#include <stdint.h>

#ifdef __cplusplus
extern "C"
{
#endif

    void hal_system_clock_pre_init();
    void hal_system_clock_init();
    void hal_system_sdk_init();
    void (*hal_system_get_systemhandler(void))(void);
    void hal_uart1_init(void);
    void hal_common_iic_init(void); /* To do need add miaosu*/
    uint8_t hal_common_iic_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
    uint8_t hal_common_iic_write(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len);
    void hal_gpio_init_int(void);
    void hal_clean_it(void);
    void hal_uart2_init(void);
uint16_t hal_uart2_read(uint8_t *buffer, uint16_t max_len);
void hal_uart2_write(uint8_t *buffer);
void hal_gpio_led_audio_on(void);
void hal_gpio_led_audio_off(void);
    uint8_t hal_xspi_write_read(uint8_t instruction, uint8_t instruction_line,\
                                              uint32_t address, uint8_t address_line, uint8_t address_len, \
                                              uint32_t alternate, uint8_t alternate_line, uint8_t alternate_len,\
                                              uint8_t dummy, uint8_t *in_buf, uint32_t in_len,\
                                              uint8_t *out_buf, uint32_t out_len, uint8_t data_line);
    int32_t hal_xspi_init(void);

    /* USB HAL Functions */


/* USB Endpoint Types --------------------------------------------------------*/

/** @brief USB Endpoint Type Definitions */
#define HAL_USB_EP_TYPE_CONTROL      0x00U  /*!< Control endpoint */
#define HAL_USB_EP_TYPE_ISOCHRONOUS  0x01U  /*!< Isochronous endpoint */
#define HAL_USB_EP_TYPE_BULK         0x02U  /*!< Bulk endpoint */
#define HAL_USB_EP_TYPE_INTERRUPT    0x03U  /*!< Interrupt endpoint */

/* USB Device States ---------------------------------------------------------*/

/** @brief USB Device State Definitions */
#define HAL_USB_STATE_RESET     0x00U  /*!< USB device in reset state */
#define HAL_USB_STATE_READY     0x01U  /*!< USB device ready */
#define HAL_USB_STATE_ERROR     0x02U  /*!< USB device error */
#define HAL_USB_STATE_BUSY      0x03U  /*!< USB device busy */
#define HAL_USB_STATE_TIMEOUT   0x04U  /*!< USB device timeout */

/* USB Error Codes -----------------------------------------------------------*/

/** @brief USB Error Code Definitions */
#define HAL_USB_ERROR_NONE          0x00U  /*!< No error */
#define HAL_USB_ERROR_INIT_FAILED   0x01U  /*!< Initialization failed */
#define HAL_USB_ERROR_DEINIT_FAILED 0x02U  /*!< Deinitialization failed */
#define HAL_USB_ERROR_START_FAILED  0x03U  /*!< Start failed */
#define HAL_USB_ERROR_STOP_FAILED   0x04U  /*!< Stop failed */
#define HAL_USB_ERROR_EP_OPEN       0x05U  /*!< Endpoint open failed */
#define HAL_USB_ERROR_EP_CLOSE      0x06U  /*!< Endpoint close failed */
#define HAL_USB_ERROR_EP_RECEIVE    0x07U  /*!< Endpoint receive failed */
#define HAL_USB_ERROR_EP_TRANSMIT   0x08U  /*!< Endpoint transmit failed */

/* Function Prototypes -------------------------------------------------------*/

/**
 * @brief Initialize USB peripheral
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_init(void);

/**
 * @brief Deinitialize USB peripheral
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_deinit(void);

/**
 * @brief Start USB device (connect to host)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_start(void);

/**
 * @brief Stop USB device (disconnect from host)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_stop(void);

/**
 * @brief Get USB device state
 * @return USB device state (HAL_USB_STATE_*)
 */
uint32_t hal_usb_get_state(void);

/**
 * @brief Check if USB device is connected
 * @return 1 if connected, 0 otherwise
 */
uint32_t hal_usb_is_connected(void);

/**
 * @brief Set USB device address
 * @param address Device address to set (0-127)
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_set_address(uint8_t address);

/**
 * @brief Open USB endpoint
 * @param ep_addr Endpoint address (direction included)
 * @param ep_type Endpoint type (HAL_USB_EP_TYPE_*)
 * @param ep_mps Endpoint maximum packet size
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_open(uint8_t ep_addr, uint8_t ep_type, uint16_t ep_mps);

/**
 * @brief Close USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_close(uint8_t ep_addr);

/**
 * @brief Receive data on USB endpoint
 * @param ep_addr Endpoint address
 * @param pbuf Pointer to receive buffer
 * @param len Length of data to receive
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_receive(uint8_t ep_addr, uint8_t *pbuf, uint32_t len);

/**
 * @brief Transmit data on USB endpoint
 * @param ep_addr Endpoint address
 * @param pbuf Pointer to transmit buffer
 * @param len Length of data to transmit
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_transmit(uint8_t ep_addr, uint8_t *pbuf, uint32_t len);

/**
 * @brief Stall USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_stall(uint8_t ep_addr);

/**
 * @brief Clear stall on USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_clear_stall(uint8_t ep_addr);

/**
 * @brief Flush USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_ep_flush(uint8_t ep_addr);

/**
 * @brief Set USB device callback functions
 * @param callbacks Structure containing callback function pointers
 * @return 0 on success, negative error code on failure
 */
int32_t hal_usb_set_callbacks(const void *callbacks);

void hal_usb_clock_io_init(void);
#ifdef __cplusplus
}
#endif

#endif /* HAL_H */