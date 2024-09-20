add_library(model INTERFACE)
target_link_libraries(model INTERFACE common httplib nlohmann_json model.generated)

