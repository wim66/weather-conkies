-- background.lua v1.5
-- by @wim66
-- June 10 2024

-- Zorg ervoor dat je het juiste pad naar settings.lua instelt
local script_path = debug.getinfo(1, 'S').source:match[[^@?(.*[\/])[^\/]-$]]
local parent_path = script_path:match("^(.*[\\/])resources[\\/].*$")

package.path = package.path .. ";" .. parent_path .. "?.lua"

-- Probeer settings.lua te laden vanuit de parent directory
local status, err = pcall(function() require("settings") end)
if not status then
    print("Error loading settings.lua: " .. err)
end

-- Zorg ervoor dat de conky_vars functie wordt aangeroepen om de variabelen in te stellen
if conky_vars then
    conky_vars()
else
    print("conky_vars function is not defined in settings.lua")
end

conky_vars()

-- Selecteer de kleur op basis van de variabele uit settings.lua
local color_options = {
    green = { {0, 0x003E00, 1}, {0.5, 0x03F404, 1}, {1, 0x003E00, 1} },
    orange = { {0, 0xE05700, 1}, {0.5, 0xFFD145, 1}, {1, 0xE05700, 1} },
    blue = { {0, 0x0000ba, 1}, {0.5, 0x8cc7ff, 1}, {1, 0x0000ba, 1} },
    black = { {0, 0x2b2b2b, 1}, {0.5, 0xa3a3a3, 1}, {1 ,0x2b2b2b, 1} },
    red = { {0, 0x5c0000, 1}, {0.5, 0xff0000, 1}, {1 ,0x5c0000, 1} }
}

local bgcolor_options = {
    black = { {1, 0x000000, 0.5} },
    blue = { {1, 0x0000ba, 0.5} },
    white = { {1, 0xffffff, 0.5} }
}

local border_color = color_options[border_COLOR] or color_options.green  -- standaard naar groen als border_COLOR niet bestaat
local bg_color = bgcolor_options[background_COLOR] or bgcolor_options.black  -- standaard naar zwart als bg_COLOR niet bestaat

local boxes_settings = {
    -- background
    {
        type = "background",
        x = 10, y = 5, w = 200, h = 200,
        centre_x = true, -- centres on conky_window.width
        colour = bg_color, -- value from settings.lua
        corners = { {"circle", 100} },
        draw_me = true,
    },
    -- Second background layer with linear gradient
    {
        type = "layer2",
        x = 0, y = 210, w = 340, h = 210,
        centre_x = true, -- centres on conky_window.width
        scale_width = true, -- auto scales to conky_window.width
        linear_gradient = {0, 210, 0, 420},  -- Linear gradient from left to right
        colours = { {0, 0x000000, 0.66}, {0.5, 0x0000FF, 0.66}, {0.5, 0x0000FF, 0.66}, {1, 0x000000, 0.66} },
        corners = { {"circle", 10} },
        draw_me = true,
    },
    -- Border
    {
        type = "border",
        x = 80, y = 5, w = 200, h = 200,
        centre_x = true, -- centres on conky_window.width
        colour = border_color, -- value from settings.lua
        linear_gradient = {100, 0, 100, 200},
        corners = { {"circle", 100} },
        border = 8,
        draw_me = true,
    },
}

-- Functie om een rechthoek met afgeronde hoeken te tekenen
local function draw_rounded_rectangle(cr, x, y, w, h, r)
    cairo_new_path(cr)
    cairo_move_to(cr, x + r, y)
    cairo_line_to(cr, x + w - r, y)
    cairo_arc(cr, x + w - r, y + r, r, -math.pi/2, 0)
    cairo_line_to(cr, x + w, y + h - r)
    cairo_arc(cr, x + w - r, y + h - r, r, 0, math.pi/2)
    cairo_line_to(cr, x + r, y + h)
    cairo_arc(cr, x + r, y + h - r, r, math.pi/2, math.pi)
    cairo_line_to(cr, x, y + r)
    cairo_arc(cr, x + r, y + r, r, math.pi, 3*math.pi/2)
    cairo_close_path(cr)
end

-- Functie om de x-coördinaat te berekenen voor centrering
local function get_centered_x(canvas_width, box_width)
    return (canvas_width - box_width) / 2
end

function conky_draw_background()
    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local cr = cairo_create(cs)

    local canvas_width = conky_window.width

    for _, box in ipairs(boxes_settings) do
        if box.draw_me then
            local x = box.x
            local w = box.w
            if box.centre_x then
                x = get_centered_x(canvas_width, box.w)
            end
            if box.type == "background" then
                -- Teken de achtergrond
                cairo_set_source_rgba(cr, ((box.colour[1][2] & 0xFF0000) >> 16) / 255, ((box.colour[1][2] & 0x00FF00) >> 8) / 255, (box.colour[1][2] & 0x0000FF) / 255, box.colour[1][3])
                draw_rounded_rectangle(cr, x, box.y, box.w, box.h, box.corners[1][2])
                cairo_fill(cr)
            elseif box.type == "layer2" then
                -- Schaal de breedte van layer2 indien nodig
                if box.scale_width then
                    w = canvas_width
                    x = 0
                end
                -- Teken de tweede laag met lineaire gradient
                local gradient = cairo_pattern_create_linear(table.unpack(box.linear_gradient))
                for _, color in ipairs(box.colours) do
                    cairo_pattern_add_color_stop_rgba(gradient, color[1], ((color[2] & 0xFF0000) >> 16) / 255, ((color[2] & 0x00FF00) >> 8) / 255, (color[2] & 0x0000FF) / 255, color[3])
                end
                cairo_set_source(cr, gradient)
                draw_rounded_rectangle(cr, x, box.y, w, box.h, box.corners[1][2])
                cairo_fill(cr)
                cairo_pattern_destroy(gradient)
            elseif box.type == "border" then
                -- Teken de rand met kleurverloop
                local gradient = cairo_pattern_create_linear(table.unpack(box.linear_gradient))
                for _, color in ipairs(box.colour) do
                    cairo_pattern_add_color_stop_rgba(gradient, color[1], ((color[2] & 0xFF0000) >> 16) / 255, ((color[2] & 0x00FF00) >> 8) / 255, (color[2] & 0x0000FF) / 255, color[3])
                end
                cairo_set_source(cr, gradient)
                cairo_set_line_width(cr, box.border)
                draw_rounded_rectangle(cr, x + box.border / 2, box.y + box.border / 2, box.w - box.border, box.h - box.border, box.corners[1][2] - box.border / 2)
                cairo_stroke(cr)
                cairo_pattern_destroy(gradient)
            end
        end
    end

    cairo_destroy(cr)
    cairo_surface_destroy(cs)
end
