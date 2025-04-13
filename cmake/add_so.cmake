# Function to add a shared library target
function(add_so)
  # Parse arguments
  set(options "")
  set(oneValueArgs TARGET OUTPUT_NAME VERSION SOVERSION)
  set(multiValueArgs SOURCES INCLUDES LINK_LIBS DEFINES OPTIONS)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Validate required arguments
  if(NOT ARG_TARGET AND ARGV0)
    # Support legacy syntax where first unnamed argument is the target
    set(ARG_TARGET ${ARGV0})
  endif()
  
  if(NOT ARG_TARGET)
    message(FATAL_ERROR "add_so: TARGET not specified")
  endif()
  
  if(NOT ARG_SOURCES AND ARG_TARGET)
    message(FATAL_ERROR "add_so: SOURCES not specified for target ${ARG_TARGET}")
  endif()
  
  # Create shared library
  add_library(${ARG_TARGET} SHARED ${ARG_SOURCES})
  
  # Set output name if specified
  if(ARG_OUTPUT_NAME)
    set_target_properties(${ARG_TARGET} PROPERTIES OUTPUT_NAME ${ARG_OUTPUT_NAME})
  endif()
  
  # Set version and soversion if specified
  if(ARG_VERSION)
    set_target_properties(${ARG_TARGET} PROPERTIES VERSION ${ARG_VERSION})
  endif()
  
  if(ARG_SOVERSION)
    set_target_properties(${ARG_TARGET} PROPERTIES SOVERSION ${ARG_SOVERSION})
  elseif(ARG_VERSION)
    # Extract major version number as soversion
    string(REGEX MATCH "^[0-9]+" major_version "${ARG_VERSION}")
    if(major_version)
      set_target_properties(${ARG_TARGET} PROPERTIES SOVERSION ${major_version})
    endif()
  endif()
  
  # Add include directories
  if(ARG_INCLUDES)
    target_include_directories(${ARG_TARGET} PUBLIC ${ARG_INCLUDES})
  endif()
  
  # Link libraries
  if(ARG_LINK_LIBS)
    target_link_libraries(${ARG_TARGET} PUBLIC ${ARG_LINK_LIBS})
  endif()
  
  # Add compile definitions
  if(ARG_DEFINES)
    target_compile_definitions(${ARG_TARGET} PRIVATE ${ARG_DEFINES})
  endif()
  
  # Add compile options
  if(ARG_OPTIONS)
    target_compile_options(${ARG_TARGET} PRIVATE ${ARG_OPTIONS})
  endif()
  
  # Set default install location if not explicitly set elsewhere
  install(TARGETS ${ARG_TARGET}
    LIBRARY DESTINATION lib
    PUBLIC_HEADER DESTINATION include
  )
endfunction()