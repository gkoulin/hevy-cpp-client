function(set_runtime_dependencies)
  # Parse args
  set(_options "")
  set(_one_value_args TARGET)
  set(_multi_value_args FILES)
  cmake_parse_arguments(
    _args
    "${_options}"
    "${_one_value_args}"
    "${_multi_value_args}"
    ${ARGN})

  if(NOT DEFINED _args_TARGET)
    message(FATAL_ERROR "Argument TARGET not defined.")
  endif()

  _get_optional_interface_prefix(_optional_interface_prefix ${_args_TARGET})

  _find_runtime_dependencies(_runtime_dependencies ${_args_TARGET})

  set_property(
    TARGET ${_args_TARGET}
    APPEND
    PROPERTY ${_optional_interface_prefix}RUNTIME_DEPENDENCIES ${_runtime_dependencies})
  set_property(
    TARGET ${_args_TARGET}
    APPEND
    PROPERTY ${_optional_interface_prefix}RUNTIME_DEPENDENCIES ${_args_FILES})
endfunction()

function(get_runtime_dependencies OUT_VAR TARGET)
  _get_optional_interface_prefix(_optional_interface_prefix ${TARGET})

  get_property(
    _runtime_dependencies
    TARGET ${TARGET}
    PROPERTY ${_optional_interface_prefix}RUNTIME_DEPENDENCIES)

  set(${OUT_VAR}
      ${_runtime_dependencies}
      PARENT_SCOPE)
endfunction()

# Older versions of CMake don't like querying arbitrary properties on interface libraries. You get the following error:
# ~~~
# INTERFACE_LIBRARY targets may only have whitelisted properties.
# ~~~
# Optionally prepend interface library properties with `INTERFACE_`
function(_get_optional_interface_prefix OUT_VAR TARGET)
  set(${OUT_VAR}
      ""
      PARENT_SCOPE)

  get_property(
    _library_type
    TARGET ${TARGET}
    PROPERTY TYPE)

  if(_library_type STREQUAL "INTERFACE_LIBRARY")
    set(${OUT_VAR}
        "INTERFACE_"
        PARENT_SCOPE)
  endif()
endfunction()

function(_find_runtime_dependencies OUT_VAR TARGET)
  _get_optional_interface_prefix(_optional_interface_prefix ${TARGET})

  # Get all link libraries.
  set(_libraries "")
  get_target_property(_link_libraries ${TARGET} ${_optional_interface_prefix}LINK_LIBRARIES)

  if(_link_libraries)
    list(APPEND _libraries ${_link_libraries})
  endif()

  set(_runtime_dependencies "")

  foreach(_library ${_libraries})
    if(NOT TARGET ${_library})
      # We can only process targets
      continue()
    endif()

    get_property(
      _library_type
      TARGET ${_library}
      PROPERTY TYPE)

    if(_library_type STREQUAL "SHARED_LIBRARY")
      get_property(
        _imported_location
        TARGET ${_library}
        PROPERTY IMPORTED_LOCATION)

      if(_imported_location)
        # Must be an imported library
        list(APPEND _runtime_dependencies ${_imported_location})
      else()
        # Must be a library build in source
        list(APPEND _runtime_dependencies $<TARGET_FILE:${_library}>)
      endif()
    endif()

    get_runtime_dependencies(_library_runtime_dependencies ${_library})

    if(_library_runtime_dependencies)
      list(APPEND _runtime_dependencies ${_library_runtime_dependencies})
    endif()

    # Recurse
    _find_runtime_dependencies(_child_runtime_dependencies ${_library})
    list(APPEND _runtime_dependencies ${_child_runtime_dependencies})
  endforeach()

  list(REMOVE_DUPLICATES _runtime_dependencies)

  set(${OUT_VAR}
      ${_runtime_dependencies}
      PARENT_SCOPE)
endfunction()
