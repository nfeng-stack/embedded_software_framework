#===============================================================================
# Embedded Framework Makefile (U-Boot style recursive build)
#===============================================================================

# Project name
PROJECT_NAME = embedded_framework

# Default target
.DEFAULT_GOAL := all

# Include global configuration
include config.mk

#===============================================================================
# Build Configuration
#===============================================================================

# Build directory
BUILD_DIR = build

# Output files
ELF_FILE = $(BUILD_DIR)/$(PROJECT_NAME).elf
BIN_FILE = $(BUILD_DIR)/$(PROJECT_NAME).bin
HEX_FILE = $(BUILD_DIR)/$(PROJECT_NAME).hex
MAP_FILE = $(BUILD_DIR)/$(PROJECT_NAME).map

#===============================================================================
# Recursive Build Configuration
#===============================================================================

# Top-level directories to recurse into
libs-y += third_party
libs-y += hal
libs-y += osal
libs-y += framework
libs-y += app

# Filter out non-existent directories
libs-y := $(foreach dir,$(libs-y),$(wildcard $(dir)))
libs-y := $(filter-out $(BUILD_DIR),$(libs-y))

# Object tree and source tree
objtree := $(BUILD_DIR)
srctree := .
export objtree srctree

# Built-in objects in build directory
builtin-objs := $(addprefix $(objtree)/,$(addsuffix /built-in.o,$(libs-y)))

# Build command
build := -f $(srctree)/scripts/Makefile.build obj

# Verbosity control
ifeq ("$(origin V)", "command line")
  KBUILD_VERBOSE = $(V)
endif
ifndef KBUILD_VERBOSE
  KBUILD_VERBOSE = 0
endif

ifeq ($(KBUILD_VERBOSE),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

export quiet Q KBUILD_VERBOSE build

#===============================================================================
# Compilation Flags
#===============================================================================

# C flags (append to config.mk CFLAGS)
CFLAGS += $(MCU) $(C_DEFS) $(C_INCLUDES) $(OPT)

# Linker flags
LDFLAGS += $(MCU) -T$(LDSCRIPT) -Wl,-Map=$(MAP_FILE) -Wl,--gc-sections $(LIBDIR) $(LIBS)

# Export toolchain and flags
export CC CXX AS LD OBJCOPY OBJDUMP SIZE GDB
export CFLAGS LDFLAGS

# Include Makefile.lib for c_flags
include scripts/Makefile.lib

#===============================================================================
# Build Targets
#===============================================================================

# Default target: build all
all: $(BIN_FILE) $(HEX_FILE)

# Binary file
$(BIN_FILE): $(ELF_FILE)
	$(OBJCOPY) -O binary $< $@

# Hex file
$(HEX_FILE): $(ELF_FILE)
	$(OBJCOPY) -O ihex $< $@

# ELF file
$(ELF_FILE): $(builtin-objs)
	@echo "Linking $@"
	@mkdir -p $(dir $@)
	$(CC) $(builtin-objs) $(LDFLAGS) -o $@
	$(SIZE) $@

# Rule to build built-in.o in each directory
$(objtree)/%/built-in.o: FORCE
	$(Q)$(MAKE) $(build)=$* obj=$*

#===============================================================================
# Utility Targets
#===============================================================================

# Clean build directory
clean:
	rm -rf $(BUILD_DIR)

# Flash target (platform-specific)
flash: $(BIN_FILE)
	@echo "Flashing $(BIN_FILE) to target..."
	$(FLASH_CMD)

# Debug target
debug: $(ELF_FILE)
	$(GDB) $(ELF_FILE)

# Size information
size: $(ELF_FILE)
	$(SIZE) $(ELF_FILE)

# Print build information
info:
	@echo "========================================="
	@echo "Build Configuration:"
	@echo "  Project:      $(PROJECT_NAME)"
	@echo "  Platform:     $(HAL_PLATFORM)"
  @echo "  RTOS:         $(OSAL_RTOS)"
  @echo "  MCU:          $(MCU)"
  @echo "  Optimize:     $(OPT)"
  @echo "  Build Dir:    $(BUILD_DIR)"
  @echo "  Directories:  $(libs-y)"
  @echo "  Linker Script: $(LDSCRIPT)"
  @echo "  Startup File:  $(STARTUP_FILE)"
	@echo "========================================="

# Help target
help:
	@echo "Embedded Framework Build System (U-Boot style)"
	@echo ""
	@echo "Usage:"
	@echo "  make [V=1]         Build all targets (verbose)"
	@echo "  make clean         Remove build directory"
	@echo "  make flash         Flash binary to target"
	@echo "  make debug         Start debugger"
	@echo "  make size          Show size information"
	@echo "  make info          Show build configuration"
	@echo "  make help          Show this help"
	@echo ""
	@echo "Options:"
	@echo "  V=1                Enable verbose output"
	@echo ""

.PHONY: FORCE all clean flash debug size info help

FORCE:

