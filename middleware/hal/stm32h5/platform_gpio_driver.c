#include "stm32h5xx_hal.h"

void platform_gpio_set_int(void) {
  /* INT引脚配置 (PA15) - 外部中断 */
  GPIO_InitTypeDef GPIO_InitStruct = {0};

  __HAL_RCC_GPIOA_CLK_ENABLE();
  GPIO_InitStruct.Pin = GPIO_PIN_5;
  GPIO_InitStruct.Mode = GPIO_MODE_OUTPUT_PP;
  GPIO_InitStruct.Pull = GPIO_PULLDOWN;
  GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_LOW;
  HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET);

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

#ifdef LIVE_TEST_MODE
  /* Live Test 模式: 4个用户按钮 */
  GPIO_InitTypeDef btn_cfg = {0};
  btn_cfg.Mode = GPIO_MODE_IT_RISING;
  btn_cfg.Pull = GPIO_PULLUP;
  btn_cfg.Speed = GPIO_SPEED_FREQ_LOW;

  __HAL_RCC_GPIOC_CLK_ENABLE();
  btn_cfg.Pin = GPIO_PIN_0;
  HAL_GPIO_Init(GPIOC, &btn_cfg);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_0);
  HAL_NVIC_ClearPendingIRQ(EXTI0_IRQn);
  HAL_NVIC_SetPriority(EXTI0_IRQn, 2, 0);
  HAL_NVIC_EnableIRQ(EXTI0_IRQn);

  btn_cfg.Pin = GPIO_PIN_1;
  HAL_GPIO_Init(GPIOC, &btn_cfg);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_1);
  HAL_NVIC_ClearPendingIRQ(EXTI1_IRQn);
  HAL_NVIC_SetPriority(EXTI1_IRQn, 2, 0);
  HAL_NVIC_EnableIRQ(EXTI1_IRQn);

  __HAL_RCC_GPIOD_CLK_ENABLE();
  btn_cfg.Pin = GPIO_PIN_2;
  HAL_GPIO_Init(GPIOD, &btn_cfg);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_2);
  HAL_NVIC_ClearPendingIRQ(EXTI2_IRQn);
  HAL_NVIC_SetPriority(EXTI2_IRQn, 2, 0);
  HAL_NVIC_EnableIRQ(EXTI2_IRQn);
#endif
}

void platform_gpio_clean_it(void) {
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_15);
  HAL_NVIC_ClearPendingIRQ(EXTI15_IRQn);
}
/**
 * 由于硬件的问题，对于电灯需要使用特殊的io驱动方式
 */
void platform_gpio_set_hight_spec(void) {
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_SET);
}

void platform_gpio_set_low_spec(void) {
  HAL_GPIO_WritePin(GPIOA, GPIO_PIN_5, GPIO_PIN_RESET);
}
#ifdef LIVE_TEST_MODE

extern volatile uint8_t btn_pending[4];

void EXTI0_IRQHandler(void)
{
  btn_pending[0] = 1;
  while(HAL_GPIO_ReadPin(GPIOC, GPIO_PIN_0) != GPIO_PIN_SET);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_0);
  HAL_NVIC_ClearPendingIRQ(EXTI0_IRQn);
}

void EXTI1_IRQHandler(void)
{
  btn_pending[1] = 1;
  while(HAL_GPIO_ReadPin(GPIOC, GPIO_PIN_1) != GPIO_PIN_SET);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_1);
  HAL_NVIC_ClearPendingIRQ(EXTI1_IRQn);
}

void EXTI3_IRQHandler(void)
{
  btn_pending[2] = 1;
  while(HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_3) != GPIO_PIN_SET);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_3);
  HAL_NVIC_ClearPendingIRQ(EXTI3_IRQn);
}

void EXTI2_IRQHandler(void)
{
  btn_pending[3] = 1;
  while(HAL_GPIO_ReadPin(GPIOD, GPIO_PIN_2) != GPIO_PIN_SET);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_2);
  HAL_NVIC_ClearPendingIRQ(EXTI2_IRQn);
}

#else

extern volatile uint8_t is_send_msg;
void EXTI3_IRQHandler(void)
{
  platform_gpio_set_low_spec();
  is_send_msg = 0;
#ifdef REALTIME_DETECT_MODE
  extern volatile uint8_t g_realtime_pause;
  g_realtime_pause = 0;
#endif
  while(HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_3) != GPIO_PIN_SET);
  __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_3);
  HAL_NVIC_ClearPendingIRQ(EXTI3_IRQn);

}

#endif