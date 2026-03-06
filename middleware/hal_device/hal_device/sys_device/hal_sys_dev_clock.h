#ifndef     HAL_SYS_DEV_CLOCK_H
#define     HAL_SYS_DEV_CLOCK_H
#ifdef  __cplusplus
extern "C"
{
#endif
/**
 * 对于clock设备应该具备管理整个系统的时钟能力，
 * 具备控制系统内核工作频率的能力，包括systick，系统每个条总线，系统每个外设。
 */

 typedef enum 
 {
    PERIPHERAL_CONTROL_I2C1_CMD = 0x01,
 }hal_sys_dev_ctr_cmd_e;

int32_t hal_sys_dev_clock_register();



#ifdef  __cplusplus
}
#endif
#endif