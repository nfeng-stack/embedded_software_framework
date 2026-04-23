#ifndef     AT_COMMAND_H
#define     AT_COMMAND_H

#include <stddef.h>
#include <stdint.h>

/**< 定义at命令所需要的函数 */

int at_module_config(void);
int https_get(const char *url, char *response_buf, size_t buf_size);
int at_do_http_request(void);
int32_t at_get_location(double *lon , double *lat );
int32_t at_send_sms(char *message, char *call_num);
int at_test_bemfa_alert(void);
int at_send_bemfa_alert(const char *message);

/* 巴法云报警配置 */
#define BEMFA_UID       "8982592ba3f24497969a3d3bb9f12e97"
#define BEMFA_DEVICE    "fallDetection"
#define BEMFA_BASE_URL  "https://apis.bemfa.com/vb/wechat/v1/wechatAlert"

#endif