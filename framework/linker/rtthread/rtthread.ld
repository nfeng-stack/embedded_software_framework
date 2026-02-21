/*
 ******************************************************************************
 **
 ** @file        : rtthread.ld
 **
 ** @author      : Embedded Framework
 **
 ** @brief       : Linker script for RT-Thread operating system
 **                Includes RT-Thread specific sections and heap configuration
 **
 ** Target       : ARM Cortex-M series (generic)
 **
 ** Distribution : The file is distributed as is, without any warranty
 **                of any kind.
 **
 ******************************************************************************
 */

/* Entry Point */
ENTRY(Reset_Handler)

/* Memories definition - should be overridden by platform-specific script */
MEMORY
{
  RAM    (RWX)     : ORIGIN = 0x20000000,   LENGTH = 640K
  FLASH  (RX)     : ORIGIN = 0x08000000,   LENGTH = 2048K
}



/* Highest address of the user mode stack */
_estack = ORIGIN(RAM) + LENGTH(RAM); /* end of RAM */

/* Heap and stack sizes - can be overridden via compiler flags */
_Min_Heap_Size  = DEFINED(_Min_Heap_Size)  ? _Min_Heap_Size  : 0x800;    /* 0KB default - using RT-Thread heap */
_Min_Stack_Size = DEFINED(_Min_Stack_Size) ? _Min_Stack_Size : 0x800;    /* 0KB default - using main stack */



/* Sections */
SECTIONS
{
  /* The startup code goes first into FLASH */
  .isr_vector :
  {
    . = ALIGN(4);
    KEEP(*(.isr_vector)) /* Startup code */
    . = ALIGN(4);
  } >FLASH

  /* The program code and other data goes into FLASH */
  .text :
  {
    . = ALIGN(4);
    *(.text)           /* .text sections (code) */
    *(.text*)          /* .text* sections (code) */
    *(.glue_7)         /* glue arm to thumb code */
    *(.glue_7t)        /* glue thumb to arm code */
    *(.eh_frame)

    KEEP (*(.init))
    KEEP (*(.fini))

    . = ALIGN(4);
    _etext = .;        /* define a global symbol at end of code */
  } >FLASH

  /* Constant data goes into FLASH */
  .rodata :
  {
    . = ALIGN(4);
    *(.rodata)         /* .rodata sections (constants, strings, etc.) */
    *(.rodata*)        /* .rodata* sections (constants, strings, etc.) */
    . = ALIGN(4);
  } >FLASH

  .ARM.extab   : { *(.ARM.extab* .gnu.linkonce.armextab.*) } >FLASH
  .ARM : {
    __exidx_start = .;
    *(.ARM.exidx*)
    __exidx_end = .;
  } >FLASH

  /* RT-Thread initialization function table */
  /* This section collects RT-Thread component initialization functions */
  .rti_fn :
  {
    . = ALIGN(4);
    __rt_init_start = .;
    KEEP(*(SORT(.rti_fn.*)))
    __rt_init_end = .;
    . = ALIGN(4);
  } >FLASH

  .preinit_array     :
  {
    PROVIDE_HIDDEN (__preinit_array_start = .);
    KEEP (*(.preinit_array*))
    PROVIDE_HIDDEN (__preinit_array_end = .);
  } >FLASH

  .init_array :
  {
    PROVIDE_HIDDEN (__init_array_start = .);
    KEEP (*(SORT(.init_array.*)))
    KEEP (*(.init_array*))
    PROVIDE_HIDDEN (__init_array_end = .);
  } >FLASH

  .fini_array :
  {
    PROVIDE_HIDDEN (__fini_array_end = .);
    KEEP (*(SORT(.fini_array.*)))
    KEEP (*(.fini_array*))
    PROVIDE_HIDDEN (__fini_array_start = .);
  } >FLASH

  /* used by the startup to initialize data */
  _sidata = LOADADDR(.data);

  /* Initialized data sections goes into RAM, load LMA copy after code */
  .data : 
  {
    . = ALIGN(4);
    _sdata = .;        /* create a global symbol at data start */
    *(.data)           /* .data sections */
    *(.data*)          /* .data* sections */

    . = ALIGN(4);
    _edata = .;        /* define a global symbol at data end */
  } >RAM AT> FLASH

  /* RAM executable code section - loaded from FLASH, executed in RAM */
  .ram_code :
  {
    . = ALIGN(4);
    _sramcode = .;      /* start of RAM code in RAM */
    KEEP(*(.ram_code))  /* RAM code sections */
    KEEP(*(.ram_code*)) /* RAM code sections */
    . = ALIGN(4);
    _eramcode = .;      /* end of RAM code in RAM */
  } >RAM AT> FLASH

  /* Load address of RAM code section in FLASH */
  _siramcode = LOADADDR(.ram_code);

  /* Uninitialized data section */
  . = ALIGN(4);
  .bss (NOLOAD) :
  {
    /* This is used by the startup in order to initialize the .bss section */
    _sbss = .;         /* define a global symbol at bss start */
    __bss_start__ = _sbss;
    *(.bss)
    *(.bss*)
    *(COMMON)

    . = ALIGN(4);
    _ebss = .;         /* define a global symbol at bss end */
    __bss_end__ = _ebss;
  } >RAM

  /* Minimal heap section to define required symbols for C library */
  /* Heap size is zero since we use RT-Thread memory management */
  ._user_heap_stack (NOLOAD) :
  {
    . = ALIGN(8);
    PROVIDE ( end = . );
    PROVIDE ( _end = . );
    . = . + _Min_Heap_Size;           /* Zero size */
    PROVIDE (_heap_limit = .);
    . = . + _Min_Stack_Size;          /* Zero size */
    . = ALIGN(8);
  } >RAM

  /* Standard libraries are kept for full C library support */

  .ARM.attributes 0 : { *(.ARM.attributes) }
}