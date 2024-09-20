#include "model/common.h"
#include <httplib.h>
#include <format>
#include <iostream>
#include <nlohmann/json.hpp>

namespace
{

  using namespace nlohmann;

  json get_workouts(httplib::Client& client)
  {
    auto const path = httplib::append_query_params("/v1/workouts",
                                                   {
                                                     model::routing::get_page(1),
                                                     model::routing::get_page_size(1),
                                                   });
    auto const result = client.Get(path, model::routing::get_header());
    if (result.error() == httplib::Error::Success)
    {
      return json::parse(result->body);
    }

    throw std::runtime_error(httplib::to_string(result.error()));
  }

  struct block_scope
  {
    block_scope(std::ostream& out, std::string_view const header) : out(out)
    {
      out << std::format("\n{}\n{{\n", header);
    }

    virtual ~block_scope()
    {
      out << "};\n\n";
    }

    std::ostream& out;
  };

  struct struct_scope : public block_scope
  {
    struct_scope(std::ostream& out, std::string_view const name) : block_scope(out, std::format("struct {}", name))
    {
    }
  };

  struct namespace_scope : public block_scope
  {
    namespace_scope(std::ostream& out, std::string_view const name)
        : block_scope(out, std::format("namespace {}", name))
    {
    }
  };

  std::string generate_value(std::ostream& out, std::string_view const key, json::value_type const& value);

  std::string_view generate_object(std::ostream& out, std::string_view const key, json::value_type const& obj)
  {
    struct_scope workouts_struct(out, key);
    for (auto const& [key, value] : obj.items())
    {
      generate_value(out, key, value);
    }

    return key;
  }

  std::string array_object_name(std::string_view const array_name)
  {
    if (array_name.back() == 's')
    {
      return std::string{ array_name.substr(0, array_name.size() - 1) };
    }

    return std::format("one_of_{}", array_name);
  }

  std::string generate_array(std::ostream& out, std::string_view const key, json::array_t const& array)
  {
    std::string type = "void";
    if (array.empty())
    {
      return type;
    }
    if (auto const& first = array[0]; first.is_object())
    {
      type = array_object_name(key);
      generate_object(out, type, first);
    }

    return std::format("std::vector<{}>", type);
  }

  std::string generate_value(std::ostream& out, std::string_view const key, json::value_type const& value)
  {
    std::string type = "int";
    if (value.is_number_float())
    {
      type = "float";
    }
    else if (value.is_number_integer())
    {
      type = "int32_t";
    }
    else if (value.is_number_unsigned())
    {
      type = "uint32_t";
    }
    else if (value.is_string())
    {
      type = "std::string";
    }
    else if (value.is_object())
    {
      generate_object(out, key, value);
      type = key;
    }
    else if (value.is_array())
    {
      type = generate_array(out, key, value);
    }

    out << std::format("{} {};\n", type, key);
    return type;
  }

  void generate_headers(std::ostream& out)
  {
    auto fn_generate_header = [](std::ostream& out, std::string_view const header)
    { out << std::format("#include <{}>\n", header); };

    fn_generate_header(out, "cstdint");
    fn_generate_header(out, "string");
    fn_generate_header(out, "vector");
  }

  void generate_api(std::string const& source, std::string const& output)
  {
    std::ifstream source_file(source);
    if (!source_file.is_open())
    {
      throw std::runtime_error(std::format("Could not open file for reading `{}`.", source));
    }

    auto const workouts = json::parse(source_file);

    std::ofstream output_file(output);
    if (!output_file.is_open())
    {
      throw std::runtime_error(std::format("Could not open file for writing `{}`.", output));
    }

    generate_headers(output_file);
    namespace_scope const hevy_namespace(output_file, "hevy");
    generate_object(output_file, "workouts", workouts);
  }

  void generate_source(std::string const& source)
  {
    httplib::Client client(std::string{ model::routing::k_hevy_app_url });

    std::ofstream file(source);
    if (!file.is_open())
    {
      throw std::runtime_error(std::format("Could not open file for writing `{}`.", source));
    }

    file << get_workouts(client).dump(2);
  }

  struct cli_args
  {
    std::string source;
    std::string output;
  };

  cli_args parse_cli(int const argc, char const* argv[])
  {
    cli_args args;
    for (auto i = 0; i < argc; ++i)
    {
      if (std::string_view{ "--source" } == argv[i] && (i + 1) < argc)
      {
        ++i;
        args.source = argv[i];
      }
      else if (std::string_view{ "--output" } == argv[i] && (i + 1) < argc)
      {
        ++i;
        args.output = argv[i];
      }
    }

    if (args.source.empty())
    {
      throw std::invalid_argument("Usage: --source <source_json> [--output <output_header>]");
    }

    return args;
  }

  void do_work(cli_args const& args)
  {
    if (!std::filesystem::exists(args.source))
    {
      generate_source(args.source);
    }
    if (!args.output.empty())
    {
      std::cout << std::format("Generating Hevy API header `{}`.", args.output) << std::endl;
      generate_api(args.source, args.output);
      std::cout << std::format("Hevy API header `{}` successfully generated.", args.output) << std::endl;
    }
  }

} // namespace

int main(int const argc, char const* argv[])
{
  try
  {
    auto const args = parse_cli(argc, argv);
    do_work(args);
  }
  catch (std::exception const& exc)
  {
    std::cerr << exc.what() << std::endl;
    exit(1);
  }

  return 0;
}
