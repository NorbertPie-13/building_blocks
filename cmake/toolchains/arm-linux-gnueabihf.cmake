# cmake/toolchains/arm-linux-gnueabihf.cmake
# Sample toolchain file for cross-compiling to ARM Linux

set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR arm)

# Specify the cross compilers
set(CMAKE_C_COMPILER arm-linux-gnueabihf-gcc)
set(CMAKE_CXX_COMPILER arm-linux-gnueabihf-g++)

# Where to look for the target environment (optional)
set(CMAKE_FIND_ROOT_PATH /usr/arm-linux-gnueabihf)

# Search for programs only in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)

# Search for libraries and headers only in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# Needed for certain versions of CMake
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)

# Set additional flags if needed
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS}" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS}" CACHE STRING "C++ flags")