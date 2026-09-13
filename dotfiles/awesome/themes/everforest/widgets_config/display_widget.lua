-- Display / xrandr widget
-- Shows active monitor count. Left-click: popup with detected outputs + preset layouts.
-- Right-click: re-run display-setup.sh
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local lain   = require("lain")
local markup = lain.util.markup

local bg_widget = "#000000"
local bg_popup  = "#000000"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_grey   = "#7A8478"
local fg_red    = "#E67E80"
local fg_yellow = "#DBBC7F"

local SETUP_SCRIPT = os.getenv("HOME") .. "/.config/awesome/display-setup.sh"

local popup = nil

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

local disp_label = wibox.widget {
    markup = markup.font(theme.font, markup.fg.color(fg_color, " ⎚ ")),
    widget = wibox.widget.textbox,
}
local disp_widget = wibox.container.background(
    wibox.container.margin(disp_label, 2, 2),
    bg_widget,
    gears.shape.octogon
)

-- Parse connected outputs from xrandr
local function get_outputs(callback)
    awful.spawn.easy_async("xrandr --query", function(stdout)
        local outputs = {}
        for line in stdout:gmatch("[^\n]+") do
            local name, status = line:match("^(%S+) (connected)")
            if name and status then
                local mode = line:match("%d+x%d+%+%d+%+%d+")
                table.insert(outputs, { name = name, active = mode ~= nil, mode = mode or "" })
            end
        end
        callback(outputs)
    end)
end

local function update_label()
    get_outputs(function(outputs)
        local active = 0
        for _, o in ipairs(outputs) do
            if o.active then active = active + 1 end
        end
        local col = active > 1 and fg_green or fg_color
        disp_label:set_markup(markup.font(theme.font,
            markup.fg.color(col, " ⎚ " .. active .. " ")))
    end)
end

-- Preset layout builder
local function make_layout_btn(label, cmd, parent_rows)
    local btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = markup.font(theme.font, markup.fg.color(fg_color, " " .. label .. " ")),
                widget = wibox.widget.textbox,
            }, 6, 6, 2, 2
        ), bg_row, gears.shape.octogon
    )
    btn:connect_signal("mouse::enter", function() btn.bg = "#4a5e53" end)
    btn:connect_signal("mouse::leave", function() btn.bg = bg_row end)
    btn:connect_signal("button::press", function()
        close_popup()
        awful.spawn.with_shell(cmd)
        gears.timer.start_new(1, function() update_label(); return false end)
    end)
    return wibox.container.margin(btn, 6, 6, 2, 2)
end

local function show_popup()
    close_popup()
    get_outputs(function(outputs)
        local rows = wibox.layout.fixed.vertical()

        -- Header
        rows:add(wibox.widget {
            { markup = markup.font(theme.font, markup.fg.color(fg_green, "<b> Displays </b>")),
              widget = wibox.widget.textbox },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
        rows:add(wibox.widget {
            color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
        })

        -- Connected outputs
        if #outputs == 0 then
            rows:add(wibox.container.margin(wibox.widget {
                markup = markup.font(theme.font, markup.fg.color(fg_grey, "No outputs detected")),
                widget = wibox.widget.textbox,
            }, 6, 6, 4, 4))
        else
            for _, o in ipairs(outputs) do
                local state_col = o.active and fg_green or fg_grey
                local state_str = o.active and ("● " .. o.mode) or "○ off"
                rows:add(wibox.container.margin(wibox.widget {
                    markup = markup.font(theme.font,
                        markup.fg.color(fg_color, o.name .. "  ") ..
                        markup.fg.color(state_col, state_str)),
                    widget = wibox.widget.textbox,
                }, 6, 6, 2, 2))
            end
        end

        -- Preset layouts (built from detected outputs)
        rows:add(wibox.widget {
            color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
        })
        rows:add(wibox.widget {
            { markup = markup.font(theme.font, markup.fg.color(fg_grey, " Layouts ")),
              widget = wibox.widget.textbox },
            top = 2, bottom = 2, left = 6, right = 6,
            widget = wibox.container.margin,
        })

        -- Single-output presets for each connected output
        for _, o in ipairs(outputs) do
            rows:add(make_layout_btn(
                "Only " .. o.name,
                "xrandr --output " .. o.name .. " --auto" ..
                    (function()
                        local off = ""
                        for _, other in ipairs(outputs) do
                            if other.name ~= o.name then
                                off = off .. " --output " .. other.name .. " --off"
                            end
                        end
                        return off
                    end)()
            ))
        end

        -- Multi-monitor: side-by-side for first two outputs
        if #outputs >= 2 then
            local a, b = outputs[1].name, outputs[2].name
            rows:add(make_layout_btn(
                a .. " + " .. b .. " (extend →)",
                "xrandr --output " .. a .. " --auto --output " .. b .. " --auto --right-of " .. a
            ))
            rows:add(make_layout_btn(
                a .. " + " .. b .. " (mirror)",
                "xrandr --output " .. a .. " --auto --output " .. b .. " --same-as " .. a
            ))
        end

        -- Re-run setup script
        rows:add(wibox.widget {
            color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
        })
        rows:add(make_layout_btn("↺ Run display-setup.sh",
            "bash " .. SETUP_SCRIPT .. " && awesome-client 'require(\"themes.everforest.widgets_config.display_widget\").update_label()'"))

        popup = awful.popup {
            widget = { rows, bg = bg_popup, widget = wibox.container.background },
            placement = function(w)
                awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
            end,
            shape        = gears.shape.octogon,
            border_width = 0,
            ontop         = true,
            visible       = true,
            minimum_width = 160,
            maximum_width = 220,
        }
        popup:connect_signal("mouse::leave", close_popup)
    end)
end

-- Initial label
update_label()

-- Refresh label when screens change
screen.connect_signal("added",   update_label)
screen.connect_signal("removed", update_label)

disp_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 3, function()
        awful.spawn.with_shell("bash " .. SETUP_SCRIPT)
        gears.timer.start_new(1, function() update_label(); return false end)
    end)
))

return disp_widget
