/**
 * @file    framework_debug.c
 * @brief   Debug Output Implementation
 * 
 * This file implements the debug output interface for the platform framework.
 * Debug output can be routed through HAL hardware interfaces or RTOS callbacks.
 */

#include "framework_debug.h"
#include "framework_rtos.h"
#include <string.h>
#include <stdarg.h>
#include <stdio.h>

/*------------------------------------------------------------------------------
 * Private Definitions
 *----------------------------------------------------------------------------*/

/** Default buffer size for formatted output */
#ifndef FRAMEWORK_DEBUG_BUFFER_SIZE
#define FRAMEWORK_DEBUG_BUFFER_SIZE 256
#endif

/** Maximum trace entries */
#ifndef FRAMEWORK_DEBUG_MAX_TRACES
#define FRAMEWORK_DEBUG_MAX_TRACES 32
#endif

/** ANSI color codes */
#define ANSI_RESET   "\033[0m"
#define ANSI_RED     "\033[31m"
#define ANSI_GREEN   "\033[32m"
#define ANSI_YELLOW  "\033[33m"
#define ANSI_BLUE    "\033[34m"
#define ANSI_MAGENTA "\033[35m"
#define ANSI_CYAN    "\033[36m"
#define ANSI_WHITE   "\033[37m"

/** Trace entry */
typedef struct {
    const char* name;
    uint32_t start_time;
    uint32_t end_time;
    bool active;
} trace_entry_t;

/*------------------------------------------------------------------------------
 * Private Variables
 *----------------------------------------------------------------------------*/

/** Current debug configuration */
static framework_debug_config_t current_config = {
    .mode = FRAMEWORK_DEBUG_UART,
    .level = FRAMEWORK_DEBUG_LEVEL_INFO,
    .baud_rate = 115200,
    .enable_timestamp = true,
    .enable_color = true,
    .buffer_size = FRAMEWORK_DEBUG_BUFFER_SIZE
};

/** Debug initialization flag */
static bool debug_initialized = false;

/** Output buffer */
static char output_buffer[FRAMEWORK_DEBUG_BUFFER_SIZE];

/** Performance trace entries */
static trace_entry_t trace_entries[FRAMEWORK_DEBUG_MAX_TRACES];
static uint32_t next_trace_id = 0;

/** Custom debug functions */
static framework_debug_output_func_t custom_output = NULL;
static framework_debug_input_ready_func_t custom_input_ready = NULL;
static framework_debug_input_func_t custom_input = NULL;

/** System tick reference for timestamps */
static uint32_t (*get_system_ticks)(void) = NULL;

/*------------------------------------------------------------------------------
 * Private Function Declarations
 *----------------------------------------------------------------------------*/

static void debug_output_char(char c);
static void debug_output_string(const char* str);
static uint32_t debug_get_timestamp(void);
static const char* debug_get_level_string(framework_debug_level_t level);
static const char* debug_get_level_color(framework_debug_level_t level);
static void debug_output_timestamp(void);
static void debug_output_level(framework_debug_level_t level);

/*------------------------------------------------------------------------------
 * Debug Initialization and Configuration
 *----------------------------------------------------------------------------*/

