cmake_minimum_required(VERSION 3.10)
project(HelloWorld VERSION 1.0.0 LANGUAGES C CXX)

set(EXE_NAME HelloWorld)
set(LIB_NAME HelloWorld.so)

# Set default build type if not specified
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE "Debug")
endif()

set(SRC_FILES 
${CMAKE_SOURCE_DIR}/src/main.c;
${CMAKE_SOURCE_DIR}/src/hello.c;
)

set(SRC
${CMAKE_SOURCE_DIR}/src/hello.c;
)

set(INCLUDE_FILES
 ${CMAKE_SOURCE_DIR}/include
 
)

set(TEST_FILES
    test/test_hello.cpp;
)

set(LIB_SRC 
    OpenSSL::OpenSSL
    pthread
)

set(LIB_INCLUDE
    pthread.h
    openssl.h
)

include_directories(include)


# Set output directories
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)


# Enable testing
enable_testing()


# Include our build system
include(${CMAKE_SOURCE_DIR}/cmake/buildsystem.cmake)

# Add all targets and tests
add_all_targets(
    LIB_NAME ${LIB_NAME}
    LIB_SOURCES "${SRC_FILES}"
    LIB_INCLUDES "${INCLUDE_FILES}"
    EXE_NAME ${EXE_NAME}
    EXE_SOURCES "${SRC_FILES}"
    EXE_INCLUDES "${INCLUDE_FILES}"

    LIB_DESTINATION lib
    EXE_DESTINATION bin
)
add_all_tests(    
    EXE_NAME ${EXE_NAME}
    SOURCES "${SRC}"
    INCLUDES "${INCLUDE_FILES}"
    TEST_SOURCES "${TEST_FILES}"
)

# Print configuration info
message(STATUS "")
message(STATUS "Configuration:")
message(STATUS "  Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  C Compiler: ${CMAKE_C_COMPILER}")
message(STATUS "")