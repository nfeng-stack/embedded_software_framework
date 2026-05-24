# 附录：系统核心源代码

## A.1 系统初始化与任务创建

### main() — 系统入口

```c
// file: app/your_app.c

int main(void) {
  osal_task_delay(100);
  log_strategy();

  at_cmd_task_init();    /* 4G AT 通信线程 */
  ai_task_init();        /* AI 推理线程 */
  fatfs_init();          /* FATFS 文件系统挂载 */
  mpu6050_init_task();   /* MPU6050 传感器线程 */
  usb_protocol_init();   /* USB CDC+MSC 协议栈 */

  while (1) {
    osal_task_delay(10000);
  }
}
```

### MPU6050 初始化

```c
// file: app/mpu6050/mpu6050_wrap.c

#define MPU6050_FREE_THRESHOLD_MG  700.0f
#define MPU6050_FREE_DURATION      1

void mpu6050_init_task(void)
{
    uint8_t res;
    mpu6050_address_t address = MPU6050_ADDRESS_AD0_LOW;

    res = mpu6050_basic_init(address);
    framework_interrupts_register_handler(41, exit_callback);
    if (res != 0) return;

    if (mpu6050_basic_get_handle(&mpu_handle) != 0 || mpu_handle == NULL)
        return;

    mpu6050_set_interrupt_read_clear(mpu_handle, MPU6050_BOOL_TRUE);

    float threshold_mg = MPU6050_FREE_THRESHOLD_MG;
    uint8_t reg;
    res = mpu6050_free_threshold_convert_to_register(mpu_handle, threshold_mg, &reg);
    if (res == 0) {
        res = mpu6050_set_free_threshold(mpu_handle, reg);
        if (res != 0) return;
    }

    res = mpu6050_set_free_duration(mpu_handle, MPU6050_FREE_DURATION);
    if (res != 0) return;

    hal_gpio_init_int();

    mpu_task_t = osal_task_create("mputhread", mpu6050_task, NULL, 10240, 10, 20);
    mpu_sem = osal_sem_create("mpu_sem", 0, 0);
    if (mpu_task_t == NULL || mpu_sem == NULL) return;
    osal_task_startup(mpu_task_t);

    mpu6050_data_logger_init();
}
```

### AI 推理任务初始化

```c
// file: app/aiNet/src/ai_task.c

void ai_task_init(void)
{
    MX_X_CUBE_AI_Init();
    ai_task_t = osal_task_create("aitask", ai_task, NULL, 2048, 10, 20);
    ai_sem = osal_sem_create("ai_sem", 0, 0);
    if (ai_task_t == NULL || ai_sem == NULL) return;
    osal_task_startup(ai_task_t);
}
```

### AT 通信任务初始化

```c
// file: app/mobile_communication/at_task.c

void at_cmd_task_init(void)
{
    hal_uart2_init();
    osal_task_t task = osal_task_create("at_task", at_task, NULL, 10240, 10, 20);
    at_sem = osal_sem_create("at_sem", 0, 0);
    if (task == NULL || at_sem == NULL) return;
    osal_task_startup(task);
}
```

---

## A.2 自由落体检测与数据采集

### 中断回调 — 唤醒采集线程

```c
// file: app/mpu6050/mpu6050_wrap.c

void exit_callback(void)
{
    osal_sem_release(mpu_sem);
    hal_clean_it();
}
```

### 量化归一化算法

```c
// file: app/mpu6050/mpu6050_wrap.c

void quantize_data(float raw_data[200][6], float quantized_data[200][6], int num_data)
{
    const float acc_scale = 255.0f / 32.0f;
    const float gry_scale = 255.0f / 4000.0f;

    for (int i = 0; i < num_data; i++) {
        for (int j = 0; j < 3; j++) {
            float value = raw_data[i][j];
            if (value < -16.0f)   value = -16.0f;
            else if (value > 16.0f) value = 16.0f;
            quantized_data[i][j] = (value + 16.0f) * acc_scale;
        }
        for (int j = 3; j < 6; j++) {
            float value = raw_data[i][j];
            if (value < -2000.0f)   value = -2000.0f;
            else if (value > 2000.0f) value = 2000.0f;
            quantized_data[i][j] = (value + 2000.0f) * gry_scale;
        }
    }
}
```

