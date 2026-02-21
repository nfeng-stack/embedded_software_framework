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
├── middleware/                          # 中间件层
│   ├── hal/                            # 硬件抽象层实现
│   │   ├── common/                     # HAL通用代码
│   │   │   ├── hal_gpio.c              # GPIO抽象实现
│   │   │   ├── hal_uart.c              # UART抽象实现
│   │   │   ├── hal_timer.c             # 定时器抽象实现
│   │   │   └── hal_common.h            # 通用内部头文件
│   │   └── stm32h5/                    # STM32H5平台具体实现
│   │       ├── hal_gpio_ll.c           # GPIO底层实现
│   │       ├── hal_uart_ll.c           # UART底层实现
│   │       ├── hal_timer_ll.c          # 定时器底层实现
│   │       └── hal_platform.h          # 平台私有定义
│   └── osal/                           # 操作系统抽象层实现
│       ├── common/                     # OSAL通用代码
│       │   ├── osal_task.c             # 任务管理抽象实现
│       │   ├── osal_queue.c            # 队列抽象实现
│       │   ├── osal_common.h           # 通用内部头文件
│       │   └── (其他OSAL实现文件)
│       └── rtthread/                   # RT-Thread适配
│           ├── osal_task_ll.c          # 任务底层实现
│           ├── osal_port.h             # RT-Thread类型映射
│           └── (其他OSAL底层实现文件)
├── framework/                          # 框架层
│   ├── config/                         # 配置文件
│   │   ├── hal_config.h                # HAL层配置
│   │   ├── osal_config.h               # OSAL层配置
│   │   └── platform_select.h           # 选择目标平台和RTOS
│   ├── linker/                         # 链接脚本
│   │   └── stm32h5xx.ld                # STM32H5链接脚本
│   ├── include/                        # 框架内部头文件
│   ├── src/                            # 框架源文件
│   ├── startup/                        # 启动文件
│   └── ports/                          # 端口适配
├── include/                            # 对外公开接口
│   ├── hal.h                           # HAL层通用接口
│   └── osal.h                          # OSAL层通用接口
├── app/                                # 应用层
│   └── your_app.c                      # 应用主文件
├── third_party/                        # 第三方代码
│   ├── stm32h5xx_hal_driver/           # STM32H5 HAL库（需用户复制）
│   └── rt-thread/                      # RT-Thread源码（需用户复制）
├── scripts/                            # 构建系统脚本
│   ├── Makefile.build                  # 递归构建核心脚本
│   └── Makefile.lib                    # 构建通用定义
├── Makefile                            # 顶层Makefile
├── config.mk                           # 全局编译配置
└── README.md                           # 本文件
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

### 添加C源文件到现有模块

1. **在对应目录的Makefile中添加源文件**：
   ```makefile
    # 例如：在 middleware/hal/common/Makefile 中添加
   obj-y += hal_spi.o      # 添加SPI驱动
   obj-y += hal_i2c.o      # 添加I2C驱动
   ```

2. **确保对应的.c文件存在于同一目录**：
    ```
    middleware/hal/common/
    ├── hal_spi.c
    ├── hal_i2c.c
    └── Makefile
    ```

3. **添加头文件路径**（如果需要）：
   ```makefile
   EXTRA_CFLAGS += -I../new_include
   ```

### 添加头文件

1. **公共接口头文件**：放在`include/`目录
   ```
   include/
   ├── hal.h
   ├── osal.h
   └── new_peripheral.h  # 新增外设接口
   ```

2. **模块内部头文件**：放在对应模块目录
    ```
    middleware/hal/common/
    ├── hal_common.h
    ├── hal_internal.h    # 新增内部头文件
    └── Makefile
    ```

3. **平台特定头文件**：放在对应平台目录
    ```
    middleware/hal/stm32h5/
    ├── hal_platform.h
    ├── hal_stm32h5_reg.h # 新增寄存器定义
    └── Makefile
    ```

