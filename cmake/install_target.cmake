# Function to install a target to a specific directory structure
# Usage:
# install_target(
#   TARGET target_name
#   DESTINATION path/to/install
#   [COMPONENT component_name]
#   [CONFIGURATIONS Release Debug RelWithDebInfo MinSizeRel]
#   [PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE]
#   [RENAME new_name]
#   [OPTIONAL]
#   [EXPORT export_name]
#   [REMOTE_DESTINATION user@host:/path/to/remote]
#   [EXCLUDE_FROM_ALL]
# )
function(install_target)
  # Define the options and their values
  set(options OPTIONAL EXCLUDE_FROM_ALL)
  set(oneValueArgs TARGET DESTINATION COMPONENT RENAME EXPORT REMOTE_DESTINATION)
  set(multiValueArgs CONFIGURATIONS PERMISSIONS)
  
  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Validate required arguments
  if(NOT ARG_TARGET)
    message(FATAL_ERROR "install_target: TARGET not specified")
  endif()
  
  if(NOT ARG_DESTINATION)
    message(FATAL_ERROR "install_target: DESTINATION not specified")
  endif()
  
  # Check if the target exists
  if(NOT TARGET ${ARG_TARGET})
    message(FATAL_ERROR "install_target: Target '${ARG_TARGET}' does not exist")
  endif()
  
  # Determine target type (executable, library, etc.)
  get_target_property(target_type ${ARG_TARGET} TYPE)
  
  # Setup the install parameters based on target type
  set(install_params TARGETS ${ARG_TARGET})
  
  if(target_type STREQUAL "EXECUTABLE")
    list(APPEND install_params RUNTIME)
  elseif(target_type STREQUAL "STATIC_LIBRARY")
    list(APPEND install_params ARCHIVE)
  elseif(target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY")
    list(APPEND install_params LIBRARY)
  else()
    # Default to RUNTIME if we can't determine the type
    list(APPEND install_params RUNTIME)
  endif()
  
  # Add the destination
  list(APPEND install_params DESTINATION ${ARG_DESTINATION})
  
  # Add optional parameters if specified
  if(ARG_COMPONENT)
    list(APPEND install_params COMPONENT ${ARG_COMPONENT})
  endif()
  
  if(ARG_CONFIGURATIONS)
    list(APPEND install_params CONFIGURATIONS ${ARG_CONFIGURATIONS})
  endif()
  
  if(ARG_PERMISSIONS)
    list(APPEND install_params PERMISSIONS ${ARG_PERMISSIONS})
  endif()
  
  if(ARG_OPTIONAL)
    list(APPEND install_params OPTIONAL)
  endif()
  
  if(ARG_EXCLUDE_FROM_ALL)
    list(APPEND install_params EXCLUDE_FROM_ALL)
  endif()
  
  if(ARG_RENAME)
    list(APPEND install_params RENAME ${ARG_RENAME})
  endif()
  
  if(ARG_EXPORT)
    list(APPEND install_params EXPORT ${ARG_EXPORT})
  endif()
  
  # Call the install command with the accumulated parameters
  install(${install_params})
  
  # If a remote destination is specified, add a custom target for remote deployment
  if(ARG_REMOTE_DESTINATION)
    # Get the actual installed file name
    if(ARG_RENAME)
      set(installed_name ${ARG_RENAME})
    else()
      get_target_property(installed_name ${ARG_TARGET} OUTPUT_NAME)
      if(NOT installed_name)
        set(installed_name ${ARG_TARGET})
      endif()
    endif()
    
    # Add prefix/suffix based on target type
    if(target_type STREQUAL "SHARED_LIBRARY" OR target_type STREQUAL "MODULE_LIBRARY")
      set(installed_name ${CMAKE_SHARED_LIBRARY_PREFIX}${installed_name}${CMAKE_SHARED_LIBRARY_SUFFIX})
    elseif(target_type STREQUAL "STATIC_LIBRARY")
      set(installed_name ${CMAKE_STATIC_LIBRARY_PREFIX}${installed_name}${CMAKE_STATIC_LIBRARY_SUFFIX})
    elseif(target_type STREQUAL "EXECUTABLE")
      set(installed_name ${CMAKE_EXECUTABLE_PREFIX}${installed_name}${CMAKE_EXECUTABLE_SUFFIX})
    endif()
    
    # Create a deployment target
    set(deploy_target_name deploy_${ARG_TARGET})
    
    # Check if deploy target already exists
    if(NOT TARGET ${deploy_target_name})
      add_custom_target(${deploy_target_name}
        COMMENT "Deploying ${ARG_TARGET} to ${ARG_REMOTE_DESTINATION}"
        COMMAND scp -r ${CMAKE_INSTALL_PREFIX}/${ARG_DESTINATION}/${installed_name} ${ARG_REMOTE_DESTINATION}
        DEPENDS ${ARG_TARGET}
      )
      
      # Create a global deploy target if it doesn't exist
      if(NOT TARGET deploy_all)
        add_custom_target(deploy_all)
      endif()
      
      # Add our target as a dependency of deploy_all
      add_dependencies(deploy_all ${deploy_target_name})
      
      message(STATUS "Created deployment target '${deploy_target_name}' for ${ARG_TARGET}")
    endif()
  endif()
  
  # Create release directory structure if needed
  if(ARG_DESTINATION MATCHES "^release/")
    # Extract the relative path within the release directory
    string(REGEX REPLACE "^release/" "" rel_path "${ARG_DESTINATION}")
    
    # Create a target to ensure the directory exists during install
    set(dir_target ensure_dir_${ARG_TARGET})
    if(NOT TARGET ${dir_target})
      add_custom_target(${dir_target} ALL
        COMMAND ${CMAKE_COMMAND} -E make_directory ${CMAKE_INSTALL_PREFIX}/${ARG_DESTINATION}
      )
      
      # Make sure the directory is created before installation
      install(CODE "execute_process(COMMAND \"${CMAKE_COMMAND}\" --build \"${CMAKE_BINARY_DIR}\" --target ${dir_target})")
    endif()
  endif()
  
  message(STATUS "Set up installation for ${ARG_TARGET} to ${ARG_DESTINATION}")
endfunction()