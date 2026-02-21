/*
 * Copyright (c) 2006-2019, RT-Thread Development Team
 *
 * SPDX-License-Identifier: Apache-2.0
 *
 * Change Logs:
 * Date           Author       Notes
 * 2021-05-24                  the first version
 */

#include <rthw.h>
#include <rtthread.h>

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
/*
 * Please modify RT_HEAP_SIZE if you enable RT_USING_HEAP
 * the RT_HEAP_SIZE max value = (sram size - ZI size), 1024 means 1024 bytes
 * For dual-heap architecture: RT-Thread heap is 576KB in dedicated section
 */
#define RT_HEAP_SIZE (300 * 1024) /* 576KB = 0x90000 bytes */

/* Place RT-Thread heap array in dedicated linker section */
__attribute__((section(".rt_heap_section"), aligned(8))) static rt_uint8_t rt_heap[RT_HEAP_SIZE];

static int rt_heap_debug_done = 0;

void *rt_heap_begin_get(void)
{
    if (!rt_heap_debug_done)
    {
        rt_kprintf("[RT-Heap] start: 0x%p, end: 0x%p, size: %d KB\n",
                   rt_heap, rt_heap + RT_HEAP_SIZE, RT_HEAP_SIZE / 1024);
        rt_heap_debug_done = 1;
    }
    return rt_heap;
}

void *rt_heap_end_get(void)
{
    return rt_heap + RT_HEAP_SIZE;
}
#endif

void rt_os_tick_callback(void)
{
    rt_interrupt_enter();

    rt_tick_increase();

    rt_interrupt_leave();
}

static void (*register_callback)(void) = RT_NULL;

void rt_register_callback(void (*callback)(void))
{
    if (register_callback == RT_NULL && callback != RT_NULL)
    {
        register_callback = callback;
    }
}
/**
 * This function will initial your board.
 */
void rt_hw_board_init(void)
{
    // #error "TODO 1: OS Tick Configuration."
    /*
     * TODO 1: OS Tick Configuration
     * Enable the hardware timer and call the rt_os_tick_callback function
     * periodically with the frequency RT_TICK_PER_SECOND.
     */
    /* will add  config rt_os_tick_callback  to systemtick_hander*/
    if (register_callback != RT_NULL)
    {
        register_callback();
    }
    /* Call components board initial (use INIT_BOARD_EXPORT()) */
#ifdef RT_USING_COMPONENTS_INIT
    rt_components_board_init();
#endif

#if defined(RT_USING_USER_MAIN) && defined(RT_USING_HEAP)
    rt_system_heap_init(rt_heap_begin_get(), rt_heap_end_get());
#endif
}

#ifdef RT_USING_CONSOLE

static int uart_init(void)
{
    // #error "TODO 2: Enable the hardware uart and config baudrate."
    return 0;
}
INIT_BOARD_EXPORT(uart_init);

void rt_hw_console_output(const char *str)
{
  
}

#endif
