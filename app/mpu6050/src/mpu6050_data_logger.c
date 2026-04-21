/**
 * @file    mpu6050_data_logger.c
 * @brief   MPU6050 Sensor Data Logger Implementation
 */

#define LOG_TAG "MPU6050_LOGGER"
#define LOG_LVL ELOG_LVL_INFO

#include "mpu6050_data_logger.h"
#include "fatfs_service.h"
#include "../../cdc_msc/usb_state.h"
#include "elog.h"
#include "osal.h"
#include <string.h>
#include <stdio.h>

/* Configuration constants */
#define DATA_DIRECTORY         "/data"
#define DATA_FILENAME          "/data/mpu6050_data.txt"
#define MAX_FILE_SIZE_BYTES    (1024 * 1024)  /* 1MB */
#define MAX_FILENAME_LEN       128
#define WRITE_BUFFER_SIZE      256            /* Per-line buffer */


/* Logger state structure - simplified for open/close per write */
typedef struct {
    bool initialized;
    bool error_state;          /* Error state flag (disabled due to too many failures) */
    uint32_t error_count;      /* Consecutive error count */
    osal_mutex_t write_mutex;  /* Mutex to protect write operations */
} logger_state_t;

static logger_state_t logger_state = {
    .initialized = false,
    .error_state = false,
    .error_count = 0,
    .write_mutex = NULL
};

/* Internal helper functions */
static int _ensure_data_directory(void);
static bool _check_usb_connected(void);
static int _check_and_rotate_file_if_needed(int32_t *file_handle);
static int _write_sample_with_timestamp(int32_t file_handle, float sample[6]);
static int _perform_file_rotation(void);
static int _write_file_header_if_needed(int32_t file_handle);
static void _update_error_state(bool success);
static int _write_batch_header(int32_t file_handle);

/*-----------------------------------------------------------------------*/
/* Public API Implementation                                             */
/*-----------------------------------------------------------------------*/

int mpu6050_data_logger_init(void)
{
    if (logger_state.initialized) {
        log_w("Logger already initialized");
        return 0;
    }
    
    log_i("Initializing MPU6050 data logger");
    
    /* Create /data directory if it doesn't exist */
    if (_ensure_data_directory() != 0) {
        log_e("Failed to create data directory");
        return -2;
    }
    
    /* Create mutex for write operations */
    logger_state.write_mutex = osal_mutex_create("mpu6050_logger_mutex", 0);
    if (logger_state.write_mutex == NULL) {
        log_e("Failed to create write mutex");
        return -3;
    }
    
    /* Reset error state */
    logger_state.error_state = false;
    logger_state.error_count = 0;
    
    logger_state.initialized = true;
    log_i("MPU6050 data logger initialized successfully");
    
    return 0;
}

