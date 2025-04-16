# Function to strip debugging symbols and information from targets Usage:
# strip_target( TARGET target_name [OUTPUT_DIR path/to/stripped/binaries]
# [ONLY_RELEASE] )
function(strip_target)
  set(options ONLY_RELEASE)
  set(oneValueArgs TARGET OUTPUT_DIR)
  set(multiValueArgs "")
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}"
                        ${ARGN})

  if(NOT ARG_TARGET)
    message(FATAL_ERROR "strip_target: TARGET not specified")
  endif()

  if(NOT TARGET ${ARG_TARGET})
    message(FATAL_ERROR "strip_target: Target '${ARG_TARGET}' does not exist")
  endif()

  if(ARG_ONLY_RELEASE AND NOT CMAKE_BUILD_TYPE STREQUAL "Release")
    message(
      STATUS
        "strip_target: Skipping '${ARG_TARGET}' (only runs in Release mode)")
    return()
  endif()

  # Get output location and name
  get_target_property(target_type ${ARG_TARGET} TYPE)
  get_target_property(target_output_name ${ARG_TARGET} OUTPUT_NAME)
  if(NOT target_output_name)
    set(target_output_name ${ARG_TARGET})
  endif()

  # Determine output binary file name with appropriate suffix
  if(target_type STREQUAL "EXECUTABLE")
    set(output_file
        ${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${target_output_name}${CMAKE_EXECUTABLE_SUFFIX}
    )
  elseif(target_type STREQUAL "STATIC_LIBRARY")
    set(output_file
        ${CMAKE_ARCHIVE_OUTPUT_DIRECTORY}/${CMAKE_STATIC_LIBRARY_PREFIX}${target_output_name}${CMAKE_STATIC_LIBRARY_SUFFIX}
    )
  elseif(target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL
                                                  "MODULE_LIBRARY")
    set(output_file
        ${CMAKE_LIBRARY_OUTPUT_DIRECTORY}/${CMAKE_SHARED_LIBRARY_PREFIX}${target_output_name}${CMAKE_SHARED_LIBRARY_SUFFIX}
    )
  else()
    message(
      WARNING "strip_target: Unrecognized target type, skipping ${ARG_TARGET}")
    return()
  endif()

  if(ARG_OUTPUT_DIR)
    set(stripped_output ${ARG_OUTPUT_DIR}/${target_output_name})
  else()
    set(stripped_output ${output_file})
  endif()

  # Add custom command to strip symbols
  add_custom_command(
    TARGET ${ARG_TARGET}
    POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E echo
            "🔧 Stripping ${output_file} → ${stripped_output}"
    COMMAND ${CMAKE_STRIP} -s -o ${stripped_output} ${output_file}
    COMMENT "Stripping symbols from ${ARG_TARGET} (Release build)")

  message(
    STATUS
      "✅ Set up stripping for target '${ARG_TARGET}' to '${stripped_output}'")
endfunction()
