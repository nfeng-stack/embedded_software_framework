#ifndef FRAMEWORK_REGISTER_DEVICE_H
#define FRAMEWORK_REGISTER_DEVICE_H

#include <stdint.h>
#include <stddef.h>

/**
 * @brief 注册设备
 * 
 * @param name 设备名称（用于查找）
 * @param device 设备指针
 * @return int32_t 0表示成功，负数表示错误
 *         -1: 参数错误（name或device为NULL）
 *         -2: 设备已存在
 *         -3: 内存分配失败
 */
int32_t framework_register_device(const char *name, const void *device);

/**
 * @brief 查找设备
 * 
 * @param name 设备名称
 * @return void* 设备指针，如果未找到则返回NULL
 */
void *framework_find_device(const char *name);

/**
 * @brief 取消注册设备
 * 
 * @param name 设备名称
 * @return int32_t 0表示成功，-1表示参数错误，-2表示设备未找到
 */
int32_t framework_unregister_device(const char *name);

/**
 * @brief 初始化设备注册表
 * 
 * @return void
 */
void framework_register_dev_init(void);

#endif // FRAMEWORK_REGISTER_DEVICE_H