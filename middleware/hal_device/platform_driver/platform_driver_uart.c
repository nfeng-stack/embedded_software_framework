#include "stdio.h"
#include "hal_device.h"
#include "platform_driver_uart.h"
#include "stm32h5xx_hal.h"
#include "stm32h5xx_ll_usart.h"

int32_t platform_driver_uart_init(hal_bus_dev_uart_init_config_t *init_cfg, hal_uart_instance_e uart)
{
    UART_HandleTypeDef huart = {0};
    switch (uart)
    {
    case HAL_UART_INSTANCE_UART1:
        huart.Instance = USART1;
        break;
    case HAL_UART_INSTANCE_UART2:
        huart.Instance = USART2;
        break;
    default:
        huart.Instance = USART1;
        break;
    }
    huart.Init.BaudRate = init_cfg->baud_rate;
    switch (init_cfg->data_bits)
    {
    case HAL_UART_DATA_BITS_7:
        huart.Init.WordLength = UART_WORDLENGTH_7B;
        break;
    case HAL_UART_DATA_BITS_8:
        huart.Init.WordLength = UART_WORDLENGTH_8B;
        break;
    case HAL_UART_DATA_BITS_9:
        huart.Init.WordLength = UART_WORDLENGTH_9B;
    default:
        huart.Init.WordLength = UART_WORDLENGTH_8B;
        break;
    }
    switch (init_cfg->stop_bits)
    {
    case HAL_UART_STOP_BITS_0_5:
        huart.Init.StopBits = UART_STOPBITS_0_5;
        /* code */
        break;
    case HAL_UART_STOP_BITS_1:
        huart.Init.StopBits = UART_STOPBITS_1;
        break;
    case HAL_UART_STOP_BITS_1_5:
        huart.Init.StopBits = UART_STOPBITS_1_5;
        break;
    case HAL_UART_STOP_BITS_2:
        huart.Init.StopBits = UART_STOPBITS_2;
        break;
    default:
        huart.Init.StopBits = UART_STOPBITS_2;
        break;
    }
    switch (init_cfg->parity)
    {
    case HAL_UART_PARITY_NONE:
        huart.Init.Parity = UART_PARITY_NONE;
        break;
    case HAL_UART_PARITY_ODD:
        huart.Init.Parity = UART_PARITY_ODD;
        break;
    case HAL_UART_PARITY_EVEN:
        huart.Init.Parity = UART_PARITY_EVEN;
        break;
    default:
        huart.Init.Parity = UART_PARITY_NONE;
        break;
    }
    switch (init_cfg->flow_control)
    {
    case HAL_UART_FLOW_CONTROL_NONE:
        huart.Init.HwFlowCtl = UART_HWCONTROL_NONE;
        /* code */
        break;
    case HAL_UART_FLOW_CONTROL_RTS_CTS:
        huart.Init.HwFlowCtl = UART_HWCONTROL_RTS_CTS;
        break;
    default:
        huart.Init.HwFlowCtl = UART_HWCONTROL_NONE;
        break;
    }
    huart.Init.Mode = UART_MODE_TX_RX;
    huart.Init.OverSampling = UART_OVERSAMPLING_16;
    huart.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
    huart.Init.ClockPrescaler = UART_PRESCALER_DIV1;
    huart.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
    if (HAL_UART_Init(&huart) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetTxFifoThreshold(&huart, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetRxFifoThreshold(&huart, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_DisableFifoMode(&huart) != HAL_OK)
    {
        // Error_Handler();
    }
    // HAL_UART_Transmit(&huart,"hello world\n",10,0xffffffff);
    // __HAL_UART_ENABLE(&huart);
    return 0;
}

int32_t plaform_driver_uart_open(hal_uart_instance_e uart)
{
    switch (uart)
    {
    case HAL_UART_INSTANCE_UART1:
        LL_USART_Enable(USART1);
        /* code */
        break;
    case HAL_UART_INSTANCE_UART2:
        LL_USART_Enable(USART2);
        break;
    default:
        break;
    }
    return 0;
}
int32_t plaform_driver_uart_close(hal_uart_instance_e uart)
{
    switch (uart)
    {
    case HAL_UART_INSTANCE_UART1:
        LL_USART_Disable(USART1);
        /* code */
        break;
    case HAL_UART_INSTANCE_UART2:
        LL_USART_Disable(USART2);
        break;
    default:
        break;
    }
    return 0;
}

void HAL_UART_MspInit(UART_HandleTypeDef *uartHandle)
{

    GPIO_InitTypeDef GPIO_InitStruct = {0};
    RCC_PeriphCLKInitTypeDef PeriphClkInitStruct = {0};
    if (uartHandle->Instance == USART1)
    {
        /* USER CODE BEGIN USART1_MspInit 0 */

        /* USER CODE END USART1_MspInit 0 */

        /** Initializes the peripherals clock
         */
        PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_USART1;
        PeriphClkInitStruct.Usart1ClockSelection = RCC_USART1CLKSOURCE_PCLK2;
        if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
        {
            // Error_Handler();
        }

        /* USART1 clock enable */
        __HAL_RCC_USART1_CLK_ENABLE();

        __HAL_RCC_GPIOA_CLK_ENABLE();
        /**USART1 GPIO Configuration
        PA9     ------> USART1_TX
        PA10     ------> USART1_RX
        */
        GPIO_InitStruct.Pin = GPIO_PIN_9 | GPIO_PIN_10;
        GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
        GPIO_InitStruct.Pull = GPIO_NOPULL;
        GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
        GPIO_InitStruct.Alternate = GPIO_AF7_USART1;
        HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

        /* USER CODE BEGIN USART1_MspInit 1 */

        /* USER CODE END USART1_MspInit 1 */
    }
    else if (uartHandle->Instance == USART2)
    {
        PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_USART2;
        PeriphClkInitStruct.Usart2ClockSelection = RCC_USART2CLKSOURCE_PCLK1;
        if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
        {
            // Error_Handler();
        }
        __HAL_RCC_USART2_CLK_ENABLE();
        __HAL_RCC_GPIOA_CLK_ENABLE();
        GPIO_InitStruct.Pin = GPIO_PIN_2 | GPIO_PIN_3;
        GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
        GPIO_InitStruct.Pull = GPIO_NOPULL;
        GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
        GPIO_InitStruct.Alternate = GPIO_AF7_USART1;
        HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
        /* code */
    }
}