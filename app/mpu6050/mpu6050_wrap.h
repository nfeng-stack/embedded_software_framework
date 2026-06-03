#ifndef MPU6050_WRAP_H
#define MPU6050_WRAP_H

#ifdef REALTIME_DETECT_MODE
extern volatile uint8_t g_realtime_pause;
#endif

void mpu6050_board_init();

void mpu6050_init_task(void);

#endif