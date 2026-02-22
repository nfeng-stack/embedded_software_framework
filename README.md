# 嵌入式开发框架 (Embedded Development Framework)

## 概述

这是一个完整的嵌入式开发框架，采用三层架构设计：
1. **硬件抽象层 (HAL)** - 提供硬件无关的GPIO、UART、定时器、IIC等外设接口
2. **操作系统抽象层 (OSAL)** - 提供RTOS无关的任务、队列、信号量、互斥锁、事件、邮箱、内存池、软件定时器等系统服务
3. **应用层** - 基于HAL和OSAL构建的用户应用程序

框架严格按照分层抽象原则设计，确保可移植性。更换硬件平台或RTOS时，只需添加新的平台/RTOS目录，无需修改应用层和common层代码。

## 目录结构

```
fall_detection_embedded_soft/
├── middleware/                          # 中间件层
│   ├── hal/                            # 硬件抽象层实现
│   │   ├── common/                     # HAL通用代码
│   │   │   ├── hal_gpio.c              # GPIO抽象实现
│   │   │   ├── hal_uart.c              # UART抽象实现
│   │   │   ├── hal_timer.c             # 定时器抽象实现
│   │   │   ├── hal_iic.c               # IIC(I2C)抽象实现
│   │   │   ├── hal_system.c            # 系统抽象实现
│   │   │   └── hal_common.h            # 通用内部头文件
│   │   ├── stm32h5/                    # STM32H5平台实现
│   │   │   ├── platform_gpio_driver.c  # GPIO底层驱动
│   │   │   ├── platform_uart_driver.c  # UART底层驱动
│   │   │   ├── platform_timer_driver.c # 定时器底层驱动
│   │   │   ├── platform_iic_driver.c   # IIC底层驱动
│   │   │   ├── platform_system_driver.c# 系统底层驱动
│   │   │   └── platform_driver.h       # 驱动接口定义
│   │   ├── stm32f4/                    # STM32F4平台实现
│   │   │   └── hal_platform.h          # 平台私有定义
│   │   └── imxrt1064/                  # IMXRT1064平台实现
│   │       └── hal_platform.h          # 平台私有定义
│   └── osal/                           # 操作系统抽象层实现
│       ├── common/                      # OSAL通用代码
│       │   ├── osal_task.c             # 任务管理抽象实现
│       │   ├── osal_mq.c               # 队列抽象实现
│       │   ├── osal_sem.c              # 信号量抽象实现
│       │   ├── osal_mutex.c            # 互斥锁抽象实现
│       │   ├── osal_event.c            # 事件标志组抽象实现
│       │   ├── osal_timer.c            # 软件定时器抽象实现
│       │   ├── osal_mem.c              # 内存池抽象实现
│       │   ├── osal_mb.c               # 邮箱抽象实现
│       │   ├── osal_mp.c               # 内存管理抽象实现
│       │   ├── osal_system.c           # 系统服务抽象实现
│       │   ├── osal_common_def.h       # 通用定义
│       │   └── xx_osExtension/         # 扩展接口
│       │       ├── osal_xx_osExtension.c
│       │       ├── xx_osExtension_def.h
│       │       └── xx_osExtension_interface.h
│       ├── rtthread/                   # RT-Thread适配
│       │   ├── _osal_task.c            # 任务适配
│       │   ├── _osal_mq.c               # 队列适配
│       │   ├── _osal_sem.c             # 信号量适配
│       │   ├── _osal_mutex.c           # 互斥锁适配
│       │   ├── _osal_event.c           # 事件适配
│       │   ├── _osal_timer.c           # 定时器适配
│       │   ├── _osal_mem.c             # 内存池适配
│       │   ├── _osal_mb.c              # 邮箱适配
│       │   ├── _osal_mp.c              # 内存管理适配
│       │   ├── _osal_object.c          # 对象管理适配
│       │   ├── _osal_system.c          # 系统适配
│       │   └── _osal_interface.h       # 适配层接口
│       └── freertos/                   # FreeRTOS适配(目录结构待完善)
│           └── osal_port.h             # FreeRTOS类型映射
├── framework/                          # 框架层
│   ├── config/                         # 配置文件
│   │   ├── hal_config.h                # HAL层配置
│   │   ├── osal_config.h               # OSAL层配置
│   │   └── platform_select.h           # 目标平台和RTOS选择
│   ├── linker/                         # 链接脚本
│   │   ├── rtthread/rtthread.ld       # RT-Thread链接脚本
│   │   └── bare/bare.ld               # 裸机链接脚本
│   ├── src/                           # 框架源文件
│   │   ├── framework_init.c            # 框架初始化
│   │   ├── framework_debug.c           # 调试支持
│   │   ├── framework_interrupts.c     # 中断处理框架
│   │   ├── framework_rtos.c           # RTOS支持框架
│   │   └── syscalls.c                 # 系统调用实现
│   ├── include/                       # 框架内部头文件
│   │   ├── framework.h                # 框架主头文件
│   │   ├── framework_init.h           # 初始化接口
│   │   ├── framework_debug.h          # 调试接口
│   │   ├── framework_rtos.h           # RTOS接口
│   │   ├── framework_startup.h        # 启动接口
│   │   ├── framework_interrupts.h    # 中断接口
│   │   └── framework_port.h          # 端口接口
│   ├── startup/                       # 启动文件
│   │   ├── c/
│   │   │   ├── startup.c              # C启动代码
│   │   │   └── Makefile
│   │   └── platforms/
│   │       └── stm32h5/
│   │           ├── vectors_stm32h5.h  # 中断向量表
│   │           └── irq_handlers_stm32h5.h # 中断处理声明
│   ├── ports/                         # 端口适配
│   │   ├── generic/                   # 通用端口
│   │   │   └── framework_port_generic.c
│   │   └── rtthread/                  # RT-Thread端口
│   │       └── framework_port_rtthread.c
│   └── log/                           # 日志系统(EasyLogger)
│       ├── src/
│       │   ├── elog.c
│       │   ├── elog_async.c
│       │   ├── elog_buf.c
│       │   ├── elog_utils.c
│       │   └── Makefile
│       ├── port/
│       │   └── elog_port.c
│       └── inc/
│           ├── elog.h
│           └── elog_cfg.h
├── include/                            # 对外公开接口
│   ├── hal.h                          # HAL层通用接口
│   └── osal.h                         # OSAL层通用接口
├── app/                                # 应用层
│   ├── your_app.c                     # 应用主文件
│   ├── Makefile
│   └── mpu6050/                       # MPU6050传感器驱动
│       ├── mpu6050_wrap.c              # 传感器封装
│       ├── mpu6050_wrap.h
│       ├── src/
│       │   ├── driver_mpu6050.c        # 驱动实现
│       │   ├── driver_mpu6050_basic.c  # 基础驱动
│       │   ├── driver_mpu6050_interface_template.c
│       │   └── Makefile
│       └── inc/
│           ├── driver_mpu6050.h
│           ├── driver_mpu6050_basic.h
│           ├── driver_mpu6050_code.h
│           └── driver_mpu6050_interface.h
├── third_party/                        # 第三方代码
│   ├── stm32h5xx_hal_driver/         # STM32H5 HAL库
│   │   ├── Src/                       # 驱动源码(100+文件)
│   │   └── Inc/                       # 驱动头文件
│   ├── CMSIS/                         # ARM CMSIS标准
│   │   └── Device/ST/STM32H5xx/       # STM32H5设备支持
│   └── rt-thread/                      # RT-Thread Nano
│       ├── include/                    # RT-Thread头文件
│       ├── src/                        # RT-Thread源码
│       └── libcpu/arm/cortex-m33/     # Cortex-M33 CPU支持
├── scripts/                            # 构建系统脚本
│   ├── Makefile.build                 # 递归构建核心脚本
│   └── Makefile.lib                   # 构建通用定义
├── build/                              # 构建输出目录
│   ├── embedded_framework.elf         # 编译输出ELF
│   └── embedded_framework.map         # 符号映射表
├── .vscode/                           # VSCode配置
│   ├── c_cpp_properties.json
│   ├── launch.json
│   ├── tasks.json
│   └── openocd.cfg
├── Makefile                            # 顶层Makefile
├── config.mk                           # 全局编译配置
├── README.md                           # 本文件
└── .gitignore
```

