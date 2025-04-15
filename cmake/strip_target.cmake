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


  # add -s -Os for stripping on binary releases
  
  message(STATUS "Set up stripping for ${ARG_TARGET}")
endfunction()