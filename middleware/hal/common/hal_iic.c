#include "hal_common.h"
#include "platform_driver.h"

void hal_common_iic_init(void)
{
    platform_iic_init();
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
uint8_t hal_common_iic_read(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len)
{
    return platform_iic_read( addr,  reg,  buf,  len);
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
uint8_t hal_common_iic_write(uint8_t addr, uint8_t reg, uint8_t *buf, uint16_t len)
{
    return platform_iic_write(addr,reg,buf,len);
}

