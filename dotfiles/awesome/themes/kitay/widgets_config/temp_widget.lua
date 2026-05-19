-- Coretemp widget
local wibox  = require("wibox")
local gears  = require("gears")
local lain   = require("lain")
local markup = lain.util.markup

-- Find hwmon temp file once at startup. io.popen here is ~5ms on sysfs —
-- acceptable tradeoff vs async complexity with lain's named timer.
local function find_temp_file()
    local h = io.popen("ls /sys/class/hwmon/hwmon*/temp1_input 2>/dev/null | head -1")
    if not h then return "/dev/null" end
    local result = h:read("*l") or ""
    h:close()
    return result ~= "" and result or "/dev/null"
end

local temp_file = find_temp_file()

local temp = lain.widget.temp({
    tempfiles = { temp_file },
    timeout = 10,
    settings = function()
        local temp_str = "N/A"
        if CORETEMP_NOW ~= "N/A" and CORETEMP_NOW ~= nil then
            temp_str = string.format("%.0f", CORETEMP_NOW)
        end
        WIDGET:set_markup(
            markup.font(theme.font, markup.fg.color("#D3C6AA", " 🔥 " .. temp_str .. "° "))
        )
    end,
})

local temp_widget = wibox.container.background(
    wibox.container.margin(temp.widget, 2, 2),
    "#425047",
    gears.shape.rounded_rect
)

return temp_widget
