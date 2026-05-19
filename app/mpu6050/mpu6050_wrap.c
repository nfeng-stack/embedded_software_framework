#ifndef LIVE_TEST_MODE

#define LOG_TAG "MPU6050"
#define LOG_LVL ELOG_LVL_DEBUG // Enable DEBUG level for this module
#define MPU6050_MOTION_THRESHOLD_MG 2000.0f
#define MPU6050_FREE_THRESHOLD_MG 700.0f
// # Low power sample rate in Hz (default 10Hz)
#define MPU6050_LOW_POWER_SAMPLE_RATE 10
// # High speed sample rate in Hz (default 200Hz)
#define MPU6050_HIGH_SPEED_SAMPLE_RATE 200
// # Wake-up frequency in Hz (1.25Hz only option for MPU6050)
#define MPU6050_WAKEUP_FREQUENCY 1.25

#define MPU6050_MOTION_DURATION 1
#define MPU6050_FREE_DURATION 1

#include "driver_mpu6050.h"
#include "driver_mpu6050_basic.h"
#include "mpu6050_data_logger.h"
#include "elog.h"
#include "framework_interrupts.h"
#include "osal.h"
#include "hal.h"
#include "stdio.h"

/* Log category macros for better debug organization */
#define LOG_INIT "[INIT]" // Initialization logs
#define LOG_MODE "[MODE]" // Mode transition logs
#define LOG_INT "[INT]"   // Interrupt logs
#define LOG_DATA "[DATA]" // Data processing logs
#define LOG_ERR "[ERR]"   // Error logs
#define LOG_CFG "[CFG]"   // Configuration logs

static mpu6050_handle_t *mpu_handle = NULL;

osal_task_t mpu_task_t = NULL;
osal_semaphore_t mpu_sem = NULL;
float raw_data[200][6] = {0};

void exit_callback(void)
{
    osal_sem_release(mpu_sem);
    hal_clean_it();
}

extern float net_data[200][6];

