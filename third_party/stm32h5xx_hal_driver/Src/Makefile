# STM32H5xx HAL Driver Source Makefile
# 自动获取本目录下所有 .c 和 .s 文件（注意：这里用的是文件名，不是路径）
CFILES   := $(notdir $(wildcard $(src)/*.c))
ASFILES  := $(notdir $(wildcard $(src)/*.s))

# 转为 .o 文件名（其实 already are base names）
OBJ_FILES := $(CFILES:.c=.o) $(ASFILES:.s=.o)

# 加入 obj-y（Makefile.build 会处理这些）
obj-y += $(OBJ_FILES)

# HAL driver specific flags
EXTRA_CFLAGS += -DUSE_HAL_DRIVER
EXTRA_CFLAGS += -DSTM32H563xx
EXTRA_CFLAGS += -Ithird_party/stm32h5xx_hal_driver/Inc
EXTRA_CFLAGS += -Ithird_party/stm32h5xx_hal_driver/Inc/Legacy
# Include local configuration if exists
-include local.mk