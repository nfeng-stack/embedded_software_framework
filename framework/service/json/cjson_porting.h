/**
 * @file cjson_porting.h
 * @brief cJSON 嵌入式平台适配层
 */

#ifndef CJSON_PORTING_H
#define CJSON_PORTING_H

#include <stddef.h>

/**
 * @brief 初始化 cJSON 内存分配器
 * @note 应在应用初始化时调用一次
 */
void cJSON_Porting_Init(void);

/**
 * @brief 检查 cJSON 是否已初始化
 */
int cJSON_Is_Init(void);

#endif /* CJSON_PORTING_H */