bool framework_debug_init(const framework_debug_config_t* config)
{
    if (debug_initialized) {
        return true;
    }
    
    if (config != NULL) {
        memcpy(&current_config, config, sizeof(framework_debug_config_t));
    }
    
    /* Initialize output buffer */
    memset(output_buffer, 0, sizeof(output_buffer));
    
    /* Initialize trace entries */
    memset(trace_entries, 0, sizeof(trace_entries));
    next_trace_id = 0;
    
    /* Try to get system ticks function from framework */
    /* This would be set by framework_init() */
    
    debug_initialized = true;
    
    /* Output initialization message */
    debug_output_string("\r\n");
    debug_output_string("=========================================\r\n");
    debug_output_string("Framework Debug Output Initialized\r\n");
    debug_output_string("Mode: ");
    
    switch (current_config.mode) {
        case FRAMEWORK_DEBUG_DISABLED:
            debug_output_string("Disabled");
            break;
        case FRAMEWORK_DEBUG_UART:
            debug_output_string("UART");
            break;
        case FRAMEWORK_DEBUG_SWO:
            debug_output_string("SWO");
            break;
        case FRAMEWORK_DEBUG_SEMIHOSTING:
            debug_output_string("Semihosting");
            break;
        case FRAMEWORK_DEBUG_RTT:
            debug_output_string("RTT");
            break;
        case FRAMEWORK_DEBUG_CUSTOM:
            debug_output_string("Custom");
            break;
        default:
            debug_output_string("Unknown");
            break;
    }
    
    debug_output_string("\r\n");
    debug_output_string("Level: ");
    debug_output_string(debug_get_level_string(current_config.level));
    debug_output_string("\r\n");
    debug_output_string("Baud rate: ");
    
    char baud_str[16];
    snprintf(baud_str, sizeof(baud_str), "%lu", current_config.baud_rate);
    debug_output_string(baud_str);
    
    debug_output_string("\r\n");
    debug_output_string("=========================================\r\n");
    
    return true;
}

void framework_debug_deinit(void)
{
    if (!debug_initialized) {
        return;
    }
    
    debug_output_string("\r\n");
    debug_output_string("Framework Debug Output Deinitialized\r\n");
    
    debug_initialized = false;
}

void framework_debug_set_config(const framework_debug_config_t* config)
{
    if (config == NULL) {
        return;
    }
    
    bool reinit = false;
    
    /* Check if reinitialization is needed */
    if (config->mode != current_config.mode ||
        config->baud_rate != current_config.baud_rate) {
        reinit = true;
    }
    
    memcpy(&current_config, config, sizeof(framework_debug_config_t));
    
    if (reinit && debug_initialized) {
        framework_debug_deinit();
        framework_debug_init(config);
    }
}

const framework_debug_config_t* framework_debug_get_config(void)
{
    return &current_config;
}

void framework_debug_set_level(framework_debug_level_t level)
{
    current_config.level = level;
}

framework_debug_level_t framework_debug_get_level(void)
{
    return current_config.level;
}

/*------------------------------------------------------------------------------
 * Debug Output Functions
 *----------------------------------------------------------------------------*/

void framework_debug_putc(char c)
{
    if (!debug_initialized || current_config.level == FRAMEWORK_DEBUG_LEVEL_NONE) {
        return;
    }
    
    debug_output_char(c);
}

void framework_debug_puts(const char* str)
{
    if (!debug_initialized || current_config.level == FRAMEWORK_DEBUG_LEVEL_NONE) {
        return;
    }
    
    if (str == NULL) {
        return;
    }
    
    debug_output_string(str);
}

int framework_debug_printf(const char* format, ...)
{
    if (!debug_initialized || current_config.level == FRAMEWORK_DEBUG_LEVEL_NONE) {
        return 0;
    }
    
    if (format == NULL) {
        return 0;
    }
    
    va_list args;
    va_start(args, format);
    int result = framework_debug_vprintf(format, args);
    va_end(args);
    
    return result;
}

int framework_debug_vprintf(const char* format, va_list args)
{
    if (!debug_initialized || current_config.level == FRAMEWORK_DEBUG_LEVEL_NONE) {
        return 0;
    }
    
    if (format == NULL) {
        return 0;
    }
    
    /* Format the string */
    int length = vsnprintf(output_buffer, sizeof(output_buffer), format, args);
    
    if (length > 0 && length < (int)sizeof(output_buffer)) {
        debug_output_string(output_buffer);
    }
    
    return length;
}

