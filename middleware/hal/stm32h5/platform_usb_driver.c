/**
 * @file    platform_usb_driver.c
 * @brief   STM32H5 USB Platform Driver Implementation
 *
 * This file implements USB hardware abstraction layer for STM32H5 platform.
 * It provides initialization, GPIO configuration, clock setup, and basic
 * USB device controller operations using STM32 HAL PCD driver.
 */

#include "stm32h5xx_hal.h"
#include "stm32h5xx_ll_usb.h"
#include "stm32h5xx_hal_pcd.h"
#include "stm32h5xx_hal_pcd_ex.h"
#include <stdint.h>
#include <string.h>
#include "elog.h"

/* Private variables ---------------------------------------------------------*/

/**
 * @brief Global USB PCD handle
 */
static PCD_HandleTypeDef hpcd_USB_DRD_FS;

/**
 * @brief USB endpoint buffers (allocated statically for now)
 */
static uint8_t usb_ep0_rx_buffer[64];
static uint8_t usb_ep0_tx_buffer[64];

/* Private function prototypes -----------------------------------------------*/

static void USB_Clock_Config(void);
static void USB_GPIO_Config(void);
static void USB_Interrupt_Config(void);

/* Public function prototypes -----------------------------------------------*/
void platform_usb_clock_io_init(void);

/* Private functions ---------------------------------------------------------*/

/**
 * @brief Configure USB clock source (HSI48 for 48MHz)
 */
static void USB_Clock_Config(void)
{
    RCC_PeriphCLKInitTypeDef PeriphClkInit = {0};

    /* Select HSI48 as USB clock source */
    PeriphClkInit.PeriphClockSelection = RCC_PERIPHCLK_USB;
    PeriphClkInit.UsbClockSelection = RCC_USBCLKSOURCE_HSI48;

    if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInit) != HAL_OK) {
        log_e("USB clock configuration failed");
        /* Error handling can be added here */
    }

    /* Enable USB peripheral clock */
    __HAL_RCC_USB_CLK_ENABLE();
}

/**
 * @brief Configure USB GPIO pins (PA11: DM, PA12: DP)
 */
static void USB_GPIO_Config(void)
{
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    /* Enable GPIOA clock */
    __HAL_RCC_GPIOA_CLK_ENABLE();

    /* Configure PA11 as USB DM (Data Minus) */
    GPIO_InitStruct.Pin = GPIO_PIN_11;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    GPIO_InitStruct.Alternate = GPIO_AF10_USB;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    /* Configure PA12 as USB DP (Data Plus) */
    GPIO_InitStruct.Pin = GPIO_PIN_12;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

    log_d("USB GPIO configured (PA11-DM, PA12-DP, AF10)");
}

/**
 * @brief Configure USB interrupts (IRQ 89)
 */
static void USB_Interrupt_Config(void)
{
    /* Configure USB interrupt priority */
    HAL_NVIC_SetPriority(USB_DRD_FS_IRQn, 5, 0);
    
    /* Enable USB interrupt */
    HAL_NVIC_EnableIRQ(USB_DRD_FS_IRQn);
    
    log_d("USB interrupt configured (IRQ 89, priority 5)");
}

/**
 * @brief HAL PCD MSP Initialization
 *        This function configures the hardware resources for USB peripheral
 */
void HAL_PCD_MspInit(PCD_HandleTypeDef *pcdHandle)
{
    if (pcdHandle->Instance == USB_DRD_FS) {
        /* Configure USB clock, GPIO, and interrupts via platform function */
        platform_usb_clock_io_init();
        
        log_d("USB MSP initialization complete");
    }
}
void platform_usb_clock_io_init(void)
{
    static bool initialized = false;
    
    if (initialized) {
        return;
    }
    
    USB_Clock_Config();
        
    /* Configure USB GPIO */
    USB_GPIO_Config();
        
    /* Configure USB interrupts */
    USB_Interrupt_Config();
    HAL_PWREx_EnableVddUSB();
    
    initialized = true;
}
/**
 * @brief HAL PCD MSP De-Initialization
 */
void HAL_PCD_MspDeInit(PCD_HandleTypeDef *pcdHandle)
{
    if (pcdHandle->Instance == USB_DRD_FS) {
        /* Disable USB peripheral clock */
        __HAL_RCC_USB_CLK_DISABLE();
        
        /* De-initialize GPIO pins */
        HAL_GPIO_DeInit(GPIOA, GPIO_PIN_11 | GPIO_PIN_12);
        
        /* Disable USB interrupt */
        HAL_NVIC_DisableIRQ(USB_DRD_FS_IRQn);
        
        log_d("USB MSP de-initialization complete");
    }
}