### MPU6050 采集任务主循环

```c
// file: app/mpu6050/mpu6050_wrap.c

void mpu6050_task(void *param)
{
    static uint8_t i = 0;
    uint8_t reg = 0;
    uint8_t res = 0;

    while (1) {
        osal_sem_take(mpu_sem, -1);

        res = mpu6050_get_interrupt_status(mpu_handle, &reg);
        if (res != 0) {
            mpu6050_set_interrupt(mpu_handle,
                MPU6050_INTERRUPT_FREE | MPU6050_INTERRUPT_DATA_READY,
                MPU6050_BOOL_FALSE);
            return;
        }
        res = mpu6050_basic_read(raw_data[i], raw_data[i] + 3);
        i++;
        if (res != 0) {
            mpu6050_set_interrupt(mpu_handle,
                MPU6050_INTERRUPT_FREE | MPU6050_INTERRUPT_DATA_READY,
                MPU6050_BOOL_FALSE);
            return;
        }

        if (reg >> MPU6050_INTERRUPT_FREE && 0x01) {
            /* 仅自由落体中断：切换到数据就绪采集模式 */
            mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE,
                                  MPU6050_BOOL_FALSE);
            mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_DATA_READY,
                                  MPU6050_BOOL_TRUE);
        } else {
            /* 数据就绪中断：累积采样 */
            if (i == 200) {
                mpu6050_set_interrupt(mpu_handle,
                    MPU6050_INTERRUPT_DATA_READY | MPU6050_INTERRUPT_DATA_READY,
                    MPU6050_BOOL_FALSE);

                /* 原始数据持久化至 Flash */
                mpu6050_data_logger_write_batch(raw_data, 200);

                i = 0;
                /* 量化为 AI 模型输入格式 */
                quantize_data(raw_data, net_data, 200);
                /* 唤醒 AI 推理线程 */
                ai_sem_relase();

                osal_task_delay(100);
                /* 恢复自由落体监测 */
                mpu6050_set_interrupt(mpu_handle, MPU6050_INTERRUPT_FREE,
                                      MPU6050_BOOL_TRUE);
            }
        }
    }
}
```

### 用户按键取消中断

```c
// file: middleware/hal/stm32h5/platform_gpio_driver.c

extern uint8_t is_send_msg;

void EXTI3_IRQHandler(void)
{
    platform_gpio_set_low_spec();   /* 关闭声光报警 */
    is_send_msg = 0;                /* 置位取消标志 */
    while (HAL_GPIO_ReadPin(GPIOB, GPIO_PIN_3) != GPIO_PIN_SET);
    __HAL_GPIO_EXTI_CLEAR_FLAG(GPIO_PIN_3);
    HAL_NVIC_ClearPendingIRQ(EXTI3_IRQn);
}
```

---

## A.3 AI 推理判决

### 推理任务循环 — 跌倒判决与报警触发

```c
// file: app/aiNet/src/ai_task.c

void ai_sem_relase(void)
{
    osal_sem_release(ai_sem);
}

void ai_task(void *param)
{
    while (1) {
        osal_sem_take(ai_sem, -1);

        uint8_t is_fall = MX_X_CUBE_AI_Process();
        if (is_fall == 1) {
            is_send_msg = 1;
            hal_gpio_led_audio_on();
            at_sem_relase();
        }
    }
}
```

### FD-CNN 输入数据格式转换

```c
// file: app/aiNet/src/app_x-cube-ai.c

float net_data[200][6];

int acquire_and_process_data(ai_i8* data[])
{
    float* input_buf = (float*)data[0];

    /* 前 600 个：加速度值按时间顺序平铺 */
    for (int t = 0; t < 200; t++) {
        input_buf[t * 3 + 0] = net_data[t][0];  /* acc_x */
        input_buf[t * 3 + 1] = net_data[t][1];  /* acc_y */
        input_buf[t * 3 + 2] = net_data[t][2];  /* acc_z */
    }
    /* 后 600 个：陀螺仪值按时间顺序平铺 */
    for (int t = 0; t < 200; t++) {
        input_buf[600 + t * 3 + 0] = net_data[t][3];  /* gyro_x */
        input_buf[600 + t * 3 + 1] = net_data[t][4];  /* gyro_y */
        input_buf[600 + t * 3 + 2] = net_data[t][5];  /* gyro_z */
    }
    return 0;
}
```