void framework_debug_hexdump(const void* data, uint32_t length, uint32_t addr)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_DEBUG) {
        return;
    }
    
    if (data == NULL || length == 0) {
        return;
    }
    
    const uint8_t* bytes = (const uint8_t*)data;
    uint32_t offset = 0;
    
    while (offset < length) {
        /* Print address */
        framework_debug_printf("%08lx: ", addr + offset);
        
        /* Print hex bytes */
        for (uint32_t i = 0; i < 16; i++) {
            if (offset + i < length) {
                framework_debug_printf("%02x ", bytes[offset + i]);
            } else {
                debug_output_string("   ");
            }
            
            if (i == 7) {
                debug_output_string(" ");
            }
        }
        
        debug_output_string(" ");
        
        /* Print ASCII representation */
        for (uint32_t i = 0; i < 16; i++) {
            if (offset + i < length) {
                uint8_t c = bytes[offset + i];
                if (c >= 32 && c <= 126) {
                    framework_debug_putc(c);
                } else {
                    framework_debug_putc('.');
                }
            } else {
                framework_debug_putc(' ');
            }
        }
        
        debug_output_string("\r\n");
        offset += 16;
    }
}

void framework_debug_hexdump_ascii(const void* data, uint32_t length, uint32_t addr)
{
    /* Same as hexdump for now */
    framework_debug_hexdump(data, length, addr);
}

/*------------------------------------------------------------------------------
 * Level-Specific Debug Functions
 *----------------------------------------------------------------------------*/

void framework_debug_error(const char* format, ...)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_ERROR) {
        return;
    }
    
    debug_output_level(FRAMEWORK_DEBUG_LEVEL_ERROR);
    
    va_list args;
    va_start(args, format);
    framework_debug_vprintf(format, args);
    va_end(args);
    
    debug_output_string("\r\n");
}

void framework_debug_warning(const char* format, ...)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_WARNING) {
        return;
    }
    
    debug_output_level(FRAMEWORK_DEBUG_LEVEL_WARNING);
    
    va_list args;
    va_start(args, format);
    framework_debug_vprintf(format, args);
    va_end(args);
    
    debug_output_string("\r\n");
}

void framework_debug_info(const char* format, ...)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_INFO) {
        return;
    }
    
    debug_output_level(FRAMEWORK_DEBUG_LEVEL_INFO);
    
    va_list args;
    va_start(args, format);
    framework_debug_vprintf(format, args);
    va_end(args);
    
    debug_output_string("\r\n");
}

void framework_debug_debug(const char* format, ...)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_DEBUG) {
        return;
    }
    
    debug_output_level(FRAMEWORK_DEBUG_LEVEL_DEBUG);
    
    va_list args;
    va_start(args, format);
    framework_debug_vprintf(format, args);
    va_end(args);
    
    debug_output_string("\r\n");
}

void framework_debug_trace(const char* format, ...)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_TRACE) {
        return;
    }
    
    debug_output_level(FRAMEWORK_DEBUG_LEVEL_TRACE);
    
    va_list args;
    va_start(args, format);
    framework_debug_vprintf(format, args);
    va_end(args);
    
    debug_output_string("\r\n");
}

void framework_debug_assert_failed(const char* file, uint32_t line, const char* expr)
{
    framework_debug_error("Assertion failed: %s, file %s, line %lu", expr, file, line);
}

/*------------------------------------------------------------------------------
 * Debug Input Functions
 *----------------------------------------------------------------------------*/

bool framework_debug_kbhit(void)
{
    if (!debug_initialized) {
        return false;
    }
    
    if (custom_input_ready != NULL) {
        return custom_input_ready();
    }
    
    /* Default implementation: always return false */
    return false;
}

char framework_debug_getc(void)
{
    if (!debug_initialized) {
        return 0;
    }
    
    if (custom_input != NULL) {
        return custom_input();
    }
    
    /* Default implementation: return 0 */
    return 0;
}

