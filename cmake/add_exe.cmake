function(add_exe)
  # Argument parsing
  set(options "")
  set(oneValueArgs TARGET OUTPUT_NAME OUTPUT_PLACE)
  set(multiValueArgs SOURCES INCLUDES LINK_LIBS DEFINES OPTIONS)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}"
                        ${ARGN})

  # Legacy support: unnamed first argument = target
  if(NOT ARG_TARGET AND ARGV0)
    set(ARG_TARGET ${ARGV0})
  endif()

  # Default values
  set(ARG_OUTPUT_PLACE
      "${ARG_OUTPUT_PLACE}"
      CACHE STRING "Executable output directory")
  if(NOT ARG_OUTPUT_PLACE)
    set(ARG_OUTPUT_PLACE bin)
  endif()

  # Validation
  if(NOT ARG_TARGET)
    message(FATAL_ERROR "add_exe: TARGET not specified")
  elseif(NOT ARG_SOURCES)
    message(
      FATAL_ERROR "add_exe: SOURCES not specified for target ${ARG_TARGET}")
  endif()

  # Add executable
  add_executable(${ARG_TARGET} ${ARG_SOURCES})
  message(STATUS "🔨 Added executable target: ${ARG_TARGET}")
  message(STATUS "    Sources: ${ARG_SOURCES}")
  if(ARG_OUTPUT_NAME)
    set_target_properties(${ARG_TARGET} PROPERTIES OUTPUT_NAME
                                                   ${ARG_OUTPUT_NAME})
    message(STATUS "    Output name: ${ARG_OUTPUT_NAME}")
  endif()

  # Includes
  if(ARG_INCLUDES)
    target_include_directories(${ARG_TARGET} PUBLIC ${ARG_INCLUDES})
  endif()

  # Link libraries
  if(ARG_LINK_LIBS)
    target_link_libraries(${ARG_TARGET} PUBLIC ${ARG_LINK_LIBS})
  endif()

  # Defines
  if(ARG_DEFINES)
    target_compile_definitions(${ARG_TARGET} PRIVATE ${ARG_DEFINES})
  endif()

  # Compile options
  if(ARG_OPTIONS)
    target_compile_options(${ARG_TARGET} PRIVATE ${ARG_OPTIONS})
  endif()

  # # Install install(TARGETS ${ARG_TARGET} RUNTIME DESTINATION
  # ${ARG_OUTPUT_PLACE} )
endfunction()
