# 嵌入式开发框架 (Embedded Development Framework)

## 概述

这是一个完整的嵌入式开发框架，采用三层架构设计：
1. **硬件抽象层 (HAL)** - 提供硬件无关的GPIO、UART、定时器等外设接口
2. **操作系统抽象层 (OSAL)** - 提供RTOS无关的任务、队列、信号量等系统服务
3. **应用层** - 基于HAL和OSAL构建的用户应用程序

框架严格按照分层抽象原则设计，确保可移植性。更换硬件平台或RTOS时，只需添加新的平台/RTOS目录，无需修改应用层和common层代码。

## 目录结构

```
your_framework/
├── include/                          # 对外公开接口
│   ├── hal.h                         # HAL层通用接口
│   └── osal.h                        # OSAL层通用接口
├── hal/                              # 硬件抽象层实现
│   ├── common/                       # HAL通用代码
│   │   ├── hal_gpio.c                # GPIO抽象实现
│   │   ├── hal_uart.c                # UART抽象实现
│   │   ├── hal_timer.c               # 定时器抽象实现
│   │   └── hal_common.h              # 通用内部头文件
│   └── stm32h5/                      # STM32H5平台具体实现
│       ├── hal_gpio_ll.c             # GPIO底层实现
│       ├── hal_uart_ll.c             # UART底层实现
│       ├── hal_timer_ll.c            # 定时器底层实现
│       └── hal_platform.h            # 平台私有定义
├── osal/                             # 操作系统抽象层实现
│   ├── common/                       # OSAL通用代码
│   │   ├── osal_task.c               # 任务管理抽象实现
│   │   ├── osal_queue.c              # 队列抽象实现
│   │   ├── osal_common.h             # 通用内部头文件
│   │   └── (其他OSAL实现文件)
│   └── rtthread/                     # RT-Thread适配
│       ├── osal_task_ll.c            # 任务底层实现
│       ├── osal_port.h               # RT-Thread类型映射
│       └── (其他OSAL底层实现文件)
├── app/                              # 应用层
│   └── your_app.c                    # 应用主文件
├── config/                           # 配置文件
│   ├── hal_config.h                  # HAL层配置
│   ├── osal_config.h                 # OSAL层配置
│   └── platform_select.h             # 选择目标平台和RTOS
├── third_party/                      # 第三方代码
│   ├── stm32h5xx_hal_driver/         # STM32H5 HAL库（需用户复制）
│   └── rt-thread/                    # RT-Thread源码（需用户复制）
├── linker/                           # 链接脚本
│   └── stm32h5xx.ld                  # STM32H5链接脚本
├── Makefile                          # 顶层Makefile
├── config.mk                         # 全局编译配置
└── README.md                         # 本文件
```

## 快速开始

### 1. 准备第三方库

将以下第三方库复制到相应目录：

```bash
# 复制STM32H5 HAL库
cp -r /Users/nfeng/STM32Cube/Repository/STM32Cube_FW_H5_V1.5.1/Drivers/STM32H5xx_HAL_Driver third_party/stm32h5xx_hal_driver

# 复制RT-Thread源码
cp -r /Users/nfeng/nanfeng/Project/rtthread-nano/rt-thread third_party/rt-thread
```

### 2. 配置目标平台和RTOS

编辑 `config/platform_select.h`，确保正确选择平台和RTOS：

```c
#define HAL_PLATFORM_STM32H5      1
#define OSAL_RTOS_RTTHREAD        1
```

### 3. 配置硬件参数

编辑 `config/hal_config.h` 配置时钟频率、外设使能等：

```c
#define HSE_VALUE               8000000UL   /* 8MHz外部晶振 */
#define SYSCLK_FREQ             250000000UL /* 250MHz系统时钟 */
#define HAL_GPIO_MODULE_ENABLED
#define HAL_UART_MODULE_ENABLED
#define HAL_TIMER_MODULE_ENABLED
```

### 4. 配置RTOS参数

编辑 `config/osal_config.h` 配置任务栈大小、时钟频率等：

```c
#define OSAL_TASK_DEFAULT_STACK_SIZE   512
#define OSAL_TICK_RATE_HZ              1000
#define OSAL_MAX_TASKS                  16
```

### 5. 编写应用程序

参考 `app/your_app.c` 中的示例，使用HAL和OSAL API：

```c
#include "hal.h"
#include "osal.h"

void app_task(void *arg) {
    hal_gpio_init(LED_PIN, HAL_GPIO_MODE_OUTPUT);
    
    while (1) {
        hal_gpio_toggle(LED_PIN);
        osal_task_delay(500);  // 延时500ms
    }
}

int main(void) {
    hal_init();
    hal_board_init();
    
    osal_init();
    
    osal_task_create("app", app_task, NULL, 
                     OSAL_TASK_DEFAULT_STACK_SIZE, 1);
    
    osal_start_scheduler();
    
    return 0;
}
```