### Softmax 后处理与阈值判决

```c
// file: app/aiNet/src/app_x-cube-ai.c

int post_process(ai_i8* data[], uint8_t *is_fall)
{
    float *logits = (float*)data[0];

    /* 数值稳定 Softmax */
    float max_val = (logits[0] > logits[1]) ? logits[0] : logits[1];
    float exp0 = expf(logits[0] - max_val);
    float exp1 = expf(logits[1] - max_val);
    float sum = exp0 + exp1;
    float prob_fall = exp0 / sum;
    float prob_no_fall = exp1 / sum;

    if (prob_fall > 0.5f) {
        *is_fall = 1;
    } else {
        *is_fall = 0;
    }
    return 0;
}
```

### AI 推理编排函数

```c
// file: app/aiNet/src/app_x-cube-ai.c

uint8_t MX_X_CUBE_AI_Process(void)
{
    int res = -1;
    uint8_t is_fall = 0;

    if (network) {
        do {
            res = acquire_and_process_data(data_ins);
            if (res == 0)
                res = ai_run();
            if (res == 0)
                res = post_process(data_outs, &is_fall);
        } while (res != 0);
    }
    return is_fall;
}
```

---

## A.4 定位与微信推送

### AT 通信任务主循环

```c
// file: app/mobile_communication/at_task.c

uint8_t is_send_msg = 1;

void at_task(void *param)
{
    (void)param;
    cJSON_Porting_Init();

    if (at_module_config() != 0) return;

    char address[256];
    double lon = 0, lat = 0;
    double out_lon = 0.0, out_lat = 0.0;

    while (1) {
        osal_sem_take(at_sem, -1);

        /* 30 秒误报取消窗口 */
        osal_task_delay(30000);

        if (is_send_msg != 1) {
            /* 用户已取消 */
            is_send_msg = 1;
            hal_gpio_led_audio_off();
        } else {
            /* 超时未取消，进入定位-推送流程 */
            if (at_get_location(&lon, &lat) == 0 &&
                query_geocode(lon, lat, address, sizeof(address),
                              &out_lon, &out_lat) == 0) {
                char sms_content[512];
                int len = snprintf(sms_content, sizeof(sms_content),
                                   "%s(%.2f,%.2f)", address, out_lon, out_lat);
                if (len > 0 && (size_t)len < sizeof(sms_content)) {
                    at_send_bemfa_alert(sms_content);
                }
            }
        }
        osal_task_delay(1000);
    }
}
```

### 高德逆地理编码 JSON 解析

```c
// file: app/mobile_communication/at_task.c

static int parse_amap_response(const char *json, char *address, size_t addr_size,
                                double *out_lon, double *out_lat)
{
    cJSON *root = cJSON_Parse(json);
    if (!root) return -1;

    cJSON *status = cJSON_GetObjectItem(root, "status");
    if (!status || !cJSON_IsString(status) ||
        strcmp(status->valuestring, "1") != 0) {
        cJSON_Delete(root);
        return -1;
    }

    cJSON *regeocode = cJSON_GetObjectItem(root, "regeocode");
    if (!regeocode) { cJSON_Delete(root); return -1; }

    cJSON *formatted = cJSON_GetObjectItem(regeocode, "formatted_address");
    if (!formatted || !cJSON_IsString(formatted)) {
        cJSON_Delete(root); return -1;
    }
    const char *addr_str = formatted->valuestring;
    size_t copy_len = strlen(addr_str) < addr_size - 1
                      ? strlen(addr_str) : (addr_size - 1);
    memcpy(address, addr_str, copy_len);
    address[copy_len] = '\0';

    /* 提取街道级精确坐标（可选） */
    if (out_lon && out_lat) {
        cJSON *addr_comp = cJSON_GetObjectItem(regeocode, "addressComponent");
        if (addr_comp) {
            cJSON *street = cJSON_GetObjectItem(addr_comp, "streetNumber");
            if (street) {
                cJSON *loc = cJSON_GetObjectItem(street, "location");
                if (loc && cJSON_IsString(loc)) {
                    char *saveptr = NULL;
                    char *token = strtok_r(loc->valuestring, ",", &saveptr);
                    if (token) {
                        *out_lon = my_atof(token);
                        token = strtok_r(NULL, ",", &saveptr);
                        if (token) *out_lat = my_atof(token);
                    }
                }
            }
        }
    }

    cJSON_Delete(root);
    return 0;
}
```

