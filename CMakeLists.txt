cmake_minimum_required(VERSION 3.10)
project(
  HelloWorld
  VERSION 1.0.0
  LANGUAGES C CXX)

set(EXE_NAME HelloWorld)
set(LIB_NAME HelloWorld.so)

set(CMAKE_C_STANDARD 19)
set(CMAKE_C_STANDARD_REQUIRED True)

find_program(CLANG_TIDY_EXE NAMES "clang-tidy")
if(CLANG_TIDY_EXE)
  set(CMAKE_C_CLANG_TIDY "${CLANG_TIDY_EXE};-p=${CMAKE_BINARY_DIR}")
endif()

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE "Debug")
endif()

# Set output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
add_subdirectory(src)