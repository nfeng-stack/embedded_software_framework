/**
 * @file hal_i2c.h
 * @brief I2C设备驱动专用配置结构体
 *
 * 本结构体定义了I2C设备初始化所需的核心配置信息，完全与硬件无关。
 * 设计参考Linux I2C设备模型和Zephyr I2C框架，确保设备驱动的可移植性和标准化。
 *
 * @note 仅包含I2C协议层必需的配置，不包含任何MCU特定的寄存器配置
 * @note 与HAL框架的hal_dev_config_t配合使用，通过init_config字段传递
 */
#ifndef HAL_I2C_H
#define HAL_I2C_H

/* ================== I2C设备地址模式 ================== */
/**
 * @brief I2C设备地址模式
 *
 * 本枚举定义了I2C设备使用的地址格式，确保协议层正确处理地址传输。
 * 设计参考Linux I2C设备模型（I2C_M_TEN标志）和Zephyr I2C框架。
 */
typedef enum {
    HAL_I2C_ADDR_7BIT = 0,  /**< 7位地址 (0x00-0x7F) */
    HAL_I2C_ADDR_10BIT = 1, /**< 10位地址 (0x000-0x3FF) */
} hal_i2c_addr_mode_e;

/* ================== I2C设备配置结构体 ================== */
/**
 * @brief I2C从设备配置结构体
 *
 * 本结构体定义了I2C从设备初始化所需的核心配置信息，完全与硬件无关。
 * 仅包含I2C协议层必需的参数，确保设备驱动的可移植性。
 * 
 * @note 设备驱动应通过hal_dev_config_t的init_config字段传递此结构体
 * @note 与硬件无关：不包含任何MCU特定的寄存器配置、时钟频率等
 */
typedef struct {
    uint16_t addr;           /**< I2C从设备地址 (7位: 0-127, 10位: 0-1023) */
    hal_i2c_addr_mode_e mode;/**< 地址模式 (7位或10位) */
    uint32_t speed;          /**< I2C总线速度 (kHz, 100, 400, 1000, etc.) */
} hal_bus_dev_i2c_init_config_t;

int32_t hal_bus_dev_i2c_register();






#endif /* HAL_I2C_H */