#include "platform_driver.h"

int32_t hal_xspi_init(void)
{
    return platform_xspi_init();
}
uint8_t hal_xspi_write_read(uint8_t instruction, uint8_t instruction_line,
                                             uint32_t address, uint8_t address_line, uint8_t address_len,
                                             uint32_t alternate, uint8_t alternate_line, uint8_t alternate_len,
                                             uint8_t dummy, uint8_t *in_buf, uint32_t in_len,
                                             uint8_t *out_buf, uint32_t out_len, uint8_t data_line)
{
    return platform_xspi_write_read(instruction,  instruction_line,
                             address, address_line, address_len,
                             alternate, alternate_line, alternate_len,
                             dummy, in_buf, in_len,
                             out_buf, out_len, data_line);
}
