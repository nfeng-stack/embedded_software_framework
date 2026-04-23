#include "stm32h5xx_hal.h"

void platform_gpio_set_int(void) {
  /* INT引脚配置 (PA15) - 外部中断 */
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  __HAL_RCC_GPIOA_CLK_ENABLE();
  GPIO_InitStruct.Pin = GPIO_PIN_15;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_FALLING;
  GPIO_InitStruct.Pull = GPIO_PULLUP; /* 上拉确保高电平 */
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
  /* 清除任何可能挂起的EXTI中断标志 */
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_15);
  HAL_NVIC_ClearPendingIRQ(EXTI15_IRQn);
  GPIO_InitStruct.Pin = GPIO_PIN_3 ;
  GPIO_InitStruct.Mode = GPIO_MODE_IT_RISING;
  HAL_GPIO_Init(GPIOB,&GPIO_InitStruct);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_3);
  HAL_NVIC_ClearPendingIRQ(EXTI3_IRQn);
  HAL_NVIC_SetPriority(EXTI3_IRQn, 2, 0);
  HAL_NVIC_EnableIRQ(EXTI3_IRQn);
  /* 配置NVIC */
  HAL_NVIC_SetPriority(EXTI15_IRQn, 2, 0);
  HAL_NVIC_EnableIRQ(EXTI15_IRQn);
}

void platform_gpio_clean_it(void) {
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_15);
  HAL_NVIC_ClearPendingIRQ(EXTI15_IRQn);
}
/**
 * 由于硬件的问题，对于电灯需要使用特殊的io驱动方式
 */
void platform_gpio_set_hight_spec(void) {
  HAL_GPIO_DeInit(GPIOA, GPIO_PIN_5);
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  GPIO_InitStruct.Pin = GPIO_PIN_5;
  GPIO_InitStruct.Mode = GPIO_MODE_INPUT;
  GPIO_InitStruct.Pull = GPIO_NOPULL;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
}

void platform_gpio_set_low_spec(void) {
  HAL_GPIO_DeInit(GPIOA, GPIO_PIN_5);
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  GPIO_InitStruct.Pin = GPIO_PIN_5;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET);
}
extern uint8_t is_send_msg;
void EXTI3_IRQHandler(void)
{
  platform_gpio_set_hight_spec();
  is_send_msg = 0;
  while(HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_3) != GPIO_PIN_SET);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_3);
  HAL_NVIC_ClearPendingIRQ(EXTI3_IRQn);

}