## 构建系统详细指南

### 构建系统架构

本项目采用类似**U-Boot的递归构建系统**，具有以下特点：

1. **递归构建**：每个目录可以有自己的Makefile，通过顶层Makefile递归调用
2. **模块化设计**：每个组件（hal、osal、app等）独立构建，最终链接成单个二进制文件
3. **配置驱动**：通过`config.mk`定义平台、RTOS、工具链等配置
4. **自动依赖**：使用gcc的`-MMD`选项自动生成头文件依赖关系

### 核心构建文件说明

| 文件 | 作用 |
|------|------|
| `Makefile` | 顶层Makefile，定义项目结构、递归构建规则和最终链接 |
| `config.mk` | 全局编译配置：平台选择、工具链、编译器标志等 |
| `scripts/Makefile.build` | 递归构建核心脚本，处理目录遍历和对象构建 |
| `scripts/Makefile.lib` | 构建通用定义和宏 |

### 配置变量详解

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `HAL_PLATFORM` | `stm32h5` | 硬件平台：stm32h5, stm32f4, imxrt1064等 |
| `OSAL_RTOS` | `rtthread` | RTOS类型：rtthread, freertos等 |
| `PREFIX` | `arm-none-eabi-` | 工具链前缀 |
| `MCU` | `-mcpu=cortex-m33 -mthumb -mfpu=fpv5-sp-d16 -mfloat-abi=hard` | 微控制器架构标志 |
| `OPT` | `-Og` | 优化级别：-O0, -O1, -O2, -O3, -Og, -Os |
| `DEBUG` | `1` | 调试信息使能 |
| `C_DEFS` | `-DUSE_HAL_DRIVER -DSTM32H563xx...` | C预处理器定义 |
| `LDSCRIPT` | 自动选择 | 链接器脚本路径 |
| `STARTUP_FILE` | `framework/startup/c/startup.c` | 启动文件路径 |

