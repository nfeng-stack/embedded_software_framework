#include "stm32h5xx_hal.h"

static I2C_HandleTypeDef hi2c1;
void platform_iic_init(void)
{
    /* 使能GPIOB和I2C1时钟 */
    __HAL_RCC_GPIOB_CLK_ENABLE();
    __HAL_RCC_I2C1_CLK_ENABLE();
    
    /* GPIO配置: PB6->SCL, PB7->SDA */
    GPIO_InitTypeDef GPIO_InitStruct = {0};
    
    /* SCL引脚配置 */
    GPIO_InitStruct.Pin = GPIO_PIN_6;
    GPIO_InitStruct.Mode = GPIO_MODE_AF_OD;
    GPIO_InitStruct.Pull = GPIO_PULLUP;
    GPIO_InitStruct.Speed = GPIO_SPEED_FREQ_HIGH;
    GPIO_InitStruct.Alternate = GPIO_AF4_I2C1;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
    
    /* SDA引脚配置 */
    GPIO_InitStruct.Pin = GPIO_PIN_7;
    HAL_GPIO_Init(GPIOB, &GPIO_InitStruct);
    
    /* I2C1配置 */
    hi2c1.Instance = I2C1;
    hi2c1.Init.Timing = 0x30114D4D;  /* 400kHz (250MHz APB1, PRESC=3, SCLDEL=1, SDADEL=1, SCLH=77, SCLL=77) */
    /* Calculated for 400kHz based on 250MHz APB1 clock */
    hi2c1.Init.OwnAddress1 = 0;
    hi2c1.Init.AddressingMode = I2C_ADDRESSINGMODE_7BIT;
    hi2c1.Init.DualAddressMode = I2C_DUALADDRESS_DISABLE;
    hi2c1.Init.OwnAddress2 = 0;
    hi2c1.Init.OwnAddress2Masks = I2C_OA2_NOMASK;
    hi2c1.Init.GeneralCallMode = I2C_GENERALCALL_DISABLE;
    hi2c1.Init.NoStretchMode = I2C_NOSTRETCH_DISABLE;
    
    if (HAL_I2C_Init(&hi2c1) != HAL_OK)
    {
        // Error_Handler();
    }
    
    /* 配置I2C时序 */
    if (HAL_I2CEx_ConfigAnalogFilter(&hi2c1, I2C_ANALOGFILTER_ENABLE) != HAL_OK)
    {
        // Error_Handler();
    }
    
    if (HAL_I2CEx_ConfigDigitalFilter(&hi2c1, 0) != HAL_OK)
    {
        // Error_Handler();
    }

}

/**
 * @brief      interface iic bus read
 * @param[in]  addr iic device write address
 * @param[in]  reg iic register address
 * @param[out] *buf pointer to a data buffer
 * @param[in]  len length of the data buffer
 * @return     status code
 *             - 0 success
 *             - 1 read failed
 * @note       none
 */
uint8_t platform_iic_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len)
{
     HAL_StatusTypeDef status;
    
    status = HAL_I2C_Mem_Read(&hi2c1, addr, reg, 
                              I2C_MEMADD_SIZE_8BIT, buf, len, 100);
    if (status != HAL_OK)
    {
        return 1;
    }
    
    return 0;
}

/**
 * @brief     interface iic bus write
 * @param[in] addr iic device write address
 * @param[in] reg iic register address
 * @param[in] *buf pointer to a data buffer
 * @param[in] len length of the data buffer
 * @return    status code
 *            - 0 success
 *            - 1 write failed
 * @note      none
 */
uint8_t platform_iic_write(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len)
{
    HAL_StatusTypeDef status;
    
    status = HAL_I2C_Mem_Write(&hi2c1, addr, reg,
                               I2C_MEMADD_SIZE_8BIT, buf, len, 100);
    
    if (status != HAL_OK)
    {
        return 1;
    }
    
    return 0;
}