#===============================================================================
# Embedded Framework Build Configuration
#===============================================================================

# Platform selection (from platform_select.h)
HAL_PLATFORM = stm32h5
OSAL_RTOS = rtthread

# Framework port selection
ifeq ($(OSAL_RTOS),rtthread)
    FRAMEWORK_PORT = rtthread
else
    FRAMEWORK_PORT = generic
endif

# Toolchain
PREFIX = arm-none-eabi-
CC = $(PREFIX)gcc
CXX = $(PREFIX)g++
AS = $(PREFIX)gcc -x assembler-with-cpp
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy
OBJDUMP = $(PREFIX)objdump
SIZE = $(PREFIX)size
GDB = $(PREFIX)gdb

# Microcontroller
MCU = -mcpu=cortex-m33 -mthumb -mfpu=fpv5-sp-d16 -mfloat-abi=hard

# Optimization
OPT = -Og

# Debug flags
DEBUG = 1
ifeq ($(DEBUG),1)
	CFLAGS += -g -gdwarf-2
endif

# C defines
C_DEFS = \
	-DUSE_HAL_DRIVER \
	-DSTM32H563xx \
	-DHAL_PLATFORM_STM32H5=1

# C includes (basic - will be extended in main Makefile)
C_INCLUDES = -Iframework/log/inc\
	-Iinclude \


# ASM defines
AS_DEFS =

# ASM includes
AS_INCLUDES =

# Linker script selection
ifeq ($(OSAL_RTOS),rtthread)
    LDSCRIPT = framework/linker/rtthread/rtthread.ld
else
    # Use bare metal linker script
    LDSCRIPT = framework/linker/bare/bare.ld
endif

# Startup file selection (unified C startup for all configurations)
STARTUP_FILE = framework/startup/c/startup.c

# Libraries - Full Newlib C library (not nano version)
LIBS = -lc -lm -lnosys -lgcc
LIBDIR =

# Flash command (platform-specific)
FLASH_CMD = st-flash write $(BIN_FILE) 0x08000000

# Warnings
CFLAGS += \
	-Wall \
	-Wextra \
	-Wpointer-arith \
	-Wstrict-prototypes \
	-Wmissing-prototypes \
	-Wmissing-declarations \
	-Wunused \
	-Wuninitialized \
	-Werror=return-type \
	-MMD -MP

# C standards
CFLAGS += \
	-std=c11 \
	-fmessage-length=0 \
	-ffunction-sections \
	-fdata-sections

# C++ standards (if needed)
CXXFLAGS += \
	-std=c++11 \
	-fmessage-length=0 \
	-ffunction-sections \
	-fdata-sections \
	-fno-exceptions \
	-fno-rtti

# Linker flags - Full C library with floating-point support
LDFLAGS += \
	-specs=nosys.specs \
	-Wl,--gc-sections \
	-Wl,--print-memory-usage \
	-Wl,-Map=$(BUILD_DIR)/$(PROJECT_NAME).map \
	-Wl,-u,_printf_float \
	-Wl,-u,_scanf_float \
	-Wl,--no-warn-rwx-segments

#===============================================================================
# Platform-Specific Configuration
#===============================================================================

ifeq ($(HAL_PLATFORM),stm32h5)
	# STM32H5 specific flags
	C_DEFS += -DSTM32H5
	C_INCLUDES += -Ithird_party/stm32h5xx_hal_driver/Inc \
		-Ithird_party/CMSIS/Core/Include \
		-Ithird_party/CMSIS/Device/ST/STM32H5xx/Include \
		-Iinclude
endif

ifeq ($(OSAL_RTOS),rtthread)
    # RT-Thread specific flags
    C_DEFS += -DRT_THREAD -DOSAL_RTOS_RTTHREAD=1
    C_INCLUDES += -Ithird_party/rt-thread/include
endif
C_INCLUDES += -Imiddleware/osal/rtthread
C_INCLUDES += -Imiddleware/osal/common/xx_osExtension
C_INCLUDES += -Imiddleware/osal/common

#===============================================================================
# Export variables
#===============================================================================

export CC CXX AS LD OBJCOPY OBJDUMP SIZE GDB
export MCU OPT DEBUG CFLAGS CXXFLAGS ASFLAGS LDFLAGS
export C_DEFS C_INCLUDES AS_DEFS AS_INCLUDES
export LDSCRIPT LIBS LIBDIR STARTUP_FILE
export HAL_PLATFORM OSAL_RTOS FRAMEWORK_PORT
