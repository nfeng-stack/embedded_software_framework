# 跌倒检测→紧急推送 功能流程图

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#0f3460','primaryTextColor': '#eaeaea','primaryBorderColor': '#16c79a','lineColor': '#16c79a','tertiaryColor': '#16213e','fontSize': '14px','fontFamily': 'system-ui'}}}%%
flowchart TB
  subgraph S1["阶段一：自由落体触发"]
    direction LR
    START([系统运行中])
    MPU[MPU6050 自由落体监测<br/>阈值 700mg，持续 1ms]
    FF{合加速度<br/>低于阈值?}
  end

  subgraph S2["阶段二：数据采集与量化"]
    direction RL
    STORE[写入 W25Qxx Flash<br/>FATFS 文件系统]
    QUANT[量化归一化<br/>±16g / ±2000°/s → 0~255]
    COLLECT[采集 200 组六轴数据<br/>加速度 xyz + 陀螺仪 xyz<br/>DATA_READY 中断循环驱动]
  end

  subgraph S3["阶段三：AI 推理与报警"]
    direction LR
    INFER[CNN 前向推理<br/>Conv3→32→64 + MaxPool<br/>FC 1600→512→2 + Softmax<br/>Cortex-M33 + FPU]
    AI{Softmax 概率<br/>> 0.5?}
    ALARM[声光报警启动<br/>PA5 HIGH: LED + 蜂鸣器<br/>释放信号量 at_sem]
  end

  subgraph S4["阶段四：30 秒误报取消"]
    direction RL
    GPS_START[进入推送流程]
    CANCEL{is_send_msg<br/>== 1?}
    WAIT30[等待 30 秒<br/>osal_task_delay 30000ms]
  end

  subgraph S5["阶段五：定位与微信推送"]
    direction LR
    GPS[AT 指令获取定位<br/>AT+QGPSGNMEA='RMC'<br/>NMEA 协议解析]
    GEOCODE[HTTPS GET 高德逆地理编码<br/>restapi.amap.com/v3/geocode<br/>cJSON 提取 formatted_address]
    BUILD[组装报警消息<br/>地址 + 经纬度 + 时间戳]
    PUSH[HTTPS GET 巴法云 API<br/>微信消息推送<br/>apis.bemfa.com]
    END_NODE([监护人微信收到报警])
  end

  BUTTON_ISR[按钮中断 PB3<br/>EXTI3_IRQHandler<br/>is_send_msg = 0<br/>关灯灭蜂鸣]:::annotation

  %% ---------- 主流程边 ----------
  START --> MPU
  MPU --> FF
  FF -->|否| MPU
  FF -->|是, 触发 EXTI15| COLLECT
  COLLECT --> QUANT
  COLLECT --> STORE
  STORE --> INFER
  QUANT --> INFER
  INFER --> AI
  AI -->|否| MPU
  AI -->|是| ALARM
  ALARM --> WAIT30
  WAIT30 --> CANCEL
  CANCEL -->|是, 已取消| MPU
  CANCEL -->|否, 超时| GPS_START
  GPS_START --> GPS
  GPS --> GEOCODE
  GEOCODE --> BUILD
  BUILD --> PUSH
  PUSH --> END_NODE

  %% ---------- 侧边注释：异步中断 ----------
  BUTTON_ISR -.-> CANCEL

  %% ---------- 样式定义 ----------
  classDef startStyle fill:#0f3460,stroke:#16c79a,stroke-width:2px,color:#eaeaea
  classDef processStyle fill:#16213e,stroke:#16c79a,stroke-width:2px,color:#eaeaea
  classDef decisionStyle fill:#1a1a2e,stroke:#e94560,stroke-width:2px,color:#eaeaea
  classDef alarmStyle fill:#e94560,stroke:#e94560,stroke-width:3px,color:#fff
  classDef storeStyle fill:#533483,stroke:#16c79a,stroke-width:2px,color:#eaeaea
  classDef endStyle fill:#0f3460,stroke:#16c79a,stroke-width:2px,color:#16c79a
  classDef annotation fill:#2d3436,stroke:#636e72,stroke-width:1px,stroke-dasharray:4 4,color:#b2bec3,font-size:12px

  class START,END_NODE endStyle
  class MPU,COLLECT,QUANT,INFER,GPS,GEOCODE,BUILD,PUSH,GPS_START processStyle
  class FF,AI,CANCEL decisionStyle
  class ALARM alarmStyle
  class STORE storeStyle
  class BUTTON_ISR annotation
