# OSAL layer Makefile
# Recursively build OSAL subdirectories

# Default RTOS if not defined
OSAL_RTOS ?= rtthread

obj-y += common/
obj-y += $(OSAL_RTOS)/

# OSAL-specific C flags (if any)
# EXTRA_CFLAGS += -DUSE_OSAL

# Include local configuration if exists
-include local.mk