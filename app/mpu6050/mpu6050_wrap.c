#define LOG_TAG "MPU6050"
#define MPU6050_MOTION_THRESHOLD_MG 1200.0f
// # Low power sample rate in Hz (default 10Hz)
#define MPU6050_LOW_POWER_SAMPLE_RATE 10
// # High speed sample rate in Hz (default 200Hz)
#define MPU6050_HIGH_SPEED_SAMPLE_RATE 200
// # Wake-up frequency in Hz (1.25Hz only option for MPU6050)
#define MPU6050_WAKEUP_FREQUENCY 1.25

#define MPU6050_MOTION_DURATION 1

#include "driver_mpu6050.h"
#include "driver_mpu6050_basic.h"
#include "elog.h"
#include "framework_interrupts.h"
#include "osal.h"
#include "hal.h"
#include "stdio.h"

static mpu6050_handle_t *mpu_handle = NULL;
void mpu6050_start(void);
void mpu6050_stop(void);

/**
 * @brief  进入高速采集模式 (200Hz)
 * @retval None
 */
void mpu6050_enter_high_speed_mode(void)
{

    /* 禁用循环唤醒模式 */
    uint8_t res = mpu6050_set_cycle_wake_up(mpu_handle, MPU6050_BOOL_FALSE);

    /* 设置高速采样率 */
    uint8_t divider = (1000 / MPU6050_HIGH_SPEED_SAMPLE_RATE) - 1;
    res = mpu6050_set_sample_rate_divider(mpu_handle, divider);

    /* 设置低通滤波器为等级0 (最大带宽) */
    res = mpu6050_set_low_pass_filter(mpu_handle, MPU6050_LOW_PASS_FILTER_0);

    /* 禁用FIFO (使用寄存器读取模式) */
    res = mpu6050_set_fifo(mpu_handle, MPU6050_BOOL_FALSE);

    /* 确保FIFO溢出中断被禁用 */
    res = mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FIFO_OVERFLOW, MPU6050_BOOL_FALSE);

    /* 禁用运动检测中断 (由调用者根据需求启用) */
    res = mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_MOTION, MPU6050_BOOL_FALSE);

    /* 禁用I2C主机中断 (可能由DMA传输触发) */
    res = mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_I2C_MAST, MPU6050_BOOL_FALSE);

    /* 禁用数据就绪中断 (仅在需要收集数据时启用) */
    res = mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_FALSE);

    /* 验证配置 */
    uint8_t sample_rate_reg;
    mpu6050_get_sample_rate_divider(mpu_handle, &sample_rate_reg);

    uint8_t fifo_enabled;
    mpu6050_get_fifo(mpu_handle, &fifo_enabled);

    uint8_t data_ready_enabled;
    mpu6050_get_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY, &data_ready_enabled);
    log_v("HIGH SPEED MODE: Data ready interrupt enabled after config: %d (should be 0)\n", data_ready_enabled);

    log_v("MPU6050 entered high speed mode (%dHz sampling, interrupts disabled by default)\n", MPU6050_HIGH_SPEED_SAMPLE_RATE);
    return ;
}

/**
 * @brief  初始化运动检测功能
 * @retval None
 */
void mpu6050_motion_detect_init(void)
{
    /* 初始化运动检测功能*/
    float threshold_mg = MPU6050_MOTION_THRESHOLD_MG;
    log_v("Initializing motion detection...\n");

    /* 配置运动监测 */
    uint8_t reg;
    uint8_t res = mpu6050_motion_threshold_convert_to_register(mpu_handle, threshold_mg, &reg);
    if (res == 0)
    {
        res = mpu6050_set_motion_threshold(mpu_handle, reg);
        if (res == 0)
        {
            log_v("Motion threshold set to ±%.1fg (%dmg) (reg: 0x%02X)\n",
                  threshold_mg / 1000.0f, (int)threshold_mg, reg);
        }
        else
        {
            log_e("Motion threshold set failed\n");
        }
    }

    /* 设置运动检测持续时间 (samples) */
    mpu6050_set_motion_duration(mpu_handle, MPU6050_MOTION_DURATION);

    mpu6050_set_interrupt_read_clear(mpu_handle, MPU6050_BOOL_TRUE);

    /* 配置中断引脚为低电平有效 (根据硬件连接) */
    mpu6050_set_interrupt_level(mpu_handle, MPU6050_PIN_LEVEL_LOW);

    /* 禁用I2C主控制器功能（防止I2C主机中断干扰） */
    mpu6050_set_iic_master(mpu_handle, MPU6050_BOOL_FALSE);

    /* 工作模式和中断由调用者配置，此处只配置运动检测参数 */

    /* 状态由调用者设置，不在此处覆盖 */

    /* 清除任何可能挂起的中断标志 */
    uint8_t int_status;
    mpu6050_get_interrupt_status(mpu_handle, &int_status);
    log_v("Cleared MPU6050 interrupt status: 0x%02X\n", int_status);
    return;
}

