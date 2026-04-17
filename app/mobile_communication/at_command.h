#ifndef     AT_COMMAND_H
#define     AT_COMMAND_H

/**< 定义at命令所需要的函数 */

int at_module_config(void);
int https_get(const char *url, char *response_buf, size_t buf_size);
int at_do_http_request(void);
int32_t at_get_location(double *lon , double *lat );
int32_t at_send_sms(char *message, char *call_num);
#endif