# Function to set default compiler and linker options for debug builds
# Usage:
# set_default_debug_options(
#   [TARGET target_name]
#   [SANITIZERS address thread undefined]
#   [ENABLE_PROFILING]
#   [STRICT_WARNINGS]
#   [USE_UBSAN]
#   [USE_ASAN]
#   [USE_TSAN]
#   [DISABLE_OPTIMIZATION]
# )
function(set_default_debug_options)
  # Define the options and their values
  set(options ENABLE_PROFILING STRICT_WARNINGS USE_UBSAN USE_ASAN USE_TSAN DISABLE_OPTIMIZATION)
  set(oneValueArgs TARGET)
  set(multiValueArgs SANITIZERS)
  
  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Determine if we're setting options for a specific target or globally
  if(ARG_TARGET)
    # Check if the target exists
    if(NOT TARGET ${ARG_TARGET})
      message(FATAL_ERROR "set_default_debug_options: Target '${ARG_TARGET}' does not exist")
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
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(COMPILER_IS_MSVC TRUE)
  endif()
  
  # Basic debug options
  if(COMPILER_IS_GCC OR COMPILER_IS_CLANG)
    # Common flags for GCC and Clang
    set(DEBUG_OPTIONS
      -g3                     # Maximum debug information
      -fno-omit-frame-pointer # Keep frame pointer for better debugging
    )
    
    if(ARG_DISABLE_OPTIMIZATION)
      list(APPEND DEBUG_OPTIONS -O0)  # No optimization
    else()
      list(APPEND DEBUG_OPTIONS -Og)  # Optimization that doesn't interfere with debugging
    endif()
    
    if(ARG_STRICT_WARNINGS)
      list(APPEND DEBUG_OPTIONS
        -Wall
        -Wextra
        -Wpedantic
        -Werror
      )
      
      if(COMPILER_IS_GCC)
        list(APPEND DEBUG_OPTIONS -Wno-maybe-uninitialized)  # GCC-specific
      elseif(COMPILER_IS_CLANG)
        list(APPEND DEBUG_OPTIONS -Wno-unused-parameter)     # Clang-specific
      endif()
    endif()
    
  elseif(COMPILER_IS_MSVC)
    # MSVC-specific flags
    set(DEBUG_OPTIONS 
      /Zi        # Produce complete debugging information
      /Od        # Disable optimization
      /RTC1      # Enable run-time error checks
      /sdl       # Enable additional security checks
      /MP        # Multi-processor compilation
    )
    
    if(ARG_STRICT_WARNINGS)
      list(APPEND DEBUG_OPTIONS
        /W4        # Warning level 4
        /WX        # Treat warnings as errors
      )
    endif()
  endif()
  
  # Handle sanitizers
  set(SANITIZER_FLAGS "")
  
  # Process explicitly requested sanitizers
  if(ARG_USE_UBSAN OR "undefined" IN_LIST ARG_SANITIZERS)
    set(ENABLE_UBSAN TRUE)
  endif()
  
  if(ARG_USE_ASAN OR "address" IN_LIST ARG_SANITIZERS)
    set(ENABLE_ASAN TRUE)
  endif()
  
  if(ARG_USE_TSAN OR "thread" IN_LIST ARG_SANITIZERS)
    set(ENABLE_TSAN TRUE)
  endif()
  
  # Configure sanitizers (only for GCC and Clang)
  if(COMPILER_IS_GCC OR COMPILER_IS_CLANG)
    if(ENABLE_UBSAN)
      list(APPEND SANITIZER_FLAGS "-fsanitize=undefined")
      message(STATUS "${message_prefix}: Enabling Undefined Behavior Sanitizer")
    endif()
    
    if(ENABLE_ASAN)
      list(APPEND SANITIZER_FLAGS "-fsanitize=address")
      message(STATUS "${message_prefix}: Enabling Address Sanitizer")
    endif()
    
    if(ENABLE_TSAN)
      list(APPEND SANITIZER_FLAGS "-fsanitize=thread")
      message(STATUS "${message_prefix}: Enabling Thread Sanitizer")
    endif()
  endif()
  
  # Handle profiling
  if(ARG_ENABLE_PROFILING)
    if(COMPILER_IS_GCC OR COMPILER_IS_CLANG)
      list(APPEND DEBUG_OPTIONS -pg)  # Generate profiling information
    elseif(COMPILER_IS_MSVC)
      list(APPEND DEBUG_OPTIONS /PROFILE)
    endif()
    message(STATUS "${message_prefix}: Enabling profiling")
  endif()
  
  # Apply the options
  if(scope_type)
    # Apply to specific target
    target_compile_options(${ARG_TARGET} PRIVATE
      $<$<CONFIG:Debug>:${DEBUG_OPTIONS}>
    )
    
    if(SANITIZER_FLAGS)
      target_compile_options(${ARG_TARGET} PRIVATE
        $<$<CONFIG:Debug>:${SANITIZER_FLAGS}>
      )
      target_link_options(${ARG_TARGET} PRIVATE
        $<$<CONFIG:Debug>:${SANITIZER_FLAGS}>
      )
    endif()
  else()
    # Apply globally
    add_compile_options(
      $<$<CONFIG:Debug>:${DEBUG_OPTIONS}>
    )
    
    if(SANITIZER_FLAGS)
      add_compile_options(
        $<$<CONFIG:Debug>:${SANITIZER_FLAGS}>
      )
      add_link_options(
        $<$<CONFIG:Debug>:${SANITIZER_FLAGS}>
      )
    endif()
  endif()
  
  message(STATUS "${message_prefix}: Debug options configured")
endfunction()