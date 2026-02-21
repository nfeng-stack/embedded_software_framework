/**
 * @file    framework_debug.h
 * @brief   Debug Output Interface for Platform Framework
 * 
 * This file defines the debug output interface for the platform framework.
 * Debug output is implemented via HAL layer hardware interfaces.
 */

#ifndef FRAMEWORK_DEBUG_H
#define FRAMEWORK_DEBUG_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stdbool.h>
#include <stdarg.h>

/*------------------------------------------------------------------------------
 * Debug Output Configuration
 *----------------------------------------------------------------------------*/

/** Debug output modes */
typedef enum {
    FRAMEWORK_DEBUG_DISABLED = 0,    /**< Debug output disabled */
    FRAMEWORK_DEBUG_UART,            /**< Debug via UART (default) */
    FRAMEWORK_DEBUG_SWO,             /**< Debug via SWO (Serial Wire Output) */
    FRAMEWORK_DEBUG_SEMIHOSTING,     /**< Debug via semihosting */
    FRAMEWORK_DEBUG_RTT,             /**< Debug via SEGGER RTT */
    FRAMEWORK_DEBUG_CUSTOM           /**< Custom debug output */
} framework_debug_mode_t;

/** Debug message levels */
typedef enum {
    FRAMEWORK_DEBUG_LEVEL_NONE = 0,  /**< No debug output */
    FRAMEWORK_DEBUG_LEVEL_ERROR,     /**< Error messages only */
    FRAMEWORK_DEBUG_LEVEL_WARNING,   /**< Warning and error messages */
    FRAMEWORK_DEBUG_LEVEL_INFO,      /**< Info, warning, and error messages */
    FRAMEWORK_DEBUG_LEVEL_DEBUG,     /**< Debug, info, warning, and error messages */
    FRAMEWORK_DEBUG_LEVEL_TRACE      /**< All messages including trace */
} framework_debug_level_t;

/** Debug configuration structure */
typedef struct {
    framework_debug_mode_t mode;     /**< Debug output mode */
    framework_debug_level_t level;   /**< Debug message level */
    uint32_t baud_rate;              /**< Baud rate for UART mode */
    bool enable_timestamp;           /**< Enable timestamp in messages */
    bool enable_color;               /**< Enable ANSI color codes */
    uint32_t buffer_size;            /**< Output buffer size */
} framework_debug_config_t;

/*------------------------------------------------------------------------------
 * Debug Initialization and Configuration
 *----------------------------------------------------------------------------*/

/**
 * @brief Initialize debug output
 * @param config Debug configuration (NULL for defaults)
 * @return true if successful, false otherwise
 */
bool framework_debug_init(const framework_debug_config_t* config);

/**
 * @brief Deinitialize debug output
 */
void framework_debug_deinit(void);

/**
 * @brief Set debug configuration
 * @param config New configuration
 * @note  May reinitialize debug output if needed
 */
void framework_debug_set_config(const framework_debug_config_t* config);

/**
 * @brief Get current debug configuration
 * @return Pointer to current configuration (read-only)
 */
const framework_debug_config_t* framework_debug_get_config(void);

/**
 * @brief Set debug output level
 * @param level New debug level
 */
void framework_debug_set_level(framework_debug_level_t level);

/**
 * @brief Get current debug output level
 * @return Current debug level
 */
framework_debug_level_t framework_debug_get_level(void);

/*------------------------------------------------------------------------------
 * Debug Output Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Output a single character
 * @param c Character to output
 */
void framework_debug_putc(char c);

/**
 * @brief Output a null-terminated string
 * @param str String to output
 */
void framework_debug_puts(const char* str);

/**
 * @brief Formatted output (similar to printf)
 * @param format Format string
 * @param ...    Variable arguments
 * @return Number of characters output
 */
int framework_debug_printf(const char* format, ...);

/**
 * @brief Formatted output with variable argument list
 * @param format Format string
 * @param args   Variable argument list
 * @return Number of characters output
 */
int framework_debug_vprintf(const char* format, va_list args);

/**
 * @brief Output data buffer in hex format
 * @param data   Data buffer
 * @param length Data length in bytes
 * @param addr   Starting address (for display)
 */
void framework_debug_hexdump(const void* data, uint32_t length, uint32_t addr);

