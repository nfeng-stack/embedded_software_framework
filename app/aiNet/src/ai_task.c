#define LOG "ai_pre"
#include "app_x-cube-ai.h"
#include "osal.h"
#include "elog.h"
#include "hal.h"
extern void at_sem_relase(void);

osal_task_t ai_task_t = NULL;
osal_semaphore_t ai_sem = NULL;
extern uint8_t is_send_msg;
void ai_sem_relase(void)
{
    osal_sem_release(ai_sem);
}
void ai_task(void *param)
{
    while (1)
    {
        osal_sem_take(ai_sem, -1);
        log_d("ai task is runing\n");
        uint8_t is_fall = MX_X_CUBE_AI_Process();
        if (is_fall == 1)
        {
            /**< 处理跌倒事件 */
            log_v("ai task detection fall event\n");
            /**< 告述4g模块发送跌倒事件 */
            is_send_msg = 1;
            hal_gpio_led_audio_on();
            at_sem_relase();

        }
        // at_sem_relase();
        // hal_gpio_led_audio_on();
    }
}

void ai_task_init(void)
{
    MX_X_CUBE_AI_Init();
    ai_task_t = osal_task_create("aitask", ai_task, NULL, 1024 * 2, 10, 20);
    ai_sem = osal_sem_create("ai_sem", 0, 0);
    if (ai_task_t == NULL || ai_sem == NULL)
    {
        log_e("ai task creat error\n");
        return;
    }
    osal_task_startup(ai_task_t);
}
