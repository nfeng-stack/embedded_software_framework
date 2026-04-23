#define LOG_TAG "at_task"
#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>
#include "osal.h"
#include "hal.h"
#include "elog.h"
#include "at_command.h"
#include "cjson_porting.h"
#include "cJSON.h"

#ifndef strtok_r
#define strtok_r(str, delim, saveptr) strtok(str, delim)
#endif

/* 高德地图 API 基础 URL（不含经纬度参数） */
#define AMAP_BASE_URL "https://restapi.amap.com/v3/geocode/regeo?key=4f70fd02d9bc904c99e6a341eb0f3d94&location="
#define CALL_NUM    "13800138000"
/* 响应缓冲区大小 */
#define RSP_BUF_SIZE 4096

/* 自定义 atof（若平台未提供标准库函数） */
static double my_atof(const char *s)
{
    if (!s || *s == '\0')
        return 0.0;

    double val = 0.0;
    int sign = 1;
    if (*s == '-')
    {
        sign = -1;
        s++;
    }
    while (*s >= '0' && *s <= '9')
        val = val * 10.0 + (*s++ - '0');
    if (*s == '.')
    {
        s++;
        double frac = 0.1;
        while (*s >= '0' && *s <= '9')
        {
            val += (*s++ - '0') * frac;
            frac *= 0.1;
        }
    }
    return sign * val;
}

/**
 * @brief 构建带经纬度的完整请求 URL
 */
static int build_url_with_coords(double lon, double lat, char *url_buf, size_t buf_size)
{
    if (!url_buf || buf_size == 0)
        return -1;

    int needed = snprintf(NULL, 0, "%s%f,%f", AMAP_BASE_URL, lon, lat);
    if (needed < 0 || (size_t)needed >= buf_size)
    {
        log_e("URL buffer too small (need %d, have %zu)", needed + 1, buf_size);
        return -1;
    }

    snprintf(url_buf, buf_size, "%s%f,%f", AMAP_BASE_URL, lon, lat);
    return 0;
}

/**
 * @brief 解析高德地图逆地理编码 JSON 响应
 */
static int parse_amap_response(const char *json, char *address, size_t addr_size,
                               double *out_lon, double *out_lat)
{
    cJSON *root = cJSON_Parse(json);
    if (!root)
    {
        const char *err_ptr = cJSON_GetErrorPtr();
        if (err_ptr)
            log_e("cJSON_Parse error\n");
        // log_e("JSON parse error at: %s\n", err_ptr);

        return -1;
    }
    /* 检查状态 */
    cJSON *status = cJSON_GetObjectItem(root, "status");
    if (!status || !cJSON_IsString(status) || strcmp(status->valuestring, "1") != 0)
    {
        log_e("Invalid status: %s", status ? status->valuestring : "null");
        cJSON_Delete(root);
        return -1;
    }

    /* 获取 regeocode 对象 */
    cJSON *regeocode = cJSON_GetObjectItem(root, "regeocode");
    if (!regeocode)
    {
        log_e("Missing 'regeocode' field");
        cJSON_Delete(root);
        return -1;
    }

    /* 提取 formatted_address */
    cJSON *formatted = cJSON_GetObjectItem(regeocode, "formatted_address");
    if (!formatted || !cJSON_IsString(formatted))
    {
        log_e("Missing 'formatted_address' or not string");
        cJSON_Delete(root);
        return -1;
    }
    const char *addr_str = formatted->valuestring;
    size_t addr_len = strlen(addr_str);
    if (addr_len >= addr_size)
    {
        log_e("Address too long (need %zu, have %zu)", addr_len + 1, addr_size);
        cJSON_Delete(root);
        return -1;
    }
    size_t copy_len = (addr_len < addr_size - 1) ? addr_len : (addr_size - 1);
    memcpy(address, addr_str, copy_len);
    address[copy_len] = '\0';

    /* 提取经纬度（可选，从 addressComponent.streetNumber.location 获取） */
    if (out_lon && out_lat)
    {
        cJSON *addr_comp = cJSON_GetObjectItem(regeocode, "addressComponent");
        if (addr_comp)
        {
            cJSON *street_num = cJSON_GetObjectItem(addr_comp, "streetNumber");
            if (street_num)
            {
                cJSON *loc = cJSON_GetObjectItem(street_num, "location");
                if (loc && cJSON_IsString(loc))
                {
                    char *saveptr = NULL;
                    char *token = strtok_r(loc->valuestring, ",", &saveptr);
                    if (token)
                    {
                        *out_lon = my_atof(token);
                        token = strtok_r(NULL, ",", &saveptr);
                        if (token)
                            *out_lat = my_atof(token);
                    }
                }
            }
        }
    }

    cJSON_Delete(root);
    return 0;
}

