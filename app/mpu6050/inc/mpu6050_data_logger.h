/**
 * @file    mpu6050_data_logger.h
 * @brief   MPU6050 Sensor Data Logger for Persistent Storage
 *
 * This module provides persistent storage of MPU6050 sensor data to FATFS file system.
 * Data is written to /data/mpu6050_data.txt with system tick timestamps.
 * USB connection detection prevents writing when filesystem is mounted as mass storage.
 * File is opened and closed for each write batch to allow safe USB host access.
 */

#ifndef MPU6050_DATA_LOGGER_H
#define MPU6050_DATA_LOGGER_H

#include <stdbool.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief Error threshold for disabling logger after continuous failures
 */
#define MPU6050_LOGGER_MAX_ERROR_COUNT 5

/**
 * @brief Mutex timeout for write operations (milliseconds)
 */
#define MPU6050_LOGGER_MUTEX_TIMEOUT_MS 100

/**
 * @brief Initialize MPU6050 data logger
 * 
 * Creates /data directory and ensures filesystem is ready.
 * Should be called after fatfs_init() and before any write operations.
 * 
 * @return 0 on success, negative error code on failure
 */
int mpu6050_data_logger_init(void);

/**
 * @brief Write a batch of sensor data to persistent storage
 * 
 * Writes multiple sensor samples with system tick timestamps to the data file.
 * Opens file for each write batch and closes immediately after writing.
 * If USB is connected or logger is in error state, writing is skipped.
 * Automatically rotates file when size exceeds limit (default 1MB).
 * 
 * @param data 2D array of sensor data [num_samples][6]
 *             Format: [accel_x, accel_y, accel_z, gyro_x, gyro_y, gyro_z]
 *             Units: acceleration in g, angular velocity in dps
 * @param num_samples Number of samples to write (must be >= 1)
 * @return Number of samples successfully written (0 if USB connected or error)
 */
int mpu6050_data_logger_write_batch(float data[][6], int num_samples);



#ifdef __cplusplus
}
#endif

#endif /* MPU6050_DATA_LOGGER_H */