### 添加库文件

1. **静态库（.a文件）**：
   ```makefile
   # 在顶层Makefile或config.mk中添加
   LIBS += -lmylib
   LIBDIR += -L/path/to/lib
   ```

2. **第三方源代码库**：
   ```
   third_party/
   ├── stm32h5xx_hal_driver/
   ├── rt-thread/
   └── my_new_lib/          # 新增第三方库
       ├── include/
       ├── src/
       └── Makefile
   ```

3. **在third_party/Makefile中添加**：
   ```makefile
   obj-y += my_new_lib/
   ```

### 添加新文件夹/模块

1. **创建目录结构**：
   ```
   new_module/
   ├── include/
   │   └── new_module.h
   ├── src/
   │   └── new_module.c
   └── Makefile
   ```

2. **编写模块Makefile**：
   ```makefile
   # new_module/Makefile
   obj-y += new_module.o
   
   # 可选：添加额外编译标志
   EXTRA_CFLAGS += -DNEW_MODULE_ENABLED=1
   ```

3. **在顶层Makefile中注册**：
   ```makefile
   # 修改顶层Makefile中的libs-y
   libs-y += third_party
   libs-y += hal
   libs-y += osal
   libs-y += framework
   libs-y += app
   libs-y += new_module      # 新增模块
   ```

### 编写模块Makefile规范

#### 基本格式
```makefile
# 模块名称/Makefile
# 源文件列表（.o文件，不要.c扩展名）
obj-y += source1.o
obj-y += source2.o
obj-y += source3.o

# 子目录（以/结尾）
obj-y += subdir/

# 额外编译标志（可选）
EXTRA_CFLAGS += -DMODULE_SPECIFIC_FLAG=1
EXTRA_CFLAGS += -I$(srctree)/module/include

# 包含本地配置（可选）
-include local.mk
```

#### 示例：平台特定模块
```makefile
# middleware/hal/stm32h5/Makefile
obj-y += platform_gpio_driver.o
obj-y += platform_timer_driver.o
obj-y += platform_uart_driver.o
obj-y += platform_system_driver.o

# 添加平台特定头文件路径
EXTRA_CFLAGS += -Imiddleware/hal/stm32h5
```

#### 示例：RTOS适配模块
```makefile
# middleware/osal/rtthread/Makefile
obj-y += osal_task_ll.o
obj-y += osal_queue_ll.o
obj-y += osal_sem_ll.o
obj-y += osal_mutex_ll.o
obj-y += osal_event_ll.o
obj-y += osal_timer_ll.o
obj-y += osal_mem_ll.o
obj-y += osal_system_ll.o
```

### 配置变量详解

| 变量 | 默认值 | 描述 |
|------|--------|------|
| `HAL_PLATFORM` | `stm32h5` | 硬件平台：stm32h5, stm32f4, imxrt1064等 |
| `OSAL_RTOS` | `rtthread` | RTOS类型：rtthread, freertos, none等 |
| `PREFIX` | `arm-none-eabi-` | 工具链前缀 |
| `MCU` | `-mcpu=cortex-m33...` | 微控制器架构标志 |
| `OPT` | `-Og` | 优化级别：-O0, -O1, -O2, -O3, -Og, -Os |
| `DEBUG` | `1` | 调试信息使能 |
| `C_DEFS` | `-DUSE_HAL_DRIVER...` | C预处理器定义 |
| `C_INCLUDES` | `-Iinclude...` | 头文件包含路径 |
| `LDSCRIPT` | 自动选择 | 链接器脚本路径 |
| `STARTUP_FILE` | `framework/startup/c/startup.c` | 启动文件路径 |

### 扩展构建系统场景示例

#### 场景1：添加新的硬件平台
1. 创建平台目录：`middleware/hal/new_platform/`
2. 添加Makefile：`middleware/hal/new_platform/Makefile`
3. 实现底层驱动文件：`platform_*_driver.c`
4. 更新`config.mk`中的平台支持