void quantize_data(float raw_data[200][6], float quantized_data[200][6], int num_data) {
    // 计算归一化系数，避免在循环中重复计算
    const float acc_scale = 255.0f / 32.0f;    // 32 = 16 - (-16)
    const float gry_scale = 255.0f / 4000.0f;  // 4000 = 2000 - (-2000)
    
    for (int i = 0; i < num_data; i++) {
        // 处理加速度计数据 (acc_x, acc_y, acc_z)
        for (int j = 0; j < 3; j++) {
            float value = raw_data[i][j];
            
            // 确保值在有效范围内
            if (value < -16.0f) value = -16.0f;
            else if (value > 16.0f) value = 16.0f;
            
            // 归一化到0-255的浮点数
            quantized_data[i][j] = (value + 16.0f) * acc_scale;
        }
        
        // 处理角速度计数据 (gry_x, gry_y, gry_z)
        for (int j = 3; j < 6; j++) {
            float value = raw_data[i][j];
            
            // 确保值在有效范围内
            if (value < -2000.0f) value = -2000.0f;
            else if (value > 2000.0f) value = 2000.0f;
            
            // 归一化到0-255的浮点数
            quantized_data[i][j] = (value + 2000.0f) * gry_scale;
        }
    }
}
extern void ai_sem_relase(void);
void mpu6050_task(void *param)
{

    static uint8_t i = 0;
    uint8_t reg = 0;
    uint8_t res = 0;
    res = mpu6050_get_interrupt_status(mpu_handle, &reg);
    if (res != 0)
    {
        log_e("mpu6050 get int state failed \n");
    }
    log_e("mpu6050 int status %#X\n", reg);
    res = mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE, MPU6050_BOOL_TRUE);
    if (res != 0)
    {
        log_e("set free int failed\n");
        return;
    }
    reg = 0;
    res = mpu6050_get_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE, &reg);
    if (res != 0 || reg != 1)
    {
        log_e("set free int failed\n");
    }
    log_e("mpu6050 int free enable %d\n", reg);

    while (1)
    {
        osal_sem_take(mpu_sem, -1);
        // log_e("mpu6050 task runing ...\n");
        res = mpu6050_get_interrupt_status(mpu_handle, &reg);
        if (res != 0)
        {
            log_e("mpu6050 get int status failed\n");
            mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE | MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_FALSE);
            return;
        }
        res = mpu6050_basic_read(raw_data[i], raw_data[i] + 3);
        i++;
        if (res != 0)
        {
            log_e("mpu6050 get data failed\n");
            mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE | MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_FALSE);
            return;
        }

        if (reg >> MPU6050_INTERRUPT_FREE && 0x01)
        {
            /* 只有落体中断*/
            mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE, MPU6050_BOOL_FALSE);
            mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_TRUE);
        }
        else
        {
            /* 数据就绪中断*/
            if (i == 200)
            {
                log_i("%s Buffer full (200 samples) - starting AI processing\n", LOG_DATA);
                mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY | MPU6050_INTERRUPT_DATA_READY, MPU6050_BOOL_FALSE);
                for (uint8_t j = 0; j < 200; j++)
                {
                    if (j % 10 == 0)
                    {
                        log_d("%s [%d] acc[%.2f, %.2f, %.2f] gry[%.2f, %.2f, %.2f]\n",
                              LOG_DATA, j, raw_data[j][0], raw_data[j][1], raw_data[j][2], raw_data[j][3], raw_data[j][4], raw_data[j][5]);
                        osal_task_delay(10);
                    }
                }
                
                /* Write raw sensor data to persistent storage */
                mpu6050_data_logger_write_batch(raw_data, 200);
                
                i = 0;
                quantize_data(raw_data,net_data,200);
                /**< 此处应该释放ai推理线程让其输出推理结果 */
                ai_sem_relase();
                log_d("%s AI processing complete - waiting 2s before next buffer\n", LOG_DATA);
                osal_task_delay(100);
                mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE, MPU6050_BOOL_TRUE);

            }
        }
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
        log_i("%s Interrupt pin type configured (push-pull)\n", LOG_INIT);
    }
    else
    {
        return; // 直接从函数中返回
    }
    /* 配置中断引脚为低电平有效 (根据硬件连接) */
    res = mpu6050_set_interrupt_level(mpu_handle, MPU6050_PIN_LEVEL_LOW);
    if (res == 0)
    {
        log_i("%s Interrupt pin level configured (low active)\n", LOG_INIT);
    }
    else
    {
        return; // 直接从函数中返回
    }
    mpu6050_set_interrupt_read_clear(mpu_handle, MPU6050_BOOL_TRUE);
    // mpu6050_motion_detect_init();
    float threshold_mg = MPU6050_FREE_THRESHOLD_MG;
    uint8_t reg;
    res = mpu6050_free_threshold_convert_to_register(mpu_handle, threshold_mg, &reg);
    if (res == 0)
    {
        res = mpu6050_set_free_threshold(mpu_handle, reg);
        if (res == 0)
        {
            log_e("free threshold set to ±%.1fg (%dmg) (reg: 0x%02X)\n",
                  threshold_mg / 1000.0f, (int)threshold_mg, reg);
            threshold_mg = 0.0, reg = 0;
            res = mpu6050_get_free_threshold(mpu_handle, &reg);
            if (res != 0)
            {
                log_e("free thread get fail\n");
                return;
            }
            res = mpu6050_free_threshold_convert_to_data(mpu_handle, reg, &threshold_mg);
            if (res != 0)
            {
                log_e("free threshold :%.1fg\n", threshold_mg);
            }
        }
        else
        {
            log_e("free threshold set failed\n");
            return;
        }
    }
    res = mpu6050_set_free_duration(mpu_handle, MPU6050_FREE_DURATION);
    if (res != 0)
    {
        log_e("free duration set failed\n");
        return;
    }
    res = mpu6050_get_free_duration(mpu_handle, &reg);
    if (res != 0)
    {
        log_e("free duration failed\n");
        return;
    }
    log_e("free duration %d\n", reg);
    hal_gpio_init_int(); /* 配置硬件中断使能 */
    mpu_task_t = osal_task_create("mputhread", mpu6050_task, NULL, 1024 * 10, 10, 20);
    mpu_sem = osal_sem_create("mpu_sem", 0, 0);
    if (mpu_task_t == NULL || mpu_sem == NULL)
    {
        log_e("mpu task error\n");
        return;
    }
    osal_task_startup(mpu_task_t);
    
    /* Initialize data logger */
    mpu6050_data_logger_init();
    
    return;
}

#endif /* LIVE_TEST_MODE */