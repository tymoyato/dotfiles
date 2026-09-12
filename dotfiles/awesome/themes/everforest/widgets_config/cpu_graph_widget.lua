-- CPU sparkline graph widget
-- Shows last 30 samples as a mini graph instead of plain percentage
-- Left-click: show/hide popup with per-core usage
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local lain  = require("lain")
local markup = lain.util.markup

local bg_widget = "#000000"
local bg_popup  = "#2D353B"
local fg_green  = "#A7C080"
local fg_color  = "#D3C6AA"
local fg_grey   = "#7A8478"
local fg_yellow = "#DBBC7F"
local fg_red    = "#E67E80"

local HISTORY = 30
local samples = {}
for i = 1, HISTORY do samples[i] = 0 end

local popup = nil
local core_labels = {}

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

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
    gears.shape.rounded_rect
)

-- Per-core popup
local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = markup.font(theme.font, markup.fg.color(fg_green, "<b> CPU cores </b>")),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    for i, lbl in ipairs(core_labels) do
        rows:add(wibox.container.margin(lbl, 6, 6, 2, 2))
    end

    popup = awful.popup {
        widget = { rows, bg = bg_popup, widget = wibox.container.background },
        placement = function(w)
            awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
        end,
        shape        = gears.shape.rounded_rect,
        border_width = 2,
        border_color = fg_green,
        ontop        = true,
        visible      = true,
        minimum_width = 160,
    }
    popup:connect_signal("mouse::leave", close_popup)
end

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

        -- rebuild core labels
        core_labels = {}
        if cpu_now.core then
            for i, core in ipairs(cpu_now.core) do
                local c = core.usage
                local cc = fg_green
                if c > 80 then cc = fg_red elseif c > 50 then cc = fg_yellow end
                table.insert(core_labels, wibox.widget {
                    markup = markup.font(theme.font,
                        markup.fg.color(fg_grey, "core" .. (i-1) .. "  ") ..
                        markup.fg.color(cc, c .. "%")),
                    widget = wibox.widget.textbox,
                })
            end
        end
    end,
}

cpu_graph_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end)
))

return cpu_graph_widget
