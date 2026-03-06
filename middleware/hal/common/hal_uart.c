#include "hal_common.h"
#include "platform_driver.h"
#include <string.h>
void hal_uart1_init(void)
{
    platform_uart1_init();
}
void hal_uart2_init(void)
{
    platform_uart2_init();
}
uint16_t hal_uart2_read(uint8_t *buffer, uint16_t max_len)
{
     return platform_uart2_read(buffer,max_len);
}

void hal_uart2_write(uint8_t *buffer)
{
    uint8_t len = strlen(buffer);
    platform_uart2_write(buffer,len);
}