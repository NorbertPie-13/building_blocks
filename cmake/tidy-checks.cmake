# Function to configure clang-tidy and other static analysis tools Usage:
# tidy_checks( [TARGET target_name] [CHECKS check1,check2,...] [EXCLUDE_CHECKS
# exclude1,exclude2,...] [CONFIG_FILE path/to/.clang-tidy] [EXTRA_ARGS arg1 arg2
# ...] [HEADER_FILTER regex] [FIX] [FIX_ERRORS] [FORMAT_STYLE
# llvm|google|webkit|mozilla|none] [QUIET] [WARNINGS_AS_ERRORS *]
# [ANALYZE_HEADERS] [CPPCHECK] [CPPCHECK_OPTIONS option1 option2 ...] [IWYU]
# [IWYU_OPTIONS option1 option2 ...] [CPPLINT] [CPPLINT_OPTIONS option1 option2
# ...] )
function(tidy_checks)
  # Define the options and their values
  set(options CPPCHECK IWYU)
  set(oneValueArgs TARGET CONFIG_FILE HEADER_FILTER FORMAT_STYLE
                   WARNINGS_AS_ERRORS)
  set(multiValueArgs CPPCHECK_OPTIONS IWYU_OPTIONS)

  # Parse the arguments
  cmake_parse_arguments(ARG "${options}" "${oneValueArgs}" "${multiValueArgs}"
                        ${ARGN})

  # Check for other analysis tools
  set(USE_CPPCHECK FALSE)
  set(USE_IWYU FALSE)

  # Configure cppcheck if requested

  find_program(CPPCHECK_EXECUTABLE NAMES cppcheck)
  if(CPPCHECK_EXECUTABLE)
    set(USE_CPPCHECK TRUE)
    set(CPPCHECK_COMMAND "${CPPCHECK_EXECUTABLE}")
    # Default cppcheck options
    set(CPPCHECK_ARGS "--enable=all" "--inline-suppr"
                      "--suppress=missingIncludeSystem")
    message(
      WARNING "tidy_checks: cppcheck not found, this tool will be skipped")
  endif()

  # Configure include-what-you-use if requested
  find_program(IWYU_EXECUTABLE NAMES include-what-you-use iwyu)
  if(IWYU_EXECUTABLE)
    set(USE_IWYU TRUE)
    set(IWYU_COMMAND "${IWYU_EXECUTABLE}")

    # Default IWYU options
    set(IWYU_ARGS "-Xiwyu" "--no_comments")

  else()
    message(
      WARNING
        "tidy_checks: include-what-you-use not found, this tool will be skipped"
    )
  endif()

endfunction()
