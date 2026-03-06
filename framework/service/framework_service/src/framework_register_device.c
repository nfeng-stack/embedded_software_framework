#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "osal.h"
#include "framework_register_device.h"
// #include "hal_device.h"

// --- 新增：strdup 的替代实现 ---
// 为了在不支持 strdup 的环境下工作，并保持与 osal_malloc 的一致性，
// 我们创建一个使用 osal_malloc 的 my_strdup 版本。
char* my_strdup(const char* str) {
    if (!str) return NULL; // 检查输入是否为 NULL 

    size_t len = strlen(str); // 计算源字符串长度 
    char* copy = (char*)osal_malloc(len + 1); // 分配 len + 1 字节内存 
    if (!copy) return NULL; // 必须检查 malloc 失败 

    strcpy(copy, str); // 复制内容并自动添加 \0 
    return copy; // 返回新字符串指针 
}
// --- 替代实现结束 ---

// 设备节点结构
typedef struct device_node {
    char *name;       // 设备名，作为哈希键
    void *dev;        // 设备指针
    struct device_node *next;  // 用于处理哈希冲突
} device_node_t;

// 设备注册表结构
typedef struct {
    uint32_t size;        // 哈希表大小
    uint32_t count;       // 当前注册的设备数量
    device_node_t **table; // 哈希表数组
} device_registry_t;

// 全局设备注册表
static device_registry_t registry = {0};

/**
 * @brief DJB2哈希函数
 * 
 * @param str 字符串
 * @return uint32_t 哈希值
 */
static uint32_t djb2_hash(const char *str) {
    uint32_t hash = 5381;
    int c;
    while ((c = *str++))
        hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
    return hash;
}

/**
 * @brief 初始化设备注册表
 * 
 * @return void
 */
void framework_register_dev_init(void) {
    // 使用质数作为哈希表大小，减少哈希冲突
    registry.size = 101;
    registry.count = 0;
    
    // 分配哈希表内存
    registry.table = (device_node_t **)osal_malloc(registry.size * sizeof(device_node_t *));
    if (!registry.table) {
        // 错误处理，实际项目中可能需要更完善的错误处理
        return;
    }
    
    // 初始化哈希表
    for (uint32_t i = 0; i < registry.size; i++) {
        registry.table[i] = NULL;
    }
    // hal_sys_dev_clock_register();
    // hal_bus_dev_i2c_register();
}

/**
 * @brief 注册设备
 * 
 * @param name 设备名称
 * @param device 设备指针
 * @return int32_t 0表示成功，负数表示错误
 */
int32_t framework_register_device(const char *name, const void *device) {
    if (name == NULL || device == NULL) {
        return -1;  // 参数错误
    }
    
    // 检查设备是否已经注册
    uint32_t hash = djb2_hash(name) % registry.size;
    device_node_t *current = registry.table[hash];
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return -2;  // 设备已存在
        }
        current = current->next;
    }
    
    // 创建新节点
    device_node_t *new_node = (device_node_t *)osal_malloc(sizeof(device_node_t));
    if (new_node == NULL) {
        return -3;  // 内存分配失败
    }
    
    // 复制设备名
    new_node->name = my_strdup(name);
    if (!new_node->name) { // 检查 my_strdup 是否成功
        osal_free(new_node); // 如果复制名字失败，要释放之前分配的节点
        return -3; // 返回内存分配失败错误码
    }
    
    new_node->dev = (void *)device;
    new_node->next = registry.table[hash];
    registry.table[hash] = new_node;
    
    registry.count++;
    return 0;
}

/**
 * @brief 查找设备
 * 
 * @param name 设备名称
 * @return void* 设备指针，如果未找到则返回NULL
 */
void *framework_find_device(const char *name) {
    if (name == NULL) {
        return NULL;
    }
    
    uint32_t hash = djb2_hash(name) % registry.size;
    device_node_t *current = registry.table[hash];
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            return current->dev;
        }
        current = current->next;
    }
    return NULL;  // 设备未找到
}

/**
 * @brief 取消注册设备
 * 
 * @param name 设备名称
 * @return int32_t 0表示成功，-1表示参数错误，-2表示设备未找到
 */
int32_t framework_unregister_device(const char *name) {
    if (name == NULL) {
        return -1;  // 参数错误
    }
    
    uint32_t hash = djb2_hash(name) % registry.size;
    device_node_t *current = registry.table[hash];
    device_node_t *prev = NULL;
    
    while (current != NULL) {
        if (strcmp(current->name, name) == 0) {
            // 找到要取消注册的设备
            if (prev) {
                prev->next = current->next;
            } else {
                registry.table[hash] = current->next;
            }
            
            // 释放节点内存
            osal_free(current->name); // 使用 osal_free 释放由 my_strdup 分配的内存
            osal_free(current);       // 使用 osal_free 释放节点内存
            registry.count--;
            return 0;
        }
        prev = current;
        current = current->next;
    }
    
    return -2;  // 设备未找到
}