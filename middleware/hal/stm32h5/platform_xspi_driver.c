#include "stm32h5xx_hal.h"
#include "stm32h5xx_hal_xspi.h"


XSPI_HandleTypeDef hospi1 = {0};
void HAL_XSPI_MspInit(XSPI_HandleTypeDef *hxspi) {
  GPIO_InitTypeDef GPIO_InitStruct = {0};
  RCC_PeriphCLKInitTypeDef PeriphClkInitStruct = {0};

  if (hxspi->Instance == OCTOSPI1) {
    // 时钟源：请根据您的实际时钟树配置
    PeriphClkInitStruct.PeriphClockSelection = RCC_PERIPHCLK_OSPI;
    PeriphClkInitStruct.OspiClockSelection = RCC_OSPICLKSOURCE_PLL1Q;
    if (HAL_RCCEx_PeriphCLKConfig(&PeriphClkInitStruct) != HAL_OK) {

    }

    __HAL_RCC_OSPI1_CLK_ENABLE();
    __HAL_RCC_GPIOC_CLK_ENABLE();
    __HAL_RCC_GPIOA_CLK_ENABLE();
    __HAL_RCC_GPIOB_CLK_ENABLE();

    // 配置 IO0~IO3, CLK, NCS
    GPIO_InitStruct.Mode = GPIO_MODE_AF_PP;
    GPIO_InitStruct.Pull = GPIO_NOPULL;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_VERY_HIGH;
    GPIO_InitStruct.Alternate = GPIO_AF9_OCTOSPI1;

    GPIO_InitStruct.Pin = GPIO_PIN_2 | GPIO_PIN_3; // PC2(IO2), PC3(IO0)
    HAL_GPIO_Init(GPIOC, &GPIO_InitStruct);
    GPIO_InitStruct.Pin = GPIO_PIN_1; // PA1(IO3)
    HAL_GPIO_Init(GPIOA, &GPIO_InitStruct);
    GPIO_InitStruct.Pin = GPIO_PIN_0; // PB0(IO1)
    GPIO_InitStruct.Alternate = GPIO_AF6_OCTOSPI1;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
    GPIO_InitStruct.Pin = GPIO_PIN_2 | GPIO_PIN_10; // PB2(CLK), PB10(NCS)
    GPIO_InitStruct.Alternate = GPIO_AF9_OCTOSPI1;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
  }
}

/* ======================== 高层 API ======================== */
int32_t platform_xspi_init(void) {

  hospi1.Instance = OCTOSPI1;
  hospi1.Init.ClockPrescaler = 1;
  hospi1.Init.FifoThresholdByte = 4;
  hospi1.Init.MemoryType = HAL_XSPI_MEMTYPE_MICRON; // 可改为 MICRON
  hospi1.Init.MemorySize = HAL_XSPI_SIZE_128MB;
  hospi1.Init.ChipSelectHighTimeCycle = 2;
  hospi1.Init.FreeRunningClock = HAL_XSPI_FREERUNCLK_DISABLE;
  hospi1.Init.ClockMode = HAL_XSPI_CLOCK_MODE_0;
  hospi1.Init.WrapSize = HAL_XSPI_WRAP_NOT_SUPPORTED;
  hospi1.Init.SampleShifting = HAL_XSPI_SAMPLE_SHIFT_NONE;
  hospi1.Init.DelayHoldQuarterCycle = HAL_XSPI_DHQC_DISABLE;
  hospi1.Init.ChipSelectBoundary = HAL_XSPI_BONDARYOF_NONE;
  hospi1.Init.DelayBlockBypass = HAL_XSPI_DELAY_BLOCK_ON;
  hospi1.Init.Refresh = 0;

  if (HAL_XSPI_Init(&hospi1) != HAL_OK) {
    return -1;
  }

  return 0;
}



