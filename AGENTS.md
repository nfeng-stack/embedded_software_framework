# Agent Instructions for Embedded Framework

## Build System

- Uses U-Boot-style recursive Makefiles. Top-level `Makefile` includes `config.mk` for configuration.
- Default platform: `stm32h5` (STM32H5 series). Default RTOS: `rtthread`.
- Override via command line: `make HAL_PLATFORM=stm32f4 OSAL_RTOS=rtthread`.
- Linker script automatically selected based on `OSAL_RTOS`:
  - `OSAL_RTOS=rtthread` → `framework/linker/rtthread/rtthread.ld`
  - else → `framework/linker/bare/bare.ld`
- Key targets:
  - `make all` (default): builds ELF, BIN, HEX
  - `make clean`: removes `build/`
  - `make flash`: uses `st-flash` to write BIN to `0x08000000`
  - `make debug`: starts GDB with ELF
  - `make size`: shows size information
  - `make info`: prints current configuration
- Verbose output: `make V=1`

## Architecture

- Three-layer abstraction: Hardware Abstraction Layer (HAL), OS Abstraction Layer (OSAL), Application.
- Dual‑heap memory layout: C library heap (Newlib) separate from RT‑Thread heap. Stack protection with `0xDEADBEEF` pattern in `framework_init.c`.
- Startup flow: `startup.c` → `Reset_Handler` → `framework_start()` → HAL/OSAL init → RT‑Thread startup (`rtthread_startup()`) → `main()` in `app/your_app.c`.
- Application code includes only `hal.h` and `osal.h`; never uses hardware/RTOS APIs directly.

## Dependencies & Libraries

- ARM GCC toolchain (`arm-none-eabi-`). Full Newlib (not nano) with floating‑point support.
- External library `AI/Lib/NetworkRuntime1020_CM33_GCC.a` required for linking (included via `-l:NetworkRuntime1020_CM33_GCC.a -L AI/Lib`).
- Third‑party code in `third_party/`: STM32 HAL, CMSIS, RT‑Thread, tinyusb, etc.

## Configuration

- Primary config file: `config.mk`. Defines compiler flags, includes, platform‑specific macros.
- Platform‑specific includes are added automatically based on `HAL_PLATFORM`.
- RT‑Thread defines: `-DRT_THREAD -DOSAL_RTOS_RTTHREAD=1`.
- C standard: `-std=c11`. Warnings: strict, treat return‑type errors as errors.

## Development Workflow

- No linting or formatting tools configured.
- No automated tests or CI pipelines.
- Flashing alternatives: `download.sh` uses OpenOCD with CMSIS‑DAP.
- Debugging: `.vscode/` directory exists but empty; use `make debug` with arm‑none‑eabi‑gdb.
- Logging via EasyLogger (elog). Use `log_v()`, `log_i()` etc. Configuration in `framework/service/log_service/inc/elog_cfg.h`.

## Common Pitfalls

- Missing `AI/Lib/NetworkRuntime1020_CM33_GCC.a` will cause linker errors. Ensure the library is present.
- When changing `HAL_PLATFORM` or `OSAL_RTOS`, run `make clean` to avoid leftover objects.
- Stack protection pattern may be overwritten; check `_msp_stack_protection_start/end` symbols if debugging stack overflows.
- Include paths in `config.mk` may reference non‑existing directories (e.g., `framework/service/log_service/inc`). These are harmless if unused.

## Adding New Hardware/RTOS Support

1. Create platform directory under `middleware/hal/<platform>` with `hal_platform.h` and driver implementations.
2. Add RTOS adapter under `middleware/osal/<rtos>` following existing patterns.
3. Update `config.mk` logic for platform‑specific flags and includes.
4. Ensure linker script exists for the new RTOS (copy and adapt from existing ones).