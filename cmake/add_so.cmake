function(add_so)
  # Parse arguments
  set(options "")
  set(oneValueArgs TARGET OUTPUT_NAME VERSION SOVERSION HEADER_DEST)
  set(multiValueArgs SOURCES INCLUDES LINK_LIBS DEFINES OPTIONS)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}"
                        ${ARGN})

  # Support legacy syntax: unnamed first arg as target
  if(NOT ARG_TARGET AND ARGV0)
    set(ARG_TARGET ${ARGV0})
  endif()

  if(NOT HEADER_DEST)
    set(ARG_HEADER_DEST include)
  endif()

  # Validation
  if(NOT ARG_TARGET)
    message(FATAL_ERROR "add_so: TARGET not specified")
  elseif(NOT ARG_SOURCES)
    message(
      FATAL_ERROR "add_so: SOURCES not specified for target ${ARG_TARGET}")
  endif()

  # Add shared library
  add_library(${ARG_TARGET} SHARED ${ARG_SOURCES})
  message(STATUS "📦 Created shared library target: ${ARG_TARGET}")

  # Set target properties
  if(ARG_OUTPUT_NAME)
    set_target_properties(${ARG_TARGET} PROPERTIES OUTPUT_NAME
                                                   ${ARG_OUTPUT_NAME})
  endif()

  if(ARG_VERSION)
    set_target_properties(${ARG_TARGET} PROPERTIES VERSION ${ARG_VERSION})
  endif()

  if(ARG_SOVERSION)
    set_target_properties(${ARG_TARGET} PROPERTIES SOVERSION ${ARG_SOVERSION})
  elseif(ARG_VERSION)
    string(REGEX MATCH "^[0-9]+" major_version "${ARG_VERSION}")
    if(major_version)
      set_target_properties(${ARG_TARGET} PROPERTIES SOVERSION ${major_version})
    endif()
  endif()

  # Include directories
  if(ARG_INCLUDES)
    target_include_directories(${ARG_TARGET} PUBLIC ${ARG_INCLUDES})
  endif()

  # Link libraries
  if(ARG_LINK_LIBS)
    target_link_libraries(${ARG_TARGET} PUBLIC ${ARG_LINK_LIBS})
  endif()

  # Compile definitions
  if(ARG_DEFINES)
    target_compile_definitions(${ARG_TARGET} PRIVATE ${ARG_DEFINES})
  endif()

  # Compile options
  if(ARG_OPTIONS)
    target_compile_options(${ARG_TARGET} PRIVATE ${ARG_OPTIONS})
  endif()

  # Install install(TARGETS ${ARG_TARGET} LIBRARY DESTINATION lib PUBLIC_HEADER
  # DESTINATION ${ARG_HEADER_DEST} )
endfunction()
