function(install_target)
  set(options OPTIONAL EXCLUDE_FROM_ALL)
  set(oneValueArgs TARGET DESTINATION COMPONENT RENAME EXPORT REMOTE_DESTINATION)
  set(multiValueArgs CONFIGURATIONS PERMISSIONS)
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

  if(NOT ARG_TARGET)
    message(FATAL_ERROR "install_target: TARGET not specified")
  endif()
  if(NOT ARG_DESTINATION)
    message(FATAL_ERROR "install_target: DESTINATION not specified")
  endif()
  if(NOT TARGET ${ARG_TARGET})
    message(FATAL_ERROR "install_target: Target '${ARG_TARGET}' does not exist")
  endif()

  get_target_property(target_type ${ARG_TARGET} TYPE)
  set(install_params TARGETS ${ARG_TARGET})

  if(target_type STREQUAL "EXECUTABLE")
    list(APPEND install_params RUNTIME)
  elseif(target_type STREQUAL "STATIC_LIBRARY")
    list(APPEND install_params ARCHIVE)
  elseif(target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY")
    list(APPEND install_params LIBRARY)
  else()
    list(APPEND install_params RUNTIME)
  endif()

  list(APPEND install_params DESTINATION ${ARG_DESTINATION})

  foreach(opt COMPONENT CONFIGURATIONS PERMISSIONS RENAME EXPORT)
    if(ARG_${opt})
      list(APPEND install_params ${opt} ${ARG_${opt}})
    endif()
  endforeach()

  if(ARG_OPTIONAL)
    list(APPEND install_params OPTIONAL)
  endif()
  if(ARG_EXCLUDE_FROM_ALL)
    list(APPEND install_params EXCLUDE_FROM_ALL)
  endif()

  install(${install_params})

  # --- Remote Deployment ---
  if(ARG_REMOTE_DESTINATION)
    set(installed_name ${ARG_RENAME})
    if(NOT installed_name)
      get_target_property(installed_name ${ARG_TARGET} OUTPUT_NAME)
      if(NOT installed_name)
        set(installed_name ${ARG_TARGET})
      endif()
    endif()

    if(target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY")
      set(installed_name ${CMAKE_SHARED_LIBRARY_PREFIX}${installed_name}${CMAKE_SHARED_LIBRARY_SUFFIX})
    elseif(target_type STREQUAL "STATIC_LIBRARY")
      set(installed_name ${CMAKE_STATIC_LIBRARY_PREFIX}${installed_name}${CMAKE_STATIC_LIBRARY_SUFFIX})
    elseif(target_type STREQUAL "EXECUTABLE")
      set(installed_name ${CMAKE_EXECUTABLE_PREFIX}${installed_name}${CMAKE_EXECUTABLE_SUFFIX})
    endif()

    set(deploy_target_name deploy_${ARG_TARGET})
    if(NOT TARGET ${deploy_target_name})
      add_custom_target(${deploy_target_name}
        COMMENT "Deploying ${ARG_TARGET} to ${ARG_REMOTE_DESTINATION}"
        COMMAND scp -r ${CMAKE_INSTALL_PREFIX}/${ARG_DESTINATION}/${installed_name} ${ARG_REMOTE_DESTINATION}
        DEPENDS ${ARG_TARGET}
      )
      if(NOT TARGET deploy_all)
        add_custom_target(deploy_all)
      endif()
      add_dependencies(deploy_all ${deploy_target_name})
      message(STATUS "Created deployment target '${deploy_target_name}' for ${ARG_TARGET}")
    endif()
  endif()

  # --- Optional Release Directory Creation ---
  if(ARG_DESTINATION MATCHES "^release/")
    string(REGEX REPLACE "^release/" "" rel_path "${ARG_DESTINATION}")
    set(dir_target ensure_dir_${ARG_TARGET})
    if(NOT TARGET ${dir_target})
      add_custom_target(${dir_target} ALL
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${ARG_DESTINATION}
      )
      install(CODE "execute_process(COMMAND \"${CMAKE_COMMAND}\" --build \"${CMAKE_BINARY_DIR}\" --target ${dir_target})")
    endif()
  endif()

  message(STATUS "✅ Set up installation for ${ARG_TARGET} → ${ARG_DESTINATION}")
endfunction()
