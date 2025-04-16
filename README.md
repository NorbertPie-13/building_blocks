# CMake Build System Project

Date: 13 Apr 2025

This project implements a modular CMake build system that can compile for multiple targets (both ELF executables and .so shared libraries) with support for cross-compilation.

## Directory Structure

```
Project/
├── CMakeLists.txt                     # Top-level CMake file
├── Makefile                           # Top-level Makefile for convenience
├── cmake/                             # CMake modules directory
│   ├── buildsystem.cmake              # Includes all other CMake files
│   ├── add_all_targets.cmake          # Adds targets (using add_exe/add_so)
│   ├── add_all_tests.cmake            # Adds test suites
│   ├── add_exe.cmake                  # Function to add executables
│   ├── add_gtest.cmake                # Function to add GTest suites
│   ├── add_so.cmake                   # Function to add shared libraries
│   ├── disable_warnings.cmake         # Function to disable warnings for files
│   ├── install_target.cmake           # Function to install targets
│   ├── set_default_debug_options.cmake # Set debug compiler/linker options
│   ├── set_default_release_options.cmake # Set release compiler/linker options
│   ├── strip_target.cmake             # Function to strip binaries
│   └── tidy-checks.cmake              # Function for clang-tidy configuration
├── include/                            
├── src/                               
|    ├── CMakeLists.txt         # CMake for src/ configurations 
|    ├── remote/    # Target
|    |      ├── test/
|    |      ├── include/
|    |      └── CMakeLists.txt                  # Cmake for remote target configurations
|    ├── local/     # Target
|    |      ├── test/
|    |      ├── include/
|    |      └── CMakeLists.txt                  # CMake for local Target configuration (possible python)
|    └── common     # Target
|           ├── test/
|           ├── include/
|           └── CMakeLists.txt                  # CMake for common Target configurations
└── test/                # Test files directory
```

## Basic Usage

### Building the Project

```bash
# Build in debug mode (default arch=native)
make debug

# Build in release mode
make release

# Build with a specific architecture (e.g., x86-64)
make release ARCH=x86-64

# Clean or wipe build folder
make clean
make distclean

# Install if your CMakeLists has install() commands
make install

```

### Running Tests

```bash
make test
```


## CMake Functions

This build system provides several functions:

- `add_exe()`: Add an executable target
- `add_so()`: Add a shared library target
- `add_gtest()`: Add a GTest test suite
- `install_target()`: Configure installation for a target
- `set_default_debug_options()`: Set compiler/linker options for debug builds
- `set_default_release_options()`: Set compiler/linker options for release builds
- `strip_target()`: Strip symbols from a target
- `disable_warnings()`: Disable warnings for specific files
- `tidy_checks()`: Configure clang-tidy static analysis

These functions are implemented in separate files within the `cmake/` directory.

## Example

The sample code implements:
- A shared library (`hello_lib`) with basic functionality
- An executable (`hello_world`) that uses the library
- A GTest suite to test the library functionality
