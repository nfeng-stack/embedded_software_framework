#include "stm32h5xx_hal.h"
#include "stm32h5xx_ll_usart.h" // 请根据您的芯片型号修改，如 stm32f1xx_ll_usart.h
#include "stm32h5xx_ll_gpio.h"  // 请根据您的芯片型号修改
#include "stm32h5xx_ll_dma.h"
#include <stdint.h>
#include <string.h>
#include "elog.h"
/* USART1 init function */

void platform_uart1_init(void)
{
    UART_HandleTypeDef huart1 = {0};

    huart1.Instance = USART1;
    huart1.Init.BaudRate = 921600;
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
// ========================
// 配置参数（可调整）
// ========================
#define RX_DMA_BUFFER_SIZE 256 // DMA 缓冲区大小（建议 2^n）
#define RING_BUFFER_SIZE 512  // 环形缓冲区总容量（建议 >= 2 * RX_DMA_BUFFER_SIZE）

// ========================
// 全局变量
// ========================
static uint8_t rx_dma_buffer[RX_DMA_BUFFER_SIZE] __attribute__((aligned(4))) = {0};
static uint8_t ring_buf[RING_BUFFER_SIZE];
static volatile uint16_t ring_head = 0; // 写入位置（ISR 更新）
static volatile uint16_t ring_tail = 0; // 读取位置（主程序更新）

// ========================
// 环形缓冲区辅助函数（内联，高效）
// ========================
static inline uint8_t ring_is_full(void)
{
    return ((ring_head + 1) % RING_BUFFER_SIZE) == ring_tail;
}

static inline uint8_t ring_is_empty(void)
{
    return ring_head == ring_tail;
}

static inline uint16_t ring_available(void)
{
    if (ring_head >= ring_tail)
    {
        return ring_head - ring_tail;
    }
    else
    {
        return RING_BUFFER_SIZE - ring_tail + ring_head;
    }
}

// 将数据写入环形缓冲区（仅在 ISR 中调用，单生产者）
static void ring_write(const uint8_t *data, uint16_t len)
{
    for (uint16_t i = 0; i < len  && !ring_is_full(); i++)
    {
        ring_buf[ring_head] = data[i];
        ring_head = (ring_head + 1) % RING_BUFFER_SIZE;
    }
    if(!ring_is_full())
    {
        ring_buf[ring_head] = '\0';
        ring_head = (ring_head + 1) % RING_BUFFER_SIZE;
    }
    // 若满则丢弃多余数据（可改为覆盖策略）
}

// 从环形缓冲区读取最多 max_len 字节（主程序调用）
uint16_t platform_uart2_read(uint8_t *buffer, uint16_t max_len)
{
    if (!buffer || max_len == 0)
        return 0;

    uint16_t avail = ring_available();
    uint16_t to_read = (avail < max_len) ? avail : max_len;

    for (uint16_t i = 0; i < to_read; i++)
    {
        buffer[i] = ring_buf[ring_tail];
        ring_tail = (ring_tail + 1) % RING_BUFFER_SIZE;
    }
    return to_read;
}

// 清空接收缓冲区（主程序调用）
void uart2_flush(void)
{
    ring_head = 0;
    ring_tail = 0;
}

void platform_uart2_init(void)
{
    /* 初始化全局UART2句柄 */
    UART_HandleTypeDef huart2 = {0};
    huart2.Instance = USART2;
    huart2.Init.BaudRate = 115200;
    huart2.Init.WordLength = UART_WORDLENGTH_8B;
    huart2.Init.StopBits = UART_STOPBITS_1;
    huart2.Init.Parity = UART_PARITY_NONE;
    huart2.Init.Mode = UART_MODE_TX_RX;
    huart2.Init.HwFlowCtl = UART_HWCONTROL_NONE;
    huart2.Init.OverSampling = UART_OVERSAMPLING_16;
    huart2.Init.OneBitSampling = UART_ONE_BIT_SAMPLE_DISABLE;
    huart2.Init.ClockPrescaler = UART_PRESCALER_DIV1;
    huart2.AdvancedInit.AdvFeatureInit = UART_ADVFEATURE_NO_INIT;

    /* 初始化UART */
    if (HAL_UART_Init(&huart2) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetTxFifoThreshold(&huart2, UART_TXFIFO_THRESHOLD_1_8) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_SetRxFifoThreshold(&huart2, UART_RXFIFO_THRESHOLD_1_8) != HAL_OK)
    {
        // Error_Handler();
    }
    if (HAL_UARTEx_DisableFifoMode(&huart2) != HAL_OK)
    {
        // Error_Handler();
    }

    LL_DMA_SetDestAddress(GPDMA1, LL_DMA_CHANNEL_0, (uint32_t)rx_dma_buffer);
    LL_DMA_SetSrcAddress(GPDMA1, LL_DMA_CHANNEL_0, (uint32_t)&USART2->RDR);
    LL_DMA_SetPeriphRequest(GPDMA1, LL_DMA_CHANNEL_0, LL_GPDMA2_REQUEST_USART2_RX);
    LL_DMA_SetBlkDataLength(GPDMA1, LL_DMA_CHANNEL_0, sizeof(rx_dma_buffer));
    LL_DMA_EnableChannel(GPDMA1, LL_DMA_CHANNEL_0);
    LL_USART_EnableDMAReq_RX(USART2);
    __HAL_UART_CLEAR_IT(&huart2, UART_IT_IDLE);
    HAL_NVIC_ClearPendingIRQ(USART2_IRQn);
    LL_USART_ClearFlag_IDLE(USART2);
    __HAL_UART_ENABLE_IT(&huart2, UART_IT_IDLE);
    HAL_NVIC_EnableIRQ(GPDMA1_Channel0_IRQn);
    __HAL_UART_ENABLE(&huart2);
}
void USART2_IRQHandler(void)
{
    HAL_NVIC_ClearPendingIRQ(USART2_IRQn);
    if (LL_USART_IsActiveFlag_IDLE(USART2))
    {
        LL_USART_ClearFlag_IDLE(USART2);
        uint32_t len = sizeof(rx_dma_buffer) - LL_DMA_GetBlkDataLength(GPDMA1, LL_DMA_CHANNEL_0);
        LL_DMA_DisableChannel(GPDMA1, LL_DMA_CHANNEL_0);
        LL_DMA_SetDestAddress(GPDMA1, LL_DMA_CHANNEL_0, (uint32_t)rx_dma_buffer);
        LL_DMA_SetBlkDataLength(GPDMA1, LL_DMA_CHANNEL_0, sizeof(rx_dma_buffer));
        LL_DMA_EnableChannel(GPDMA1, LL_DMA_CHANNEL_0);
        ring_write(rx_dma_buffer, len);
    }
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
    else if (uartHandle->Instance == USART2)
    {
        PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_USART2;
        PeriphClkInitStruct.Usart2ClockSelection = RCC_USART2CLKSOURCE_PCLK1;
        if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK)
        {
            // Error_Handler();
        }
        HAL_NVIC_ClearPendingIRQ(USART2_IRQn);
        HAL_NVIC_SetPriority(USART2_IRQn, 2, 0);
        HAL_NVIC_EnableIRQ(USART2_IRQn);
        __HAL_RCC_USART2_CLK_ENABLE();
        __HAL_RCC_GPIOA_CLK_ENABLE();
        GPIO_InitStruct.Pin = GPIO_PIN_2 | GPIO_PIN_3;
        GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
        GPIO_InitStruct.Pull = GPIO_NOPULL;
        GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
        GPIO_InitStruct.Alternate = GPIO_AF7_USART1;
        HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);

        __HAL_RCC_GPDMA1_CLK_ENABLE();

        /* GPDMA1 interrupt Init */
        HAL_NVIC_SetPriority(GPDMA1_Channel0_IRQn, 2, 0);

        /* USER CODE BEGIN GPDMA1_Init 1 */

        /* USER CODE END GPDMA1_Init 1 */
        DMA_HandleTypeDef handle_GPDMA1_Channel0 = {0};
        handle_GPDMA1_Channel0.Instance = GPDMA1_Channel0;
        handle_GPDMA1_Channel0.Init.Request = GPDMA1_REQUEST_USART2_RX;
        handle_GPDMA1_Channel0.Init.BlkHWRequest = DMA_BREQ_SINGLE_BURST;
        handle_GPDMA1_Channel0.Init.Direction = DMA_PERIPH_TO_MEMORY;
        handle_GPDMA1_Channel0.Init.SrcInc = DMA_SINC_FIXED;
        handle_GPDMA1_Channel0.Init.DestInc = DMA_DINC_INCREMENTED;
        handle_GPDMA1_Channel0.Init.SrcDataWidth = DMA_SRC_DATAWIDTH_BYTE;
        handle_GPDMA1_Channel0.Init.DestDataWidth = DMA_DEST_DATAWIDTH_BYTE;
        handle_GPDMA1_Channel0.Init.Priority = DMA_LOW_PRIORITY_HIGH_WEIGHT;
        handle_GPDMA1_Channel0.Init.SrcBurstLength = 1;
        handle_GPDMA1_Channel0.Init.DestBurstLength = 1;
        handle_GPDMA1_Channel0.Init.TransferAllocatedPort = DMA_SRC_ALLOCATED_PORT0 | DMA_DEST_ALLOCATED_PORT1;
        handle_GPDMA1_Channel0.Init.TransferEventMode = DMA_TCEM_BLOCK_TRANSFER;
        handle_GPDMA1_Channel0.Init.Mode = DMA_NORMAL;
        if (HAL_DMA_Init(&handle_GPDMA1_Channel0) != HAL_OK)
        {
            // Error_Handler();
        }
        if (HAL_DMA_ConfigChannelAttributes(&handle_GPDMA1_Channel0, DMA_CHANNEL_NPRIV) != HAL_OK)
        {
            // Error_Handler();
        }
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

/**
 * @brief  重定向 C 库的 fputc 函数（printf 会调用它）到串口
 * @param  ch: 要发送的字符
 * @retval 返回发送的字符
 */
int __io_putchar(int ch)
{
    // 等待发送数据寄存器空 (TDRE 标志位)
    while (!LL_USART_IsActiveFlag_TXE(USART1))
    {
    }
    // 将字符写入发送数据寄存器
    LL_USART_TransmitData8(USART1, (uint8_t)ch);

    // // 等待发送完成 (TC 标志位) - 确保字符已移位发送出去
    // while (!LL_USART_IsActiveFlag_TC(USART1)) {}

    return ch; // 返回发送的字符
}

void platform_uart2_write(uint8_t *buffer, uint8_t len)
{
    for (uint8_t i = 0; i < len; i++)
    {
        while (!LL_USART_IsActiveFlag_TXE(USART2))
        {
        }
        LL_USART_TransmitData8(USART2, (uint8_t)buffer[i]);
    }
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
        while (!LL_USART_IsActiveFlag_TXE(USART1))
        {
        }
        // 将字符写入发送数据寄存器
        LL_USART_TransmitData8(USART1, (uint8_t)ptr[i]);

        // 等待发送完成 (TC 标志位) - 确保字符已移位发送出去
        // while (!LL_USART_IsActiveFlag_TC(USART1)) {}
    }

    return len; // 返回成功发送的字节数
}
void output_char(int file, char *ptr, unsigned int len)
{
    my_write(file, ptr, len);
}