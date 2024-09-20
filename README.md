# Hevy C++ Client

Just wanted to play around with RESTful APIs in C++. So I decided to create a client for a service I already use, [Hevy](https://www.hevyapp.com/).

## Toolchain

- Language: C++23
- Dependencies:
  - JSON: [nlohmann/json](https://github.com/nlohmann/json)
  - HTTP: [yhirose/cpp-httplib](https://github.com/yhirose/cpp-httplib)
  - UI: [ocornut/imgui](https://github.com/ocornut/imgui) and [glfw](https://github.com/glfw/glfw.git)
  - Testing: [catchorg/Catch2](https://github.com/catchorg/Catch2)
- Build system: CMake

## Building

Create `.env` in the root of your project which defines your Hevy App API key:

```
HEVY_API_KEY=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
```

## License

This project is licensed under the [MIT License](./LICENSE).