### 逆地理编码查询流程

```c
// file: app/mobile_communication/at_task.c

int query_geocode(double lon, double lat, char *address, size_t addr_size,
                   double *out_lon, double *out_lat)
{
    if (!address || addr_size == 0) return -1;
    if (lon < -180.0 || lon > 180.0 || lat < -90.0 || lat > 90.0)
        return -1;

    char url[512];
    if (build_url_with_coords(lon, lat, url, sizeof(url)) != 0)
        return -1;

    char *rsp_buf = (char *)osal_malloc(4096);
    if (!rsp_buf) return -1;

    int ret = https_get(url, rsp_buf, 4096);
    if (ret != 0) { osal_free(rsp_buf); return -1; }

    ret = parse_amap_response(rsp_buf, address, addr_size, out_lon, out_lat);
    osal_free(rsp_buf);
    return ret;
}
```

### NMEA 坐标格式转换

```c
// file: app/mobile_communication/at_command.c

static int nmea_to_decimal(const char *nmea_val, double *degrees)
{
    if (nmea_val == NULL || degrees == NULL) return -1;

    int len = my_strlen(nmea_val);
    if (len < 4) return -1;

    char *dot_pos = my_strchr(nmea_val, '.');
    if (dot_pos == NULL) return -1;

    char *min_start = dot_pos - 2;
    if (min_start < nmea_val) return -1;

    char degree_str[10] = {0};
    int degree_len = min_start - nmea_val;
    if (degree_len >= (int)sizeof(degree_str)) return -1;
    for (int i = 0; i < degree_len; i++)
        degree_str[i] = nmea_val[i];
    int degree = my_atoi(degree_str);

    double minute = my_atof(min_start);

    *degrees = (double)degree + (minute / 60.0);
    return 0;
}
```

### GPS 定位获取

```c
// file: app/mobile_communication/at_command.c

int32_t at_get_location(double *lon, double *lat)
{
    char *rx_buffer = (char *)osal_malloc(AT_BUFFER_SIZE);
    if (rx_buffer == NULL) return -1;

    hal_uart2_write((uint8_t *)"AT+QGPSGNMEA=\"RMC\"\r\n");
    int ret = at_rsp_wait(NULL, rx_buffer, AT_BUFFER_SIZE, AT_CMD_TIMEOUT);
    if (ret != 0) { osal_free(rx_buffer); return -1; }

    *lon = 0.0;
    *lat = 0.0;

    char *rmc_start = my_strstr(rx_buffer, "$GNRMC");
    if (rmc_start == NULL) rmc_start = my_strstr(rx_buffer, "$GPRMC");
    if (rmc_start == NULL) { osal_free(rx_buffer); return -1; }

    /* 按逗号分割 NMEA 语句 */
    char lat_str[20] = {0}, lon_str[20] = {0};
    char lat_dir = 'N', lon_dir = 'E', status = 'V';
    char *token, *saveptr;
    int field_idx = 0;

    token = my_strtok_r(rmc_start, ",", &saveptr);
    while (token != NULL) {
        char *newline = my_strchr(token, '\r');
        if (newline) *newline = 0;
        newline = my_strchr(token, '\n');
        if (newline) *newline = 0;

        switch (field_idx) {
            case 2: status = token[0]; break;
            case 3:
                for (int i = 0; i < 19 && token[i] != '\0'; i++)
                    lat_str[i] = token[i];
                break;
            case 4: lat_dir = token[0]; break;
            case 5:
                for (int i = 0; i < 19 && token[i] != '\0'; i++)
                    lon_str[i] = token[i];
                break;
            case 6: lon_dir = token[0]; break;
            default: break;
        }
        field_idx++;
        token = my_strtok_r(NULL, ",", &saveptr);
    }
    osal_free(rx_buffer);

    if (status != 'A') return -1;   /* GPS 未定位 */

    if (nmea_to_decimal(lat_str, lat) != 0) return -1;
    if (nmea_to_decimal(lon_str, lon) != 0) return -1;

    if (lat_dir == 'S') *lat = -*lat;
    if (lon_dir == 'W') *lon = -*lon;

    return 0;
}
```

