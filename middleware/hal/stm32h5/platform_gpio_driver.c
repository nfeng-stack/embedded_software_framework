#include "stm32h5xx_hal.h"

void platform_gpio_set_int(void)
{
       /* INT引脚配置 (PA15) - 外部中断 */
    GPIO_InitTypeDef GPIO_InitStruct = {0};

    __HAL_RCC_GPIOA_CLK_ENABLE();
    GPIO_InitStruct.Pin = GPIO_PIN_15;
    GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
    GPIO_InitStruct.Pull = GPIO_PULLUP;  /* 上拉确保高电平 */
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
    /* 清除任何可能挂起的EXTI中断标志 */
    __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_15);
    HAL_NVIC_ClearPendingIRQ(EXTI15_IRQn);
    /* 配置NVIC */
    HAL_NVIC_SetPriority(EXTI15_IRQn, 2, 0);
    HAL_NVIC_EnableIRQ(EXTI15_IRQn);
}

void platform_gpio_clean_it(void)
{
    __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_15);
    HAL_NVIC_ClearPendingIRQ(EXTI15_IRQn);
}