### 自动选择机制

构建系统根据 `OSAL_RTOS` 配置变量自动选择合适的链接脚本和框架端口：

#### 链接脚本选择
- 当 `OSAL_RTOS = rtthread` 时：使用 `framework/linker/rtthread/rtthread.ld`
- 其他情况：使用 `framework/linker/bare/bare.ld`

#### 框架端口选择
- 当 `OSAL_RTOS = rtthread` 时：使用 `framework/ports/rtthread/`
- 其他情况：使用 `framework/ports/generic/`

#### 查看当前配置
```bash
make info
```

## 双堆内存架构设计

### 概述

本嵌入式系统采用**双堆内存架构**，将C标准库（Newlib）的动态内存分配与RT-Thread操作系统的堆内存完全分离。

**设计原则：**
- **隔离性**：C库堆与RT-Thread堆物理分离，互不干扰
- **安全性**：主栈（MSP）下方设置保护区域，检测栈溢出
- **确定性**：所有内存区域大小固定，运行时无碎片化风险
- **可维护性**：清晰的内存布局便于调试和问题排查

### 详细内存布局（RAM: 0x20000000 - 0x200A0000）

```
┌─────────────────────────────────────────────────────────────────────────────┐
│ RAM起始地址: 0x2000 0000                                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│ .data段（已初始化全局变量）                                                │
│ .bss段（未初始化全局变量）                                                 │
│                                                                              │
│ 地址范围: 0x2000 0000 - 0x2000 120F (约4.6KB)                           │
├─────────────────────────────────────────────────────────────────────────────┤
│ C标准库堆（Newlib）                                                        │
│ 起始地址: 0x2000 1210 (_end)                                              │
│ 结束地址: 0x2000 5210 (_heap_limit)                                       │
│ 大小: 16KB (0x4000)                                                       │
├─────────────────────────────────────────────────────────────────────────────┤
│ 隔离缓冲区 (4KB)                                                          │
├─────────────────────────────────────────────────────────────────────────────┤
│ C库栈保留区 (4KB)                                                         │
├─────────────────────────────────────────────────────────────────────────────┤
│ RT-Thread堆                                                                │
│ 起始地址: 0x2000 7210                                                      │
│ 大小: 576KB (0x90000)                                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│ MSP栈保护区域 (4KB, 魔数0xDEADBEEF)                                      │
├─────────────────────────────────────────────────────────────────────────────┤
│ MSP栈区                                                                    │
│ 地址范围: 0x2009 8210 - 0x200A 0000 (_estack)                           │
│ 可用大小: ~32KB                                                            │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 栈保护机制

**初始化代码：** `framework/src/framework_init.c`

```c
void framework_data_init(void) {
    /* 初始化MSP栈保护区域 */
    uint32_t *prot_start = (uint32_t *)&_msp_stack_protection_start;
    uint32_t *prot_end = (uint32_t *)&_msp_stack_protection_end;
    
    for (uint32_t *p = prot_start; p < prot_end; p++) {
        *p = 0xDEADBEEF;
    }
}
```

## 系统初始化流程设计

### 初始化阶段

#### 阶段1：CPU复位和启动代码
- **入口点**：Reset_Handler
- **操作**：
  1. 设置堆栈指针
  2. 调用SystemInit()
  3. 复制.data段
  4. 清零.bss段
  5. 调用__libc_init_array
  6. 跳转到main或rtthread_startup

#### 阶段2：硬件抽象层（HAL）初始化
- **函数**：hal_init(), hal_board_init()
- **操作**：
  1. 初始化HAL库
  2. 配置系统时钟
  3. 使能外设时钟
  4. 初始化板级外设

#### 阶段3：操作系统抽象层（OSAL）初始化
- **函数**：osal_init()
- **操作**：
  1. 初始化RTOS内核
  2. 创建系统对象
  3. 初始化内存管理

#### 阶段4：应用程序初始化
- **函数**：main()
- **操作**：
  1. 创建应用程序任务
  2. 初始化传感器/外设
  3. 启动调度器

## 快速开始

### 1. 编译项目

```bash
# 编译项目
make all

