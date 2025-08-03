-- Clock
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

-- For graphical calendar (same as CCCP theme)
local calendar_popup = require("awful.widget.calendar_popup").month

theme.widget_clock = theme.dir .. "/icons/widgets/clock.png"
local clock_icon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.textclock('<span font="Meslo LGS Regular 10" color="#FFFFFF"> %a %d %b  %H:%M </span>')
local clock_widget = wibox.container.background(
	wibox.container.margin(wibox.widget({ clock_icon, clock, layout = wibox.layout.align.horizontal }), 2, 2),
	"#6c5ce7",
	gears.shape.rounded_rect
)

-- Kitay Colors
local kitay_dark = "#2d2d2d"
local kitay_purple = "#6c5ce7"
local kitay_white = "#FFFFFF"
local kitay_black = "#000000"

-- Graphical Calendar Popup with Kitay theme (same structure as CCCP)
local cal_popup = calendar_popup({
	start_sunday = false,
	spacing = 10,
	style_month = {
		border_width = 2,
		border_color = kitay_purple,
		padding = 8,
		bg_color = kitay_dark,
		fg_color = kitay_white,
	},
	style_header = { fg_color = kitay_purple, font = "Meslo LGS Regular 12", bg_color = kitay_dark },
	style_weekday = { fg_color = kitay_purple, font = "Meslo LGS Regular 10", bg_color = kitay_dark },
	style_focus = { fg_color = kitay_black, bg_color = kitay_purple, markup = true },
	style_normal = { fg_color = kitay_white, bg_color = kitay_dark },
	long_weekdays = true,
})

-- Show on hover (same as CCCP theme)
clock_widget:connect_signal("mouse::enter", function()
	cal_popup:attach(clock_widget, "tr", { on_hover = true })
end)
clock_widget:connect_signal("mouse::leave", function()
	cal_popup.visible = false
end)

return clock_widget 