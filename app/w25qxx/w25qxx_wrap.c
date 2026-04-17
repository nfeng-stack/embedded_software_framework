#include "driver_w25qxx.h"
#include "driver_w25qxx_advance.h"
#include <stdint.h>
#define LOG_TAG "w25q"
#include "elog.h"
#include "osal.h"

int32_t w25xx_test(void) {
  log_e("start init w25q\n");
  if (w25qxx_advance_init(W25Q128, W25QXX_INTERFACE_SPI, W25QXX_BOOL_TRUE) !=
      0) {
    log_e("w25qxx init error\n");
  }
  log_e("w25qxx init ok\n");
  uint8_t buf[128] = {0};
  w25qxx_advance_only_spi_fast_read_quad_io(0, buf, 128);
  for(int i = 0 ; i < 128 ; i++)
  {

    log_e("position:%d,value:%d\n",i,buf[i]);
    buf[i] += buf[i] ; 
    osal_task_delay(1);
  }
  w25qxx_advance_sector_erase_4k(0);
  w25qxx_advance_only_spi_page_program_quad_input(0, buf, 128);
  w25qxx_advance_only_spi_fast_read_quad_io(0, buf, 128);
  for(int i = 0 ; i < 128 ; i++)
  {

    log_e("position:%d,value:%d\n",i,buf[i]);
    buf[i] += buf[i] ; 
    osal_task_delay(1);
  }
  return 0;
}