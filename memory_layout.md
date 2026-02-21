# 双堆内存架构设计

## 概述

本嵌入式系统采用**双堆内存架构**，将C标准库（Newlib/Picolibc）的动态内存分配与RT-Thread操作系统的堆内存完全分离。这种设计避免了内存管理冲突，提高了系统稳定性和可预测性。整个640KB RAM被精细划分为数据段、两个独立的堆区域、隔离缓冲区、栈保护区和主栈，确保系统在异常处理和线程调度时的安全边界。

**设计原则：**
- **隔离性**：C库堆与RT-Thread堆物理分离，互不干扰
- **安全性**：主栈（MSP）下方设置保护区域，检测栈溢出
- **确定性**：所有内存区域大小固定，运行时无碎片化风险
- **可维护性**：清晰的内存布局便于调试和问题排查

## 详细内存布局（RAM: 0x20000000 - 0x200A0000）

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

## 双堆架构详解

### C标准库堆（16KB）

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

### RT-Thread堆（576KB）

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

**链接器脚本配置：** `framework/linker/rtthread/rtthread.ld`

```ld
/* RT-Thread堆段定义 */
.rt_heap_section :
{
    . = ALIGN(8);
    _rt_heap_section_start = .;
    KEEP(*(.rt_heap_section))
    . = ALIGN(8);
    _rt_heap_section_end = .;
} > RAM

/* 大小定义 */
_Min_Heap_Size = 0x4000;     /* 16KB C库堆 */
_Min_Stack_Size = 0x1000;    /* 4KB C库栈保留 */
_RT_Heap_Size = 640K - 64K;  /* 576KB RT-Thread堆 */
```

## 栈保护机制

### MSP栈保护区域

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

**验证函数示例：**

```c
int check_msp_stack_integrity(void) {
    uint32_t *prot_start = (uint32_t *)&_msp_stack_protection_start;
    uint32_t *prot_end = (uint32_t *)&_msp_stack_protection_end;
    
    for (uint32_t *p = prot_start; p < prot_end; p++) {
        if (*p != 0xDEADBEEF) {
            /* 栈溢出检测！ */
            return -1;
        }
    }
    return 0;
}
```

## 初始化序列

### 1. 复位阶段
- **硬件自动**：从向量表加载MSP到`_estack` (0x200A0000)
- **向量表位置**：FLASH起始地址(0x08000000)
- **初始栈指针**：MSP = 0x200A0000

### 2. 启动代码 (`Reset_Handler`)
1. 设置MSP（已由硬件完成）
2. 复制`.data`段到RAM
3. 清零`.bss`段
4. 调用`SystemInit()`配置系统时钟
5. 调用`__libc_init_array()`（C++全局构造函数）
6. 跳转到`rtthread_startup()`或`main()`

### 3. 数据初始化 (`framework_data_init`)
1. 初始化MSP栈保护区域（填充0xDEADBEEF）
2. 其他系统数据初始化

### 4. RT-Thread初始化 (`rtthread_startup`)
1. 关闭全局中断
2. 板级硬件初始化
3. 显示版本信息
4. 初始化系统定时器
5. 初始化调度器
6. 初始化应用程序线程
7. 初始化定时器线程
8. 初始化空闲线程
9. 启动调度器

## 运行时行为

### MSP与PSP的使用

| 栈指针 | 使用场景 | 管理方 |
|--------|----------|--------|
| **MSP** | 异常处理、中断服务程序、RT-Thread上下文切换 | 硬件/RT-Thread内核 |
| **PSP** | 线程栈（应用程序线程） | RT-Thread任务调度器 |

**关键点：**
- **异常模式**：CPU自动切换到MSP
- **线程模式**：RT-Thread使用PSP管理线程栈
- **上下文切换**：`resume.S`中保存/恢复PSP，仅在初始线程切换时恢复MSP

### 上下文切换中的MSP处理

**汇编代码：** `resume.S` (关键片段)

```assembly
rt_hw_context_switch_to:
    /* 设置MSP回到初始值（仅第一次线程切换时） */
    ldr r1, =SCB_VTOR
    ldr r1, [r1]
    ldr r0, [r1]
    msr msp, r0  /* 从向量表恢复MSP */
    
    /* 切换到第一个线程 */
    /* ... */
```

**行为分析：**
1. **复位后**：MSP = `_estack` (0x200A0000)
2. **初始化阶段**：MSP可能被临时使用，可能向下生长
3. **首次线程切换**：RT-Thread显式恢复MSP到`_estack`
4. **后续异常**：MSP继续从`_estack`向下生长
5. **后续线程切换**：不修改MSP，保持当前值

