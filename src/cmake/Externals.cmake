include(FetchContent)

block(PROPAGATE CMAKE_MODULE_PATH)

# ------
# Catch2
if(BUILD_TESTING)
  include(FetchContent)
  FetchContent_Declare(
    catch
    GIT_REPOSITORY https://github.com/catchorg/Catch2.git
    GIT_TAG v3.7.0)

  # Check if population has already been performed
  FetchContent_GetProperties(catch)

  if(NOT catch_POPULATED)
    # Fetch the content using previously declared details
    FetchContent_Populate(catch)

    # Catch2 doesn't support shared libs out of the box properly and fails incremental build. Set BUILD_SHARED_LIBS OFF
    # and then reinstate this flag.
    block()
    set(BUILD_SHARED_LIBS OFF)

    # Bring the populated content into the build
    add_subdirectory(${catch_SOURCE_DIR} ${catch_BINARY_DIR} EXCLUDE_FROM_ALL)
    endblock()
    list(APPEND CMAKE_MODULE_PATH "${catch_SOURCE_DIR}/extras")
  endif()
endif()

# Disable testing for externals
set(BUILD_TESTING OFF)

# -----------
# cpp-httplib
FetchContent_Declare(
  cpp-httplib
  GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
  GIT_TAG v0.18.0)
if(NOT cpp-httplib_POPULATED)
  FetchContent_Populate(cpp-httplib)
  add_subdirectory(${cpp-httplib_SOURCE_DIR} ${cpp-httplib_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

# ---- json
FetchContent_Declare(
  json
  GIT_REPOSITORY https://github.com/nlohmann/json.git
  GIT_TAG v3.11.3)
if(NOT json_POPULATED)
  FetchContent_Populate(json)
  add_subdirectory(${json_SOURCE_DIR} ${json_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

# ----- imgui
FetchContent_Declare(
  imgui
  GIT_REPOSITORY https://github.com/ocornut/imgui.git
  GIT_TAG v1.91.1-docking)
FetchContent_GetProperties(imgui)
if(NOT imgui_POPULATED)
  FetchContent_Populate(imgui)

  add_library(
    imgui STATIC
    "${imgui_SOURCE_DIR}/imgui.cpp"
    "${imgui_SOURCE_DIR}/imgui_demo.cpp"
    "${imgui_SOURCE_DIR}/imgui_draw.cpp"
    "${imgui_SOURCE_DIR}/imgui_tables.cpp"
    "${imgui_SOURCE_DIR}/imgui_widgets.cpp"
    "${imgui_SOURCE_DIR}/backends/imgui_impl_glfw.cpp"
    "${imgui_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp"
    "${imgui_SOURCE_DIR}/misc/cpp/imgui_stdlib.cpp")
  target_include_directories(imgui PUBLIC "${imgui_SOURCE_DIR}" "${imgui_SOURCE_DIR}/backends"
                                          "${imgui_SOURCE_DIR}/misc/cpp")

  target_link_libraries(imgui PRIVATE glfw ${SYSTEM_LIBS})
endif()

# ---- glfw
FetchContent_Declare(
  glfw
  GIT_REPOSITORY https://github.com/glfw/glfw.git
  GIT_TAG 3.4)
FetchContent_GetProperties(glfw)
if(NOT glfw_POPULATED)
  FetchContent_Populate(glfw)

  set(GLFW_LIBRARY_TYPE STATIC)
  set(GLFW_BUILD_DOCS OFF)
  set(GLFW_BUILD_TESTS OFF)
  set(GLFW_BUILD_EXAMPLES OFF)
  set(GLFW_INSTALL OFF)
  add_subdirectory(${glfw_SOURCE_DIR} ${glfw_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()

endblock()