/**
 * @brief 查询指定经纬度的地理位置信息
 */
int query_geocode(double lon, double lat, char *address, size_t addr_size,
                  double *out_lon, double *out_lat)
{
    if (!address || addr_size == 0)
    {
        log_e("Invalid address buffer");
        return -1;
    }

    if (lon < -180.0 || lon > 180.0 || lat < -90.0 || lat > 90.0)
    {
        log_e("Invalid coordinates: lon=%f, lat=%f", lon, lat);
        return -1;
    }

    /* 构建 URL */
    char url[512];
    if (build_url_with_coords(lon, lat, url, sizeof(url)) != 0)
    {
        return -1;
    }
    log_d("Request URL: %s\n", url);

    /* 分配响应缓冲区 */
    char *rsp_buf = (char *)osal_malloc(RSP_BUF_SIZE);
    if (!rsp_buf)
    {
        log_e("Failed to allocate response buffer");
        return -1;
    }

    /* 执行 HTTPS GET 请求 */
    int ret = https_get(url, rsp_buf, RSP_BUF_SIZE);
    if (ret != 0)
    {
        log_e("HTTPS GET failed");
        osal_free(rsp_buf);
        return -1;
    }

    /* 解析 JSON 并提取信息 */
    ret = parse_amap_response(rsp_buf, address, addr_size, out_lon, out_lat);
    osal_free(rsp_buf);
    return ret;
}
osal_semaphore_t at_sem = NULL;
void at_sem_relase(void)
{
    osal_sem_release(at_sem);
}
/**
 * @brief AT 命令处理任务（示例）
 */
void at_task(void *param)
{
    (void)param;

    /* 初始化 cJSON 内存适配 */
    cJSON_Porting_Init();

    /* 初始化网络模块 */
    if (at_module_config() != 0)
    {
        log_e("Module config failed");
        return;
    }

    char address[256];
    double lon = 0, lat = 0;
    double out_lon = 0.0, out_lat = 0.0;
 

    while (1)
    {
        osal_sem_take(at_sem, -1);

        if (at_get_location(&lon, &lat) == 0 && 
            query_geocode(lon, lat, address, sizeof(address), &out_lon, &out_lat) == 0)
        {
            /* 构造短信内容：地址 + 经纬度 */
            char sms_content[512];
            int len = snprintf(sms_content, sizeof(sms_content),
                               "%s(%.2f,%.2f)",address,out_lon,out_lat);
            log_e("%s",sms_content);
            if (len < 0 || (size_t)len >= sizeof(sms_content))
            {
                log_e("SMS content too long");
            }
            else
            {
                if (at_send_bemfa_alert(sms_content) != 0)
                {
                    log_e("Send SMS failed");
                }
                else
                {
                    log_i("SMS sent: %s", sms_content);
                }
            }
        }
        else
        {
            log_e("Failed to get location");
        }

        osal_task_delay(1000);
    }
}

/**
 * @brief 初始化 AT 命令处理任务
 */
void at_cmd_task_init(void)
{
    hal_uart2_init();
    osal_task_t task = osal_task_create("at_task", at_task, NULL, 1024 * 10, 10, 20);
    at_sem = osal_sem_create("at_sem", 0, 0);

    if (task == NULL || at_sem == NULL)
    {
        log_e("AT task creation failed");
        return;
    }
    log_i("AT command task initialized successfully");
    osal_task_startup(task);
}