void exit_callback(void)
{
    // log_v("this callback\n");
    mpu6050_irq_handler(mpu_handle);
    hal_clean_it();
}
osal_task_t mpu_task_t = NULL;
osal_semaphore_t mpu_sem = NULL;
float raw_data[200][6] = {0};
float gry[3] = {0};
float acc[3] = {0};
void mpu_task_relase_sem(uint8_t type)
{
    if (type == 0) /* 数据就绪中断*/
    {
        uint8_t res = mpu6050_basic_read(acc, gry);
        if (res == 0)
        {
            // log_e("acc_x:%.2f acc_y:%.2f acc_z:%.2f gry_x:%.2f gry_y:%.2f gry_z:%.2f\n",\
            //     acc[0],acc[1],acc[2],gry[0],gry[1],gry[2]);
            osal_sem_release(mpu_sem);
            static uint16_t count = 0;
            count++;
            if(count == 200)
            {
                mpu6050_stop();
                count = 0;
                log_e("mpu6050 stop entry low power\n");
            }
        }
        else
        {
            log_e("read data fail\n");
        }
    }
    else if (type == 1) /* 运动中断 */
    {
        /*清楚数据就绪 打开运动检测*/
        uint8_t res = mpu6050_basic_read(acc, gry);
        if (res == 0) {
            log_e("motion int acc_x:%.2f acc_y:%.2f acc_z:%.2f gry_x:%.2f gry_y:%.2f gry_z:%.2f\n",
                acc[0], acc[1], acc[2], gry[0], gry[1], gry[2]);
            mpu6050_get_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY, (mpu6050_bool_t *)&type);
            mpu6050_start();
            log_e("mpu6050 start entry normal\n");
        } else
        {
            mpu6050_set_interrupt(mpu_handle,MPU6050_INTERRUPT_MOTION,MPU6050_BOOL_FALSE);
            mpu6050_set_interrupt(mpu_handle,MPU6050_INTERRUPT_DATA_READY,MPU6050_BOOL_FALSE);
            log_e("mpu6050 error ...\n");
        }
    }
}

/**
 * @brief  进入低功耗模式 (1.25Hz唤醒，10Hz采样)
 * @retval None
 */
void mpu6050_enter_low_power_mode(void)
{
    /* 步骤1: 禁用所有MPU6050中断，防止在配置过程中触发 */
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_MOTION, MPU6050_BOOL_FALSE);
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_FALSE);
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FIFO_OVERFLOW, MPU6050_BOOL_FALSE);
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_I2C_MAST, MPU6050_BOOL_FALSE);

    /* 步骤3: 配置低功耗模式参数 */
    /* 启用循环唤醒模式 */
    mpu6050_set_cycle_wake_up(mpu_handle, MPU6050_BOOL_TRUE);
    mpu6050_set_wake_up_frequency(mpu_handle, MPU6050_WAKE_UP_FREQUENCY_40_HZ);

    /* 设置低采样率以节省功耗 */
    mpu6050_set_sample_rate_divider(mpu_handle, (1000 / MPU6050_LOW_POWER_SAMPLE_RATE) - 1);

    /* 禁用FIFO */
    mpu6050_set_fifo(mpu_handle, MPU6050_BOOL_FALSE);

    /* 设置低通滤波器为适当等级以减少噪声 */
    mpu6050_set_low_pass_filter(mpu_handle, MPU6050_LOW_PASS_FILTER_2);

    /* 步骤6: 启用运动检测中断（最后一步） */
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_MOTION, MPU6050_BOOL_TRUE);

    /* 验证运动检测中断已启用 */
    uint8_t motion_enabled;
    mpu6050_get_interrupt(mpu_handle, MPU6050_INTERRUPT_MOTION, &motion_enabled);
    log_e("Motion interrupt enabled: %d\n", motion_enabled);

    log_e("MPU6050 entered low power mode (%.2fHz wake-up, %dHz sampling)\n",
          (float)MPU6050_WAKEUP_FREQUENCY, MPU6050_LOW_POWER_SAMPLE_RATE);
    return;
}