## 风险分析与缓解

### 潜在风险

1. **MSP栈溢出**
   - **场景**：深度中断嵌套或大型局部变量
   - **后果**：破坏保护区域，可能破坏RT-Thread堆
   - **检测**：保护区域魔数检查
   - **缓解**：32KB栈空间足够多数应用；监控保护区域

2. **C库堆耗尽**
   - **场景**：大量使用C库动态内存
   - **后果**：`malloc()`返回NULL
   - **缓解**：16KB对C库使用足够；考虑使用RT-Thread堆替代

3. **RT-Thread堆碎片化**
   - **场景**：长期运行，频繁分配释放不同大小内存
   - **后果**：分配失败即使总空闲内存足够
   - **缓解**：576KB提供充足空间；使用内存池固定大小块

4. **隔离缓冲区不足**
   - **场景**：C库堆或RT-Thread堆越界
   - **后果**：破坏相邻区域
   - **缓解**：4KB缓冲区提供足够安全边际

### 安全边界计算

```
C库堆最大可能溢出: 16KB (实际分配不应超过此值)
隔离缓冲区: 4KB
RT-Thread堆与保护区域距离: 576KB + 4KB = 580KB

最坏情况: C库堆完全溢出需超过580KB才能破坏保护区域
实际可能性: 极低
```

## 关键符号参考

| 符号 | 地址（十六进制） | 描述 |
|------|------------------|------|
| `_end` / `end` | 0x2000 1210 | C库堆起始地址 |
| `_heap_limit` | 0x2000 5210 | C库堆结束地址 |
| `_rt_heap_boundary` | 0x2000 6210 | RT-Thread堆边界 |
| `_rt_heap_start` / `rt_heap` | 0x2000 7210 | RT-Thread堆起始 |
| `_rt_heap_end` | 0x2009 7210 | RT-Thread堆结束 |
| `_rt_heap_section_start` | 0x2000 7210 | RT-Thread堆段起始 |
| `_rt_heap_section_end` | 0x2009 7210 | RT-Thread堆段结束 |
| `_msp_stack_protection_start` | 0x2009 7210 | MSP保护区域起始 |
| `_msp_stack_protection_end` | 0x2009 8210 | MSP保护区域结束 |
| `_estack` | 0x200A 0000 | 初始MSP值（RAM顶部） |

## 验证与测试

### 构建时验证

```bash
# 生成内存映射文件
make clean && make

# 查看关键符号地址
arm-none-eabi-nm -n build/embedded_framework.elf | grep -E "_end|_heap_limit|_rt_heap|_msp_stack_protection|_estack"
```

### 运行时测试

参考测试应用：`app/your_app.c`

**测试项目：**
1. **C库堆分配**：验证`malloc()`/`free()`正常工作
2. **RT-Thread堆分配**：验证`rt_malloc()`/`rt_free()`正常工作
3. **保护区域检查**：验证魔数完整性
4. **边界测试**：尝试分配超过可用内存，验证错误处理

### 监控建议

1. **定期检查**：应用程序周期验证保护区域
2. **使用统计**：监控堆使用率，避免耗尽
3. **栈水印**：可添加栈使用量监测

## 配置调整

### 修改堆大小

**C库堆大小：** 修改`framework/linker/rtthread/rtthread.ld`
```ld
_Min_Heap_Size = 0x8000;  /* 改为32KB */
```

**RT-Thread堆大小：** 修改`third_party/rt-thread/src/board.c`
```c
#define RT_HEAP_SIZE (640 * 1024 - 32 * 1024)  /* 改为608KB */
```

### 修改保护区域大小

**链接器脚本：**
```ld
_MSP_Stack_Protection_Size = 0x2000;  /* 改为8KB */
```

### 注意事项

1. **总RAM限制**：640KB，所有区域总和不能超过此值
2. **对齐要求**：地址保持8字节对齐优化性能
3. **重置验证**：修改后务必验证完整内存布局

## 故障排查

### 常见问题

1. **分配失败**
   - 检查对应堆的使用情况
   - 验证堆边界是否正确

2. **保护区域损坏**
   - 检查MSP栈使用深度
   - 审查中断处理函数栈使用

3. **链接错误**
   - 验证链接器脚本语法
   - 检查段重叠警告

### 调试工具

1. **map文件分析**：`build/embedded_framework.map`
2. **elf文件检查**：`arm-none-eabi-objdump -h build/embedded_framework.elf`
3. **运行时输出**：通过串口输出内存统计信息

---

**文档版本：** 1.0  
**最后更新：** 2025-02-21  
**相关文档：** [initialization_flow.md](initialization_flow.md)（系统初始化流程）