### 巴法云微信推送

```c
// file: app/mobile_communication/at_command.c

int at_send_bemfa_alert(const char *message)
{
    if (!message || strlen(message) == 0) return -1;

    size_t msg_len = strlen(message);
    if (msg_len > 200) return -1;

    char buffer[AT_BUFFER_SIZE];
    int ret;

    /* SSL/TLS 配置 */
    if (at_send_and_check_ok("AT+QSSLCFG=\"sslversion\",1,3\r\n") != 0 ||
        at_send_and_check_ok("AT+QSSLCFG=\"ciphersuite\",1,0xFFFF\r\n") != 0 ||
        at_send_and_check_ok("AT+QSSLCFG=\"seclevel\",1,0\r\n") != 0)
        return -1;

    /* HTTP 配置 */
    if (at_send_and_check_ok("AT+QHTTPCFG=\"contextid\",1\r\n") != 0 ||
        at_send_and_check_ok("AT+QHTTPCFG=\"sslctxid\",1\r\n") != 0 ||
        at_send_and_check_ok("AT+QHTTPCFG=\"requestheader\",1\r\n") != 0 ||
        at_send_and_check_ok("AT+QHTTPCFG=\"responseheader\",1\r\n") != 0)
        return -1;

    /* 构造巴法云 API URL */
    char url[1024];
    int url_len = snprintf(url, sizeof(url),
        BEMFA_BASE_URL "?uid=" BEMFA_UID "&device=" BEMFA_DEVICE "&message=%s",
        message);
    if (url_len < 0 || url_len >= (int)sizeof(url)) return -1;

    /* 发送 URL */
    char cmd[64];
    snprintf(cmd, sizeof(cmd), "AT+QHTTPURL=%d,30000\r\n", url_len);
    ret = at_send_and_wait_for(cmd, "CONNECT", buffer, sizeof(buffer),
                               AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK) return -1;
    hal_uart2_write(url);
    hal_uart2_write("\r\n");
    ret = at_rsp_wait(NULL, buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "OK") == NULL) return -1;

    /* 构造 HTTP GET 请求头 */
    char http_request[1152];
    int head_len = snprintf(http_request, sizeof(http_request),
        "GET /vb/wechat/v1/wechatAlert?uid=" BEMFA_UID
        "&device=" BEMFA_DEVICE "&message=%s HTTP/1.1\r\n"
        "Host: apis.bemfa.com\r\n\r\n", message);
    if (head_len < 0 || head_len >= (int)sizeof(http_request)) return -1;

    /* 发起 GET 请求 */
    snprintf(cmd, sizeof(cmd), "AT+QHTTPGET=80,%d\r\n", head_len);
    ret = at_send_and_wait_for(cmd, "CONNECT", buffer, sizeof(buffer),
                               AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK) return -1;
    hal_uart2_write(http_request);
    ret = at_rsp_wait(NULL, buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK || strstr(buffer, "OK") == NULL) return -1;

    /* 等待 HTTP 响应 */
    ret = at_rsp_wait("+QHTTPGET:", buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK) return -1;
    if (strstr(buffer, "+QHTTPGET: 0,200,") == NULL) return -1;

    /* 读取并校验响应 */
    hal_uart2_write("AT+QHTTPREAD=80\r\n");
    ret = at_rsp_wait("+QHTTPREAD: 0", buffer, sizeof(buffer), AT_HTTP_TIMEOUT);
    if (ret != AT_RSP_OK) return -1;
    if (strstr(buffer, "\"code\":0") == NULL) return -1;

    return 0;
}
```
