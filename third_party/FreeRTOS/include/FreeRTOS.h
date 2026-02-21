/**
 * @file    FreeRTOS.h
 * @brief   FreeRTOS main header (stub)
 * 
 * This is a stub header for FreeRTOS to allow compilation of OSAL layer.
 * Users should replace this with actual FreeRTOS headers.
 */

#ifndef FREERTOS_H
#define FREERTOS_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stdint.h>
#include <stddef.h>

/* Basic FreeRTOS types */
typedef void * TaskHandle_t;
typedef void * QueueHandle_t;
typedef void * SemaphoreHandle_t;
typedef void * EventGroupHandle_t;
typedef void * TimerHandle_t;
typedef long BaseType_t;
typedef unsigned long UBaseType_t;
typedef void (*TaskFunction_t)(void*);

/* FreeRTOS configuration */
#define configUSE_PREEMPTION                1
#define configUSE_IDLE_HOOK                 0
#define configUSE_TICK_HOOK                 0
#define configCPU_CLOCK_HZ                  (SystemCoreClock)
#define configTICK_RATE_HZ                  1000
#define configMAX_PRIORITIES                32
#define configMINIMAL_STACK_SIZE            ( ( unsigned short ) 128 )
#define configTOTAL_HEAP_SIZE               ( ( size_t ) ( 16 * 1024 ) )
#define configMAX_TASK_NAME_LEN             16
#define configUSE_TRACE_FACILITY            0
#define configUSE_16_BIT_TICKS              0
#define configIDLE_SHOULD_YIELD             1
#define configUSE_MUTEXES                   1
#define configUSE_RECURSIVE_MUTEXES         0
#define configUSE_COUNTING_SEMAPHORES       1
#define configUSE_ALTERNATIVE_API           0
#define configQUEUE_REGISTRY_SIZE           10
#define configCHECK_FOR_STACK_OVERFLOW      0
#define configUSE_CO_ROUTINES               0
#define configMAX_CO_ROUTINE_PRIORITIES     2
#define configUSE_TIMERS                    1

/* FreeRTOS port specific definitions */
#define portCHAR                            char
#define portFLOAT                           float
#define portDOUBLE                          double
#define portLONG                            long
#define portSHORT                           short
#define portSTACK_TYPE                      uint32_t
#define portBASE_TYPE                       long
#define portMAX_DELAY                       ( ( TickType_t ) 0xffffffffUL )

typedef uint32_t TickType_t;
#define portTICK_PERIOD_MS                  ( ( TickType_t ) 1000 / configTICK_RATE_HZ )

/* Macros */
#define pdTRUE                              ( 1 )
#define pdFALSE                             ( 0 )
#define pdPASS                              ( 1 )
#define pdFAIL                              ( 0 )

/* Function prototypes */
void vTaskDelay( TickType_t xTicksToDelay );
void vTaskDelayUntil( TickType_t *pxPreviousWakeTime, TickType_t xTimeIncrement );
BaseType_t xTaskCreate( TaskFunction_t pxTaskCode, const char * const pcName, 
                        uint16_t usStackDepth, void *pvParameters, 
                        UBaseType_t uxPriority, TaskHandle_t *pxCreatedTask );
void vTaskDelete( TaskHandle_t xTask );
void vTaskSuspend( TaskHandle_t xTask );
void vTaskResume( TaskHandle_t xTask );
UBaseType_t uxTaskPriorityGet( TaskHandle_t xTask );
void vTaskPrioritySet( TaskHandle_t xTask, UBaseType_t uxNewPriority );

#ifdef __cplusplus
}
#endif

#endif /* FREERTOS_H */