#include "hal_common.h"

#if defined(HAL_PLATFORM_STM32H5) && HAL_PLATFORM_STM32H5
#include "../stm32h5/platform_system_driver.h"
#else
#error "Unsupported platform"
#endif

void hal_system_clock_pre_init()
{
    platform_system_clock_pre_init();
}

void hal_system_clock_init()
{
    platform_system_clock_init();
}

void hal_system_sdk_init()
{
    platform_sdk_init();
}

void (*hal_system_get_systemhandler(void))(void)
{
    return platform_get_sytemtick_handler();
}