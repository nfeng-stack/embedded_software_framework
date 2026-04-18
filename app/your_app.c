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
#include "fatfs_service.h"
#include "hal.h"
#include "mpu6050_wrap.h"
#include "osal.h"
#include "cdc_msc/usb_protocol.h"
#include <string.h>

extern void at_cmd_task_init(void);
extern void ai_task_init(void);

int main(void) {
  osal_task_delay(100);
  log_strategy();
  // at_cmd_task_init();
  // ai_task_init();
  // mpu6050_init_task();
  fatfs_init();
  // Initialize USB protocol stack (includes hardware initialization via HAL)
  if (usb_protocol_init() != 0) {
    log_e("USB protocol initialization failed");
  } else {
    log_i("USB protocol initialized successfully");
  }
  fatfs_fileinfo_t entries[5] = {0};
  uint32_t count = 0;
  fatfs_err_t err =  fatfs_service_listdir("/nanfeng", entries, 5,  &count);
  if(err != FATFS_OK) {
    log_e("ls error\n");
  }
     log_i("listdir found %u entries in /test:", count);
        for (uint32_t i = 0; i < count; i++) {
            log_i("  [%u] %s (%s, %u bytes)", i, entries[i].name,
                  fatfs_is_directory(&entries[i]) ? "DIR" : "FILE", entries[i].size);
        }
  while (1) {
    log_v("os is runing ...\n");
    osal_task_delay(10000);
  }
}
