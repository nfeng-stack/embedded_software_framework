#!/bin/bash
openocd -s /usr/local/openocd/openocd-stm32-full/tcl \
        -f interface/cmsis-dap.cfg \
        -f target/stm32h5x.cfg \
        -c "program ./build/embedded_framework.elf verify reset exit"