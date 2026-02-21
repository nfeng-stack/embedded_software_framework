# Third-party SDK Makefile (U-Boot style)
# Lists subdirectories to be built recursively

obj-y += stm32h5xx_hal_driver/
obj-y += CMSIS/
# Startup file (selected by config.mk)
# startup.c is built by framework, not third_party
# obj-y += ../$(STARTUP_FILE:.c=.o)
# Instead, add startup.c as a source file to be compiled
obj-y += ../framework/startup/c/startup.o

# RT-Thread OS (only built when OSAL_RTOS=rtthread)
ifeq ($(OSAL_RTOS),rtthread)
obj-y += rt-thread/
endif

# Include local configuration if exists
-include local.mk