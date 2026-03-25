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

		if bat_now.status ~= "N/A" then
			if bat_now.status == "Charging" then
				bat_icon:set_image(theme.widget_ac)
				widget:set_markup(markup.font(theme.font, markup.fg.color("#A7C080", " +" .. bat_now.perc .. "% ")))
			elseif bat_now.status == "Full" then
				bat_icon:set_image(theme.widget_ac)
				widget:set_markup(markup.font(theme.font, markup.fg.color("#A7C080", " ~" .. bat_now.perc .. "% ")))
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
		else
			bat_icon:set_image(theme.widget_battery_no)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " AC ")))
		end
	end,
})

local battery_widget = wibox.container.background(
	wibox.container.margin(
		wibox.widget({ bat_icon, bat.widget, layout = wibox.layout.align.horizontal }),
		2, 4
	),
	"#425047",
	gears.shape.rounded_rect
)

return battery_widget
