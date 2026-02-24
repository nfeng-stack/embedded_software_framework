/**
 * @file hal_device.h
 * @brief 现代化HAL设备框架 - 为嵌入式系统提供Linux风格的设备抽象层
 *
 * 本框架采用Linux设备驱动设计哲学，完全剥离OS依赖，适配裸机、FreeRTOS、RT-Thread等嵌入式环境。
 * 通过标准化设备接口，为应用层提供稳定、可移植的驱动抽象，减少硬件差异带来的开发复杂性。
 * 设计遵循"意图而非动作"原则，使代码自解释性更强，降低维护成本。
 *
 * @note 本文件定义所有设备类型的基类和操作接口，各外设驱动应包含此文件并定义具体设备结构
 * @note 设备状态管理遵循Linux设备生命周期模型：未初始化 -> 初始化 -> 打开 -> 使用中 -> 关闭 -> 未初始化
 * @note 错误处理采用Linux标准错误码规范（负值表示错误，0表示成功）
 * @note 本框架设计符合嵌入式系统资源受限环境下的维护性要求
 * @note 设备持有关系使用"持有者"而非"拥有者"表述，避免所有权混淆
 */
#ifndef HAL_DEVICE_H
#define HAL_DEVICE_H

#ifdef __cplusplus
extern "C"
{
#endif

#include <stdint.h>
#include <stddef.h>

/* ================== 设备类型定义 ================== */
/**
 * @brief 设备类型枚举
 *
 * 本枚举定义了系统中可能存在的设备类型，用于设备分类和操作接口分发。
 * 设计遵循Linux设备分类思想，确保设备驱动开发的模块化和可扩展性。
 */
typedef enum {
    HAL_DEV_TYPE_CHAR = 0x01,  /**< 字符设备: 传感器、LED、按键等流式数据设备 */
    HAL_DEV_TYPE_BLOCK = 0x02, /**< 块设备: Flash存储器、SD卡等块级存储设备 */
    HAL_DEV_TYPE_BUS = 0x03,   /**< 总线接口设备: I2C、SPI、USART等通信总线设备 */
    HAL_DEV_TYPE_NET = 0x04,   /**< 网络设备: CAN、以太网等网络通信设备 */
    HAL_DEV_TYPE_OTHER = 0x05, /**< 其他类型设备: 未归类设备 */
} hal_dev_type_e;

/* ================== 设备状态定义 ================== */
/**
 * @brief 设备状态枚举
 *
 * 本枚举定义了设备在生命周期中可能处于的状态，用于设备状态管理和错误处理。
 * 设计参考Linux设备驱动状态管理机制，确保设备状态的完整性和一致性。
 * 每个状态转换都应有明确的触发条件和操作，避免状态不一致。
 */
typedef enum {
    HAL_DEV_NO_INIT = 0x00,  /**< 设备未初始化: 未进行任何初始化操作 */
    HAL_DEV_OPENED = 0x01,   /**< 设备已打开: 已完成初始化，可进行读写操作 */
    HAL_DEV_USING = 0x02,    /**< 设备正在使用: 已被应用层打开并处于活动状态 */
    HAL_DEV_FAULT = 0x03,    /**< 设备故障: 设备出现错误，无法正常工作 */
    HAL_DEV_CLOSED = 0x04,   /**< 设备已关闭: 已被应用层关闭，不再可进行操作 */
    HAL_DEV_DEINIT = 0x05,   /**< 设备已去初始化: 已完成去初始化，恢复到未初始化状态 */
    HAL_DEV_UNKNOWN = 0x06,  /**< 设备状态未知: 设备状态无法确定 */
} hal_dev_state_e;

/* ================== 设备错误码定义 ================== */
/**
 * @brief HAL设备错误码枚举
 *
 * 本枚举定义了设备操作中可能发生的错误类型，遵循Linux错误码规范（负值表示错误）。
 * 设计参考Linux errno规范，确保错误码的语义清晰和可移植性。
 * 所有错误码均使用负值，0表示成功，负值表示错误（-errno）。
 */
typedef enum {
    HAL_ERR_SUCCESS = 0,                     /**< 操作成功 */
    HAL_ERR_INVALID_PARAM = -1,              /**< 无效参数 */
    HAL_ERR_NOT_INITIALIZED = -2,            /**< 设备未初始化 */
    HAL_ERR_ALREADY_OPEN = -3,               /**< 设备已打开 */
    HAL_ERR_NOT_OPEN = -4,                   /**< 设备未打开 */
    HAL_ERR_FAULT = -5,                      /**< 设备故障 */
    HAL_ERR_TIMEOUT = -6,                    /**< 操作超时 */
    HAL_ERR_NO_MEMORY = -7,                  /**< 内存不足 */
    HAL_ERR_NOT_SUPPORTED = -8,              /**< 操作不支持 */
    HAL_ERR_BUSY = -9,                       /**< 设备忙 */
    HAL_ERR_INVALID_STATE = -10,             /**< 无效状态 */
    HAL_ERR_INVALID_OPERATION = -11,         /**< 无效操作 */
    HAL_ERR_INVALID_DEVICE = -12,            /**< 无效设备 */
    HAL_ERR_DEVICE_BUSY = -13,               /**< 设备忙 */
    HAL_ERR_DEVICE_FAULT = -14,              /**< 设备故障 */
} hal_errno_e;

/* ================== 设备持有关系定义 ================== */
/**
 * @brief 设备持有者链表节点，用来表示设备持有哪些设备
 *
 * 用于管理设备被哪些组件"持有"（即使用该设备的组件），支持设备的多用户共享。
 * 设计参考Linux内核的引用计数机制，但采用链表实现，适用于嵌入式环境。
 * @note "持有"表示使用关系，而非所有权，避免与C++所有权概念混淆
 */
typedef struct hal_dev_holder {
    struct hal_dev_holder *next;            /**< 下一个持有者节点 */
    struct hal_dev *holder;                 /**< 持有该设备的组件 */
} hal_dev_holder_t;

/**
 * @brief 设备状态管理结构
 *
 * 该结构体用于管理设备的状态及其持有者信息，确保设备状态的一致性。
 * 设计参考Linux设备状态管理思想，为设备提供完整的状态生命周期管理。
 */
typedef struct hal_dev_state {
    hal_dev_state_e state;                  /**< 当前设备状态 */
    uint8_t hold_count;                     /**< 当前持有设备的组件数量 */
    struct hal_dev * owner;                 /**< 当前设备被那个设备拥有 */
    hal_dev_holder_t hold_head;             /**< 持有设备的链表头 */
} hal_dev_state_t;

/* ================== 设备操作接口适配具体硬件 ================== */
/**
 * @brief 设备操作接口
 *
 * 本结构体定义了设备的标准操作接口，所有设备驱动必须实现这些接口。
 * 设计遵循Linux字符设备驱动框架思想，确保接口的统一性和可移植性。
 * 每个函数指针都应有清晰的语义和错误处理机制。
 */
typedef struct hal_ops {
    int (*l_init)(struct hal_dev *selfdev);                /**< 设备初始化 */
    int (*l_open)(struct hal_dev *selfdev);                /**< 设备打开 */
    int (*l_close)(struct hal_dev *selfdev);               /**< 设备关闭 */
    int (*l_deinit)(struct hal_dev *selfdev);              /**< 设备去初始化 */
    int (*l_read)(struct hal_dev *selfdev, void *buf, size_t len, uint32_t timeout_ms); /**< 设备读操作 */
    int (*l_write)(struct hal_dev *selfdev, const void *buf, size_t len, uint32_t timeout_ms); /**< 设备写操作 */
    int (*l_control)(struct hal_dev *selfdev, uint32_t cmd, void *arg); /**< 设备控制命令 */
    int (*l_notify_register)(struct hal_dev *selfdev, void (*notify_callback)(struct hal_dev *callback_dev)); /**< 通知回调注册 */
    void *l_extend_ops; /* 设备的扩展操作，指向设备扩展操作结构体 */
} hal_l_ops_t;
/* ================== 设备操作接口 ================== */
/**
 * @brief 设备操作接口
 *
 * 本结构体定义了设备的标准操作接口，所有设备驱动必须实现这些接口。
 * 设计遵循Linux字符设备驱动框架思想，确保接口的统一性和可移植性。
 * 每个函数指针都应有清晰的语义和错误处理机制。
 */
typedef struct hal_ops {
    int (*init)(struct hal_dev *selfdev);                /**< 设备初始化 */
    int (*open)(struct hal_dev *selfdev);                /**< 设备打开 */
    int (*close)(struct hal_dev *selfdev);               /**< 设备关闭 */
    int (*deinit)(struct hal_dev *selfdev);              /**< 设备去初始化 */
    int (*read)(struct hal_dev *selfdev, void *buf, size_t len, uint32_t timeout_ms); /**< 设备读操作 */
    int (*write)(struct hal_dev *selfdev, const void *buf, size_t len, uint32_t timeout_ms); /**< 设备写操作 */
    int (*control)(struct hal_dev *selfdev, uint32_t cmd, void *arg); /**< 设备控制命令 */
    int (*notify_register)(struct hal_dev *selfdev, void (*notify_callback)(struct hal_dev *callback_dev)); /**< 通知回调注册 */
    hal_l_ops_t * l_ops;
    void *extend_ops; /* 设备的扩展操作，指向设备扩展操作结构体 */
} hal_ops_t;

/* ================== 设备配置 ================== */
/**
 * @brief 设备配置结构
 *
 * 本结构体用于存储设备的初始化配置和回调函数，使设备驱动能够灵活适应不同硬件。
 * 设计参考Linux设备树思想，通过配置结构实现硬件与驱动的解耦。
 */
typedef struct hal_config {
    uint32_t read_buffer_size;/* 设备读数据缓冲区大小 */
    uint32_t write_buffer_size; /* 设备写缓冲区大小*/
    void *init_config; /* 具体设备的初始化配置，如GPIO引脚号、时钟频率等 */
    void (*notify_callback)(struct hal_dev *callback_dev); /* 通知回调函数 */
    struct hal_dev *notify_dev; /* 通知目标设备 */
} hal_dev_config_t;

/* ================== 设备核心结构 ================== */
/**
 * @brief 设备核心结构体
 *
 * 本结构体是所有设备的基类，包含设备的基本信息和操作接口。
 * 设计参考Linux设备模型，确保设备驱动的统一性和可扩展性。
 * 每个设备都应包含此结构体作为其成员，以实现统一的设备管理。
 */
typedef struct hal_dev {
    const char *dev_name;                   /**< 设备名称，用于系统识别 */
    hal_dev_type_e device_class;      /**< 设备类型，用于分类和操作分发 */
    hal_ops_t opts;                   /**< 设备操作接口 */
    hal_dev_config_t config;          /**< 设备工作配置 */
    hal_dev_state_t state;            /**< 设备状态管理结构 */
    char *read_buffer;
    char *write_buffer;
} hal_device_t;

/* ================== 设备注册与管理接口 ================== */
/**
 * @brief 注册设备到系统
 *
 * 本函数将设备注册到系统中，使其可被应用层发现和使用。
 * 设计参考Linux设备注册机制，确保设备的可发现性和可管理性。
 *
 * @param dev 设备结构体指针
 * @return HAL_ERR_SUCCESS表示成功，其他表示失败（错误码参考hal_errno_e）
 * @note 设备注册后，系统将管理设备的生命周期，应用层无需关心设备的内部实现
 */
int hal_dev_register(const hal_device_t *dev);

/**
 * @brief 从系统中注销设备
 *
 * 本函数将设备从系统中注销，使其不再被应用层发现和使用。
 * 设计参考Linux设备注销机制，确保资源的正确回收。
 *
 * @param dev 设备结构体指针
 * @return HAL_ERR_SUCCESS表示成功，其他表示失败
 * @note 注销前应确保设备已关闭且处于未使用状态
 */
int hal_dev_unregister(const hal_device_t *dev);

/**
 * @brief 在系统中查找设备
 *
 * 本函数通过设备名称查找已注册的设备。
 * 设计参考Linux设备查找机制，确保设备的可发现性。
 *
 * @param name 设备名称
 * @return 找到的设备指针，若未找到则返回NULL
 * @note 查找结果应进行NULL检查，避免空指针解引用
 */
hal_device_t * hal_dev_find(const char * name);

/**
 * @brief 初始化设备
 *
 * 本函数初始化设备，使其进入可操作状态。
 * 设计参考Linux设备初始化流程，确保设备初始化的正确性和一致性。
 *
 * @param dev 设备结构体指针
 * @return HAL_ERR_SUCCESS表示成功，其他表示失败（错误码参考hal_errno_e）
 * @note 初始化前应确保设备未处于其他状态，如已初始化或打开状态
 * @note 初始化失败时，设备应保持在未初始化状态
 */
int hal_dev_init(hal_device_t *dev);

/**
 * @brief 释放设备资源
 *
 * 本函数释放设备占用的资源，使其恢复到未初始化状态。
 * 设计参考Linux设备去初始化流程，确保资源的正确回收。
 *
 * @param dev 设备结构体指针
 * @return HAL_ERR_SUCCESS表示成功，其他表示失败
 * @note 释放前应确保设备已关闭，避免资源泄漏
 * @note 释放后设备应处于未初始化状态，可重新初始化
 */
int hal_dev_deinit(hal_device_t *dev);

/**
 * @brief 设置设备状态
 *
 * 本函数用于设置设备的状态，确保状态转换符合设备生命周期模型。
 * 设计参考Linux设备状态管理机制，确保状态转换的正确性。
 *
 * @param dev 设备结构体指针
 * @param state 要设置的目标状态
 * @return HAL_ERR_SUCCESS表示成功，其他表示失败（错误码参考hal_errno_e）
 * @note 状态转换应遵循设备状态机，避免非法状态转换
 * @note 状态设置前应进行状态检查，确保转换合法
 */
int hal_dev_set_state(hal_device_t *dev, hal_dev_state_e state);

/**
 * @brief 获取设备状态
 *
 * 本函数用于获取设备的当前状态。
 * 设计参考Linux设备状态获取机制，确保状态信息的准确性和一致性。
 *
 * @param dev 设备结构体指针
 * @return 当前设备状态
 * @note 状态获取不应修改设备状态，应为只读操作
 */
hal_dev_state_e hal_dev_get_state(hal_device_t *dev);

/**
 * @brief 获取设备信息
 *
 * 本函数用于获取设备的详细信息，如硬件版本、驱动版本等。
 * 设计参考Linux设备信息获取机制，提供设备的元数据信息。
 *
 * @param dev 设备结构体指针
 * @param info 用于存储设备信息的缓冲区
 * @param len 缓冲区长度
 * @return 实际写入缓冲区的字节数，或负数表示错误（错误码参考hal_errno_e）
 * @note 信息格式应遵循统一规范，便于应用层解析
 */
int hal_dev_get_info(hal_device_t *dev, void *info, size_t len);

/**
 * @brief 执行设备控制命令
 *
 * 本函数用于执行设备特定的控制命令，类似于Linux的ioctl。
 * 设计参考Linux ioctl机制，提供灵活的设备控制接口。
 *
 * @param dev 设备结构体指针
 * @param cmd 控制命令
 * @param arg 命令参数
 * @return HAL_ERR_SUCCESS表示成功，其他表示失败（错误码参考hal_errno_e）
 * @note 控制命令应有明确的语义和参数规范
 * @note 命令执行失败时，应设置适当的错误码
 */
int hal_dev_control(hal_device_t *dev, uint32_t cmd, void *arg);

/**
 * @brief 获取设备持有者列表
 *
 * 本函数用于获取当前持有该设备的组件列表。
 * 设计参考Linux设备持有关系管理，提供设备共享状态信息。
 *
 * @param dev 设备结构体指针
 * @param holders 用于存储持有者列表的缓冲区
 * @param len 缓冲区长度
 * @return 实际获取的持有者数量，或负数表示错误
 * @note 应用层可使用此接口检查设备是否被其他组件持有
 */
int hal_dev_get_holders(hal_device_t *dev, hal_device_t **holders, size_t len);

/**
 * @brief 获取设备的父设备
 *
 * 本函数用于获取设备的父设备（如总线设备）。
 * 设计参考Linux设备树思想，提供设备层次关系。
 *
 * @param dev 设备结构体指针
 * @return 父设备指针，若无父设备则返回NULL
 */
hal_device_t * hal_dev_get_parent(hal_device_t *dev);

/**
 * @brief 设置设备的父设备
 *
 * 本函数用于设置设备的父设备（如总线设备）。
 * 设计参考Linux设备树思想，建立设备层次关系。
 *
 * @param dev 设备结构体指针
 * @param parent 父设备指针
 * @return HAL_ERR_SUCCESS表示成功，其他表示失败
 */
int hal_dev_set_parent(hal_device_t *dev, hal_device_t *parent);

#ifdef __cplusplus
}
#endif

#endif /* HAL_DEVICE_H */