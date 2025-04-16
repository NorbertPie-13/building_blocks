# Function to disable lint/clang-tidy warnings for specific files Usage:
# disable_warnings( FILES file1.cpp file2.cpp ... [TARGET target_name] )
function(disable_warnings)
  # Define the options and their values
  set(options "")
  set(oneValueArgs TARGET)
  set(multiValueArgs FILES)

  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}"
                        ${ARGN})

  # Validate required arguments
  if(NOT ARG_FILES)
    message(FATAL_ERROR "disable_warnings: FILES not specified")
  endif()

  # Process each file to disable warnings
  foreach(file ${ARG_FILES})
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
      # Get absolute path to the file
      get_filename_component(file_absolute
                             "${CMAKE_CURRENT_SOURCE_DIR}/${file}" ABSOLUTE)

      # Set properties to disable warnings for the file
      set_source_files_properties(
        ${file_absolute}
        PROPERTIES COMPILE_FLAGS "-w" # Disable all compiler warnings
                   COMPILE_OPTIONS "-Wno-everything" # For Clang specifically
      )

      # Disable clang-tidy for the file
      set_source_files_properties(
        ${file_absolute}
        PROPERTIES SKIP_LINTING ON # Generic property for custom linters
                   C_CLANG_TIDY "" # Disable clang-tidy for C files
                   CXX_CLANG_TIDY "" # Disable clang-tidy for C++ files
      )

      message(STATUS "Disabled warnings for file: ${file}")
    else()
      message(WARNING "File not found: ${CMAKE_CURRENT_SOURCE_DIR}/${file}")
    endif()
  endforeach()

  # If a target is specified, also set target-specific properties
  if(ARG_TARGET)
    if(TARGET ${ARG_TARGET})
      # Get target source files
      get_target_property(target_sources ${ARG_TARGET} SOURCES)

      # Filter the specified files to only those that belong to the target
      foreach(file ${ARG_FILES})
        get_filename_component(file_name "${file}" NAME)

        # Check if the file is part of the target
        foreach(target_file ${target_sources})
          get_filename_component(target_file_name "${target_file}" NAME)
          if(file_name STREQUAL target_file_name)
            list(APPEND target_filtered_files ${file})
            break()
          endif()
        endforeach()
      endforeach()

      # Add the files to a source group to make it clear they have warnings
      # disabled
      if(target_filtered_files)
        source_group("NoWarnings" FILES ${target_filtered_files})
        message(
          STATUS "Created 'NoWarnings' source group for target: ${ARG_TARGET}")
      endif()
    else()
      message(WARNING "Target not found: ${ARG_TARGET}")
    endif()
  endif()
endfunction()
