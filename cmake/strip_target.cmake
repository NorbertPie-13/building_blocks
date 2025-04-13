# Function to strip debugging symbols and information from targets
# Usage:
# strip_target(
#   TARGET target_name
#   [CONFIGURATIONS Release RelWithDebInfo MinSizeRel]
#   [STRIP_COMMAND /path/to/strip]
#   [STRIP_FLAGS --strip-all --strip-debug ...]
#   [OUTPUT_DIR path/to/stripped/binaries]
#   [ONLY_RELEASE]
# )
function(strip_target)
  # Define the options and their values
  set(options ONLY_RELEASE)
  set(oneValueArgs TARGET STRIP_COMMAND OUTPUT_DIR)
  set(multiValueArgs CONFIGURATIONS STRIP_FLAGS)
  
  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Validate required arguments
  if(NOT ARG_TARGET)
    message(FATAL_ERROR "strip_target: TARGET not specified")
  endif()
  
  # Check if the target exists
  if(NOT TARGET ${ARG_TARGET})
    message(FATAL_ERROR "strip_target: Target '${ARG_TARGET}' does not exist")
  endif()
  
  # Default configurations if not specified
  if(NOT ARG_CONFIGURATIONS)
    set(ARG_CONFIGURATIONS Release MinSizeRel RelWithDebInfo)
  endif()
  
  # Find strip command if not specified
  if(NOT ARG_STRIP_COMMAND)
    find_program(STRIP_PROGRAM strip)
    if(STRIP_PROGRAM)
      set(ARG_STRIP_COMMAND ${STRIP_PROGRAM})
    else()
      message(WARNING "strip_target: 'strip' command not found, using CMAKE_STRIP")
      set(ARG_STRIP_COMMAND ${CMAKE_STRIP})
    endif()
  endif()
  
  # Verify we have a strip command
  if(NOT ARG_STRIP_COMMAND)
    message(FATAL_ERROR "strip_target: No strip command found or specified")
  endif()
  
  # Default strip flags if not specified
  if(NOT ARG_STRIP_FLAGS)
    set(ARG_STRIP_FLAGS --strip-all)
  endif()
  
  # Get target properties
  get_target_property(target_type ${ARG_TARGET} TYPE)
  get_target_property(is_imported ${ARG_TARGET} IMPORTED)
  
  # Skip if this is an imported target
  if(is_imported)
    message(WARNING "strip_target: '${ARG_TARGET}' is an imported target and cannot be stripped")
    return()
  endif()

  # Determine the binary type and name
  if(target_type STREQUAL "EXECUTABLE")
    set(binary_prefix "${CMAKE_EXECUTABLE_PREFIX}")
    set(binary_suffix "${CMAKE_EXECUTABLE_SUFFIX}")
  elseif(target_type STREQUAL "SHARED_LIBRARY")
    set(binary_prefix "${CMAKE_SHARED_LIBRARY_PREFIX}")
    set(binary_suffix "${CMAKE_SHARED_LIBRARY_SUFFIX}")
  elseif(target_type STREQUAL "MODULE_LIBRARY")
    set(binary_prefix "${CMAKE_SHARED_MODULE_PREFIX}")
    set(binary_suffix "${CMAKE_SHARED_MODULE_SUFFIX}")
  elseif(target_type STREQUAL "STATIC_LIBRARY")
    message(WARNING "strip_target: Static libraries (${ARG_TARGET}) typically don't need stripping")
    set(binary_prefix "${CMAKE_STATIC_LIBRARY_PREFIX}")
    set(binary_suffix "${CMAKE_STATIC_LIBRARY_SUFFIX}")
  else()
    message(WARNING "strip_target: Unknown target type for '${ARG_TARGET}', assuming executable")
    set(binary_prefix "${CMAKE_EXECUTABLE_PREFIX}")
    set(binary_suffix "${CMAKE_EXECUTABLE_SUFFIX}")
  endif()
  
  # Get output name of the target (respecting OUTPUT_NAME property if set)
  get_target_property(output_name ${ARG_TARGET} OUTPUT_NAME)
  if(NOT output_name)
    set(output_name "${ARG_TARGET}")
  endif()
  
  # Check if we should respect configuration postfixes
  foreach(config ${CMAKE_CONFIGURATION_TYPES} ${CMAKE_BUILD_TYPE})
    string(TOUPPER "${config}" config_upper)
    get_target_property(config_postfix ${ARG_TARGET} "${config_upper}_POSTFIX")
    if(config_postfix)
      set(has_config_postfix TRUE)
      break()
    endif()
  endforeach()
  
  # Create post-build command for each configuration
  foreach(config ${ARG_CONFIGURATIONS})
    # Skip non-release configurations if ONLY_RELEASE is specified
    if(ARG_ONLY_RELEASE)
      if(NOT config STREQUAL "Release" AND NOT config STREQUAL "MinSizeRel")
        continue()
      endif()
    endif()
    
    # Determine the actual binary name with potential configuration postfix
    string(TOUPPER "${config}" config_upper)
    get_target_property(config_postfix ${ARG_TARGET} "${config_upper}_POSTFIX")
    if(NOT config_postfix)
      set(config_postfix "")
    endif()
    
    set(binary_name "${binary_prefix}${output_name}${config_postfix}${binary_suffix}")
    
    # Determine source and destination paths
    if(ARG_OUTPUT_DIR)
      set(stripped_dir "${ARG_OUTPUT_DIR}")
      
      # Create the output directory if it doesn't exist
      add_custom_command(
        TARGET ${ARG_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E make_directory "${stripped_dir}"
        COMMENT "Creating directory for stripped binaries: ${stripped_dir}"
        VERBATIM
      )
      
      set(source_path "$<TARGET_FILE:${ARG_TARGET}>")
      set(dest_path "${stripped_dir}/${binary_name}")
      
      # First copy, then strip the copy
      add_custom_command(
        TARGET ${ARG_TARGET} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy "${source_path}" "${dest_path}"
        COMMAND ${ARG_STRIP_COMMAND} ${ARG_STRIP_FLAGS} "${dest_path}"
        COMMENT "Stripping ${binary_name} (${config}) to ${stripped_dir}"
        VERBATIM
        CONDITION $<CONFIG:${config}>
      )
    else()
      # Strip in-place
      add_custom_command(
        TARGET ${ARG_TARGET} POST_BUILD
        COMMAND ${ARG_STRIP_COMMAND} ${ARG_STRIP_FLAGS} "$<TARGET_FILE:${ARG_TARGET}>"
        COMMENT "Stripping ${binary_name} (${config}) in-place"
        VERBATIM
        CONDITION $<CONFIG:${config}>
      )
    endif()
  endforeach()
  
  # Create a custom target to strip manually if needed
  set(strip_target_name strip_${ARG_TARGET})
  if(NOT TARGET ${strip_target_name})
    add_custom_target(${strip_target_name}
      COMMENT "Manually stripping ${ARG_TARGET}"
      DEPENDS ${ARG_TARGET}
      COMMAND ${CMAKE_COMMAND} -E echo "Stripping ${ARG_TARGET}..."
      COMMAND ${ARG_STRIP_COMMAND} ${ARG_STRIP_FLAGS} "$<TARGET_FILE:${ARG_TARGET}>"
      VERBATIM
    )
    
    # Create a global strip target if it doesn't exist
    if(NOT TARGET strip_all)
      add_custom_target(strip_all)
    endif()
    
    # Add our target as a dependency of strip_all
    add_dependencies(strip_all ${strip_target_name})
  endif()
  
  message(STATUS "Set up stripping for ${ARG_TARGET}")
endfunction()