/**
 * @file    fatfs_service.h
 * @brief   FATFS Service Layer for Embedded Framework
 *
 * This file provides a simplified API interface for FATFS file system operations
 * on W25Q128JV SPI Flash memory.
 */

#ifndef FATFS_SERVICE_H
#define FATFS_SERVICE_H

#include <stdint.h>
#include <stdbool.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * @brief FATFS service error codes
 */
typedef enum {
    FATFS_OK = 0,           /**< Operation successful */
    FATFS_ERR_INIT = -1,    /**< FATFS initialization failed */
    FATFS_ERR_MOUNT = -2,   /**< Volume mount failed */
    FATFS_ERR_OPEN = -3,    /**< File open failed */
    FATFS_ERR_READ = -4,    /**< File read failed */
    FATFS_ERR_WRITE = -5,   /**< File write failed */
    FATFS_ERR_CLOSE = -6,   /**< File close failed */
    FATFS_ERR_NO_FILE = -7, /**< File not found */
    FATFS_ERR_EXISTS = -8,  /**< File already exists */
    FATFS_ERR_NO_SPACE = -9,/**< No free space */
    FATFS_ERR_PARAM = -10,  /**< Invalid parameter */
    FATFS_ERR_FLASH = -11   /**< Flash hardware error */
} fatfs_err_t;

/**
 * @brief File open modes
 */
typedef enum {
    FATFS_MODE_READ = 0,    /**< Open for reading (existing file) */
    FATFS_MODE_WRITE,       /**< Open for writing (create or overwrite) */
    FATFS_MODE_APPEND       /**< Open for appending (create or append) */
} fatfs_mode_t;

/**
 * @brief File information structure
 */
typedef struct {
    char name[256];         /**< File name with path */
    uint32_t size;          /**< File size in bytes */
    uint16_t date;          /**< Last modified date */
    uint16_t time;          /**< Last modified time */
    uint8_t attr;           /**< File attributes */
} fatfs_fileinfo_t;

/* File attribute constants (compatible with FATFS) */
#define FATFS_ATTR_READ_ONLY  0x01  /**< Read only */
#define FATFS_ATTR_HIDDEN     0x02  /**< Hidden */
#define FATFS_ATTR_SYSTEM     0x04  /**< System */
#define FATFS_ATTR_DIRECTORY  0x10  /**< Directory */
#define FATFS_ATTR_ARCHIVE    0x20  /**< Archive */

/**
 * @brief Initialize FATFS service
 * 
 * This function initializes the W25Q128JV Flash and FATFS file system.
 * If the Flash is not formatted, it will be automatically formatted.
 * 
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_init(void);

/**
 * @brief High-level FATFS initialization (convenience wrapper)
 * 
 * This function initializes the FATFS service and prints capacity information.
 * It's a simplified interface for applications that don't need fine-grained control.
 * 
 * @return 0 on success, -1 on failure
 */
int32_t fatfs_init(void);
/**
 * @brief Deinitialize FATFS service
 * 
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_deinit(void);

/**
 * @brief Get file system status
 * 
 * @param[out] total_kb Total capacity in KB
 * @param[out] free_kb Free space in KB
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_status(uint32_t *total_kb, uint32_t *free_kb);

/**
 * @brief Open a file
 * 
 * @param[in] path File path (e.g., "/data/log.txt")
 * @param[in] mode Open mode
 * @return File handle (>= 0) on success, negative error code on failure
 */
int32_t fatfs_service_open(const char *path, fatfs_mode_t mode);

/**
 * @brief Read from file
 * 
 * @param[in] fh File handle returned by fatfs_service_open
 * @param[out] buffer Data buffer
 * @param[in] size Number of bytes to read
 * @return Number of bytes read, or negative error code
 */
int32_t fatfs_service_read(int32_t fh, void *buffer, uint32_t size);

/**
 * @brief Write to file
 * 
 * @param[in] fh File handle returned by fatfs_service_open
 * @param[in] buffer Data buffer
 * @param[in] size Number of bytes to write
 * @return Number of bytes written, or negative error code
 */
int32_t fatfs_service_write(int32_t fh, const void *buffer, uint32_t size);

/**
 * @brief Close file
 * 
 * @param[in] fh File handle returned by fatfs_service_open
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_close(int32_t fh);

/**
 * @brief Delete file
 * 
 * @param[in] path File path
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_delete(const char *path);

/**
 * @brief Create directory
 * 
 * @param[in] path Directory path
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_mkdir(const char *path);

/**
 * @brief Remove directory (must be empty)
 * 
 * @param[in] path Directory path
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_rmdir(const char *path);

/**
 * @brief Check if file or directory exists
 * 
 * @param[in] path Path to check
 * @return true if exists, false otherwise
 */
bool fatfs_service_exists(const char *path);

/**
 * @brief Get file information
 * 
 * @param[in] path File path
 * @param[out] info File information structure
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_stat(const char *path, fatfs_fileinfo_t *info);

/**
 * @brief Format the file system
 * 
 * WARNING: This will erase all data on the Flash!
 * 
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_format(void);

/**
 * @brief Synchronize file system (flush caches)
 * 
 * @return FATFS_OK on success, error code on failure
 */
fatfs_err_t fatfs_service_sync(void);

/**
 * @brief Move or rename a file or directory
 * 
 * @param[in] old_path Source path
 * @param[in] new_path Destination path
 * @return FATFS_OK on success, error code on failure
 * @note Can move files/directories across different directories
 */
fatfs_err_t fatfs_service_rename(const char *old_path, const char *new_path);

/**
 * @brief List directory contents (array version)
 * 
 * @param[in] path Directory path
 * @param[out] entries Array to store directory entries
 * @param[in] max_entries Maximum number of entries that can be stored
 * @param[out] count Actual number of entries returned
 * @return FATFS_OK on success, error code on failure
 * @note Use fatfs_is_directory() to check if entry is a directory
 */
fatfs_err_t fatfs_service_listdir(const char *path, 
                                 fatfs_fileinfo_t *entries, 
                                 uint32_t max_entries, 
                                 uint32_t *count);

/**
 * @brief Copy a file
 * 
 * @param[in] src_path Source file path
 * @param[in] dst_path Destination file path
 * @param[in] buffer_size Copy buffer size in bytes (0 for default 4KB)
 * @return FATFS_OK on success, error code on failure
 * @note Destination file will be overwritten if exists
 */
fatfs_err_t fatfs_service_copy(const char *src_path, 
                              const char *dst_path, 
                              uint32_t buffer_size);

/**
 * @brief Remove file or directory recursively
 * 
 * @param[in] path Path to remove
 * @return FATFS_OK on success, error code on failure
 * @warning This permanently deletes all contents of directories
 */
fatfs_err_t fatfs_service_remove_recursive(const char *path);

/**
 * @brief Check if file info represents a directory
 * 
 * @param[in] info File information structure
 * @return true if directory, false if file
 */
static inline bool fatfs_is_directory(const fatfs_fileinfo_t *info) {
    return (info->attr & FATFS_ATTR_DIRECTORY) != 0;
}

#ifdef __cplusplus
}
#endif

#endif /* FATFS_SERVICE_H */