/* Public functions ----------------------------------------------------------*/

/**
 * @brief Initialize USB peripheral
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_init(void)
{
    log_d("Initializing USB peripheral...");
    
    /* Initialize PCD handle */
    hpcd_USB_DRD_FS.Instance = USB_DRD_FS;
    hpcd_USB_DRD_FS.Init.dev_endpoints = 8;
    hpcd_USB_DRD_FS.Init.speed = PCD_SPEED_FULL;
    hpcd_USB_DRD_FS.Init.phy_itface = PCD_PHY_EMBEDDED;
    hpcd_USB_DRD_FS.Init.Sof_enable = DISABLE;
    hpcd_USB_DRD_FS.Init.low_power_enable = DISABLE;
    hpcd_USB_DRD_FS.Init.lpm_enable = DISABLE;
    hpcd_USB_DRD_FS.Init.battery_charging_enable = DISABLE;
    /* Initialize USB peripheral */
    if (HAL_PCD_Init(&hpcd_USB_DRD_FS) != HAL_OK) {
        log_e("USB initialization failed");
        return -1;
    }
    
    /* Configure EP0 (Control Endpoint) */
    HAL_PCDEx_PMAConfig(&hpcd_USB_DRD_FS, 0x00, PCD_SNG_BUF, 0x40);
    HAL_PCDEx_PMAConfig(&hpcd_USB_DRD_FS, 0x80, PCD_SNG_BUF, 0x80);
    
    log_d("USB initialization successful");
    return 0;
}

/**
 * @brief Deinitialize USB peripheral
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_deinit(void)
{
    log_d("Deinitializing USB peripheral...");
    
    if (HAL_PCD_DeInit(&hpcd_USB_DRD_FS) != HAL_OK) {
        log_e("USB deinitialization failed");
        return -1;
    }
    
    log_d("USB deinitialization successful");
    return 0;
}

/**
 * @brief Start USB device (connect to host)
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_start(void)
{
    log_d("Starting USB device...");
    
    /* Start USB device */
    if (HAL_PCD_Start(&hpcd_USB_DRD_FS) != HAL_OK) {
        log_e("USB start failed");
        return -1;
    }
    
    log_d("USB device started");
    return 0;
}

/**
 * @brief Stop USB device (disconnect from host)
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_stop(void)
{
    log_d("Stopping USB device...");
    
    /* Stop USB device */
    HAL_PCD_Stop(&hpcd_USB_DRD_FS);
    
    log_d("USB device stopped");
    return 0;
}

/**
 * @brief Get USB device state
 * @return USB device state (HAL_PCD_STATE_*)
 */
uint32_t platform_usb_get_state(void)
{
    return hpcd_USB_DRD_FS.State;
}

/**
 * @brief Check if USB device is connected
 * @return 1 if connected, 0 otherwise
 */
uint32_t platform_usb_is_connected(void)
{
    /* Simple check based on device state */
    return (hpcd_USB_DRD_FS.State == HAL_PCD_STATE_READY);
}

