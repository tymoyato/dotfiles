-- Clock
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

-- For graphical calendar
local calendar_popup = require("awful.widget.calendar_popup").month

theme.widget_clock = theme.dir .. "/icons/widgets/clock.png"
local clock_icon = wibox.widget.imagebox(theme.widget_clock)
local clock = awful.widget.textclock('<span font="Meslo LGS Regular 10" color="#D3C6AA"> %a %d %b  %H:%M </span>')
local clock_widget = wibox.container.background(
	wibox.container.margin(wibox.widget({ clock_icon, clock, layout = wibox.layout.align.horizontal }), 2, 2),
	"#425047",
	gears.shape.rounded_rect
)

-- Everforest colors
local everforest_bg = "#2D353B"
local everforest_green = "#A7C080"
local everforest_fg = "#D3C6AA"
local everforest_bg_green = "#425047"

-- Graphical Calendar Popup with Everforest theme
local cal_popup = calendar_popup({
	start_sunday = false,
	spacing = 10,
	style_month = {
		border_width = 2,
		border_color = everforest_green,
		padding = 8,
		bg_color = everforest_bg,
		fg_color = everforest_fg,
	},
	style_header = { fg_color = everforest_green, font = "Meslo LGS Regular 12", bg_color = everforest_bg },
	style_weekday = { fg_color = everforest_green, font = "Meslo LGS Regular 10", bg_color = everforest_bg },
	style_focus = { fg_color = everforest_bg, bg_color = everforest_green, markup = true },
	style_normal = { fg_color = everforest_fg, bg_color = everforest_bg },
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
