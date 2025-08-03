-- Coretemp (lain, average)
local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local gears = require("gears")

theme.widget_temp = theme.dir .. "/icons/widgets/temp.png"
local temp_icon = wibox.widget.imagebox(theme.widget_temp)
local temp = lain.widget.temp({
	tempfiles = { "/sys/class/hwmon/hwmon2/temp1_input" },
	settings = function()
		local temp_str = "N/A"
		if CORETEMP_NOW ~= "N/A" then
			temp_str = string.format("%.0f", CORETEMP_NOW)
		end
		WIDGET:set_markup(markup.font(theme.font, markup.fg.color(theme.fg_widget, " " .. temp_str .. "° ")))
	end,
})
local temp_widget = wibox.container.background(
	wibox.container.margin(wibox.widget({ temp_icon, temp.widget, layout = wibox.layout.align.horizontal }), 2, 2),
	"#DC143C",
	gears.shape.rounded_rect
)

return temp_widget
