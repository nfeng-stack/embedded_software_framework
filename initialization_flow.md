# 系统初始化流程设计

## 概述
本文档描述了嵌入式系统从复位到应用程序运行的完整初始化流程，涵盖了硬件初始化、操作系统内核初始化、外设初始化和线程创建等关键步骤。

## 初始化阶段

### 阶段1：CPU复位和启动代码（汇编）
- **入口点**：Reset_Handler（在向量表中定义）
- **操作**：
  1. 设置堆栈指针（从向量表加载）
  2. 可选：初始化CPU缓存、MMU/MPU（如果存在）
  3. 调用SystemInit()函数配置系统时钟、闪存延迟等
  4. 复制.data段从FLASH到RAM（初始化全局变量）
  5. 清零.bss段（未初始化全局变量）
  6. 调用__libc_init_array（C++全局构造函数）
  7. 跳转到主初始化函数（rtthread_startup或main）

### 阶段2：硬件抽象层（HAL）初始化
- **函数**：hal_init(), hal_board_init()
- **操作**：
  1. 初始化HAL库（HAL_Init）
  2. 配置系统时钟（如果SystemInit未完全配置）
  3. 使能外设时钟（GPIO、UART、TIM等）
  4. 初始化板级外设（GPIO默认状态、调试串口等）

### 阶段3：操作系统抽象层（OSAL）初始化
- **函数**：osal_init()
- **操作**：
  1. 初始化RTOS内核（如果使用RTOS）
  2. 创建系统对象（信号量、互斥锁、队列等）
  3. 初始化内存管理（堆分配器）

### 阶段4：操作系统内核初始化（RT-Thread专用）
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

### 阶段5：应用程序初始化
- **函数**：main() 或 应用程序任务
- **操作**：
  1. 创建应用程序任务/线程
  2. 初始化应用程序数据结构
  3. 启动周期性任务
  4. 进入主循环或等待调度器调度

## 内存布局
链接脚本定义以下关键内存区域：

### FLASH（只读执行）
- `.isr_vector`：中断向量表
- `.text`：程序代码
- `.rodata`：只读数据
- `.ARM.extab`和`.ARM.exidx`：异常处理表
- `.init_array`和`.fini_array`：全局构造函数/析构函数表

### RAM（读写数据）
- `.data`：已初始化全局变量（从FLASH复制）
- `.bss`：未初始化全局变量（清零）
- `.heap`：动态内存分配区域
- `.stack`：主堆栈（MSP）
- 可选的线程栈区域（如果使用RTOS）

## 链接脚本设计要点
1. **入口点**：ENTRY(Reset_Handler)
2. **内存区域定义**：准确匹配目标芯片的FLASH和RAM大小
3. **堆栈大小**：根据应用需求调整_Min_Heap_Size和_Min_Stack_Size
4. **对齐要求**：确保4字节或8字节对齐以优化性能
5. **RT-Thread扩展**：可添加`.rti_fn`段用于组件自动初始化

## 启动文件设计要点
1. **向量表**：必须放置在FLASH起始位置（0x08000000）
2. **堆栈初始化**：设置主堆栈指针（MSP）
3. **数据复制**：高效复制.data段，支持非对齐地址
4. **BSS清零**：使用循环清零.bss段
5. **可扩展性**：通过预处理器宏支持不同配置（如RT_THREAD）

## 配置选项
- **USE_RTTHREAD**：定义时启用RT-Thread初始化流程
- **HEAP_SIZE**和**STACK_SIZE**：通过链接器脚本或编译选项配置
- **SYSTEM_CLOCK**：系统时钟频率配置

## 验证步骤
1. 检查向量表是否正确放置
2. 验证.data和.bss段初始化是否正确
3. 确认系统时钟配置正确
4. 测试动态内存分配（堆）
5. 验证中断和异常处理
6. 测试RTOS任务调度（如果使用）

## 自动选择机制

构建系统根据 `OSAL_RTOS` 配置变量自动选择合适的链接脚本和启动文件：

### 链接脚本选择
- 当 `OSAL_RTOS = rtthread` 时：使用 `linker/rtthread.ld`
- 其他情况：使用平台特定的链接脚本（如 `linker/stm32h5xx.ld`）

### 启动文件选择
- 当 `OSAL_RTOS = rtthread` 时：使用 `startup/startup_rtthread.S`
- 其他情况：使用 `startup/startup_generic.S`

### 配置示例
在 `config.mk` 中设置：
```makefile
HAL_PLATFORM = stm32h5
OSAL_RTOS = rtthread   # 或设为其他值使用通用版本
```

### 查看当前配置
```bash
make info
```
输出将显示当前选择的链接脚本和启动文件。

## 自定义配置

### 覆盖默认选择
可以在 `config.mk` 或命令行中覆盖配置：
```bash
make OSAL_RTOS=none    # 使用通用版本
make OSAL_RTOS=rtthread # 使用RT-Thread版本
```

### 平台特定文件
- 链接脚本：创建 `linker/<platform>.ld` 并在 `config.mk` 中设置 `LDSCRIPT`
- 启动文件：创建 `startup/startup_<platform>.S` 并在 `config.mk` 中设置 `STARTUP_FILE`

## 文件清单
- `linker/embedded_framework.ld`：通用链接脚本模板
- `linker/rtthread.ld`：RT-Thread优化链接脚本
- `linker/stm32h5xx.ld`：STM32H5平台链接脚本（默认非RT-Thread）
- `startup/startup_generic.S`：通用启动文件
- `startup/startup_rtthread.S`：RT-Thread启动文件
- `system_init.c`：系统初始化C函数（SystemInit等）