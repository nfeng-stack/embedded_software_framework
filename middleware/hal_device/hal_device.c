
#ifdef __cplusplus
extern "C"
{
#endif
#include "hal_device.h"
#include "framework_register_device.h"
#include "elog.h"
#define LOG_TAG     "hal_dev"
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
int hal_dev_register(const hal_device_t *dev) /* 函数的具体实现应该由框架层注册到内核去*/
{    
    int32_t res = framework_register_device((const void *)dev);
    if (res)
    {
        log_e("%s,hal register dev error\n",__func__);
        return -1;
    }
    return 0;
}

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
int hal_dev_unregister(const hal_device_t *dev)
{
    return framework_unregister_device((const void *)dev);   
}

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
hal_device_t * hal_dev_find(const char * name)
{
    return (hal_device_t *)framework_find_device((const char *)name);
}

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
int hal_dev_init(hal_device_t *dev)
{
    return dev->opts.init(dev);
}

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
int hal_dev_deinit(hal_device_t *dev)
{
    return dev->opts.deinit(dev);
}

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
int hal_dev_set_state(hal_device_t *dev, hal_dev_state_e state)
{
    return 0;
}

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
hal_dev_state_e hal_dev_get_state(hal_device_t *dev)
{
    return dev->state.state;
}

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
int hal_dev_get_info(hal_device_t *dev, void *info, size_t len)
{
    return 0;
}

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
int hal_dev_control(hal_device_t *dev, uint32_t cmd, void *arg)
{
    return 0;
}

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
int hal_dev_get_holders(hal_device_t *dev, hal_device_t **holders, size_t len)
{
    return 0;
}

/**
 * @brief 获取设备的父设备
 *
 * 本函数用于获取设备的父设备（如总线设备）。
 * 设计参考Linux设备树思想，提供设备层次关系。
 *
 * @param dev 设备结构体指针
 * @return 父设备指针，若无父设备则返回NULL
 */
hal_device_t * hal_dev_get_parent(hal_device_t *dev)
{
    return 0;
}

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
int hal_dev_set_parent(hal_device_t *dev, hal_device_t *parent)
{
    return 0;
}


#ifdef __cplusplus
}
#endif