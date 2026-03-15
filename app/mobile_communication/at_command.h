#ifndef     AT_COMMAND_H
#define     AT_COMMAND_H

/**< 定义at命令所需要的函数 */

int32_t at_check_sim_status_is_ready(void);
int32_t at_check_sms_status(void);
 int32_t at_check_net_status(void);
#endif