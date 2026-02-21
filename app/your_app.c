/**
 * @file    your_app.c
 * @brief   Application layer example for embedded framework
 *
 * This file demonstrates how to use the HAL and OSAL layers in an embedded application.
 * It shows the recommended initialization sequence and provides example tasks.
 */

#include "hal.h"
#include "osal.h"
#include <stdio.h>
#include <stdint.h>
#include <math.h>
#include <stdlib.h>

/* Linker symbols for heap boundaries */
extern char end;          /* start of C library heap */
extern char _heap_limit;  /* end of C library heap */
extern char _rt_heap_boundary; /* start of RT-Thread heap section */
extern char _rt_heap_section_start;
extern char _rt_heap_section_end;
extern uint32_t _msp_stack_protection_start;
extern uint32_t _msp_stack_protection_end;

/* Traditional main function (used when RTOS is not enabled) */
int main(void)
{
    hal_uart1_init();
    printf("=== Dual-Heap Memory Layout Test ===\n");
    
    /* Print C library heap boundaries */
    printf("C library heap: start=%p, limit=%p, size=%lu bytes\n", 
           &end, &_heap_limit, (unsigned long)(&_heap_limit - &end));
    
    /* Print RT-Thread heap boundaries */
    printf("RT-Thread heap section: start=%p, end=%p, size=%lu bytes\n",
           &_rt_heap_section_start, &_rt_heap_section_end,
           (unsigned long)(&_rt_heap_section_end - &_rt_heap_section_start));
    
    /* Check MSP stack protection region */
    {
        uint32_t *prot = &_msp_stack_protection_start;
        uint32_t *prot_end = &_msp_stack_protection_end;
        uint32_t *original_prot = prot;
        uint32_t *original_prot_end = prot_end;
        int ok = 1;
        while (prot < prot_end) {
            if (*prot != 0xDEADBEEF) {
                ok = 0;
                break;
            }
            prot++;
        }
        printf("MSP stack protection region: %s (start=%p, end=%p)\n", 
               ok ? "OK" : "CORRUPTED", original_prot, original_prot_end);
    }
    
    /* Test C library malloc */
    char *p = (char *)malloc(20);
    printf("C library malloc(20) = %p\n", p);
    if (p) free(p);
    
    /* Test OSAL malloc (RT-Thread heap) */
    void *q = osal_malloc(50);
    printf("OSAL malloc(50) = %p\n", q);
    if (q) osal_free(q);
    
    /* Test larger allocations */
    void *large = malloc(1024);
    printf("malloc(1024) = %p\n", large);
    if (large) free(large);
    
    /* Test floating-point printf support (full C library) */
    printf("\n=== Floating-point Test ===\n");
    float f = 3.14159265f;
    double d = 2.718281828459045;
    printf("Float: %f (%.6f)\n", f, f);
    printf("Double: %lf (%.15lf)\n", d, d);
    printf("Scientific: %e, %E\n", f, d);
    printf("Mixed: %f + %f = %f\n", f, (float)d, f + (float)d);
    
    /* Test math functions */
    printf("sin(%f) = %f, cos(%f) = %f\n", 
           f, sinf(f), d, cos(d));
    printf("sqrt(%f) = %f, exp(%f) = %f\n",
           f, sqrtf(f), 1.0f, expf(1.0f));
    
    /* Test heap with floating-point values */
    float *arr = malloc(5 * sizeof(float));
    if (arr) {
        for (int i = 0; i < 5; i++) arr[i] = i * f;
        printf("Array[3] = %f\n", arr[3]);
        free(arr);
    }
    
    printf("Floating-point test completed.\n");
    
    printf("Test completed.\n");
    while (1)
        ;
}
