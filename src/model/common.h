#include <httplib.h>
#include <string>
#include <string_view>

namespace model
{

  namespace routing
  {

    constexpr std::string_view k_hevy_app_url = "http://api.hevyapp.com";

    constexpr std::string_view k_workouts = "/v1/workouts";

    inline auto get_page(int const _page)
    {
      return std::make_pair(std::string{ "page" }, std::to_string(_page));
    }

    inline auto get_page_size(int const size)
    {
      return std::make_pair(std::string{ "pageSize" }, std::to_string(size));
    }

    inline httplib::Headers get_header()
    {
      return {
        { "api-key", HEVY_API_KEY },
        { "accept", "application/json" },
      };
    }

  } // namespace routing

} // namespace model
