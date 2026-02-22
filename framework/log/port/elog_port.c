/*
 * This file is part of the EasyLogger Library.
 *
 * Copyright (c) 2015, Armink, <armink.ztl@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * 'Software'), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 *
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 *
 * Function: Portable interface for each platform.
 * Created on: 2015-04-28
 */
 
#include <elog.h>
#include "osal.h"
#include <stdio.h>

static osal_semaphore output_lock;

#ifdef ELOG_ASYNC_OUTPUT_ENABLE
static osal_semaphore output_notice;

static void async_output(void *arg);
#endif

/**
 * EasyLogger port initialize
 *
 * @return result
 */
ElogErrCode elog_port_init(void) {
    ElogErrCode result = ELOG_NO_ERR;

    osal_sem_init(&output_lock, "elog lock", 1, 0x01);
    
#ifdef ELOG_ASYNC_OUTPUT_ENABLE
    rt_thread_t async_thread = NULL;
    
    osal_sem_init(&output_notice, "elog async", 0, 0x01);

    async_thread = osal_task_create("elog_async", async_output, NULL, 1024, RT_THREAD_PRIORITY_MAX - 1, 10);
    if (async_thread) {
        osal_task_startup(async_thread);
    }
#endif

    return result;
}

/**
 * EasyLogger port deinitialize
 *
 */
void elog_port_deinit(void) {

    /* add your code here */

}

/**
 * output log port interface
 *
 * @param log output of log
 * @param size log size
 */
void elog_port_output(const char *log, size_t size) {
    printf("%.*s",size,log);
}

/**
 * output lock
 */
void elog_port_output_lock(void) {
    
    /* add your code here */
    osal_sem_take(&output_lock, RT_WAITING_FOREVER);
    
}

/**
 * output unlock
 */
void elog_port_output_unlock(void) {
    
    /* add your code here */
    osal_sem_release(&output_lock);
    
}

/**
 * get current time interface
 *
 * @return current time
 */
const char *elog_port_get_time(void) {
    
    /* add your code here */
    static char cur_system_time[16] = { 0 };
    snprintf(cur_system_time, 16, "tick:%010d", rt_tick_get());
    return cur_system_time;
    
}


/**
 * get current thread name interface
 *
 * @return current thread name
 */
const char *elog_port_get_t_info(void) {
    
    /* add your code here */
    return osal_task_self()->name;
    
}


/**
 * get current process name interface
 *
 * @return current process name
 */
const char *elog_port_get_p_info(void) {
    return "";
}
#ifdef ELOG_ASYNC_OUTPUT_ENABLE

void elog_async_output_notice(void) {
    osal_sem_release(&output_notice);
}
static void async_output(void *arg) {
    size_t get_log_size = 0;
    static char poll_get_buf[ELOG_LINE_BUF_SIZE - 4];

    while(true) {
        /* waiting log */
        rt_sem_take(&output_notice, RT_WAITING_FOREVER);
        /* polling gets and outputs the log */
        while(true) {

#ifdef ELOG_ASYNC_LINE_OUTPUT
            get_log_size = elog_async_get_line_log(poll_get_buf, sizeof(poll_get_buf));
#else
            get_log_size = elog_async_get_log(poll_get_buf, sizeof(poll_get_buf));
#endif

            if (get_log_size) {
                elog_port_output(poll_get_buf, get_log_size);
            } else {
                break;
            }
        }
    }
}
#endif
