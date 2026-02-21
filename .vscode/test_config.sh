#!/bin/bash

echo "=== VS Code Configuration Test ==="
echo

echo "1. Checking compiler..."
if [ -f "/usr/local/arm/arm-gnu-toolchain-14.3.rel1-darwin-arm64-arm-none-eabi/bin/arm-none-eabi-gcc" ]; then
    echo "✓ Compiler found"
    /usr/local/arm/arm-gnu-toolchain-14.3.rel1-darwin-arm64-arm-none-eabi/bin/arm-none-eabi-gcc --version | head -1
else
    echo "✗ Compiler not found at configured path"
fi

echo
echo "2. Checking OpenOCD..."
if [ -f "/usr/local/openocd/openocd-stm32-full/bin/openocd" ]; then
    echo "✓ OpenOCD found"
    /usr/local/openocd/openocd-stm32-full/bin/openocd --version 2>/dev/null | head -1 || echo "OpenOCD version check failed"
else
    echo "✗ OpenOCD not found at configured path"
fi

echo
echo "3. Checking include directories..."
missing_dirs=0
for dir in \
    "include" \
    "framework/config" \
    "framework/include" \
    "hal/include" \
    "third_party/stm32h5xx_hal_driver/Inc" \
    "third_party/CMSIS/Core/Include" \
    "third_party/CMSIS/Device/ST/STM32H5xx/Include" \
    "third_party/rt-thread/include"
do
    if [ -d "$dir" ]; then
        echo "✓ $dir"
    else
        echo "✗ $dir (missing)"
        ((missing_dirs++))
    fi
done

echo
echo "4. Testing build system..."
if make info >/dev/null 2>&1; then
    echo "✓ Make works"
    make info | grep -E "Project:|Platform:|RTOS:"
else
    echo "✗ Make failed"
fi

echo
echo "=== Test Complete ==="
if [ $missing_dirs -eq 0 ]; then
    echo "All checks passed! VS Code should be properly configured."
else
    echo "Found $missing_dirs missing directories. Please check configuration."
fi