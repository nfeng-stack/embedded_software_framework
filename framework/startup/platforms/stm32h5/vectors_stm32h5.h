/**
 * @file    vectors_stm32h5.h
 * @brief   STM32H5 Interrupt Vector Table Definitions
 * 
 * This file contains the interrupt vector table entries for STM32H5 series.
 * It should be included in the vector table array in startup.c.
 * 
 * @note    Based on STM32H563xx vector table from startup_stm32h563xx.s
 */

#ifndef VECTORS_STM32H5_H
#define VECTORS_STM32H5_H

/* External interrupt handler declarations (weak symbols defined elsewhere) */
void WWDG_IRQHandler(void);
void PVD_AVD_IRQHandler(void);
void RTC_IRQHandler(void);
void RTC_S_IRQHandler(void);
void TAMP_IRQHandler(void);
void RAMCFG_IRQHandler(void);
void FLASH_IRQHandler(void);
void FLASH_S_IRQHandler(void);
void GTZC_IRQHandler(void);
void RCC_IRQHandler(void);
void RCC_S_IRQHandler(void);
void EXTI0_IRQHandler(void);
void EXTI1_IRQHandler(void);
void EXTI2_IRQHandler(void);
void EXTI3_IRQHandler(void);
void EXTI4_IRQHandler(void);
void EXTI5_IRQHandler(void);
void EXTI6_IRQHandler(void);
void EXTI7_IRQHandler(void);
void EXTI8_IRQHandler(void);
void EXTI9_IRQHandler(void);
void EXTI10_IRQHandler(void);
void EXTI11_IRQHandler(void);
void EXTI12_IRQHandler(void);
void EXTI13_IRQHandler(void);
void EXTI14_IRQHandler(void);
void EXTI15_IRQHandler(void);
void GPDMA1_Channel0_IRQHandler(void);
void GPDMA1_Channel1_IRQHandler(void);
void GPDMA1_Channel2_IRQHandler(void);
void GPDMA1_Channel3_IRQHandler(void);
void GPDMA1_Channel4_IRQHandler(void);
void GPDMA1_Channel5_IRQHandler(void);
void GPDMA1_Channel6_IRQHandler(void);
void GPDMA1_Channel7_IRQHandler(void);
void IWDG_IRQHandler(void);
void ADC1_IRQHandler(void);
void DAC1_IRQHandler(void);
void FDCAN1_IT0_IRQHandler(void);
void FDCAN1_IT1_IRQHandler(void);
void TIM1_BRK_IRQHandler(void);
void TIM1_UP_IRQHandler(void);
void TIM1_TRG_COM_IRQHandler(void);
void TIM1_CC_IRQHandler(void);
void TIM2_IRQHandler(void);
void TIM3_IRQHandler(void);
void TIM4_IRQHandler(void);
void TIM5_IRQHandler(void);
void TIM6_IRQHandler(void);
void TIM7_IRQHandler(void);
void I2C1_EV_IRQHandler(void);
void I2C1_ER_IRQHandler(void);
void I2C2_EV_IRQHandler(void);
void I2C2_ER_IRQHandler(void);
void SPI1_IRQHandler(void);
void SPI2_IRQHandler(void);
void SPI3_IRQHandler(void);
void USART1_IRQHandler(void);
void USART2_IRQHandler(void);
void USART3_IRQHandler(void);
void UART4_IRQHandler(void);
void UART5_IRQHandler(void);
void LPUART1_IRQHandler(void);
void LPTIM1_IRQHandler(void);
void TIM8_BRK_IRQHandler(void);
void TIM8_UP_IRQHandler(void);
void TIM8_TRG_COM_IRQHandler(void);
void TIM8_CC_IRQHandler(void);
void ADC2_IRQHandler(void);
void LPTIM2_IRQHandler(void);
void TIM15_IRQHandler(void);
void TIM16_IRQHandler(void);
void TIM17_IRQHandler(void);
void USB_DRD_FS_IRQHandler(void);
void CRS_IRQHandler(void);
void UCPD1_IRQHandler(void);
void FMC_IRQHandler(void);
void OCTOSPI1_IRQHandler(void);
void SDMMC1_IRQHandler(void);
void I2C3_EV_IRQHandler(void);
void I2C3_ER_IRQHandler(void);
void SPI4_IRQHandler(void);
void SPI5_IRQHandler(void);
void SPI6_IRQHandler(void);
void USART6_IRQHandler(void);
void USART10_IRQHandler(void);
void USART11_IRQHandler(void);
void SAI1_IRQHandler(void);
void SAI2_IRQHandler(void);
void GPDMA2_Channel0_IRQHandler(void);
void GPDMA2_Channel1_IRQHandler(void);
void GPDMA2_Channel2_IRQHandler(void);
void GPDMA2_Channel3_IRQHandler(void);
void GPDMA2_Channel4_IRQHandler(void);
void GPDMA2_Channel5_IRQHandler(void);
void GPDMA2_Channel6_IRQHandler(void);
void GPDMA2_Channel7_IRQHandler(void);
void UART7_IRQHandler(void);
void UART8_IRQHandler(void);
void UART9_IRQHandler(void);
void UART12_IRQHandler(void);
void SDMMC2_IRQHandler(void);
void FPU_IRQHandler(void);
void ICACHE_IRQHandler(void);
void DCACHE1_IRQHandler(void);
void ETH_IRQHandler(void);
void ETH_WKUP_IRQHandler(void);
void DCMI_PSSI_IRQHandler(void);
void FDCAN2_IT0_IRQHandler(void);
void FDCAN2_IT1_IRQHandler(void);
void CORDIC_IRQHandler(void);
void FMAC_IRQHandler(void);
void DTS_IRQHandler(void);
void RNG_IRQHandler(void);
void HASH_IRQHandler(void);
void CEC_IRQHandler(void);
void TIM12_IRQHandler(void);
void TIM13_IRQHandler(void);
void TIM14_IRQHandler(void);
void I3C1_EV_IRQHandler(void);
void I3C1_ER_IRQHandler(void);
void I2C4_EV_IRQHandler(void);
void I2C4_ER_IRQHandler(void);
void LPTIM3_IRQHandler(void);
void LPTIM4_IRQHandler(void);
void LPTIM5_IRQHandler(void);
void LPTIM6_IRQHandler(void);

