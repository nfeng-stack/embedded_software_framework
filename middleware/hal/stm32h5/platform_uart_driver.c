#include "stm32h5xx_hal.h"
#include "stm32h5xx_ll_usart.h" // 请根据您的芯片型号修改，如 stm32f1xx_ll_usart.h
#include "stm32h5xx_ll_gpio.h"  // 请根据您的芯片型号修改

/* USART1 init function */

void platform_uart1_init(void)
{
    UART_HandleTypeDef huart1 = {0};

    huart1.Instance = USART1;
    huart1.Init.BaudRate = 115200;
    huart1.Init.WordLength = UART_WORDLENGTH_8B;
    huart1.Init.StopBits = UART_STOPBITS_1;
    huart1.Init.Parity = UART_PARITY_NONE;
    huart1.Init.Mode = UART_MODE_TX_RX;
    huart1.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    huart1.Init.OverSampling = UART_OVERSAMPLING_16;
    huart1.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
    huart1.Init.ClockPrescaler = UART_PRESCALER_DIV1;
    huart1.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;
    if (HAL_UART_Init(&huart1) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetTxFifoThreshold(&huart1, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetRxFifoThreshold(&huart1, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_DisableFifoMode(&huart1) != HAL_OK)
    {
        // Error_Handler();
    }
    // HAL_UART_Transmit(&huart1,"hello world\n",10,0xffffffff);
    __HAL_UART_ENABLE(&huart1);
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
        GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
        GPIO_InitStruct.Alternate = GPIO_AF7_USART1;
        HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

        /* USER CODE BEGIN USART1_MspInit 1 */

        /* USER CODE END USART1_MspInit 1 */
    }
}

void HAL_UART_MspDeInit(UART_HandleTypeDef *uartHandle)
{

    if (uartHandle->Instance == USART1)
    {
        /* USER CODE BEGIN USART1_MspDeInit 0 */

        /* USER CODE END USART1_MspDeInit 0 */
        /* Peripheral clock disable */
        __HAL_RCC_USART1_CLK_DISABLE();

        /**USART1 GPIO Configuration
        PA9     ------> USART1_TX
        PA10     ------> USART1_RX
        */
        HAL_GPIO_DeInit(GPIOA, GPIO_PIN_9 | GPIO_PIN_10);

        /* USER CODE BEGIN USART1_MspDeInit 1 */

        /* USER CODE END USART1_MspDeInit 1 */
    }
}


/* USER CODE BEGIN 1 */


/**
 * @brief  重定向 C 库的 fputc 函数（printf 会调用它）到串口
 * @param  ch: 要发送的字符
 * @retval 返回发送的字符
 */
int __io_putchar(int ch)
{
    // 等待发送数据寄存器空 (TDRE 标志位)
    while (!LL_USART_IsActiveFlag_TXE(USART1)) {}
    // 将字符写入发送数据寄存器
    LL_USART_TransmitData8(USART1, (uint8_t)ch);

    // // 等待发送完成 (TC 标志位) - 确保字符已移位发送出去
    // while (!LL_USART_IsActiveFlag_TC(USART1)) {}

    return ch; // 返回发送的字符
}

/**
 * @brief  重定向 C 库的 _write 函数（fwrite 等会调用它）到串口
 * @param  file: 文件句柄（未使用）
 * @param  ptr:  要发送的数据指针
 * @param  len:  数据长度
 * @retval 成功返回发送的字节数，失败返回 -1
 */
int my_write(int file, char *ptr, unsigned int len)
{
    // HAL_UART_Transmit(&huart1,ptr,len,0xffffffff);
    (void)file; // 忽略文件句柄参数

    for (int i = 0; i < len; i++)
    {
        // 等待发送数据寄存器空 (TDRE 标志位)
        while (!LL_USART_IsActiveFlag_TXE(USART1)) {}
        // 将字符写入发送数据寄存器
        LL_USART_TransmitData8(USART1, (uint8_t)ptr[i]);

        // 等待发送完成 (TC 标志位) - 确保字符已移位发送出去
        // while (!LL_USART_IsActiveFlag_TC(USART1)) {}
    }

    return len; // 返回成功发送的字节数
}
/* USER CODE END 1 */
void output_char(int file, char *ptr, unsigned int len)
{
    my_write(file,ptr,len);
}