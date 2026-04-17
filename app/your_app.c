/**
 * @file    your_app.c
 * @brief   Application layer example for embedded framework
 *
 * This file demonstrates how to use the HAL and OSAL layers in an embedded
 * application. It shows the recommended initialization sequence and provides
 * example tasks.
 */
#define LOG_TAG "main"
#include <string.h>
#include "elog.h"
#include "hal.h"
#include "mpu6050_wrap.h"
#include "osal.h"
#include "fatfs_service.h"

extern void at_cmd_task_init(void);
extern void ai_task_init(void);




int main(void) {
  osal_task_delay(100);
  log_strategy();
//   at_cmd_task_init();
//   ai_task_init();
//   mpu6050_init_task();
  fatfs_init();
  while (1) {
    log_v("os is runing ...\n");
    osal_task_delay(10000);
  }
}