# 查看编译信息
make size

# 烧录到目标板
make flash

# 清理构建文件
make clean
```

### 2. 配置目标平台和RTOS

编辑 `config.mk` 或通过命令行覆盖：

```bash
# 使用RT-Thread
make OSAL_RTOS=rtthread

# 使用裸机（无RTOS）
make OSAL_RTOS=bare

# 更换硬件平台
make HAL_PLATFORM=stm32h5
make HAL_PLATFORM=stm32f4
```

### 3. 配置硬件参数

编辑 `framework/config/hal_config.h`：

```c
#define HSE_VALUE               8000000UL   /* 8MHz外部晶振 */
#define SYSCLK_FREQ             250000000UL /* 250MHz系统时钟 */
#define HAL_GPIO_MODULE_ENABLED
#define HAL_UART_MODULE_ENABLED
#define HAL_TIMER_MODULE_ENABLED
#define HAL_IIC_MODULE_ENABLED
```

### 4. 编写应用程序

参考 `app/your_app.c`：

```c
#include "hal.h"
#include "osal.h"

void app_task(void *arg) {
    hal_gpio_init(LED_PIN, HAL_GPIO_MODE_OUTPUT);
    
    while (1) {
        hal_gpio_toggle(LED_PIN);
        osal_task_delay(500);
    }
}

