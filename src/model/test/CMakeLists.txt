if(NOT BUILD_TESTING)
  return()
endif()

add_executable(model.test quick.cpp)
target_link_libraries(model.test PRIVATE Catch2::Catch2WithMain model)

include(UnitTesting)
add_unit_test(TARGET model.test)