int32_t platform_xspi_single_read(uint8_t instruction, uint32_t addr, uint8_t *data,
                                   uint32_t size) {
  XSPI_RegularCmdTypeDef cmd = {0};
  cmd.OperationType = HAL_XSPI_OPTYPE_COMMON_CFG;
  cmd.InstructionMode = HAL_XSPI_INSTRUCTION_1_LINE;
  cmd.Instruction = instruction;
  cmd.AddressMode = HAL_XSPI_ADDRESS_1_LINE;
  cmd.AddressWidth = HAL_XSPI_ADDRESS_24_BITS;
  cmd.Address = addr;
  cmd.AlternateBytesMode = HAL_XSPI_ALT_BYTES_NONE;
  cmd.DataMode = HAL_XSPI_DATA_1_LINE;
  cmd.DataLength = size;
  cmd.DummyCycles = 0;
  cmd.DQSMode = HAL_XSPI_DQS_DISABLE;
  cmd.SIOOMode = HAL_XSPI_SIOO_INST_EVERY_CMD;

  if (HAL_XSPI_Command(&hospi1, &cmd, HAL_MAX_DELAY) != HAL_OK)
    return -1;
  return HAL_XSPI_Receive(&hospi1, data, HAL_MAX_DELAY) != HAL_OK ? -1 : 0;
}

int32_t platform_xspi_single_write(uint8_t instruction,uint32_t addr, uint8_t *data,
                                    uint32_t size) {

  XSPI_RegularCmdTypeDef cmd = {0};
  cmd.OperationType = HAL_XSPI_OPTYPE_COMMON_CFG;
  cmd.InstructionMode = HAL_XSPI_INSTRUCTION_1_LINE;
  cmd.Instruction = instruction;
  cmd.AddressMode = HAL_XSPI_ADDRESS_1_LINE;
  cmd.AddressWidth = HAL_XSPI_ADDRESS_24_BITS;
  cmd.Address = addr;
  cmd.AlternateBytesMode = HAL_XSPI_ALT_BYTES_NONE;
  cmd.DataMode = HAL_XSPI_DATA_1_LINE;
  cmd.DataLength = size;
  cmd.DummyCycles = 0;
  cmd.DQSMode = HAL_XSPI_DQS_DISABLE;
  cmd.SIOOMode = HAL_XSPI_SIOO_INST_EVERY_CMD;

  if (HAL_XSPI_Command(&hospi1, &cmd, HAL_MAX_DELAY) != HAL_OK)
    return -1;
  if (HAL_XSPI_Transmit(&hospi1, data, HAL_MAX_DELAY) != HAL_OK)
    return -1;
  return 0;
}

int32_t platform_xspi_quad_read(uint8_t instruction,uint32_t addr, uint8_t *data, uint32_t size) {
  XSPI_RegularCmdTypeDef cmd = {0};

  cmd.OperationType = HAL_XSPI_OPTYPE_COMMON_CFG;
  cmd.InstructionMode = HAL_XSPI_INSTRUCTION_1_LINE; // 指令通过 1 线发送
  cmd.Instruction = instruction;             // 0xEB

  cmd.AddressMode =
      HAL_XSPI_ADDRESS_4_LINES; // !!!! 关键修改1：地址也用 4 线发送 !!!!
  cmd.AddressWidth = HAL_XSPI_ADDRESS_24_BITS;
  cmd.Address = addr;

  // !!!! 关键修改2：禁用模式位 !!!!
  cmd.AlternateBytesMode = HAL_XSPI_ALT_BYTES_NONE;
  cmd.DataMode = HAL_XSPI_DATA_4_LINES; // 数据用 4 线接收
  cmd.DataLength = size;

  cmd.DummyCycles = 6;

  cmd.DQSMode = HAL_XSPI_DQS_DISABLE;
  cmd.SIOOMode = HAL_XSPI_SIOO_INST_EVERY_CMD;

  if (HAL_XSPI_Command(&hospi1, &cmd, HAL_MAX_DELAY) != HAL_OK) {
    return -1;
  }
  return HAL_XSPI_Receive(&hospi1, data, HAL_MAX_DELAY) != HAL_OK ? -1 : 0;
}