#### 场景2：添加新的RTOS适配
1. 创建RTOS目录：`middleware/osal/new_rtos/`
2. 添加Makefile：`middleware/osal/new_rtos/Makefile`
3. 实现底层适配文件：`osal_*_ll.c`
4. 更新`config.mk`中的RTOS选择逻辑

#### 场景3：添加外设驱动
1. 在`middleware/hal/common/`添加抽象实现：`hal_peripheral.c`
2. 在各平台目录添加底层实现：`platform_peripheral_driver.c`
3. 在`include/hal.h`中添加API声明
4. 在对应Makefile中添加源文件引用

### 构建过程详解

1. **配置阶段**：读取`config.mk`，设置工具链、平台、RTOS等
2. **递归构建**：遍历`libs-y`列表中的每个目录
3. **对象编译**：每个目录的Makefile指定`obj-y`，编译为.o文件
4. **链接阶段**：所有`built-in.o`文件链接为最终ELF文件
5. **格式转换**：ELF转换为BIN/HEX格式

## 双堆内存架构设计

### 概述

本嵌入式系统采用**双堆内存架构**，将C标准库（Newlib/Picolibc）的动态内存分配与RT-Thread操作系统的堆内存完全分离。这种设计避免了内存管理冲突，提高了系统稳定性和可预测性。整个640KB RAM被精细划分为数据段、两个独立的堆区域、隔离缓冲区、栈保护区和主栈，确保系统在异常处理和线程调度时的安全边界。

**设计原则：**
- **隔离性**：C库堆与RT-Thread堆物理分离，互不干扰
- **安全性**：主栈（MSP）下方设置保护区域，检测栈溢出
- **确定性**：所有内存区域大小固定，运行时无碎片化风险
- **可维护性**：清晰的内存布局便于调试和问题排查

### 详细内存布局（RAM: 0x20000000 - 0x200A0000）

