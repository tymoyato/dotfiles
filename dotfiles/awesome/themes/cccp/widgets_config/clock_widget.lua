-- Clock
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

-- For graphical calendar
local calendar_popup = require("awful.widget.calendar_popup").month

theme.widget_clock = theme.dir .. "/icons/widgets/clock.png"
local clock_icon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.textclock('<span font="Meslo LGS Regular 10" color="#FFD700"> %a %d %b  %H:%M </span>')
local clock_widget = wibox.container.background(
	wibox.container.margin(wibox.widget({ clock_icon, clock, layout = wibox.layout.align.horizontal }), 2, 2),
	"#DC143C",
	gears.shape.rounded_rect
)

-- Soviet Colors
local soviet_dark_red = "#7B1A1A"
local soviet_gold = "#FFD700"
local soviet_white = "#FFFFFF"
local soviet_black = "#222222"

-- Graphical Calendar Popup with Soviet theme
local cal_popup = calendar_popup({
	start_sunday = false,
	spacing = 10,
	style_month = {
		border_width = 2,
		border_color = soviet_gold,
		padding = 8,
		bg_color = soviet_dark_red,
		fg_color = soviet_white,
	},
	style_header = { fg_color = soviet_gold, font = "Meslo LGS Regular 12", bg_color = soviet_dark_red },
	style_weekday = { fg_color = soviet_gold, font = "Meslo LGS Regular 10", bg_color = soviet_dark_red },
	style_focus = { fg_color = soviet_black, bg_color = soviet_gold, markup = true },
	style_normal = { fg_color = soviet_white, bg_color = soviet_dark_red },
	long_weekdays = true,
})

-- Show on hover
clock_widget:connect_signal("mouse::enter", function()
	cal_popup:attach(clock_widget, "tr", { on_hover = true })
end)
clock_widget:connect_signal("mouse::leave", function()
	cal_popup.visible = false
end)

return clock_widget
