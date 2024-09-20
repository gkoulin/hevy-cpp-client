add_executable(model.generator.api api.cpp)
target_link_libraries(model.generator.api PRIVATE common httplib nlohmann_json)

set(generated_header "${CMAKE_CURRENT_BINARY_DIR}/generated/generated_hevy_api.h")

find_program(clang_format_exe clang-format)

set(generate_cmd
    $<TARGET_FILE:model.generator.api>
    --source
    "${CMAKE_CURRENT_SOURCE_DIR}/source.json"
    --output
    "${generated_header}")
if(clang_format_exe)
  list(
    APPEND
    generate_cmd
    &&
    ${clang_format_exe}
    -i
    ${generated_header})
endif()

add_custom_command(
  OUTPUT ${generated_header}
  DEPENDS model.generator.api
  COMMAND ${generate_cmd}
  COMMENT "Generating: ${generated_header}")
add_custom_target(model.generated.header ALL DEPENDS ${generated_header} model.generator.api)

add_library(model.generated INTERFACE ${generated_header})
add_dependencies(model.generated model.generated.header)
target_include_directories(model.generated INTERFACE ${CMAKE_CURRENT_BINARY_DIR}/generated)