int mpu6050_data_logger_write_batch(float data[][6], int num_samples)
{
    int samples_written = 0;
    int32_t file_handle = -1;
    bool write_success = false;
    
    /* Parameter validation */
    if (!logger_state.initialized) {
        log_e("Logger not initialized");
        return 0;
    }
    
    if (logger_state.error_state) {
        log_w("Logger in error state, skipping write");
        return 0;
    }
    
    if (num_samples <= 0 || data == NULL) {
        log_e("Invalid parameters");
        return 0;
    }
    
    /* Acquire write mutex with timeout to prevent deadlock */
    if (osal_mutex_take(logger_state.write_mutex, MPU6050_LOGGER_MUTEX_TIMEOUT_MS) != 0) {
        log_w("Failed to acquire write mutex, skipping write");
        return 0;
    }
    
    /* If in error state and USB not connected, attempt to reset error state */
    if (logger_state.error_state && !_check_usb_connected()) {
        log_i("Logger in error state but USB disconnected, attempting reset");
        logger_state.error_state = false;
        logger_state.error_count = 0;
    }
    
    /* Check USB connection under mutex protection */
    if (_check_usb_connected()) {
        log_v("USB connected, skipping data write");
        osal_mutex_release(logger_state.write_mutex);
        return 0;
    }
    
    /* Open file for this write batch */
    file_handle = fatfs_service_open(DATA_FILENAME, FATFS_MODE_APPEND);
    if (file_handle < 0) {
        log_e("Failed to open file '%s': %d", DATA_FILENAME, file_handle);
        
        /* Check if file doesn't exist - try to create it */
        if (!fatfs_service_exists(DATA_FILENAME)) {
            log_i("File doesn't exist, trying to create");
            /* Create directory just in case */
            _ensure_data_directory();
            
            /* Try to open with write mode to create file */
            file_handle = fatfs_service_open(DATA_FILENAME, FATFS_MODE_WRITE);
            if (file_handle >= 0) {
                /* Write header for new file */
                _write_file_header_if_needed(file_handle);
                /* Close and reopen in append mode */
                fatfs_service_close(file_handle);
                file_handle = fatfs_service_open(DATA_FILENAME, FATFS_MODE_APPEND);
            }
        }
        
        if (file_handle < 0) {
            log_e("Failed to create/open file, skipping write");
            osal_mutex_release(logger_state.write_mutex);
            _update_error_state(false);
            return 0;
        }
    }
    
    /* Check if file header is needed */
    if (_write_file_header_if_needed(file_handle) != 0) {
        log_w("Failed to write file header");
    }
    
    /* Check if file needs rotation */
    int rotation_result = _check_and_rotate_file_if_needed(&file_handle);
    if (rotation_result == 1) {
        /* File was rotated successfully, need to open new file */
        log_i("File rotated, opening new file for writing");
        file_handle = fatfs_service_open(DATA_FILENAME, FATFS_MODE_APPEND);
        if (file_handle < 0) {
            log_e("Failed to open new file after rotation");
            /* Cannot continue without valid file handle */
            osal_mutex_release(logger_state.write_mutex);
            _update_error_state(false);
            return 0;
        }
        
        /* Write header for new file */
        _write_file_header_if_needed(file_handle);
    } else if (rotation_result < 0) {
        /* File rotation failed, need to reopen original file */
        log_w("File rotation failed: %d", rotation_result);
        if (file_handle < 0) {
            /* File handle was closed during failed rotation, reopen it */
            file_handle = fatfs_service_open(DATA_FILENAME, FATFS_MODE_APPEND);
            if (file_handle < 0) {
                log_e("Failed to reopen file after rotation failure");
                osal_mutex_release(logger_state.write_mutex);
                _update_error_state(false);
                return 0;
            }
        }
        /* Continue with existing file handle */
    }
    
    /* Write batch header */
    if (_write_batch_header(file_handle) != 0) {
        log_w("Failed to write batch header, continuing anyway");
    }
    
    /* Write each sample with timestamp */
    for (int i = 0; i < num_samples; i++) {
        if (_write_sample_with_timestamp(file_handle, data[i]) == 0) {
            samples_written++;
        } else {
            log_w("Failed to write sample %d", i);
        }
    }
    
    if (samples_written > 0) {
        /* Close file */
        fatfs_err_t close_err = fatfs_service_close(file_handle);
        if (close_err != FATFS_OK) {
            log_w("Failed to close file: %d", close_err);
        }
        
        /* Force sync to ensure data is written to flash */
        fatfs_err_t sync_err = fatfs_service_sync();
        if (sync_err != FATFS_OK) {
            log_w("Failed to sync filesystem: %d", sync_err);
        }
        
        write_success = true;
        log_v("Wrote %d samples to data file", samples_written);
    } else {
        /* No samples written, just close the file */
        fatfs_service_close(file_handle);
    }
    
    /* Update error state based on write success */
    _update_error_state(write_success);
    
    /* Release mutex */
    osal_mutex_release(logger_state.write_mutex);
    
    return samples_written;
}







/*-----------------------------------------------------------------------*/
/* Internal Helper Functions                                             */
/*-----------------------------------------------------------------------*/

static int _ensure_data_directory(void)
{
    /* Check if directory exists */
    if (fatfs_service_exists(DATA_DIRECTORY)) {
        return 0;
    }
    
    /* Create directory */
    fatfs_err_t err = fatfs_service_mkdir(DATA_DIRECTORY);
    if (err != FATFS_OK) {
        log_e("Failed to create directory '%s': %d", DATA_DIRECTORY, err);
        return -1;
    }
    
    log_i("Created directory '%s'", DATA_DIRECTORY);
    return 0;
}

static int _check_and_rotate_file_if_needed(int32_t *file_handle)
{
    if (file_handle == NULL || *file_handle < 0) {
        return 0; /* Invalid file handle */
    }
    
    /* Get actual file size using file path */
    fatfs_fileinfo_t file_info;
    fatfs_err_t err = fatfs_service_stat(DATA_FILENAME, &file_info);
    if (err != FATFS_OK) {
        log_w("Failed to get file info: %d", err);
        return 0; /* Can't determine size, continue anyway */
    }
    
    /* Check if file exceeds size limit */
    if (file_info.size >= MAX_FILE_SIZE_BYTES) {
        log_i("Data file size (%lu bytes) exceeds limit (%u bytes), rotating...",
              (unsigned long)file_info.size, MAX_FILE_SIZE_BYTES);
        
        /* Close current file */
        fatfs_service_close(*file_handle);
        *file_handle = -1;
        
        /* Perform rotation */
        int result = _perform_file_rotation();
        if (result < 0) {
            log_e("File rotation failed: %d", result);
            return result; /* Return error code */
        }
        
        /* Return special code to indicate rotation occurred */
        return 1;
    }
    
    return 0;
}

