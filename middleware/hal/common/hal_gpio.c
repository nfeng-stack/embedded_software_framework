#include "platform_driver.h"
void hal_gpio_init_int(void)
{
    platform_gpio_set_int();
}
void hal_clean_it(void)
{
    platform_gpio_clean_it();
}