int32_t platform_xspi_quad_write(uint8_t instruction,uint32_t addr, uint8_t *data, uint32_t size) {
 
  XSPI_RegularCmdTypeDef cmd = {0};
  cmd.OperationType = HAL_XSPI_OPTYPE_COMMON_CFG;
  cmd.InstructionMode = HAL_XSPI_INSTRUCTION_1_LINE;
  cmd.Instruction = instruction;
  cmd.AddressMode = HAL_XSPI_ADDRESS_1_LINE;
  cmd.AddressWidth = HAL_XSPI_ADDRESS_24_BITS;
  cmd.Address = addr;
  cmd.AlternateBytesMode = HAL_XSPI_ALT_BYTES_NONE;
  cmd.DataMode = HAL_XSPI_DATA_4_LINES;
  cmd.DataLength = size;
  cmd.DummyCycles = 0;
  cmd.DQSMode = HAL_XSPI_DQS_DISABLE;
  cmd.SIOOMode = HAL_XSPI_SIOO_INST_EVERY_CMD;

  if (HAL_XSPI_Command(&hospi1, &cmd, HAL_MAX_DELAY) != HAL_OK)
    return -1;
  if (HAL_XSPI_Transmit(&hospi1, data, HAL_MAX_DELAY) != HAL_OK)
    return -1;
  return 0;
}

static uint32_t map_line_to_instruction_mode(uint8_t line)
{
    switch (line) {
        case 0:  return HAL_XSPI_INSTRUCTION_NONE;
        case 1:  return HAL_XSPI_INSTRUCTION_1_LINE;
        case 2:  return HAL_XSPI_INSTRUCTION_2_LINES;
        case 4:  return HAL_XSPI_INSTRUCTION_4_LINES;
        case 8:  return HAL_XSPI_INSTRUCTION_8_LINES;
        default: return HAL_XSPI_INSTRUCTION_1_LINE;
    }
}

static uint32_t map_line_to_address_mode(uint8_t line)
{
    switch (line) {
        case 0:  return HAL_XSPI_ADDRESS_NONE;
        case 1:  return HAL_XSPI_ADDRESS_1_LINE;
        case 2:  return HAL_XSPI_ADDRESS_2_LINES;
        case 4:  return HAL_XSPI_ADDRESS_4_LINES;
        case 8:  return HAL_XSPI_ADDRESS_8_LINES;
        default: return HAL_XSPI_ADDRESS_1_LINE;
    }
}

static uint32_t map_line_to_alternate_mode(uint8_t line)
{
    switch (line) {
        case 0:  return HAL_XSPI_ALT_BYTES_NONE;
        case 1:  return HAL_XSPI_ALT_BYTES_1_LINE;
        case 2:  return HAL_XSPI_ALT_BYTES_2_LINES;
        case 4:  return HAL_XSPI_ALT_BYTES_4_LINES;
        case 8:  return HAL_XSPI_ALT_BYTES_8_LINES;
        default: return HAL_XSPI_ALT_BYTES_1_LINE;
    }
}

static uint32_t map_line_to_data_mode(uint8_t line)
{
    switch (line) {
        case 0:  return HAL_XSPI_DATA_NONE;
        case 1:  return HAL_XSPI_DATA_1_LINE;
        case 2:  return HAL_XSPI_DATA_2_LINES;
        case 4:  return HAL_XSPI_DATA_4_LINES;
        case 8:  return HAL_XSPI_DATA_8_LINES;
        default: return HAL_XSPI_DATA_1_LINE;
    }
}

/**
 * @brief  将地址长度 (字节数) 转换为 HAL XSPI 地址宽度
 * @param  len : 地址字节数 (3 或 4)
 * @retval HAL 地址宽度
 */
