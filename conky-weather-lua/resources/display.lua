--[[
 conky-weather-lua display.lua   
 by @wim66    
  v1.1 8-June-2024       
]]
-- Import the required Cairo libraries
require 'cairo'

-- Functie om de weergegevens te lezen en te parsen
local function read_weather_data()
    local weather_data = {}
    local weather_file = "./resources/weather_data"
    local file = io.open(weather_file, "r")

    if not file then
        print("Could not open weather data file: " .. weather_file)
        return weather_data
    end

    for line in file:lines() do
        local key, value = line:match("([^=]+)=([^=]+)")
        if key and value then
            weather_data[key] = value
        end
    end

    file:close()
    return weather_data
end

-- Functie om een afbeelding te laden en te tekenen met Cairo
local function draw_image(cr, img_path, x, y, width, height)
    local image = cairo_image_surface_create_from_png(img_path)
    local img_w = cairo_image_surface_get_width(image)
    local img_h = cairo_image_surface_get_height(image)

    cairo_save(cr)
    cairo_translate(cr, x, y)
    cairo_scale(cr, width / img_w, height / img_h)
    cairo_set_source_surface(cr, image, 0, 0)
    cairo_paint(cr)
    cairo_restore(cr)

    cairo_surface_destroy(image)
end

-- Functie om de tekst te tekenen met Cairo
local function draw_text(cr, text, x, y, font, size, color)
    cairo_select_font_face(cr, font, CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size(cr, size)
    cairo_set_source_rgba(cr, color[1], color[2], color[3], color[4])
    cairo_move_to(cr, x, y)
    cairo_show_text(cr, text)
    cairo_stroke(cr)
end

-- Functie om de weergegevens weer te geven
function conky_draw_weather()
    if conky_window == nil then
        return
    end

    local weather_data = read_weather_data()

    local city = weather_data.CITY or "N/A"
    local weather_icon_path = "./resources/cache/weathericon.png"
    local weather_desc = weather_data.WEATHER_DESC or "N/A"
    local temp = weather_data.TEMP or "N/A"
    local humidity = weather_data.HUMIDITY or "N/A"
    local wind_speed = weather_data.WIND_SPEED or "N/A"

    -- Creëer een cairo oppervlak en context
    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    -- Teken de afbeelding met Cairo
    draw_image(cr, weather_icon_path, 20, 20, 120, 120)

    -- Teken de teksten met Cairo
    draw_text(cr, city, 160, 110, "ChopinScript", 72, {1, 0.4, 0, 1})
    draw_text(cr, weather_desc, 100, 160, "Dejavu Serif", 22, {249, 168, 0, 1})
    draw_text(cr, temp, 430, 70, "Dejavu Serif", 22, {249, 168, 0, 1})
    -- draw_text(cr, "Luchtvochtigheid: " .. humidity .. "%", 100, 110, "Dejavu Sans Mono", 22, {1, 0.4, 0, 1})
    -- draw_text(cr, "Wind snelheid: " .. wind_speed .. " m/s", 100, 140, "Dejavu Sans Mono", 22, {1, 0.4, 0, 1})

    -- Vernietig de cairo context en oppervlak
    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end

function conky_draw_weather_text()
    return ""
end