static int _write_sample_with_timestamp(int32_t file_handle, float sample[6])
{
    char buffer[WRITE_BUFFER_SIZE];
    osal_tick_t tick = osal_tick_get();
    
    /* Format: [tick:12345678] -16.12,1.45,0.78,-12.34,45.67,89.01\n */
    int len = snprintf(buffer, sizeof(buffer),
                      "[tick:%lu] %.4f,%.4f,%.4f,%.4f,%.4f,%.4f\n",
                      (unsigned long)tick,
                      sample[0], sample[1], sample[2],
                      sample[3], sample[4], sample[5]);
    
    if (len <= 0 || len >= (int)sizeof(buffer)) {
        log_e("Failed to format sample data");
        return -1;
    }
    
    /* Write to file */
    int32_t written = fatfs_service_write(file_handle, buffer, len);
    if (written != len) {
        log_e("Failed to write sample to file: wrote %d of %d bytes", written, len);
        return -2;
    }
    
    return 0;
}

static int _write_file_header_if_needed(int32_t file_handle)
{
    if (file_handle < 0) {
        return -1;
    }
    
    /* Check file size using file path to determine if it's new */
    fatfs_fileinfo_t file_info;
    fatfs_err_t err = fatfs_service_stat(DATA_FILENAME, &file_info);
    if (err != FATFS_OK) {
        /* File might not exist yet, but we have a handle, so it's a new file */
        log_v("File stat failed (likely new file), writing header");
    } else if (file_info.size > 0) {
        /* If file is not empty, no header needed */
        return 0;
    }
    
    /* Write header for new file */
    const char *header = "# MPU6050 Sensor Data Log\n"
                        "# Format: [tick_count] accel_x,accel_y,accel_z,gyro_x,gyro_y,gyro_z\n"
                        "# Units: acceleration (g), angular velocity (dps)\n";
    
    int32_t written = fatfs_service_write(file_handle, header, strlen(header));
    if (written != (int32_t)strlen(header)) {
        log_w("Failed to write file header: wrote %d of %d bytes", written, (int)strlen(header));
        return -3;
    }
    
    log_i("Wrote header to new data file");
    return 0;
}

static void _update_error_state(bool success)
{
    if (success) {
        /* Reset error count on successful write */
        logger_state.error_count = 0;
        logger_state.error_state = false;
    } else {
        /* Increment error count */
        logger_state.error_count++;
        
        /* Check if we've exceeded threshold */
        if (logger_state.error_count >= MPU6050_LOGGER_MAX_ERROR_COUNT) {
            logger_state.error_state = true;
            log_e("Logger disabled due to %d consecutive failures", logger_state.error_count);
        }
    }
}

static bool _check_usb_connected(void)
{
    return usb_state_is_connected();
}

static int _write_batch_header(int32_t file_handle)
{
    if (file_handle < 0) {
        return -1;
    }
    
    char buffer[128];
    osal_tick_t tick = osal_tick_get();
    
    /* Format: # --- Batch at tick:12345678 --- */
    int len = snprintf(buffer, sizeof(buffer),
                      "# --- Batch at tick:%lu ---\n",
                      (unsigned long)tick);
    
    if (len <= 0 || len >= (int)sizeof(buffer)) {
        log_e("Failed to format batch header");
        return -2;
    }
    
    /* Write batch header */
    int32_t written = fatfs_service_write(file_handle, buffer, len);
    if (written != len) {
        log_w("Failed to write batch header: wrote %d of %d bytes", written, len);
        return -3;
    }
    
    log_v("Wrote batch header (tick:%lu)", (unsigned long)tick);
    return 0;
}

static int _perform_file_rotation(void)
{
    char new_filename[MAX_FILENAME_LEN];
    osal_tick_t tick = osal_tick_get();
    
    /* Generate new filename with timestamp */
    snprintf(new_filename, sizeof(new_filename),
             "/data/mpu6050_data_%lu.txt", (unsigned long)tick);
    
    /* Rename current file */
    fatfs_err_t err = fatfs_service_rename(DATA_FILENAME, new_filename);
    if (err != FATFS_OK) {
        log_e("Failed to rename data file: %d", err);
        return -1;
    }
    
    log_i("Rotated data file to '%s'", new_filename);
    
    /* Clean up old rotated files */
    /* Note: This is a simplified implementation - in production you might want
       to implement a more sophisticated cleanup strategy */
    
    return 0;
}