/* Vector table entries (starting from position 16, after system exceptions) */
/* Note: Position 0-15 are system exceptions defined in startup.c */
#define STM32H5_VECTOR_TABLE \
    /* External Interrupts */ \
    [16] = WWDG_IRQHandler,                /* 0: Window WatchDog */ \
    [17] = PVD_AVD_IRQHandler,             /* 1: PVD/AVD through EXTI Line detection */ \
    [18] = RTC_IRQHandler,                 /* 2: RTC non-secure interrupt */ \
    [19] = RTC_S_IRQHandler,               /* 3: RTC secure interrupt */ \
    [20] = TAMP_IRQHandler,                /* 4: Tamper global interrupt */ \
    [21] = RAMCFG_IRQHandler,              /* 5: RAMCFG global interrupt */ \
    [22] = FLASH_IRQHandler,               /* 6: FLASH non-secure global interrupt */ \
    [23] = FLASH_S_IRQHandler,             /* 7: FLASH secure global interrupt */ \
    [24] = GTZC_IRQHandler,                /* 8: Global TrustZone Controller */ \
    [25] = RCC_IRQHandler,                 /* 9: RCC non secure global interrupt */ \
    [26] = RCC_S_IRQHandler,               /* 10: RCC secure global interrupt */ \
    [27] = EXTI0_IRQHandler,               /* 11: EXTI Line0 */ \
    [28] = EXTI1_IRQHandler,               /* 12: EXTI Line1 */ \
    [29] = EXTI2_IRQHandler,               /* 13: EXTI Line2 */ \
    [30] = EXTI3_IRQHandler,               /* 14: EXTI Line3 */ \
    [31] = EXTI4_IRQHandler,               /* 15: EXTI Line4 */ \
    [32] = EXTI5_IRQHandler,               /* 16: EXTI Line5 */ \
    [33] = EXTI6_IRQHandler,               /* 17: EXTI Line6 */ \
    [34] = EXTI7_IRQHandler,               /* 18: EXTI Line7 */ \
    [35] = EXTI8_IRQHandler,               /* 19: EXTI Line8 */ \
    [36] = EXTI9_IRQHandler,               /* 20: EXTI Line9 */ \
    [37] = EXTI10_IRQHandler,              /* 21: EXTI Line10 */ \
    [38] = EXTI11_IRQHandler,              /* 22: EXTI Line11 */ \
    [39] = EXTI12_IRQHandler,              /* 23: EXTI Line12 */ \
    [40] = EXTI13_IRQHandler,              /* 24: EXTI Line13 */ \
    [41] = EXTI14_IRQHandler,              /* 25: EXTI Line14 */ \
    [42] = EXTI15_IRQHandler,              /* 26: EXTI Line15 */ \
    [43] = GPDMA1_Channel0_IRQHandler,     /* 27: GPDMA1 Channel 0 */ \
    [44] = GPDMA1_Channel1_IRQHandler,     /* 28: GPDMA1 Channel 1 */ \
    [45] = GPDMA1_Channel2_IRQHandler,     /* 29: GPDMA1 Channel 2 */ \
    [46] = GPDMA1_Channel3_IRQHandler,     /* 30: GPDMA1 Channel 3 */ \
    [47] = GPDMA1_Channel4_IRQHandler,     /* 31: GPDMA1 Channel 4 */ \
    [48] = GPDMA1_Channel5_IRQHandler,     /* 32: GPDMA1 Channel 5 */ \
    [49] = GPDMA1_Channel6_IRQHandler,     /* 33: GPDMA1 Channel 6 */ \
    [50] = GPDMA1_Channel7_IRQHandler,     /* 34: GPDMA1 Channel 7 */ \
    [51] = IWDG_IRQHandler,                /* 35: IWDG global interrupt */ \
    [52] = 0,                              /* 36: Reserved */ \
    [53] = ADC1_IRQHandler,                /* 37: ADC1 global interrupt */ \
    [54] = DAC1_IRQHandler,                /* 38: DAC1 global interrupt */ \
    [55] = FDCAN1_IT0_IRQHandler,          /* 39: FDCAN1 interrupt 0 */ \
    [56] = FDCAN1_IT1_IRQHandler,          /* 40: FDCAN1 interrupt 1 */ \
    [57] = TIM1_BRK_IRQHandler,            /* 41: TIM1 Break */ \
    [58] = TIM1_UP_IRQHandler,             /* 42: TIM1 Update */ \
    [59] = TIM1_TRG_COM_IRQHandler,        /* 43: TIM1 Trigger and Commutation */ \
    [60] = TIM1_CC_IRQHandler,             /* 44: TIM1 Capture Compare */ \
    [61] = TIM2_IRQHandler,                /* 45: TIM2 global interrupt */ \
    [62] = TIM3_IRQHandler,                /* 46: TIM3 global interrupt */ \
    [63] = TIM4_IRQHandler,                /* 47: TIM4 global interrupt */ \
    [64] = TIM5_IRQHandler,                /* 48: TIM5 global interrupt */ \
    [65] = TIM6_IRQHandler,                /* 49: TIM6 global interrupt */ \
    [66] = TIM7_IRQHandler,                /* 50: TIM7 global interrupt */ \
    [67] = I2C1_EV_IRQHandler,             /* 51: I2C1 Event */ \
    [68] = I2C1_ER_IRQHandler,             /* 52: I2C1 Error */ \
    [69] = I2C2_EV_IRQHandler,             /* 53: I2C2 Event */ \
    [70] = I2C2_ER_IRQHandler,             /* 54: I2C2 Error */ \
    [71] = SPI1_IRQHandler,                /* 55: SPI1 global interrupt */ \
    [72] = SPI2_IRQHandler,                /* 56: SPI2 global interrupt */ \
    [73] = SPI3_IRQHandler,                /* 57: SPI3 global interrupt */ \
    [74] = USART1_IRQHandler,              /* 58: USART1 global interrupt */ \
    [75] = USART2_IRQHandler,              /* 59: USART2 global interrupt */ \
    [76] = USART3_IRQHandler,              /* 60: USART3 global interrupt */ \
    [77] = UART4_IRQHandler,               /* 61: UART4 global interrupt */ \
    [78] = UART5_IRQHandler,               /* 62: UART5 global interrupt */ \
    [79] = LPUART1_IRQHandler,             /* 63: LPUART1 global interrupt */ \
    [80] = LPTIM1_IRQHandler,              /* 64: LPTIM1 global interrupt */ \
    [81] = TIM8_BRK_IRQHandler,            /* 65: TIM8 Break */ \
    [82] = TIM8_UP_IRQHandler,             /* 66: TIM8 Update */ \
    [83] = TIM8_TRG_COM_IRQHandler,        /* 67: TIM8 Trigger and Commutation */ \
    [84] = TIM8_CC_IRQHandler,             /* 68: TIM8 Capture Compare */ \
    [85] = ADC2_IRQHandler,                /* 69: ADC2 global interrupt */ \
    [86] = LPTIM2_IRQHandler,              /* 70: LPTIM2 global interrupt */ \
    [87] = TIM15_IRQHandler,               /* 71: TIM15 global interrupt */ \
    [88] = TIM16_IRQHandler,               /* 72: TIM16 global interrupt */ \
    [89] = TIM17_IRQHandler,               /* 73: TIM17 global interrupt */ \
    [90] = USB_DRD_FS_IRQHandler,          /* 74: USB_DRD_FS global interrupt */ \
    [91] = CRS_IRQHandler,                 /* 75: CRS global interrupt */ \
    [92] = UCPD1_IRQHandler,               /* 76: UCPD1 global interrupt */ \
    [93] = FMC_IRQHandler,                 /* 77: FMC global interrupt */ \
    [94] = OCTOSPI1_IRQHandler,            /* 78: OCTOSPI1 global interrupt */ \
    [95] = SDMMC1_IRQHandler,              /* 79: SDMMC1 global interrupt */ \
    [96] = I2C3_EV_IRQHandler,             /* 80: I2C3 Event */ \
    [97] = I2C3_ER_IRQHandler,             /* 81: I2C3 Error */ \
    [98] = SPI4_IRQHandler,                /* 82: SPI4 global interrupt */ \
    [99] = SPI5_IRQHandler,                /* 83: SPI5 global interrupt */ \
    [100] = SPI6_IRQHandler,               /* 84: SPI6 global interrupt */ \
    [101] = USART6_IRQHandler,             /* 85: USART6 global interrupt */ \
    [102] = USART10_IRQHandler,            /* 86: USART10 global interrupt */ \
    [103] = USART11_IRQHandler,            /* 87: USART11 global interrupt */ \
    [104] = SAI1_IRQHandler,               /* 88: SAI1 global interrupt */ \
    [105] = SAI2_IRQHandler,               /* 89: SAI2 global interrupt */ \
    [106] = GPDMA2_Channel0_IRQHandler,    /* 90: GPDMA2 Channel 0 */ \
    [107] = GPDMA2_Channel1_IRQHandler,    /* 91: GPDMA2 Channel 1 */ \
    [108] = GPDMA2_Channel2_IRQHandler,    /* 92: GPDMA2 Channel 2 */ \
    [109] = GPDMA2_Channel3_IRQHandler,    /* 93: GPDMA2 Channel 3 */ \
    [110] = GPDMA2_Channel4_IRQHandler,    /* 94: GPDMA2 Channel 4 */ \
    [111] = GPDMA2_Channel5_IRQHandler,    /* 95: GPDMA2 Channel 5 */ \
    [112] = GPDMA2_Channel6_IRQHandler,    /* 96: GPDMA2 Channel 6 */ \
    [113] = GPDMA2_Channel7_IRQHandler,    /* 97: GPDMA2 Channel 7 */ \
    [114] = UART7_IRQHandler,              /* 98: UART7 global interrupt */ \
    [115] = UART8_IRQHandler,              /* 99: UART8 global interrupt */ \
    [116] = UART9_IRQHandler,              /* 100: UART9 global interrupt */ \
    [117] = UART12_IRQHandler,             /* 101: UART12 global interrupt */ \
    [118] = SDMMC2_IRQHandler,             /* 102: SDMMC2 global interrupt */ \
    [119] = FPU_IRQHandler,                /* 103: FPU global interrupt */ \
    [120] = ICACHE_IRQHandler,             /* 104: ICACHE global interrupt */ \
    [121] = DCACHE1_IRQHandler,            /* 105: DCACHE1 global interrupt */ \
    [122] = ETH_IRQHandler,                /* 106: ETH global interrupt */ \
    [123] = ETH_WKUP_IRQHandler,           /* 107: ETH_WKUP global interrupt */ \
    [124] = DCMI_PSSI_IRQHandler,          /* 108: DCMI_PSSI global interrupt */ \
    [125] = FDCAN2_IT0_IRQHandler,         /* 109: FDCAN2 interrupt 0 */ \
    [126] = FDCAN2_IT1_IRQHandler,         /* 110: FDCAN2 interrupt 1 */ \
    [127] = CORDIC_IRQHandler,             /* 111: CORDIC global interrupt */ \
    [128] = FMAC_IRQHandler,               /* 112: FMAC global interrupt */ \
    [129] = DTS_IRQHandler,                /* 113: DTS global interrupt */ \
    [130] = RNG_IRQHandler,                /* 114: RNG global interrupt */ \
    [131] = 0,                             /* 115: Reserved */ \
    [132] = 0,                             /* 116: Reserved */ \
    [133] = HASH_IRQHandler,               /* 117: HASH global interrupt */ \
    [134] = 0,                             /* 118: Reserved (PKA) */ \
    [135] = CEC_IRQHandler,                /* 119: CEC-HDMI global interrupt */ \
    [136] = TIM12_IRQHandler,              /* 120: TIM12 global interrupt */ \
    [137] = TIM13_IRQHandler,              /* 121: TIM13 global interrupt */ \
    [138] = TIM14_IRQHandler,              /* 122: TIM14 global interrupt */ \
    [139] = I3C1_EV_IRQHandler,            /* 123: I3C1 event */ \
    [140] = I3C1_ER_IRQHandler,            /* 124: I3C1 error */ \
    [141] = I2C4_EV_IRQHandler,            /* 125: I2C4 event */ \
    [142] = I2C4_ER_IRQHandler,            /* 126: I2C4 error */ \
    [143] = LPTIM3_IRQHandler,             /* 127: LPTIM3 global interrupt */ \
    [144] = LPTIM4_IRQHandler,             /* 128: LPTIM4 global interrupt */ \
    [145] = LPTIM5_IRQHandler,             /* 129: LPTIM5 global interrupt */ \
    [146] = LPTIM6_IRQHandler              /* 130: LPTIM6 global interrupt */

#define PLATFORM_VECTOR_TABLE STM32H5_VECTOR_TABLE
#define VECTOR_TABLE_SIZE 147  /* 0-146 */

#endif /* VECTORS_STM32H5_H */