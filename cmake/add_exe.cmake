# Function to add an executable target
function(add_exe)
  # Parse arguments
  set(options "")
  set(oneValueArgs TARGET OUTPUT_NAME)
  set(multiValueArgs SOURCES INCLUDES LINK_LIBS DEFINES OPTIONS)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Validate required arguments
  if(NOT ARG_TARGET AND ARGV0)
    # Support legacy syntax where first unnamed argument is the target
    set(ARG_TARGET ${ARGV0})
  endif()
  
  if(NOT ARG_TARGET)
    message(FATAL_ERROR "add_exe: TARGET not specified")
  endif()
  
  if(NOT ARG_SOURCES)
    message(FATAL_ERROR "add_exe: SOURCES not specified for target ${ARG_TARGET}")
  endif()
  
  # Create the executable
  message(STATUS "\nAdding ${ARG_SOURCES} to ${ARG_TARGET}\n\n")
  add_executable(${ARG_TARGET} ${ARG_SOURCES})
  

  # Set output name if specified
  if(ARG_OUTPUT_NAME)
    set_target_properties(${ARG_TARGET} PROPERTIES OUTPUT_NAME ${ARG_OUTPUT_NAME})
  endif()
  message(STATUS "Output name: ${ARG_OUTPUT_NAME}")
  
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
    RUNTIME DESTINATION bin
  )
endfunction()