int framework_debug_gets(char* buffer, uint32_t size)
{
    if (!debug_initialized || buffer == NULL || size == 0) {
        return 0;
    }
    
    int index = 0;
    
    while (index < (int)size - 1) {
        /* Wait for character */
        while (!framework_debug_kbhit()) {
            /* Could add timeout here */
        }
        
        char c = framework_debug_getc();
        
        /* Handle backspace */
        if (c == '\b' || c == 0x7F) {
            if (index > 0) {
                index--;
                framework_debug_putc('\b');
                framework_debug_putc(' ');
                framework_debug_putc('\b');
            }
            continue;
        }
        
        /* Echo character */
        framework_debug_putc(c);
        
        /* Check for newline/return */
        if (c == '\r' || c == '\n') {
            buffer[index] = '\0';
            framework_debug_putc('\n');
            return index;
        }
        
        /* Store character */
        buffer[index++] = c;
    }
    
    buffer[size - 1] = '\0';
    return size - 1;
}

/*------------------------------------------------------------------------------
 * Debug Performance Tracing
 *----------------------------------------------------------------------------*/

uint32_t framework_debug_trace_start(const char* name)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_TRACE) {
        return 0;
    }
    
    uint32_t trace_id = next_trace_id;
    
    if (trace_id < FRAMEWORK_DEBUG_MAX_TRACES) {
        trace_entries[trace_id].name = name;
        trace_entries[trace_id].start_time = debug_get_timestamp();
        trace_entries[trace_id].active = true;
        
        next_trace_id = (next_trace_id + 1) % FRAMEWORK_DEBUG_MAX_TRACES;
        
        framework_debug_trace("Trace start: %s", name);
    }
    
    return trace_id;
}

void framework_debug_trace_end(uint32_t trace_id)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_TRACE) {
        return;
    }
    
    if (trace_id < FRAMEWORK_DEBUG_MAX_TRACES && trace_entries[trace_id].active) {
        trace_entries[trace_id].end_time = debug_get_timestamp();
        trace_entries[trace_id].active = false;
        
        uint32_t duration = trace_entries[trace_id].end_time - trace_entries[trace_id].start_time;
        framework_debug_trace("Trace end: %s (%lu ms)", 
                             trace_entries[trace_id].name, duration);
    }
}

void framework_debug_trace_dump(void)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_TRACE) {
        return;
    }
    
    framework_debug_info("Performance Trace Dump:");
    framework_debug_info("ID  Name                              Duration (ms)");
    framework_debug_info("--- --------------------------------- -------------");
    
    for (uint32_t i = 0; i < FRAMEWORK_DEBUG_MAX_TRACES; i++) {
        if (trace_entries[i].name != NULL && !trace_entries[i].active) {
            uint32_t duration = trace_entries[i].end_time - trace_entries[i].start_time;
            framework_debug_info("%3lu %-33s %13lu", i, trace_entries[i].name, duration);
        }
    }
}

/*------------------------------------------------------------------------------
 * Debug System Information
 *----------------------------------------------------------------------------*/

void framework_debug_system_info(void)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_INFO) {
        return;
    }
    
    framework_debug_info("=== System Information ===");
    framework_debug_info("Framework version: %s", "1.0.0"); /* Should get from framework */
    framework_debug_info("Debug level: %s", debug_get_level_string(current_config.level));
    framework_debug_info("Debug mode: %d", current_config.mode);
    framework_debug_info("Timestamp: %s", current_config.enable_timestamp ? "enabled" : "disabled");
    framework_debug_info("Color: %s", current_config.enable_color ? "enabled" : "disabled");
}

void framework_debug_memory_info(void)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_INFO) {
        return;
    }
    
    /* Memory information would come from linker symbols or heap manager */
    framework_debug_info("=== Memory Information ===");
    framework_debug_info("To be implemented");
}

void framework_debug_task_info(void)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_INFO) {
        return;
    }
    
    framework_debug_info("=== Task Information ===");
    framework_debug_info("To be implemented (RTOS dependent)");
}

void framework_debug_interrupt_info(void)
{
    if (!debug_initialized || current_config.level < FRAMEWORK_DEBUG_LEVEL_INFO) {
        return;
    }
    
    framework_debug_info("=== Interrupt Information ===");
    framework_debug_info("To be implemented");
}

/*------------------------------------------------------------------------------
 * Custom Debug Output Registration
 *----------------------------------------------------------------------------*/