/**
 * @brief Set USB device address
 * @param address Device address to set
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_set_address(uint8_t address)
{
    HAL_PCD_SetAddress(&hpcd_USB_DRD_FS, address);
    return 0;
}

/**
 * @brief Open USB endpoint
 * @param ep_addr Endpoint address (direction included)
 * @param ep_type Endpoint type (BULK, INTERRUPT, ISOCHRONOUS, CONTROL)
 * @param ep_mps Endpoint maximum packet size
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_ep_open(uint8_t ep_addr, uint8_t ep_type, uint16_t ep_mps)
{
    if (HAL_PCD_EP_Open(&hpcd_USB_DRD_FS, ep_addr, ep_mps, ep_type) != HAL_OK) {
        log_e("Failed to open endpoint 0x%02x", ep_addr);
        return -1;
    }
    return 0;
}

/**
 * @brief Close USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_ep_close(uint8_t ep_addr)
{
    HAL_PCD_EP_Close(&hpcd_USB_DRD_FS, ep_addr);
    return 0;
}

/**
 * @brief Receive data on USB endpoint
 * @param ep_addr Endpoint address
 * @param pbuf Pointer to receive buffer
 * @param len Length of data to receive
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_ep_receive(uint8_t ep_addr, uint8_t *pbuf, uint32_t len)
{
    if (HAL_PCD_EP_Receive(&hpcd_USB_DRD_FS, ep_addr, pbuf, len) != HAL_OK) {
        log_e("Failed to start receive on endpoint 0x%02x", ep_addr);
        return -1;
    }
    return 0;
}

/**
 * @brief Transmit data on USB endpoint
 * @param ep_addr Endpoint address
 * @param pbuf Pointer to transmit buffer
 * @param len Length of data to transmit
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_ep_transmit(uint8_t ep_addr, uint8_t *pbuf, uint32_t len)
{
    if (HAL_PCD_EP_Transmit(&hpcd_USB_DRD_FS, ep_addr, pbuf, len) != HAL_OK) {
        log_e("Failed to start transmit on endpoint 0x%02x", ep_addr);
        return -1;
    }
    return 0;
}

/**
 * @brief Stall USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_ep_stall(uint8_t ep_addr)
{
    HAL_PCD_EP_SetStall(&hpcd_USB_DRD_FS, ep_addr);
    return 0;
}

/**
 * @brief Clear stall on USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_ep_clear_stall(uint8_t ep_addr)
{
    HAL_PCD_EP_ClrStall(&hpcd_USB_DRD_FS, ep_addr);
    return 0;
}

/**
 * @brief Flush USB endpoint
 * @param ep_addr Endpoint address
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_ep_flush(uint8_t ep_addr)
{
    HAL_PCD_EP_Flush(&hpcd_USB_DRD_FS, ep_addr);
    return 0;
}

/**
 * @brief Set USB device callback functions
 * @param callbacks Structure containing callback function pointers
 * @return 0 on success, negative error code on failure
 */
int32_t platform_usb_set_callbacks(const void *callbacks)
{
    /* Callback registration will be implemented when USE_HAL_PCD_REGISTER_CALLBACKS is enabled */
    (void)callbacks;
    log_d("USB callbacks registration not yet implemented");
    return 0;
}

/* Interrupt Handler ---------------------------------------------------------*/

/**
 * @brief USB DRD FS Interrupt Handler
 *        Overrides the weak symbol in irq_handlers_stm32h5.h
 */
// void USB_DRD_FS_IRQHandler(void)
// {
//     /* Call HAL PCD IRQ handler */
   
    
//     /* Note: Application-specific interrupt handling can be added here */
// }

/* Weak callback implementations ---------------------------------------------*/

/**
 * @brief Default USB Setup Stage callback (weak implementation)
 * @param hpcd PCD handle pointer
 */
__weak void HAL_PCD_SetupStageCallback(PCD_HandleTypeDef *hpcd)
{
    (void)hpcd;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB Data Out Stage callback (weak implementation)
 * @param hpcd PCD handle pointer
 * @param epnum Endpoint number
 */
__weak void HAL_PCD_DataOutStageCallback(PCD_HandleTypeDef *hpcd, uint8_t epnum)
{
    (void)hpcd;
    (void)epnum;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB Data In Stage callback (weak implementation)
 * @param hpcd PCD handle pointer
 * @param epnum Endpoint number
 */
__weak void HAL_PCD_DataInStageCallback(PCD_HandleTypeDef *hpcd, uint8_t epnum)
{
    (void)hpcd;
    (void)epnum;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB SOF callback (weak implementation)
 * @param hpcd PCD handle pointer
 */
__weak void HAL_PCD_SOFCallback(PCD_HandleTypeDef *hpcd)
{
    (void)hpcd;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB Reset callback (weak implementation)
 * @param hpcd PCD handle pointer
 */
__weak void HAL_PCD_ResetCallback(PCD_HandleTypeDef *hpcd)
{
    (void)hpcd;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB Suspend callback (weak implementation)
 * @param hpcd PCD handle pointer
 */
__weak void HAL_PCD_SuspendCallback(PCD_HandleTypeDef *hpcd)
{
    (void)hpcd;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB Resume callback (weak implementation)
 * @param hpcd PCD handle pointer
 */
__weak void HAL_PCD_ResumeCallback(PCD_HandleTypeDef *hpcd)
{
    (void)hpcd;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB Connect callback (weak implementation)
 * @param hpcd PCD handle pointer
 */
__weak void HAL_PCD_ConnectCallback(PCD_HandleTypeDef *hpcd)
{
    (void)hpcd;
    /* Default implementation - can be overridden by application */
}

/**
 * @brief Default USB Disconnect callback (weak implementation)
 * @param hpcd PCD handle pointer
 */
__weak void HAL_PCD_DisconnectCallback(PCD_HandleTypeDef *hpcd)
{
    (void)hpcd;
    /* Default implementation - can be overridden by application */
}
