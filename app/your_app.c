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

/* Traditional main function (used when RTOS is not enabled) */
int main(void)
{
    hal_uart1_init();
    printf("hello world\n");
    char *p = (char *)malloc(20);
    printf("%p", p);
    while (1)
        ;
}