void framework_debug_register_custom(framework_debug_output_func_t output,
                                     framework_debug_input_ready_func_t input_ready,
                                     framework_debug_input_func_t input)
{
    custom_output = output;
    custom_input_ready = input_ready;
    custom_input = input;
    
    if (output != NULL) {
        current_config.mode = FRAMEWORK_DEBUG_CUSTOM;
    }
}

/*------------------------------------------------------------------------------
 * Debug Utilities
 *----------------------------------------------------------------------------*/

void framework_debug_flush(void)
{
    /* Implementation depends on output method */
    /* For buffered output, this would flush the buffer */
}

bool framework_debug_ready(void)
{
    /* Default implementation: always ready */
    return true;
}

bool framework_debug_wait_ready(uint32_t timeout_ms)
{
    (void)timeout_ms;
    
    /* Default implementation: always ready */
    return true;
}

/*------------------------------------------------------------------------------
 * Private Helper Functions
 *----------------------------------------------------------------------------*/

static void debug_output_char(char c)
{
    if (current_config.mode == FRAMEWORK_DEBUG_DISABLED) {
        return;
    }
    
    if (custom_output != NULL) {
        custom_output(c);
        return;
    }
    
    /* Use RTOS debug output if registered */
    framework_rtos_debug_putc(c);
    
    /* TODO: Implement other output modes (UART, SWO, etc.) */
}

static void debug_output_string(const char* str)
{
    if (str == NULL) {
        return;
    }
    
    while (*str != '\0') {
        debug_output_char(*str);
        str++;
    }
}

static uint32_t debug_get_timestamp(void)
{
    if (get_system_ticks != NULL) {
        return get_system_ticks();
    }
    
    /* Default: return 0 */
    return 0;
}

static const char* debug_get_level_string(framework_debug_level_t level)
{
    switch (level) {
        case FRAMEWORK_DEBUG_LEVEL_NONE:    return "NONE";
        case FRAMEWORK_DEBUG_LEVEL_ERROR:   return "ERROR";
        case FRAMEWORK_DEBUG_LEVEL_WARNING: return "WARNING";
        case FRAMEWORK_DEBUG_LEVEL_INFO:    return "INFO";
        case FRAMEWORK_DEBUG_LEVEL_DEBUG:   return "DEBUG";
        case FRAMEWORK_DEBUG_LEVEL_TRACE:   return "TRACE";
        default:                            return "UNKNOWN";
    }
}

static const char* debug_get_level_color(framework_debug_level_t level)
{
    if (!current_config.enable_color) {
        return "";
    }
    
    switch (level) {
        case FRAMEWORK_DEBUG_LEVEL_ERROR:   return ANSI_RED;
        case FRAMEWORK_DEBUG_LEVEL_WARNING: return ANSI_YELLOW;
        case FRAMEWORK_DEBUG_LEVEL_INFO:    return ANSI_GREEN;
        case FRAMEWORK_DEBUG_LEVEL_DEBUG:   return ANSI_CYAN;
        case FRAMEWORK_DEBUG_LEVEL_TRACE:   return ANSI_MAGENTA;
        default:                            return ANSI_WHITE;
    }
}

static void debug_output_timestamp(void)
{
    if (!current_config.enable_timestamp) {
        return;
    }
    
    uint32_t timestamp = debug_get_timestamp();
    
    if (timestamp > 0) {
        char ts_buffer[16];
        snprintf(ts_buffer, sizeof(ts_buffer), "[%8lu] ", timestamp);
        debug_output_string(ts_buffer);
    }
}

static void debug_output_level(framework_debug_level_t level)
{
    debug_output_timestamp();
    
    if (current_config.enable_color) {
        debug_output_string(debug_get_level_color(level));
    }
    
    const char* level_str = debug_get_level_string(level);
    char level_buffer[16];
    snprintf(level_buffer, sizeof(level_buffer), "%-7s: ", level_str);
    debug_output_string(level_buffer);
    
    if (current_config.enable_color) {
        debug_output_string(ANSI_RESET);
    }
}