cmake_minimum_required(VERSION 3.26)
project(hevy-cpp-client)

option(BUILD_TESTING "Enable testing" OFF)
if(BUILD_TESTING)
  enable_testing()
endif()

add_subdirectory(src)
