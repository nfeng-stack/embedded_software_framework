#ifndef     HAL_BUS_DEV_UART_H
#define     HAL_BUS_DEV_UART_H
#ifdef      __cpulsplus
extern  "C"
{
#endif

/**
 * @file hal_serial.h
 * @brief 串口设备驱动专用配置结构体
 *
 * 本结构体定义了串口设备初始化所需的核心配置信息，完全与硬件无关。
 * 设计参考Linux串口设备模型和标准串行通信协议，确保设备驱动的可移植性和标准化。
 *
 * @note 仅包含串行协议层必需的配置，不包含任何MCU特定的寄存器配置
 * @note 与HAL框架的hal_dev_config_t配合使用，通过init_config字段传递
 */

/* ================== 串口数据位配置 ================== */
/**
 * @brief 串口数据位配置
 *
 * 本枚举定义了串口数据位的长度，确保协议层正确处理数据传输。
 */
typedef enum {
    HAL_UART_DATA_BITS_7 = 7,  /**< 7位数据 */
    HAL_UART_DATA_BITS_8 = 8,  /**< 8位数据 */
    HAL_UART_DATA_BITS_9 = 9,  /**< 6位数据 */
} hal_uart_data_bits_e;

/* ================== 串口停止位配置 ================== */
/**
 * @brief 串口停止位配置
 *
 * 本枚举定义了串口停止位的长度，确保协议层正确处理数据传输。
 */
typedef enum {
    HAL_UART_STOP_BITS_0_5 = 05,
    HAL_UART_STOP_BITS_1 = 1,   /**< 1位停止位 */
    HAL_UART_STOP_BITS_1_5 = 15, /**< 1.5位停止位 */
    HAL_UART_STOP_BITS_2 = 2,   /**< 2位停止位 */
} hal_uart_stop_bits_e;

/* ================== 串口校验位配置 ================== */
/**
 * @brief 串口校验位配置
 *
 * 本枚举定义了串口校验位的类型，确保协议层正确处理数据传输。
 */
typedef enum {
    HAL_UART_PARITY_NONE = 0,   /**< 无校验 */
    HAL_UART_PARITY_ODD = 1,    /**< 奇校验 */
    HAL_UART_PARITY_EVEN = 2,   /**< 偶校验 */
    HAL_UART_PARITY_MARK = 3,   /**< 标记校验 */
    HAL_UART_PARITY_SPACE = 4,  /**< 空格校验 */
} hal_uart_parity_e;

/* ================== 串口流控制配置 ================== */
/**
 * @brief 串口流控制配置
 *
 * 本枚举定义了串口流控制的类型，确保协议层正确处理数据传输。
 */
typedef enum {
    HAL_UART_FLOW_CONTROL_NONE = 0,   /**< 无流控制 */
    HAL_UART_FLOW_CONTROL_RTS_CTS = 1, /**< RTS/CTS流控制 */
    HAL_UART_FLOW_CONTROL_XON_XOFF = 2, /**< XON/XOFF流控制 */
} hal_uart_flow_control_e;

typedef enum{
    HAL_UART_INSTANCE_UART1 = 0X01,
    HAL_UART_INSTANCE_UART2 = 0X02
} hal_uart_instance_e;

/* ================== 串口设备配置结构体 ================== */
/**
 * @brief 串口设备配置结构体
 *
 * 本结构体定义了串口设备初始化所需的核心配置信息，完全与硬件无关。
 * 仅包含串行协议层必需的参数，确保设备驱动的可移植性。
 * 
 * @note 设备驱动应通过hal_dev_config_t的init_config字段传递此结构体
 * @note 与硬件无关：不包含任何MCU特定的寄存器配置、时钟频率等
 */
typedef struct {
    uint32_t baud_rate;                /**< 串口波特率 (bps, e.g. 9600, 115200) */
    hal_uart_data_bits_e data_bits;  /**< 数据位长度 (5-8) */
    hal_uart_stop_bits_e stop_bits;  /**< 停止位长度 (1, 1.5, 2) */
    hal_uart_parity_e parity;        /**< 校验位类型 */
    hal_uart_flow_control_e flow_control; /**< 流控制类型 */
} hal_bus_dev_uart_init_config_t;

int32_t hal_bus_dev_uart_register();




#ifdef      __cplusplus
}
#endif
#endif