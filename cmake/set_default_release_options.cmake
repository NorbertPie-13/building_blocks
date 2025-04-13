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
  set(options LTO PGO_GENERATE STRIP_SYMBOLS WITH_DEBUG_INFO ENABLE_ASSERTS)
  set(oneValueArgs TARGET OPTIMIZATION_LEVEL PGO_USE)
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
  elseif(CMAKE_CXX_COMPILER_ID MATCHES "MSVC")
    set(COMPILER_IS_MSVC TRUE)
  endif()
  
  # Basic release options
  if(COMPILER_IS_GCC OR COMPILER_IS_CLANG)
    # Default optimization level
    if(NOT ARG_OPTIMIZATION_LEVEL)
      set(ARG_OPTIMIZATION_LEVEL 3)  # Default to -O3
    endif()
    
    # Set optimization flag based on level
    if(ARG_OPTIMIZATION_LEVEL STREQUAL "size")
      set(OPT_FLAG "-Os")  # Optimize for size
    elseif(ARG_OPTIMIZATION_LEVEL STREQUAL "fast")
      set(OPT_FLAG "-Ofast")  # Fastest optimization, may break IEEE/ISO
    elseif(ARG_OPTIMIZATION_LEVEL STREQUAL "g")
      set(OPT_FLAG "-Og")  # Optimize for debugging
    else()
      set(OPT_FLAG "-O${ARG_OPTIMIZATION_LEVEL}")  # Numeric optimization level
    endif()
    
    # Common flags for GCC and Clang
    set(RELEASE_OPTIONS
      ${OPT_FLAG}
      -DNDEBUG  # Define NDEBUG to disable assertions
      -ffunction-sections  # Place each function in its own section
      -fdata-sections      # Place each data item in its own section
    )
    
    # If assertions should be enabled, remove NDEBUG
    if(ARG_ENABLE_ASSERTS)
      list(REMOVE_ITEM RELEASE_OPTIONS -DNDEBUG)
    endif()
    
    # Add debug info if requested
    if(ARG_WITH_DEBUG_INFO)
      list(APPEND RELEASE_OPTIONS -g)
    endif()
    
    # Linker options
    set(RELEASE_LINK_OPTIONS "")
    
    if(COMPILER_IS_GCC)
      list(APPEND RELEASE_LINK_OPTIONS -Wl,--gc-sections)  # Remove unused sections
    elseif(COMPILER_IS_CLANG)
      if(APPLE)
        list(APPEND RELEASE_LINK_OPTIONS -Wl,-dead_strip)  # macOS equivalent
      else()
        list(APPEND RELEASE_LINK_OPTIONS -Wl,--gc-sections)  # Linux/other
      endif()
    endif()
    
    # Handle Link-Time Optimization
    if(ARG_LTO)
      if(COMPILER_IS_GCC)
        list(APPEND RELEASE_OPTIONS -flto)
        list(APPEND RELEASE_LINK_OPTIONS -flto)
      elseif(COMPILER_IS_CLANG)
        list(APPEND RELEASE_OPTIONS -flto=thin)
        list(APPEND RELEASE_LINK_OPTIONS -flto=thin)
      endif()
      message(STATUS "${message_prefix}: Enabling Link-Time Optimization")
    endif()
    
    # Handle Profile-Guided Optimization
    if(ARG_PGO_GENERATE)
      list(APPEND RELEASE_OPTIONS -fprofile-generate)
      list(APPEND RELEASE_LINK_OPTIONS -fprofile-generate)
      message(STATUS "${message_prefix}: Enabling PGO (generation phase)")
    elseif(ARG_PGO_USE)
      list(APPEND RELEASE_OPTIONS -fprofile-use=${ARG_PGO_USE})
      list(APPEND RELEASE_LINK_OPTIONS -fprofile-use=${ARG_PGO_USE})
      message(STATUS "${message_prefix}: Enabling PGO (use phase) with profile: ${ARG_PGO_USE}")
    endif()
    
    # Handle symbol stripping
    if(ARG_STRIP_SYMBOLS)
      list(APPEND RELEASE_LINK_OPTIONS -Wl,--strip-all)
      message(STATUS "${message_prefix}: Stripping symbols")
    endif()
    
  elseif(COMPILER_IS_MSVC)
    # Default optimization level for MSVC
    if(NOT ARG_OPTIMIZATION_LEVEL)
      set(ARG_OPTIMIZATION_LEVEL 2)  # Default to /O2
    endif()
    
    # Set optimization flag based on level
    if(ARG_OPTIMIZATION_LEVEL STREQUAL "size")
      set(OPT_FLAG "/O1")  # Optimize for size
    elseif(ARG_OPTIMIZATION_LEVEL STREQUAL "fast")
      set(OPT_FLAG "/O2 /fp:fast")  # Fast optimization
    elseif(ARG_OPTIMIZATION_LEVEL STREQUAL "g")
      set(OPT_FLAG "/O1 /Zo")  # Optimize for debugging
    else()
      set(OPT_FLAG "/O${ARG_OPTIMIZATION_LEVEL}")  # Numeric optimization level
    endif()
    
    # MSVC-specific flags
    set(RELEASE_OPTIONS 
      ${OPT_FLAG}
      /DNDEBUG    # Define NDEBUG to disable assertions
      /GF         # Eliminate duplicate strings
      /Gy         # Function-level linking
      /Gw         # Optimize global data
      /MP         # Multi-processor compilation
    )
    
    # If assertions should be enabled, remove NDEBUG
    if(ARG_ENABLE_ASSERTS)
      list(REMOVE_ITEM RELEASE_OPTIONS /DNDEBUG)
    endif()
    
    # Add debug info if requested
    if(ARG_WITH_DEBUG_INFO)
      list(APPEND RELEASE_OPTIONS /Zi)
      set(RELEASE_LINK_OPTIONS /DEBUG)
    else()
      set(RELEASE_LINK_OPTIONS "")
    endif()
    
    # Handle Link-Time Optimization
    if(ARG_LTO)
      list(APPEND RELEASE_OPTIONS /GL)    # Whole program optimization
      list(APPEND RELEASE_LINK_OPTIONS /LTCG)  # Link-time code generation
      message(STATUS "${message_prefix}: Enabling Link-Time Optimization")
    endif()
    
    # Handle Profile-Guided Optimization
    if(ARG_PGO_GENERATE)
      list(APPEND RELEASE_LINK_OPTIONS /LTCG:PGINSTRUMENT)
      message(STATUS "${message_prefix}: Enabling PGO (generation phase)")
    elseif(ARG_PGO_USE)
      list(APPEND RELEASE_LINK_OPTIONS /LTCG:PGOPTIMIZE)
      message(STATUS "${message_prefix}: Enabling PGO (use phase)")
    endif()
  endif()
  
  # Apply the options
  if(scope_type)
    # Apply to specific target
    target_compile_options(${ARG_TARGET} PRIVATE
      $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>,$<CONFIG:RelWithDebInfo>>:${RELEASE_OPTIONS}>
    )
    
    if(RELEASE_LINK_OPTIONS)
      target_link_options(${ARG_TARGET} PRIVATE
        $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>,$<CONFIG:RelWithDebInfo>>:${RELEASE_LINK_OPTIONS}>
      )
    endif()
  else()
    # Apply globally
    add_compile_options(
      $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>,$<CONFIG:RelWithDebInfo>>:${RELEASE_OPTIONS}>
    )
    
    if(RELEASE_LINK_OPTIONS)
      add_link_options(
        $<$<OR:$<CONFIG:Release>,$<CONFIG:MinSizeRel>,$<CONFIG:RelWithDebInfo>>:${RELEASE_LINK_OPTIONS}>
      )
    endif()
  endif()
  
  message(STATUS "${message_prefix}: Release options configured")
endfunction()