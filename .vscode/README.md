# VS Code Configuration for Embedded Framework

This directory contains VS Code configuration files for the embedded framework project.

## Recommended Extensions

Install the following extensions for the best development experience:

1. **C/C++** (ms-vscode.cpptools) - C/C++ IntelliSense, debugging, and code browsing
2. **Cortex-Debug** (marus25.cortex-debug) - ARM Cortex-M debugging support
3. **CMake Tools** (ms-vscode.cmake-tools) - CMake support (if using CMake)
4. **Makefile Tools** (ms-vscode.makefile-tools) - Makefile support

You can install all recommended extensions by:
1. Opening the Extensions view (Ctrl+Shift+X)
2. Searching for "@recommended" in the search box
3. Clicking "Install" on each extension

## Configuration Files

### c_cpp_properties.json
- Defines include paths, compiler settings, and preprocessor definitions
- Configured for STM32H5 with RT-Thread RTOS
- Uses ARM GCC toolchain from `/usr/local/arm/...`

### tasks.json
- Defines build tasks (Build, Clean, Flash, etc.)
- Main build task: `Ctrl+Shift+B` or run "Build Project" from Terminal menu
- Other tasks available via Terminal > Run Task...

### launch.json
- Debug configurations for Cortex-M debugging
- Supports ST-Link with OpenOCD
- Also includes GDB debugging configuration

### settings.json
- Workspace-specific settings
- File associations for .h, .s, .ld files
- Excludes build directories from search

## Usage

### Building
1. Use `Ctrl+Shift+B` to build the project
2. Or run Terminal > Run Task... > "Build Project"
3. For verbose output: Run Task... > "Build Project (Verbose)"

### Debugging
1. Ensure ST-Link debug probe is connected
2. Install OpenOCD: `brew install openocd` (on macOS)
3. Select "Cortex Debug (ST-Link)" in Debug view
4. Press F5 to start debugging

### Code Navigation
- `Ctrl+Click` on symbols to go to definition
- `F12` to go to definition
- `Alt+F12` to peek definition
- `Shift+F12` to find references

## Troubleshooting

### IntelliSense Issues
1. If IntelliSense doesn't work, run "C/C++: Reset IntelliSense Database" from Command Palette
2. Check that compiler path is correct in c_cpp_properties.json
3. Verify all include directories exist

### Build Issues
1. Ensure ARM GCC toolchain is installed and in PATH
2. Check that all dependencies are available in third_party directory

### Debugging Issues
1. Install Cortex-Debug extension
2. Ensure OpenOCD is installed and accessible
3. Verify ST-Link is properly connected

## Platform Configuration

The project is configured for:
- **MCU**: STM32H563xx (Cortex-M33)
- **Toolchain**: ARM GCC 14.3
- **RTOS**: RT-Thread
- **Debug Probe**: ST-Link

To change platform configuration, update:
1. `config.mk` - Build configuration
2. `.vscode/c_cpp_properties.json` - IntelliSense configuration
3. `.vscode/launch.json` - Debug configuration