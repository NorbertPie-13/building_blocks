# Function to add all test suites for the project
function(add_all_tests)
    # Enable CTest
    enable_testing()
    set(options STRIP_RELEASE)
    set(oneValueArgs EXE_NAME OUTPUT_NAME)
    set(multiValueArgs SOURCES INCLUDES TEST_SOURCES)
    cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

    if (NOT DEFINED ARG_OUTPUT_NAME)
        set(ARG_OUTPUT_NAME ${ARG_EXE_NAME}_test)
    endif()

    message(STATUS "TEST SOURCES: ${ARG_TEST_SOURCES}")

    # Make sure GTest is available
    find_package(GTest REQUIRED)
    
    # Add hello library test
    add_gtest(${ARG_OUTPUT_NAME}
        SOURCES
            "${ARG_SOURCES}"
        TEST_SOURCES
            "${ARG_TEST_SOURCES}"
        INCLUDES
            "${ARG_INCLUDE}"
    )
    
    message(STATUS "Test configuration complete")
endfunction()