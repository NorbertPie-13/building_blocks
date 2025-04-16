# Main build system file that includes all other modules

# Include all build system components
include(${CMAKE_CURRENT_LIST_DIR}/add_all_targets.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/add_all_tests.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/add_gtest.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/add_exe.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/add_so.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/disable_warnings.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/install_target.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/set_default_debug_options.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/set_default_release_options.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/strip_target.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/tidy-checks.cmake)

message(STATUS "Build system loaded from ${CMAKE_CURRENT_LIST_FILE}")