int main(void) {
    hal_init();
    hal_board_init();
    
    osal_init();
    
    osal_task_create("app", app_task, NULL, 
                     OSAL_TASK_DEFAULT_STACK_SIZE, 5);
    
    osal_start_scheduler();
    
    return 0;
}
```

## 框架设计原理

### 分层抽象架构

1. **应用层**：只包含 `hal.h` 和 `osal.h`，不直接接触硬件或RTOS API
2. **Common层**：实现通用抽象逻辑，调用平台/RTOS特定的底层函数
3. **平台/RTOS层**：实现底层硬件/RTOS操作，提供标准化接口给Common层

### 完整接口支持

#### HAL层接口
- GPIO：初始化、读写、翻转、设置/复位
- UART：初始化、收发、状态检查、格式化输出
- 定时器：初始化、启停、回调、微秒级延时
- IIC：初始化、收发、状态检查
- 系统初始化：芯片级和板级初始化

#### OSAL层接口
- 任务管理：创建、删除、挂起、恢复、优先级、延时
- 队列：创建、删除、发送、接收、状态查询
- 信号量：创建、删除、获取、释放、计数
- 互斥锁：创建、删除、加锁、解锁
- 事件标志组：创建、删除、设置、等待、查询
- 软件定时器：创建、删除、启停、剩余时间
- 内存池：创建、删除、分配、释放
- 邮箱：创建、删除、发送、接收
- 内存管理：分配、释放、初始化
- 系统服务：时间获取、系统复位、临界区

## 扩展框架

### 添加新的硬件平台

1. 在 `middleware/hal/` 下创建新平台目录
2. 创建 `hal_platform.h` 定义平台特定类型
3. 实现底层驱动文件
4. 更新 `config.mk` 中的平台配置

### 添加新的RTOS

1. 在 `middleware/osal/` 下创建新RTOS目录
2. 创建适配层文件
3. 更新 `config.mk` 中的RTOS选择逻辑

### 添加新的外设驱动

1. 在 `include/hal.h` 中添加API声明
2. 在 `middleware/hal/common/` 中添加抽象实现
3. 在各平台目录中添加底层实现

## 构建系统命令参考

### 主要Makefile目标

| 命令 | 描述 |
|------|------|
| `make all` | 编译生成elf、bin、hex文件 |
| `make clean` | 清理构建目录 |
| `make flash` | 烧录到目标板 |
| `make debug` | 启动GDB调试会话 |
| `make size` | 显示代码大小信息 |
| `make info` | 显示构建配置信息 |
| `make help` | 显示帮助信息 |

### 高级用法

1. **详细输出**：`make V=1`
2. **配置覆盖**：`make OSAL_RTOS=rtthread HAL_PLATFORM=stm32f4`

## 故障排查

### 常见构建问题

1. **找不到头文件** - 检查`C_INCLUDES`路径
2. **链接错误** - 查看`build/embedded_framework.map`
3. **内存溢出** - 使用`make size`检查

### 运行时问题

1. **启动失败** - 检查启动文件和时钟配置
2. **堆栈溢出** - 使用`check_msp_stack_integrity()`检查
3. **内存分配失败** - 确认双堆架构配置

### 调试工具

```bash
# Map文件分析
arm-none-eabi-nm -n build/embedded_framework.elf | grep -E "_end|_heap"

# ELF段信息
arm-none-eabi-objdump -h build/embedded_framework.elf
```

## 当前实现状态

### ✅ 已完成
- 完整目录结构
- HAL层common实现（GPIO、UART、Timer、IIC、System）
- OSAL层common实现（Task、Queue、Sem、Mutex、Event、Timer、Mem、Mb、Mp、System）
- STM32H5平台底层实现
- RT-Thread适配层完整实现
- FreeRTOS适配层框架
- 构建系统完整配置
- EasyLogger日志系统
- MPU6050传感器驱动
- 双堆内存架构
- 栈保护机制

### 🔄 待完善
- STM32F4平台底层实现
- IMXRT1064平台底层实现
- FreeRTOS适配层完整实现

## 许可证

本项目采用MIT许可证。第三方库（STM32 HAL、RT-Thread）遵循各自的许可证。

---

**文档版本：** 3.0  
**最后更新：** 2026-02-22
