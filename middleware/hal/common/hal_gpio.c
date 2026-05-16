#include "platform_driver.h"
void hal_gpio_init_int(void)
{
    platform_gpio_set_int();
}
void hal_clean_it(void)
{
    platform_gpio_clean_it();
}
void hal_gpio_led_audio_on(void)
{
    platform_gpio_set_hight_spec();
}
void hal_gpio_led_audio_off(void)
{
    platform_gpio_set_low_spec();
}