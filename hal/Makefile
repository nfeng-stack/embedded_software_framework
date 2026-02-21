# HAL layer Makefile
# Recursively build HAL subdirectories

# Default platform if not defined
HAL_PLATFORM ?= stm32h5

obj-y += common/
obj-y += $(HAL_PLATFORM)/

# HAL-specific C flags (if any)
# EXTRA_CFLAGS += -DUSE_HAL

# Include local configuration if exists
-include local.mk