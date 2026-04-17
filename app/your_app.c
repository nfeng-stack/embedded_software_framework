/**
 * @file    your_app.c
 * @brief   Application layer example for embedded framework
 *
 * This file demonstrates how to use the HAL and OSAL layers in an embedded
 * application. It shows the recommended initialization sequence and provides
 * example tasks.
 */
#define LOG_TAG "main"
#include "elog.h"
#include "hal.h"
#include "mpu6050_wrap.h"
#include "osal.h"

extern void at_cmd_task_init(void);
extern void ai_task_init(void);
extern int32_t w25xx_test(void);

static int log_strategy(void) {
  elog_init();
  elog_start();
  return 0;
}
int main(void) {
  hal_uart1_init();
  hal_uart2_init();
  log_strategy();
  // at_cmd_task_init();
  // ai_task_init();
  // mpu6050_init_task();
  osal_task_delay(10);
 w25xx_test();
  while (1) {
    log_v("os is runing ...\n");
    osal_task_delay(10000);
  }
}