```
┌──────────────────────────────────────────────────────────────────────────────┐
│ RAM起始地址: 0x2000 0000                                                     │
├──────────────────────────────────────────────────────────────────────────────┤
│ .data段（已初始化全局变量）                                                  │
│ .bss段（未初始化全局变量）                                                   │
│ 其他数据段                                                                   │
│                                                                              │
│ 地址范围: 0x2000 0000 - 0x2000 120F (约4.6KB，实际大小随应用变化)            │
├──────────────────────────────────────────────────────────────────────────────┤
│ C标准库堆（Newlib/Picolibc）                                                 │
│ 用途: malloc()、free()、realloc()等C库函数                                  │
│ 管理方式: _sbrk()系统调用                                                    │
│                                                                              │
│ 起始地址: 0x2000 1210 (_end)                                                 │
│ 结束地址: 0x2000 5210 (_heap_limit)                                          │
│ 大小: 16KB (0x4000)                                                         │
├──────────────────────────────────────────────────────────────────────────────┤
│ 隔离缓冲区                                                                   │
│ 用途: 防止C库堆与RT-Thread堆意外重叠                                         │
│                                                                              │
│ 地址范围: 0x2000 5210 - 0x2000 6210                                          │
│ 大小: 4KB (0x1000)                                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│ C库栈保留区（未使用）                                                        │
│ 用途: 链接器为C库栈保留的空间（实际使用MSP栈）                               │
│                                                                              │
│ 地址范围: 0x2000 6210 - 0x2000 7210                                          │
│ 大小: 4KB (0x1000)                                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│ RT-Thread堆（操作系统堆）                                                    │
│ 用途: rt_malloc()、rt_free()等RT-Thread内存管理函数                         │
│ 管理方式: RT-Thread内存池（静态数组）                                        │
│ 位置属性: __attribute__((section(".rt_heap_section")))                       │
│                                                                              │
│ 起始地址: 0x2000 7210 (_rt_heap_start, rt_heap数组)                          │
│ 结束地址: 0x2009 7210 (_rt_heap_end)                                         │
│ 大小: 576KB (0x90000)                                                       │
├──────────────────────────────────────────────────────────────────────────────┤
│ MSP栈保护区域                                                                │
│ 用途: 检测主栈（MSP）溢出，填充魔数0xDEADBEEF                                │
│ 初始化: framework_data_init()中设置                                          │
│ 检查: 运行时可验证魔数是否被破坏                                             │
│                                                                              │
│ 起始地址: 0x2009 7210 (_msp_stack_protection_start)                          │
│ 结束地址: 0x2009 8210 (_msp_stack_protection_end)                            │
│ 大小: 4KB (0x1000)                                                          │
├──────────────────────────────────────────────────────────────────────────────┤
│ MSP栈区（主栈）                                                              │
│ 用途: 异常处理、中断服务程序、RT-Thread上下文切换                           │
│ 生长方向: 向下（递减）                                                       │
│ 初始栈指针: _estack (0x200A 0000)                                            │
│                                                                              │
│ 起始地址: 0x2009 8210                                                        │
│ 结束地址: 0x200A 0000 (_estack)                                              │
│ 可用大小: ~32KB (0x7DF0)                                                    │
├──────────────────────────────────────────────────────────────────────────────┤
│ RAM结束地址: 0x200A 0000                                                     │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 双堆架构详解

#### C标准库堆（16KB）
**管理方式：**
- 通过`_sbrk()`和`_sbrk_r()`系统调用实现
- 链接器符号`_end`标记堆起始地址
- 链接器符号`_heap_limit`标记堆结束地址
- 由Newlib/Picolibc库内部管理

**实现文件：** `framework/src/syscalls.c`

```c
void *_sbrk(ptrdiff_t incr) {
    static char *heap_end = (char *)&_end;
    char *prev_heap_end = heap_end;
    
    if (heap_end + incr > (char *)&_heap_limit) {
        errno = ENOMEM;
        return (void *)-1;
    }
    
    heap_end += incr;
    return (void *)prev_heap_end;
}
```

#### RT-Thread堆（576KB）
**管理方式：**
- 静态数组：`static rt_uint8_t rt_heap[RT_HEAP_SIZE]`
- 通过`__attribute__((section(".rt_heap_section")))`放置在专用链接段
- RT-Thread内存池管理算法（首次适应、最佳适应等）
- 通过重写弱函数`rt_heap_begin_get()`和`rt_heap_end_get()`提供边界

**实现文件：** `third_party/rt-thread/src/board.c`

```c
/* RT-Thread堆数组定义 */
static rt_uint8_t rt_heap[RT_HEAP_SIZE] __attribute__((section(".rt_heap_section")));

/* 重写堆边界获取函数 */
rt_uint8_t *rt_heap_begin_get(void) {
    return rt_heap;
}