static uint32_t map_address_len_to_width(uint8_t len)
{
    if (len == 3) return HAL_XSPI_ADDRESS_24_BITS;
    if (len == 4) return HAL_XSPI_ADDRESS_32_BITS;
    return HAL_XSPI_ADDRESS_24_BITS; /* 默认 24 位 */
}

/**
 * @brief  将交替字节长度 (字节数) 转换为 HAL XSPI 交替字节大小
 * @param  len : 交替字节长度 (字节数)
 * @retval HAL 交替字节大小
 */
static uint32_t map_alternate_len_to_size(uint8_t len)
{
    if (len == 1) return HAL_XSPI_ALT_BYTES_8_BITS;
    if (len == 2) return HAL_XSPI_ALT_BYTES_16_BITS;
    if (len == 3) return HAL_XSPI_ALT_BYTES_24_BITS;
    if (len == 4) return HAL_XSPI_ALT_BYTES_32_BITS;
    return HAL_XSPI_ALT_BYTES_8_BITS; /* 默认 8 位 */
}

/**
 * @brief  通用 QSPI 命令执行（支持任意指令、地址、交替字节、哑周期、数据收发）
 */
uint8_t platform_xspi_write_read(uint8_t instruction, uint8_t instruction_line,
                                             uint32_t address, uint8_t address_line, uint8_t address_len,
                                             uint32_t alternate, uint8_t alternate_line, uint8_t alternate_len,
                                             uint8_t dummy, uint8_t *in_buf, uint32_t in_len,
                                             uint8_t *out_buf, uint32_t out_len, uint8_t data_line)
{
    XSPI_RegularCmdTypeDef cmd = {0};

    /* 基本配置 */
    cmd.OperationType      = HAL_XSPI_OPTYPE_COMMON_CFG;
    cmd.InstructionMode    = map_line_to_instruction_mode(instruction_line);
    cmd.Instruction        = instruction;
    cmd.AddressMode        = map_line_to_address_mode(address_line);
    cmd.AddressWidth       = map_address_len_to_width(address_len);
    cmd.Address            = address;
    cmd.AlternateBytesMode = map_line_to_alternate_mode(alternate_line);
    cmd.AlternateBytesWidth = map_alternate_len_to_size(alternate_len);
    cmd.AlternateBytes     = alternate;
    cmd.DataMode           = map_line_to_data_mode(data_line);
    cmd.DummyCycles        = dummy;
    cmd.DQSMode            = HAL_XSPI_DQS_DISABLE;
    cmd.SIOOMode           = HAL_XSPI_SIOO_INST_EVERY_CMD;

    /* 根据实际数据流向决定数据长度和后续动作 */
    if (in_len > 0 && out_len > 0) {
        /* 理论上 W25QXX 驱动不会同时要求收发，若出现，仅处理发送或接收其一 */
        return 1;
    }

    if (in_len > 0) {
        cmd.DataLength = in_len;
        if (HAL_XSPI_Command(&hospi1, &cmd, HAL_MAX_DELAY) != HAL_OK)
            return 1;
        if (HAL_XSPI_Transmit(&hospi1, in_buf, HAL_MAX_DELAY) != HAL_OK)
            return 1;
    } else if (out_len > 0) {
        cmd.DataLength = out_len;
        if (HAL_XSPI_Command(&hospi1, &cmd, HAL_MAX_DELAY) != HAL_OK)
            return 1;
        if (HAL_XSPI_Receive(&hospi1, out_buf, HAL_MAX_DELAY) != HAL_OK)
            return 1;
    } else {
        /* 只有命令、地址、交替字节、哑周期，无数据阶段 */
        cmd.DataLength = 0;
        if (HAL_XSPI_Command(&hospi1, &cmd, HAL_MAX_DELAY) != HAL_OK)
            return 1;
    }

    return 0;
}


