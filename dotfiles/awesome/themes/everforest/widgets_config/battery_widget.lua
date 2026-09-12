-- Battery
local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local gears = require("gears")

theme.widget_ac = theme.dir .. "/icons/widgets/ac.png"
theme.widget_battery = theme.dir .. "/icons/widgets/battery.png"
theme.widget_battery_medium = theme.dir .. "/icons/widgets/battery_medium.png"
theme.widget_battery_low = theme.dir .. "/icons/widgets/battery_low.png"
theme.widget_battery_empty = theme.dir .. "/icons/widgets/battery_empty.png"
theme.widget_battery_no = theme.dir .. "/icons/widgets/battery_no.png"

local bat_icon = wibox.widget.imagebox(theme.widget_battery)
local battery_widget
local bat = lain.widget.bat({
	battery = "BAT0",
	timeout = 30,
	notify = "on",
	n_perc = { 5, 15 },
	settings = function()
		bat_notification_low_preset = {
			title = "Battery low",
			text = "Plug the cable!",
			timeout = 15,
			fg = "#D3C6AA",
			bg = "#E69875",
		}
		bat_notification_critical_preset = {
			title = "Battery exhausted",
			text = "Shutdown imminent",
			timeout = 15,
			fg = "#D3C6AA",
			bg = "#E67E80",
		}

		local on_ac = bat_now.status == "Charging" or bat_now.status == "Full" or bat_now.status == "N/A"
		if battery_widget then battery_widget.visible = not on_ac end

		if bat_now.status == "Charging" then
			bat_icon:set_image(theme.widget_ac)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#A7C080", " +" .. bat_now.perc .. "% ")))
		elseif bat_now.status == "Full" then
			bat_icon:set_image(theme.widget_ac)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#A7C080", " ~" .. bat_now.perc .. "% ")))
		elseif bat_now.status == "N/A" then
			bat_icon:set_image(theme.widget_battery_no)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " AC ")))
		elseif tonumber(bat_now.perc) <= 35 then
			bat_icon:set_image(theme.widget_battery_empty)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#E67E80", " -" .. bat_now.perc .. "% ")))
		elseif tonumber(bat_now.perc) <= 70 then
			bat_icon:set_image(theme.widget_battery_medium)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#E69875", " -" .. bat_now.perc .. "% ")))
		else
			bat_icon:set_image(theme.widget_battery)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " -" .. bat_now.perc .. "% ")))
		end
	end,
})

battery_widget = wibox.container.background(
	wibox.container.margin(
		wibox.widget({ bat_icon, bat.widget, layout = wibox.layout.align.horizontal }),
		2, 4
	),
	"#000000",
	gears.shape.rounded_rect
)
battery_widget.visible = false
bat.update()

return battery_widget
