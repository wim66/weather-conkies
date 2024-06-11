-- settings.lua
-- by @wim66
-- June 10 2024
function conky_vars()

    API_KEY = "your_openweathermap_api_key" -- put your OpenWeatherMap api here https://openweathermap.org/
    CITY_ID = "2759794"  -- find your city id in the url box https://openweathermap.org/city/2759794
    UNITS = "metric"  -- 'metric' for Celsius or 'imperial' for Fahrenheit
    LANG = "en"

    border_COLOR = "orange"  -- options, green, orange, blue, black, red
    background_COLOR = "black"      -- options black, blue
    --- Border and background can be disabled in background.lua (draw_me = true or false)

end