### 6. 编译和烧录

```bash
# 编译项目
make all

# 查看编译信息
make size

# 烧录到目标板（需配置FLASH_CMD）
make flash

# 清理构建文件
make clean
```

## 框架设计原理

### 分层抽象架构

1. **应用层**：只包含 `hal.h` 和 `osal.h`，不直接接触硬件或RTOS API
2. **Common层**：实现通用抽象逻辑，调用平台/RTOS特定的底层函数
3. **平台/RTOS层**：实现底层硬件/RTOS操作，提供标准化接口给Common层

### 可移植性设计

- **更换硬件平台**：添加新的 `hal/<platform>` 目录，实现底层函数
- **更换RTOS**：添加新的 `osal/<rtos>` 目录，实现底层函数
- **应用代码无需修改**：API保持一致

### 完整接口支持

框架实现了规范要求的所有接口：

#### HAL层接口
- GPIO：初始化、读写、翻转、设置/复位
- UART：初始化、收发、状态检查、格式化输出
- 定时器：初始化、启停、回调、微秒级延时
- 系统初始化：芯片级和板级初始化

#### OSAL层接口
- 任务管理：创建、删除、挂起、恢复、优先级、延时
- 队列：创建、删除、发送、接收、状态查询
- 信号量：创建、删除、获取、释放、计数
- 互斥锁：创建、删除、加锁、解锁
- 事件标志组：创建、删除、设置、等待、查询
- 软件定时器：创建、删除、启停、剩余时间
- 内存管理：分配、释放、初始化
- 系统服务：时间获取、系统复位、临界区

## 扩展框架

### 添加新的硬件平台

1. 在 `hal/` 下创建新平台目录（如 `hal/stm32f4/`）
2. 创建 `hal_platform.h` 定义平台特定类型和函数声明
3. 实现底层函数（`hal_gpio_ll.c`、`hal_uart_ll.c`、`hal_timer_ll.c`）
4. 在 `config/platform_select.h` 中添加平台选项

### 添加新的RTOS

1. 在 `osal/` 下创建新RTOS目录（如 `osal/freertos/`）
2. 创建 `osal_port.h` 定义类型映射和函数声明
3. 实现底层函数（`osal_task_ll.c`、`osal_queue_ll.c` 等）
4. 在 `config/platform_select.h` 中添加RTOS选项

### 添加新的外设驱动

1. 在 `include/hal.h` 中添加新外设的API声明
2. 在 `hal/common/` 中添加抽象实现
3. 在各平台目录中添加底层实现

## 构建系统

### 主要Makefile目标

- `make all`：编译生成elf、bin、hex文件
- `make clean`：清理构建目录
- `make flash`：烧录到目标板
- `make debug`：启动GDB调试会话
- `make size`：显示代码大小信息
- `make info`：显示构建配置信息

### 配置变量

在 `config.mk` 中可配置：

- `HAL_PLATFORM`：硬件平台（stm32h5）
- `OSAL_RTOS`：RTOS类型（rtthread）
- `PREFIX`：工具链前缀（arm-none-eabi-）
- `MCU`：微控制器参数
- `OPT`：优化级别
- `DEBUG`：调试信息使能

## 已知问题和待完成项

### 当前状态
- ✅ 完整的目录结构已创建
- ✅ 所有头文件接口已定义
- ✅ HAL层common实现已完成（GPIO、UART、定时器）
- ✅ OSAL层common实现部分完成（任务、队列）
- ✅ STM32H5平台底层框架已创建
- ✅ RT-Thread适配框架已创建
- ✅ 构建系统已配置
- ✅ 应用示例已提供

### 待完成项
1. **OSAL层完整实现**：需要完成信号量、互斥锁、事件、定时器、内存管理的common实现
2. **RT-Thread底层完整实现**：需要完成所有OSAL功能的RT-Thread适配
3. **STM32H5 HAL集成**：需要完善底层实现，集成真正的STM32 HAL库
4. **编译错误修复**：需要解决当前的头文件包含和类型定义问题
5. **测试验证**：需要在真实硬件上测试框架功能

### 使用建议
1. 首先复制第三方库到 `third_party/` 目录
2. 根据实际硬件调整 `config/hal_config.h` 中的参数
3. 逐步完善底层实现，先实现GPIO和UART基础功能
4. 使用示例应用进行验证和测试

## 许可证

本项目采用MIT许可证。第三方库（STM32 HAL、RT-Thread）遵循各自的许可证。

## 支持

如有问题或建议，请参考代码注释或提交Issue。