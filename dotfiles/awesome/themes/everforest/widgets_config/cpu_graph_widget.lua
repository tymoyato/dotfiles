-- CPU sparkline graph widget
-- Shows last 30 samples as a mini graph instead of plain percentage
local wibox = require("wibox")
local gears = require("gears")
local lain  = require("lain")
local markup = lain.util.markup

local bg_widget = "#000000"
local fg_green  = "#A7C080"
local fg_color  = "#D3C6AA"
local fg_yellow = "#DBBC7F"
local fg_red    = "#E67E80"

local HISTORY = 30
local samples = {}
for i = 1, HISTORY do samples[i] = 0 end

-- Graph widget
local graph = wibox.widget {
    max_value        = 100,
    min_value        = 0,
    forced_width     = 40,
    forced_height    = 12,
    step_width       = 2,
    step_spacing     = 0,
    color            = fg_green,
    background_color = "#00000000",
    widget           = wibox.widget.graph,
}

-- Percentage label next to graph
local pct_label = wibox.widget {
    markup = markup.font(theme.font, markup.fg.color(fg_color, " 0% ")),
    widget = wibox.widget.textbox,
}

local cpu_graph_widget = wibox.container.background(
    wibox.container.margin(
        wibox.widget {
            graph,
            pct_label,
            layout = wibox.layout.fixed.horizontal,
        },
        2, 2, 2, 2
    ),
    bg_widget,
    gears.shape.octogon
)

-- Poll cpu via lain
lain.widget.cpu {
    timeout = 2,
    settings = function()
        local total = cpu_now.usage
        -- push sample
        table.remove(samples, 1)
        table.insert(samples, total)
        graph:add_value(total)

        -- color threshold
        local col = fg_green
        if total > 80 then col = fg_red
        elseif total > 50 then col = fg_yellow
        end
        pct_label:set_markup(markup.font(theme.font, markup.fg.color(col, " " .. total .. "% ")))
        graph.color = col
    end,
}

return cpu_graph_widget