rt_uint8_t *rt_heap_end_get(void) {
    return rt_heap + sizeof(rt_heap);
}
```

### 栈保护机制

#### MSP栈保护区域
**目的：** 检测主栈（MSP）溢出，防止破坏RT-Thread堆数据

**实现：**
1. **区域定义**：链接器脚本中定义4KB保护区域
2. **魔数填充**：`framework_data_init()`中填充`0xDEADBEEF`
3. **运行时检查**：应用程序可定期验证魔数完整性

**初始化代码：** `framework/src/framework_init.c`

```c
void framework_data_init(void) {
    /* ... 其他初始化 ... */
    
    /* 初始化MSP栈保护区域 */
    uint32_t *prot_start = (uint32_t *)&_msp_stack_protection_start;
    uint32_t *prot_end = (uint32_t *)&_msp_stack_protection_end;
    
    for (uint32_t *p = prot_start; p < prot_end; p++) {
        *p = 0xDEADBEEF;
    }
    
    /* ... 后续初始化 ... */
}
```

## 系统初始化流程设计

### 初始化阶段

#### 阶段1：CPU复位和启动代码（汇编）
- **入口点**：Reset_Handler（在向量表中定义）
- **操作**：
  1. 设置堆栈指针（从向量表加载）
  2. 可选：初始化CPU缓存、MMU/MPU（如果存在）
  3. 调用SystemInit()函数配置系统时钟、闪存延迟等
  4. 复制.data段从FLASH到RAM（初始化全局变量）
  5. 清零.bss段（未初始化全局变量）
  6. 调用__libc_init_array（C++全局构造函数）
  7. 跳转到主初始化函数（rtthread_startup或main）

#### 阶段2：硬件抽象层（HAL）初始化
- **函数**：hal_init(), hal_board_init()
- **操作**：
  1. 初始化HAL库（HAL_Init）
  2. 配置系统时钟（如果SystemInit未完全配置）
  3. 使能外设时钟（GPIO、UART、TIM等）
  4. 初始化板级外设（GPIO默认状态、调试串口等）

#### 阶段3：操作系统抽象层（OSAL）初始化
- **函数**：osal_init()
- **操作**：
  1. 初始化RTOS内核（如果使用RTOS）
  2. 创建系统对象（信号量、互斥锁、队列等）
  3. 初始化内存管理（堆分配器）

#### 阶段4：操作系统内核初始化（RT-Thread专用）
- **函数**：rtthread_startup()
- **操作**：
  1. 关闭全局中断（rt_hw_interrupt_disable）
  2. 板级硬件初始化（rt_hw_board_init）
  3. 显示RT-Thread版本信息（rt_show_version）
  4. 初始化系统定时器（rt_system_timer_init）
  5. 初始化调度器（rt_system_scheduler_init）
  6. 初始化应用程序线程（rt_application_init）
  7. 初始化定时器线程（rt_system_timer_thread_init）
  8. 初始化空闲线程（rt_thread_idle_init）
  9. 启动调度器（rt_system_scheduler_start）

#### 阶段5：应用程序初始化
- **函数**：main() 或 应用程序任务
- **操作**：
  1. 创建应用程序任务/线程
  2. 初始化应用程序数据结构
  3. 启动周期性任务
  4. 进入主循环或等待调度器调度

### 内存布局

#### FLASH（只读执行）
- `.isr_vector`：中断向量表
- `.text`：程序代码
- `.rodata`：只读数据
- `.ARM.extab`和`.ARM.exidx`：异常处理表
- `.init_array`和`.fini_array`：全局构造函数/析构函数表

#### RAM（读写数据）
- `.data`：已初始化全局变量（从FLASH复制）
- `.bss`：未初始化全局变量（清零）
- `.heap`：动态内存分配区域
- `.stack`：主堆栈（MSP）
- 可选的线程栈区域（如果使用RTOS）

### 自动选择机制

构建系统根据 `OSAL_RTOS` 配置变量自动选择合适的链接脚本和启动文件：

#### 链接脚本选择
- 当 `OSAL_RTOS = rtthread` 时：使用 `framework/linker/rtthread.ld`
- 其他情况：使用平台特定的链接脚本（如 `framework/linker/stm32h5xx.ld`）

#### 启动文件选择
- 当 `OSAL_RTOS = rtthread` 时：使用 `framework/startup/startup_rtthread.S`
- 其他情况：使用 `framework/startup/startup_generic.S`

#### 查看当前配置
```bash
make info
```
输出将显示当前选择的链接脚本和启动文件。

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

编辑 `framework/config/platform_select.h`，确保正确选择平台和RTOS：

```c
#define HAL_PLATFORM_STM32H5      1
#define OSAL_RTOS_RTTHREAD        1
```

### 3. 配置硬件参数

编辑 `framework/config/hal_config.h` 配置时钟频率、外设使能等：

```c
#define HSE_VALUE               8000000UL   /* 8MHz外部晶振 */
#define SYSCLK_FREQ             250000000UL /* 250MHz系统时钟 */
#define HAL_GPIO_MODULE_ENABLED
#define HAL_UART_MODULE_ENABLED
#define HAL_TIMER_MODULE_ENABLED
```

### 4. 配置RTOS参数

编辑 `framework/config/osal_config.h` 配置任务栈大小、时钟频率等：

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

- **更换硬件平台**：添加新的 `middleware/hal/<platform>` 目录，实现底层函数
- **更换RTOS**：添加新的 `middleware/osal/<rtos>` 目录，实现底层函数
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

1. 在 `middleware/hal/` 下创建新平台目录（如 `middleware/hal/stm32f4/`）
2. 创建 `hal_platform.h` 定义平台特定类型和函数声明
3. 实现底层函数（`hal_gpio_ll.c`、`hal_uart_ll.c`、`hal_timer_ll.c`）
4. 在 `framework/config/platform_select.h` 中添加平台选项

### 添加新的RTOS

1. 在 `middleware/osal/` 下创建新RTOS目录（如 `middleware/osal/freertos/`）
2. 创建 `osal_port.h` 定义类型映射和函数声明
3. 实现底层函数（`osal_task_ll.c`、`osal_queue_ll.c` 等）
4. 在 `framework/config/platform_select.h` 中添加RTOS选项

### 添加新的外设驱动

1. 在 `include/hal.h` 中添加新外设的API声明
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

1. **详细输出**：
   ```bash
   make V=1          # 显示详细构建命令
   ```

2. **配置覆盖**：
   ```bash
   make OSAL_RTOS=none      # 使用通用版本（无RTOS）
   make OSAL_RTOS=rtthread  # 使用RT-Thread版本
   make HAL_PLATFORM=stm32f4 # 更换硬件平台
   ```

3. **组合使用**：
   ```bash
   make clean all V=1       # 完全重新编译，显示详细过程
   make all && make size    # 编译后查看大小信息
   ```

## 故障排查

### 常见构建问题

1. **找不到头文件**
   - 检查`C_INCLUDES`路径是否正确
   - 确认第三方库已正确复制到`third_party/`
   - 验证`config.mk`中的平台特定包含路径

2. **链接错误**
   - 检查`LDSCRIPT`链接器脚本路径
   - 确认所有必需的`.o`文件已生成
   - 查看`build/embedded_framework.map`映射文件

3. **内存溢出**
   - 使用`make size`检查代码大小
   - 调整链接器脚本中的内存区域大小
   - 优化代码或启用编译优化

### 运行时问题

1. **启动失败**
   - 检查启动文件是否正确
   - 验证中断向量表位置
   - 确认系统时钟配置

2. **堆栈溢出**
   - 增加栈保护区域大小
   - 优化函数调用深度
   - 使用`check_msp_stack_integrity()`检查保护区域

3. **内存分配失败**
   - 确认双堆架构配置正确
   - 检查C库堆和RT-Thread堆边界
   - 监控堆使用情况

### 调试工具

1. **map文件分析**：`build/embedded_framework.map`
2. **elf文件检查**：`arm-none-eabi-objdump -h build/embedded_framework.elf`
3. **内存布局验证**：
   ```bash
   arm-none-eabi-nm -n build/embedded_framework.elf | grep -E "_end|_heap_limit|_rt_heap|_msp_stack_protection|_estack"
   ```

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
2. 根据实际硬件调整 `framework/config/hal_config.h` 中的参数
3. 逐步完善底层实现，先实现GPIO和UART基础功能
4. 使用示例应用进行验证和测试

## 许可证

本项目采用MIT许可证。第三方库（STM32 HAL、RT-Thread）遵循各自的许可证。

## 支持

如有问题或建议，请参考代码注释或提交Issue。

---

**文档版本：** 2.0  
**最后更新：** 2025-02-21  
**集成文档：** memory_layout.md, initialization_flow.md, build_system_guide