list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(Externals)
include(Toolchain)
include(Env)
include(Assert)

load_env_file(${CMAKE_SOURCE_DIR}/.env)
assert_env_var(HEVY_API_KEY)

add_library(common INTERFACE)
target_link_libraries(common INTERFACE toolchain)
target_compile_definitions(common INTERFACE HEVY_API_KEY="$ENV{HEVY_API_KEY}")
target_include_directories(common INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})
add_subdirectory(model)