/**
 * @brief Output data buffer in hex and ASCII format
 * @param data   Data buffer
 * @param length Data length in bytes
 * @param addr   Starting address (for display)
 */
void framework_debug_hexdump_ascii(const void* data, uint32_t length, uint32_t addr);

/*------------------------------------------------------------------------------
 * Level-Specific Debug Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Output error message (level: ERROR and above)
 * @param format Format string
 * @param ...    Variable arguments
 */
void framework_debug_error(const char* format, ...);

/**
 * @brief Output warning message (level: WARNING and above)
 * @param format Format string
 * @param ...    Variable arguments
 */
void framework_debug_warning(const char* format, ...);

/**
 * @brief Output info message (level: INFO and above)
 * @param format Format string
 * @param ...    Variable arguments
 */
void framework_debug_info(const char* format, ...);

/**
 * @brief Output debug message (level: DEBUG and above)
 * @param format Format string
 * @param ...    Variable arguments
 */
void framework_debug_debug(const char* format, ...);

/**
 * @brief Output trace message (level: TRACE only)
 * @param format Format string
 * @param ...    Variable arguments
 */
void framework_debug_trace(const char* format, ...);

/**
 * @brief Output assertion failure message
 * @param file   Source file name
 * @param line   Line number
 * @param expr   Assertion expression
 */
void framework_debug_assert_failed(const char* file, uint32_t line, const char* expr);

/*------------------------------------------------------------------------------
 * Debug Input Functions
 *----------------------------------------------------------------------------*/

/**
 * @brief Check if input character is available
 * @return true if character available, false otherwise
 */
bool framework_debug_kbhit(void);

/**
 * @brief Get a character from debug input
 * @return Character received, or 0 if no character available
 */
char framework_debug_getc(void);

/**
 * @brief Get a line from debug input (blocking)
 * @param buffer Buffer to store line
 * @param size   Buffer size
 * @return Number of characters read
 */
int framework_debug_gets(char* buffer, uint32_t size);

/*------------------------------------------------------------------------------
 * Debug Performance Tracing
 *----------------------------------------------------------------------------*/

/**
 * @brief Start performance trace
 * @param name Trace name
 * @return Trace identifier
 */
uint32_t framework_debug_trace_start(const char* name);

/**
 * @brief End performance trace
 * @param trace_id Trace identifier
 */
void framework_debug_trace_end(uint32_t trace_id);

/**
 * @brief Output performance trace results
 */
void framework_debug_trace_dump(void);

/*------------------------------------------------------------------------------
 * Debug System Information
 *----------------------------------------------------------------------------*/

/**
 * @brief Output system information
 */
void framework_debug_system_info(void);

/**
 * @brief Output memory usage information
 */
void framework_debug_memory_info(void);

/**
 * @brief Output task/thread information (RTOS only)
 */
void framework_debug_task_info(void);

/**
 * @brief Output interrupt information
 */
void framework_debug_interrupt_info(void);

/*------------------------------------------------------------------------------
 * Custom Debug Output Registration
 *----------------------------------------------------------------------------*/

/** Custom debug output function types */
typedef void (*framework_debug_output_func_t)(char c);
typedef bool (*framework_debug_input_ready_func_t)(void);
typedef char (*framework_debug_input_func_t)(void);

/**
 * @brief Register custom debug output functions
 * @param output     Output function
 * @param input_ready Input ready check function (can be NULL)
 * @param input      Input function (can be NULL)
 */
void framework_debug_register_custom(framework_debug_output_func_t output,
                                     framework_debug_input_ready_func_t input_ready,
                                     framework_debug_input_func_t input);

/*------------------------------------------------------------------------------
 * Debug Utilities
 *----------------------------------------------------------------------------*/

/**
 * @brief Flush debug output buffer
 */
void framework_debug_flush(void);

/**
 * @brief Check if debug output is ready
 * @return true if ready, false if busy
 */
bool framework_debug_ready(void);

/**
 * @brief Wait for debug output to be ready
 * @param timeout_ms Timeout in milliseconds (0 = infinite)
 * @return true if ready, false if timeout
 */
bool framework_debug_wait_ready(uint32_t timeout_ms);

#ifdef __cplusplus
}
#endif

#endif /* FRAMEWORK_DEBUG_H */