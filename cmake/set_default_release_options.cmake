# Function to set default compiler and linker options for release builds
# Usage:
# set_default_release_options(
#   [TARGET target_name]
#   [OPTIMIZATION_LEVEL 0|1|2|3|fast|size|g]
#   [LTO]
#   [PGO_GENERATE]
#   [PGO_USE filename]
#   [STRIP_SYMBOLS]
#   [WITH_DEBUG_INFO]
#   [ENABLE_ASSERTS]
# )
function(set_default_release_options)
  # Define the options and their values
  set(options TARGET WITH_DEBUG_INFO)
  set(oneValueArgs TARGET WITH_DEBUG_INFO)
  set(multiValueArgs "")
  
  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Determine if we're setting options for a specific target or globally
  if(ARG_TARGET)
    # Check if the target exists
    if(NOT TARGET ${ARG_TARGET})
      message(FATAL_ERROR "set_default_release_options: Target '${ARG_TARGET}' does not exist")
    endif()
    
    set(scope_type TARGET ${ARG_TARGET})
    set(message_prefix "Target ${ARG_TARGET}")
  else()
    set(scope_type "")
    set(message_prefix "Global")
  endif()
  
  # Detect compiler
  if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
    set(COMPILER_IS_GCC TRUE)
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "Clang")
    set(COMPILER_IS_CLANG TRUE)
  endif()
  
  # Basic release options
  if(COMPILER_IS_GCC OR COMPILER_IS_CLANG)
    # Default optimization level
    if(NOT ARG_OPTIMIZATION_LEVEL)
      set(ARG_OPTIMIZATION_LEVEL 3)  # Default to -O3
    endif()
    
    # Common flags for GCC and Clang
    set(RELEASE_OPTIONS
      ${OPT_FLAG}
      -DNDEBUG  # Define NDEBUG to disable assertions
      -ffunction-sections  # Place each function in its own section
      -fdata-sections      # Place each data item in its own section
    )
    
    # Linker options
    set(RELEASE_LINK_OPTIONS "")
    
    if(COMPILER_IS_GCC)
      list(APPEND RELEASE_LINK_OPTIONS -Wl,--gc-sections)  # Remove unused sections
    elseif(COMPILER_IS_CLANG)
        list(APPEND RELEASE_LINK_OPTIONS -Wl,--gc-sections)  # Linux/other
    endif()
    set(ONLY_RELEASE True)

    strip_target(${TARGET} ${ONLY_RELEASE} )
    
  
  message(STATUS "${message_prefix}: Release options configured")
endfunction()