```

## 图片生成方式

### 方案 A：在线编辑器（推荐，无需安装）

1. 打开浏览器访问 **[Mermaid Live Editor](https://mermaid.live)**
2. 将上方 `flowchart TB ...` 代码块内的内容完整粘贴到编辑器左侧输入区（不含 3 个反引号的行）
3. 右侧将实时预览流程图效果
4. 点击顶部工具栏 **"Actions"** → 选择 **"Export as PNG"** 或 **"Export as SVG"**
5. 调整导出分辨率建议：**宽度 2400px**，**缩放 2x**（保证论文 300dpi 印刷效果）

> **注意**：Mermaid Live 导出 PNG 时，请在弹出的设置框中设置 `scale` 为 `2` 或 `3`，以获得高清图片。

### 方案 B：命令行工具（适合批量生成）

```bash
# 安装 mermaid-cli
npm install -g @mermaid-js/mermaid-cli

# 从当前 .md 文件生成 PNG
mmdc -i fall_detection_flowchart.md -o fall_detection_flowchart.png \
     -w 2400 -H 3600 --scale 2 \
     -p /dev/null \
     --backgroundColor "#1a1a2e"

# 如需 SVG（矢量，缩放不失真）
mmdc -i fall_detection_flowchart.md -o fall_detection_flowchart.svg -w 2400
```

> `-w/--width` 和 `-H/--height` 控制输出画布大小，`--scale` 为 2x 超采样。

### 方案 C：VS Code 插件

1. 安装插件 **"Markdown Preview Mermaid Support"**（作者：bierner）
2. 在当前 `.md` 文件的 Mermaid 代码块上，按 `Ctrl+Shift+P`
3. 选择 **"Markdown: Open Preview to the Side"** 查看预览
4. 右键预览区 → **Save Image As...** 导出 PNG

> **推荐组合**：开发调试使用 VS Code 插件预览 → 最终交付使用 **方案 A**（Mermaid Live）导出高分辨率 PNG。

---

## 流程图节点说明

| 阶段 | 节点 | 说明 | 对应源代码 |
|------|------|------|-----------|
| **阶段一：自由落体触发** | MPU6050 监测 → 硬件中断 | MPU6050 内部 DSP 实时计算合加速度，低于 700mg 持续 1ms 时 INT 引脚输出低电平，触发 STM32 EXTI15 中断。`exit_callback` 在 ISR 上下文释放 `mpu_sem` 唤醒 MPU 线程 | `mpu6050_wrap.c:126` INT_STATUS bit7 判定 |
| **阶段二：数据采集与量化** | 200 组 6 轴采集 → Flash 写入 + 量化归一化 | MPU 线程检测 FREE_FALL 位后，关闭 FREE 中断、使能 DATA_READY 中断。每收到一次 EXTI15 中断读取 1 组六轴数据，循环 200 次。满后关闭中断、写入 Flash、量化数据至 `net_data[200][6]`，最后释放 `ai_sem` 唤醒 AI 线程 | `mpu6050_wrap.c:135-158`（采集循环 + 满缓冲处理） |
| **阶段三：AI 推理与报警** | CNN 推理 → Softmax 判定 | AI 线程从 `ai_sem` 唤醒后，调用 FD-CNN 网络前向推理。`post_process` 计算 Softmax 概率，`prob_fall > 0.5` 即判定跌倒。若跌倒：`is_send_msg=1`，PA5 输出 HIGH 开启 LED+蜂鸣器，释放 `at_sem` 唤醒 AT 线程 | `ai_task.c:22-29`（判决 + 报警）；`app_x-cube-ai.c:221`（prob_fall 阈值） |
| **阶段四：30 秒误报取消** | 30 秒延迟 → 按键作废检查 | AT 线程从 `at_sem` 唤醒后立即执行 `osal_task_delay(30000)` 等待 30 秒。期间若用户按下 PB3 按钮，`EXTI3_IRQHandler` 异步执行 `is_send_msg=0` 并关闭 LED/蜂鸣器。30 秒后检查 `is_send_msg`：0 表示已取消，复位标志并回到等待状态；1 表示超时未取消，进入推送流程 | `at_task.c:233-234`（延迟 + 检查）；`platform_gpio_driver.c:119`（EXTI3 ISR） |
| **阶段五：定位与微信推送** | AT GPS → 高德逆地理编码 → 巴法云推送 | `at_get_location()` 发送 AT+QGPSGNMEA='RMC' 并手写 NMEA 解析器提取十进制度经纬度。`query_geocode()` 通过 HTTPS GET 调用高德逆地理编码 API（`restapi.amap.com`），cJSON 解析返回的 `formatted_address`。组装"地址+经纬度+时间戳"消息后，通过 HTTPS GET 巴法云 API 推送到监护人微信 | `at_command.c:727`（GPS+NMEA）；`at_task.c:157`（地理编码）；`at_command.c:1115`（巴法云推送） |
