if(BUILD_TESTING)
  include(CTest)

  option(NO_POST_BUILD_TEST_RUN "Disable post build test run" OFF)

  set(TEST_BIN_DIR "${CMAKE_BINARY_DIR}/test-bin" CACHE INTERNAL "Binary directory for testing.")
  file(MAKE_DIRECTORY ${TEST_BIN_DIR})
endif()

function(_copy_test_dependency TARGET)
  get_property(_runtime_dependencies TARGET ${TARGET} PROPERTY RUNTIME_DEPENDENCIES)

  if(_runtime_dependencies)
    add_custom_command(TARGET ${TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} ARGS -E copy_if_different
                                                           ${_runtime_dependencies} ${TEST_BIN_DIR})
  endif()
endfunction()

function(add_unit_test)
  if(NOT BUILD_TESTING)
    return()
  endif()

  # Parse args
  set(_options "")
  set(_one_value_args RUN_POST_BUILD TARGET)
  set(_multi_value_args TEST_ARGS)
  cmake_parse_arguments(
    _args
    "${_options}"
    "${_one_value_args}"
    "${_multi_value_args}"
    ${ARGN})

  if(NOT DEFINED _args_RUN_POST_BUILD)
    set(_args_RUN_POST_BUILD ON)
  endif()
  if(NO_POST_BUILD_TEST_RUN)
    set(_args_RUN_POST_BUILD OFF)
  endif()

  if(NOT DEFINED _args_TARGET)
    message(FATAL_ERROR "Argument TARGET not defined.")
  endif()

  include(RuntimeDependencies)
  set_runtime_dependencies(TARGET ${_args_TARGET})

  _copy_test_dependency(${_args_TARGET})

  set_target_properties(${_args_TARGET} PROPERTIES RUNTIME_OUTPUT_DIRECTORY ${TEST_BIN_DIR})
  set_target_properties(${_args_TARGET} PROPERTIES FOLDER "Test")

  if(_args_RUN_POST_BUILD)
    add_custom_command(
      TARGET ${_args_TARGET} POST_BUILD COMMAND ${CMAKE_COMMAND} -E echo
                                                "Running test ${_args_TARGET} as a post build step."
      COMMAND $<TARGET_FILE:${_args_TARGET}> ${_args_TEST_ARGS})
  endif()

  include(Catch)
  catch_discover_tests(${_args_TARGET} EXTRA_ARGS ${_args_TEST_ARGS})
endfunction()
