# RT-Thread OS Makefile
# Build RT-Thread kernel

obj-y += src/
obj-y += libcpu/arm/cortex-m33/

# RT-Thread specific flags
EXTRA_CFLAGS += -DRT_THREAD

# Include local configuration if exists
-include local.mk