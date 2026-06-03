/**
 * @file    your_app.c
 * @brief   Application layer example for embedded framework
 *
 * This file demonstrates how to use the HAL and OSAL layers in an embedded
 * application. It shows the recommended initialization sequence and provides
 * example tasks.
 */
#include <stdint.h>
#define LOG_TAG "main"
#include "elog.h"
#include "mpu6050_wrap.h"
#include "osal.h"
#include "cdc_msc/usb_protocol.h"
#include "fatfs_service.h"
#include "w25qxx/inc/driver_w25qxx_advance.h"
#ifdef AI_BENCHMARK_MODE
#include "ai_benchmark.h"
#include "app_x-cube-ai.h"
#elif defined(LIVE_TEST_MODE)
#include "ai_live_test.h"
#endif
#ifndef LIVE_TEST_MODE
extern void at_cmd_task_init(void);
extern void ai_task_init(void);
#endif
int main(void) {
  osal_task_delay(100);
  log_strategy();
#ifdef AI_BENCHMARK_MODE
  MX_X_CUBE_AI_Init();
  fatfs_init();
  usb_protocol_init();
  osal_task_delay(500);
  ai_benchmark_task_init();
#elif defined(LIVE_TEST_MODE)
  fatfs_init();
  usb_protocol_init();
  osal_task_delay(500);
  live_test_init();
#elif defined(REALTIME_DETECT_MODE)
  at_cmd_task_init();
  ai_task_init();
  fatfs_init();
  mpu6050_init_task();
  usb_protocol_init();
#else
  at_cmd_task_init();
  ai_task_init();
  fatfs_init();
  mpu6050_init_task();
  usb_protocol_init();
#endif
  while (1) {
    log_v("os is runing ...\n");
    osal_task_delay(10000);
  }
}
