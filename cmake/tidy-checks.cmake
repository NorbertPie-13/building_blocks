# Function to configure clang-tidy and other static analysis tools
# Usage:
# tidy_checks(
#   [TARGET target_name]
#   [CHECKS check1,check2,...]
#   [EXCLUDE_CHECKS exclude1,exclude2,...]
#   [CONFIG_FILE path/to/.clang-tidy]
#   [EXTRA_ARGS arg1 arg2 ...]
#   [HEADER_FILTER regex]
#   [FIX]
#   [FIX_ERRORS]
#   [FORMAT_STYLE llvm|google|webkit|mozilla|none]
#   [QUIET]
#   [WARNINGS_AS_ERRORS *]
#   [ANALYZE_HEADERS]
#   [CPPCHECK]
#   [CPPCHECK_OPTIONS option1 option2 ...]
#   [IWYU]
#   [IWYU_OPTIONS option1 option2 ...]
#   [CPPLINT]
#   [CPPLINT_OPTIONS option1 option2 ...]
# )
function(tidy_checks)
  # Define the options and their values
  set(options FIX FIX_ERRORS QUIET ANALYZE_HEADERS CPPCHECK IWYU CPPLINT)
  set(oneValueArgs TARGET CONFIG_FILE HEADER_FILTER FORMAT_STYLE WARNINGS_AS_ERRORS)
  set(multiValueArgs CHECKS EXCLUDE_CHECKS EXTRA_ARGS CPPCHECK_OPTIONS IWYU_OPTIONS CPPLINT_OPTIONS)
  
  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Find clang-tidy
  find_program(CLANG_TIDY_EXECUTABLE NAMES clang-tidy clang-tidy-14 clang-tidy-13 clang-tidy-12)
  if(NOT CLANG_TIDY_EXECUTABLE)
    message(WARNING "tidy_checks: clang-tidy not found, static analysis will be disabled")
    return()
  endif()
  
  # Determine the scope (target or global)
  if(ARG_TARGET)
    # Check if the target exists
    if(NOT TARGET ${ARG_TARGET})
      message(FATAL_ERROR "tidy_checks: Target '${ARG_TARGET}' does not exist")
    endif()
    
    set(scope_type TARGET)
    set(message_prefix "Target ${ARG_TARGET}")
  else()
    set(scope_type "")
    set(message_prefix "Global")
  endif()
  
  # Set default checks if not specified
  if(NOT ARG_CHECKS)
    set(ARG_CHECKS "bugprone-*,cert-*,cppcoreguidelines-*,modernize-*,performance-*,portability-*,readability-*")
  endif()
  
  # Start building clang-tidy command
  set(CLANG_TIDY_COMMAND "${CLANG_TIDY_EXECUTABLE}")
  
  # Add checks
  list(APPEND CLANG_TIDY_ARGS "--checks=${ARG_CHECKS}")
  
  # Add exclude checks if specified
  if(ARG_EXCLUDE_CHECKS)
    list(APPEND CLANG_TIDY_ARGS "--checks=-${ARG_EXCLUDE_CHECKS}")
  endif()
  
  # Add config file if specified
  if(ARG_CONFIG_FILE)
    if(EXISTS "${ARG_CONFIG_FILE}")
      list(APPEND CLANG_TIDY_ARGS "--config-file=${ARG_CONFIG_FILE}")
    else()
      message(WARNING "tidy_checks: Config file '${ARG_CONFIG_FILE}' not found, using default config")
    endif()
  endif()
  
  # Add fix options if specified
  if(ARG_FIX)
    list(APPEND CLANG_TIDY_ARGS "--fix")
  endif()
  
  if(ARG_FIX_ERRORS)
    list(APPEND CLANG_TIDY_ARGS "--fix-errors")
  endif()
  
  # Add header filter if specified
  if(ARG_HEADER_FILTER)
    list(APPEND CLANG_TIDY_ARGS "--header-filter=${ARG_HEADER_FILTER}")
  endif()
  
  # Add format style if specified
  if(ARG_FORMAT_STYLE)
    list(APPEND CLANG_TIDY_ARGS "--format-style=${ARG_FORMAT_STYLE}")
  endif()
  
  # Add warnings-as-errors if specified
  if(ARG_WARNINGS_AS_ERRORS)
    list(APPEND CLANG_TIDY_ARGS "--warnings-as-errors=${ARG_WARNINGS_AS_ERRORS}")
  endif()
  
  # Add extra arguments if specified
  if(ARG_EXTRA_ARGS)
    list(APPEND CLANG_TIDY_ARGS ${ARG_EXTRA_ARGS})
  endif()
  
  # Add quiet option if specified
  if(ARG_QUIET)
    list(APPEND CLANG_TIDY_ARGS "--quiet")
  endif()
  
  # Configure clang-tidy
  string(REPLACE ";" "," CLANG_TIDY_ARGS_STR "${CLANG_TIDY_ARGS}")
  set(CLANG_TIDY_COMMAND_STR "${CLANG_TIDY_EXECUTABLE},${CLANG_TIDY_ARGS_STR}")
  
  # Check for other analysis tools
  set(USE_CPPCHECK FALSE)
  set(USE_IWYU FALSE)
  set(USE_CPPLINT FALSE)
  
  # Configure cppcheck if requested
  if(ARG_CPPCHECK)
    find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)
    if(CPPCHECK_EXECUTABLE)
      set(USE_CPPCHECK TRUE)
      set(CPPCHECK_COMMAND "${CPPCHECK_EXECUTABLE}")
      
      # Default cppcheck options
      set(CPPCHECK_ARGS "--enable=all" "--inline-suppr" "--suppress=missingIncludeSystem")
      
      # Add user-specified options
      if(ARG_CPPCHECK_OPTIONS)
        list(APPEND CPPCHECK_ARGS ${ARG_CPPCHECK_OPTIONS})
      endif()
      
      string(REPLACE ";" "," CPPCHECK_ARGS_STR "${CPPCHECK_ARGS}")
      set(CPPCHECK_COMMAND_STR "${CPPCHECK_EXECUTABLE},${CPPCHECK_ARGS_STR}")
    else()
      message(WARNING "tidy_checks: cppcheck not found, this tool will be skipped")
    endif()
  endif()
  
  # Configure include-what-you-use if requested
  if(ARG_IWYU)
    find_program(IWYU_EXECUTABLE NAMES include-what-you-use iwyu)
    if(IWYU_EXECUTABLE)
      set(USE_IWYU TRUE)
      set(IWYU_COMMAND "${IWYU_EXECUTABLE}")
      
      # Default IWYU options
      set(IWYU_ARGS "-Xiwyu" "--no_comments")
      
      # Add user-specified options
      if(ARG_IWYU_OPTIONS)
        list(APPEND IWYU_ARGS ${ARG_IWYU_OPTIONS})
      endif()
      
      string(REPLACE ";" "," IWYU_ARGS_STR "${IWYU_ARGS}")
      set(IWYU_COMMAND_STR "${IWYU_EXECUTABLE},${IWYU_ARGS_STR}")
    else()
      message(WARNING "tidy_checks: include-what-you-use not found, this tool will be skipped")
    endif()
  endif()
  
  # Configure cpplint if requested
  if(ARG_CPPLINT)
    find_program(CPPLINT_EXECUTABLE NAMES cpplint cpplint.py)
    if(CPPLINT_EXECUTABLE)
      set(USE_CPPLINT TRUE)
      set(CPPLINT_COMMAND "${CPPLINT_EXECUTABLE}")
      
      # Default cpplint options
      set(CPPLINT_ARGS "--filter=-legal/copyright,-build/include_order")
      
      # Add user-specified options
      if(ARG_CPPLINT_OPTIONS)
        list(APPEND CPPLINT_ARGS ${ARG_CPPLINT_OPTIONS})
      endif()
      
      string(REPLACE ";" "," CPPLINT_ARGS_STR "${CPPLINT_ARGS}")
      set(CPPLINT_COMMAND_STR "${CPPLINT_EXECUTABLE},${CPPLINT_ARGS_STR}")
    else()
      message(WARNING "tidy_checks: cpplint not found, this tool will be skipped")
    endif()
  endif()
  
  # Set combined analyzer commands
  set(ANALYZER_COMMANDS "")
  
  # Always add clang-tidy
  list(APPEND ANALYZER_COMMANDS "${CLANG_TIDY_COMMAND_STR}")
  
  # Add other tools if enabled
  if(USE_CPPCHECK)
    list(APPEND ANALYZER_COMMANDS "${CPPCHECK_COMMAND_STR}")
  endif()
  
  if(USE_IWYU)
    list(APPEND ANALYZER_COMMANDS "${IWYU_COMMAND_STR}")
  endif()
  
  if(USE_CPPLINT)
    list(APPEND ANALYZER_COMMANDS "${CPPLINT_COMMAND_STR}")
  endif()
  
  # Join the commands with semicolons
  string(REPLACE ";" ";" ANALYZER_COMMANDS_STR "${ANALYZER_COMMANDS}")
  
  # Apply the analyzers
  if(ARG_TARGET)
    # Apply to specific target
    set_target_properties(${ARG_TARGET} PROPERTIES
      CXX_CLANG_TIDY "${CLANG_TIDY_COMMAND};${CLANG_TIDY_ARGS}"
    )
    
    if(USE_CPPCHECK)
      set_target_properties(${ARG_TARGET} PROPERTIES
        CXX_CPPCHECK "${CPPCHECK_COMMAND};${CPPCHECK_ARGS}"
      )
    endif()
    
    if(USE_IWYU)
      set_target_properties(${ARG_TARGET} PROPERTIES
        CXX_INCLUDE_WHAT_YOU_USE "${IWYU_COMMAND};${IWYU_ARGS}"
      )
    endif()
    
    if(USE_CPPLINT)
      set_target_properties(${ARG_TARGET} PROPERTIES
        CXX_CPPLINT "${CPPLINT_COMMAND};${CPPLINT_ARGS}"
      )
    endif()
    
    message(STATUS "${message_prefix}: Static analysis configured with: ${ANALYZER_COMMANDS}")
  else()
    # Apply globally
    set(CMAKE_CXX_CLANG_TIDY "${CLANG_TIDY_COMMAND};${CLANG_TIDY_ARGS}")
    
    if(USE_CPPCHECK)
      set(CMAKE_CXX_CPPCHECK "${CPPCHECK_COMMAND};${CPPCHECK_ARGS}")
    endif()
    
    if(USE_IWYU)
      set(CMAKE_CXX_INCLUDE_WHAT_YOU_USE "${IWYU_COMMAND};${IWYU_ARGS}")
    endif()
    
    if(USE_CPPLINT)
      set(CMAKE_CXX_CPPLINT "${CPPLINT_COMMAND};${CPPLINT_ARGS}")
    endif()
    
    message(STATUS "${message_prefix}: Static analysis configured with: ${ANALYZER_COMMANDS}")
  endif()
  
  # Create custom targets to run analysis manually
  if(ARG_TARGET)
    set(analysis_target_name analyze_${ARG_TARGET})
    
    # Create a custom target to run all analyzers
    if(NOT TARGET ${analysis_target_name})
      get_target_property(target_sources ${ARG_TARGET} SOURCES)
      get_target_property(target_source_dir ${ARG_TARGET} SOURCE_DIR)
      
      # Create an analyze target that runs all tools
      add_custom_target(${analysis_target_name}
        COMMENT "Running static analysis on ${ARG_TARGET}"
        COMMAND ${CMAKE_COMMAND} -E echo "Running clang-tidy on ${ARG_TARGET}..."
        COMMAND ${CLANG_TIDY_COMMAND} ${CLANG_TIDY_ARGS} ${target_sources}
        WORKING_DIRECTORY ${target_source_dir}
        VERBATIM
      )
      
      # Add additional tools if enabled
      if(USE_CPPCHECK)
        add_custom_command(
          TARGET ${analysis_target_name}
          COMMAND ${CMAKE_COMMAND} -E echo "Running cppcheck on ${ARG_TARGET}..."
          COMMAND ${CPPCHECK_COMMAND} ${CPPCHECK_ARGS} ${target_sources}
          WORKING_DIRECTORY ${target_source_dir}
          VERBATIM
        )
      endif()
      
      if(USE_IWYU)
        add_custom_command(
          TARGET ${analysis_target_name}
          COMMAND ${CMAKE_COMMAND} -E echo "Running include-what-you-use on ${ARG_TARGET}..."
          COMMAND ${IWYU_COMMAND} ${IWYU_ARGS} ${target_sources}
          WORKING_DIRECTORY ${target_source_dir}
          VERBATIM
        )
      endif()
      
      if(USE_CPPLINT)
        add_custom_command(
          TARGET ${analysis_target_name}
          COMMAND ${CMAKE_COMMAND} -E echo "Running cpplint on ${ARG_TARGET}..."
          COMMAND ${CPPLINT_COMMAND} ${CPPLINT_ARGS} ${target_sources}
          WORKING_DIRECTORY ${target_source_dir}
          VERBATIM
        )
      endif()
      
      # Create a global analyze target if it doesn't exist
      if(NOT TARGET analyze_all)
        add_custom_target(analyze_all)
      endif()
      
      # Add our target as a dependency of analyze_all
      add_dependencies(analyze_all ${analysis_target_name})
    endif()
  endif()
  
  # Create a custom target for generating a .clang-tidy config file
  if(NOT TARGET generate_clang_tidy_config)
    add_custom_target(generate_clang_tidy_config
      COMMAND ${CMAKE_COMMAND} -E echo "---" > .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "Checks: '${ARG_CHECKS}'" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "WarningsAsErrors: ''" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "HeaderFilterRegex: '${ARG_HEADER_FILTER}'" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "FormatStyle: ${ARG_FORMAT_STYLE}" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "CheckOptions:" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "  - key: readability-identifier-naming.ClassCase" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "    value: CamelCase" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "  - key: readability-identifier-naming.MethodCase" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "    value: camelBack" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "  - key: readability-identifier-naming.VariableCase" >> .clang-tidy
      COMMAND ${CMAKE_COMMAND} -E echo "    value: camelBack" >> .clang-tidy
      WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
      COMMENT "Generating .clang-tidy configuration file"
      VERBATIM
    )
  endif()
