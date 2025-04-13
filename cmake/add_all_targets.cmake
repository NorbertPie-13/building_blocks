function(add_all_targets)
  # Parse function arguments
  set(options STRIP_RELEASE)
  set(oneValueArgs LIB_NAME EXE_NAME LIB_DESTINATION EXE_DESTINATION PUBLIC_HEADER)
  set(multiValueArgs LIB_SOURCES LIB_INCLUDES EXE_SOURCES EXE_INCLUDES)
  
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})


  # Apply defaults for missing arguments
  if(NOT DEFINED ARG_LIB_NAME)
    set(ARG_LIB_NAME "project3_lib")
  endif()
  
  if(NOT DEFINED ARG_EXE_NAME)
    set(ARG_EXE_NAME "project3")
  endif()
  
  if(NOT DEFINED ARG_LIB_DESTINATION)
    set(ARG_LIB_DESTINATION "lib")
  endif()
  
  if(NOT DEFINED ARG_EXE_DESTINATION)
    set(ARG_EXE_DESTINATION "bin")
  endif()
  
  # Add library as a shared object
  add_so(${ARG_LIB_NAME} 
    SOURCES ${ARG_LIB_SOURCES}
    INCLUDES ${ARG_LIB_INCLUDES}
  )
  
  # Set public headers for the library (if provided)
  if(DEFINED ARG_PUBLIC_HEADER)
    set_target_properties(${ARG_LIB_NAME} PROPERTIES
      PUBLIC_HEADER "${ARG_PUBLIC_HEADER}"
    )
  endif()
  
  # Add executable
  add_exe(TARGET ${ARG_EXE_NAME}
    SOURCES ${ARG_EXE_SOURCES}
    INCLUDES ${ARG_EXE_INCLUDES}
    OUTPUT_NAME ${ARG_EXE_NAME}
  )

  
  
  
  # Link executable against the library
  target_link_libraries(${ARG_EXE_NAME} PRIVATE ${ARG_LIB_NAME})
  
  # Configure installation
  install_target(TARGET ${ARG_LIB_NAME} DESTINATION ${ARG_LIB_DESTINATION})
  install_target(TARGET ${ARG_EXE_NAME} DESTINATION ${ARG_EXE_DESTINATION})
  
  # Apply compiler options based on build type
  if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    set_default_debug_options(TARGET ${ARG_LIB_NAME})
    set_default_debug_options(TARGET ${ARG_EXE_NAME})
  else()
    set_default_release_options(TARGET ${ARG_LIB_NAME})
    set_default_release_options(TARGET ${ARG_EXE_NAME})
    
    # Strip symbols from executables in Release mode if requested
    if(ARG_STRIP_RELEASE)
      strip_target(TARGET ${ARG_EXE_NAME})
    endif()
  endif()
  
  message(STATUS "All targets added successfully")
endfunction()