void mpu6050_start(void)
{
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_MOTION, MPU6050_BOOL_FALSE);
    mpu6050_enter_high_speed_mode();
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_TRUE);
}

void mpu6050_stop(void)
{
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_FALSE);
    mpu6050_enter_low_power_mode();
    mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_MOTION, MPU6050_BOOL_TRUE);
}
extern void MX_X_CUBE_AI_Process(void);

void mpu6050_task(void *param)
{

    static uint8_t i = 0;
    mpu6050_start();
    while (1)
    {
        osal_sem_take(mpu_sem, -1);

        raw_data[i][0] = acc[0];
        raw_data[i][1] = acc[1];
        raw_data[i][2] = acc[2];
        raw_data[i][3] = acc[3];
        raw_data[i][4] = acc[4];
        raw_data[i][5] = acc[5];
        if (++i == 200)
        {
            log_v("mpu6050 buffer full\n");
            // mpu6050_stop(); /*关闭数据就绪中断，打开检测中断*/
            for (uint8_t j = 0; j < 200; j++)
            {
                if (j % 10 == 0)
                {
                    log_v(" %d acc_x:%.2f acc_y:%.2f acc_z:%.2f gry_x:%.2f gry_y:%.2f gry_z:%.2f\n",
                          j, raw_data[j][0], raw_data[j][1], raw_data[j][2], raw_data[j][3], raw_data[j][4], raw_data[j][5]);
                    osal_task_delay(10);
                }
            }
            i = 0;
            MX_X_CUBE_AI_Process();
            osal_task_delay(2000);
        }
        log_v("mpu6050_task run ...\n");
    }
}

void mpu6050_init_task(void)
{
    uint8_t res;
    mpu6050_address_t address = MPU6050_ADDRESS_AD0_LOW;
    /* 初始化MPU6050 */
    res = mpu6050_basic_init(address);
    framework_interrupts_register_handler(41, exit_callback);
    if (res != 0)
    {
        log_e("MPU6050 init fail\n");
        return;
    }
    else
    {
        log_v("MPU6050 init success\n");
    }
    if (mpu6050_basic_get_handle(&mpu_handle) != 0 || mpu_handle == NULL)
    {
        log_e("Failed to get MPU6050 handle\n");
        return;
    }
    /* 适配板子的中断配置 */
    res = mpu6050_set_interrupt_pin_type(mpu_handle, MPU6050_PIN_TYPE_PUSH_PULL);
    if (res == 0)
    {
        log_e("mpu6050 int config is ok\n");
    }
    else
    {
        return; // 直接从函数中返回
    }
    /* 配置中断引脚为低电平有效 (根据硬件连接) */
    res = mpu6050_set_interrupt_level(mpu_handle, MPU6050_PIN_LEVEL_LOW);
    if (res == 0)
    {
        log_e("mpu6050 int pin config is ok\n");
    }
    else
    {
        return; // 直接从函数中返回
    }
    mpu6050_motion_detect_init();
    hal_gpio_init_int(); /* 配置硬件中断使能 */
    /* 进入低功耗检测状态*/
    // mpu6050_stop();
    mpu_task_t = osal_task_create("mputhread", mpu6050_task, NULL, 1024 * 10, 10, 1);
    mpu_sem = osal_sem_create("mpu_sem", 0, 0);
    if (mpu_task_t == NULL || mpu_sem == NULL)
    {
        log_e("mpu task error\n");
        return;
    }
    osal_task_startup(mpu_task_t);
    return;
}