# Function to add a GTest suite
function(add_gtest TARGET_NAME)
    # Parse arguments
    set(options "")
    set(oneValueArgs "")
    set(multiValueArgs SOURCES TEST_SOURCES INCLUDES LINK_LIBS)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
    
    # Support using first positional argument as target name
    if(NOT TARGET_NAME AND ARGV0)
        set(TARGET_NAME ${ARGV0})
    endif()
    
    # Validate required parameters
    if(NOT TARGET_NAME)
        message(FATAL_ERROR "add_gtest: TARGET_NAME parameter is required")
    endif()
    
    # At least test sources are required
    if(NOT ARG_TEST_SOURCES)
        message(FATAL_ERROR "add_gtest: TEST_SOURCES parameter is required")
    endif()
    
    # Create test executable name
    set(test_executable "${TARGET_NAME}")
    
    # Create test executable with both source and test files
    add_executable(${test_executable} ${ARG_SOURCES} ${ARG_TEST_SOURCES})
    
    # Add include directories
    if(ARG_INCLUDES)
        target_include_directories(${test_executable} PRIVATE ${ARG_INCLUDES})
    endif()
    
    # Link against GTest and any additional libraries
    target_link_libraries(${test_executable} PRIVATE 
        GTest::GTest 
        GTest::Main
        ${ARG_LINK_LIBS}
        pthread
    )
    
    # Add as a test to CTest
    add_test(NAME ${test_executable} COMMAND ${test_executable})
    
    message(STATUS "Added test: ${test_executable}")
endfunction()