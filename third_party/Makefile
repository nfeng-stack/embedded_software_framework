# Third-party SDK Makefile (U-Boot style)
# Lists subdirectories to be built recursively

obj-y += stm32h5xx_hal_driver/
obj-y += CMSIS/


# RT-Thread OS (only built when OSAL_RTOS=rtthread)
ifeq ($(OSAL_RTOS),rtthread)
obj-y += rt-thread/
endif

obj-y += tinyusb/
# Include local configuration if exists
-include local.mk