endfunction()

# Helper function to exclude specific files from static analysis
# Usage:
# exclude_from_analysis(
#   TARGET target_name
#   FILES file1.cpp file2.cpp ...
# )
function(exclude_from_analysis)
  # Define the options and their values
  set(options "")
  set(oneValueArgs TARGET)
  set(multiValueArgs FILES)
  
  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
  
  # Validate required arguments
  if(NOT ARG_TARGET)
    message(FATAL_ERROR "exclude_from_analysis: TARGET not specified")
  endif()
  
  if(NOT ARG_FILES)
    message(FATAL_ERROR "exclude_from_analysis: FILES not specified")
  endif()
  
  # Check if the target exists
  if(NOT TARGET ${ARG_TARGET})
    message(FATAL_ERROR "exclude_from_analysis: Target '${ARG_TARGET}' does not exist")
  endif()
  
  # Process each file to exclude from analysis
  foreach(file ${ARG_FILES})
    if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/${file}")
      # Get absolute path to the file
      get_filename_component(file_absolute "${CMAKE_CURRENT_SOURCE_DIR}/${file}" ABSOLUTE)
      
      # Set properties to disable analysis for the file
      set_source_files_properties(${file_absolute} PROPERTIES
        C_CLANG_TIDY ""                            # Disable clang-tidy for C files
        CXX_CLANG_TIDY ""                          # Disable clang-tidy for C++ files
        C_CPPCHECK ""                              # Disable cppcheck for C files
        CXX_CPPCHECK ""                            # Disable cppcheck for C++ files
        C_INCLUDE_WHAT_YOU_USE ""                  # Disable IWYU for C files
        CXX_INCLUDE_WHAT_YOU_USE ""                # Disable IWYU for C++ files
        C_CPPLINT ""                               # Disable cpplint for C files
        CXX_CPPLINT ""                             # Disable cpplint for C++ files
        SKIP_LINTING ON                            # Generic property for custom linters
      )
      
      message(STATUS "Disabled static analysis for file: ${file}")
    else()
      message(WARNING "File not found: ${CMAKE_CURRENT_SOURCE_DIR}/${file}")
    endif()
  endforeach()
endfunction()
