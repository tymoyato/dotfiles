-- Coretemp (lain, average)
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local lain = require("lain")
local markup = lain.util.markup

-- Function to auto-detect the first available temp*_input file
local function find_temp_file()
    local command = [[
        for hwmon in /sys/class/hwmon/hwmon*; do
            for temp in "$hwmon"/temp*_input; do
                if [ -f "$temp" ]; then
                    echo "$temp"
                    exit 0
                fi
            done
        done
    ]]

    -- Use awful.spawn.easy_async_with_shell for async shell command
    local handle = io.popen(command)
    if handle then
        local result = handle:read("*l")  -- Only read the first line
        handle:close()
        return result or nil
    else
        return nil
    end
end

-- Get temperature file path
local temp_file = find_temp_file() or "/dev/null"

-- Create the widget
theme.widget_temp = theme.dir .. "/icons/widgets/temp.png"
local temp_icon = wibox.widget.imagebox(theme.widget_temp)

local temp = lain.widget.temp({
    tempfiles = { temp_file },
    settings = function()
        local temp_str = "N/A"
        if CORETEMP_NOW ~= "N/A" then
            temp_str = string.format("%.0f", CORETEMP_NOW)
        end
        WIDGET:set_markup(
            markup.font(theme.font, markup.fg.color(theme.fg_widget, " " .. temp_str .. "° "))
        )
    end,
})

local temp_widget = wibox.container.background(
    wibox.container.margin(
        wibox.widget({ temp_icon, temp.widget, layout = wibox.layout.align.horizontal }),
        2, 2
    ),
    "#DC143C",
    gears.shape.rounded_rect
)

return temp_widget
