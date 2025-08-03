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
	timeout = 1,
	notify = "on",
	n_perc = { 5, 15 },
	settings = function()
		bat_notification_low_preset = {
			title = "Battery low",
			text = "Plug the cable!",
			timeout = 15,
			fg = "#232323",
			bg = "#f18e38",
		}
		bat_notification_critical_preset = {
			title = "Battery exhausted",
			text = "Shutdown imminent",
			timeout = 15,
			fg = "#232323",
			bg = "#c92132",
		}

		if bat_now.status ~= "N/A" then
			if bat_now.status == "Charging" then
				bat_icon:set_image(theme.widget_ac)
				widget:set_markup(
					markup.font(
						theme.font,
						markup.fg.color(
							theme.fg_widget,
							" +" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]"
						)
					)
				)
			elseif bat_now.status == "Full" then
				bat_icon:set_image(theme.widget_ac)
				widget:set_markup(
					markup.font(
						theme.font,
						markup.fg.color(
							theme.fg_widget,
							" ~" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]"
						)
					)
				)
			elseif tonumber(bat_now.perc) <= 35 then
				bat_icon:set_image(theme.widget_battery_empty)
				widget:set_markup(
					markup.font(
						theme.font,
						markup.fg.color(
							theme.fg_widget,
							" -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]"
						)
					)
				)
			elseif tonumber(bat_now.perc) <= 70 then
				bat_icon:set_image(theme.widget_battery_medium)
				widget:set_markup(
					markup.font(
						theme.font,
						markup.fg.color(
							theme.fg_widget,
							" -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]"
						)
					)
				)
			elseif tonumber(bat_now.perc) <= 90 then
				bat_icon:set_image(theme.widget_battery)
				widget:set_markup(
					markup.font(
						theme.font,
						markup.fg.color(
							theme.fg_widget,
							" -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]"
						)
					)
				)
			else
				bat_icon:set_image(theme.widget_battery)
				widget:set_markup(
					markup.font(
						theme.font,
						markup.fg.color(
							theme.fg_widget,
							" -" .. bat_now.perc .. "% [" .. bat_now.watt .. "W][" .. bat_now.time .. "]"
						)
					)
				)
			end
		else
			widget:set_markup(markup.font(theme.font, markup.fg.color(theme.fg_widget, " AC ")))
			bat_icon:set_image(theme.widget_battery_no)
		end
	end,
})

-- Battery
local batbar = wibox.widget({
	forced_height = 1,
	forced_width = 45,
	color = "#232323",
	background_color = "#232323",
	margins = 1,
	paddings = 1,
	ticks = true,
	ticks_size = 5,
	widget = wibox.widget.progressbar,
})

local batbg = wibox.container.background(batbar, "#474747")
local bat_widget = wibox.container.margin(batbg, 2, 7, 4, 4)
local battery_widget1 = wibox.container.background(
	wibox.container.margin(wibox.widget({ bat_icon, bat_widget, layout = wibox.layout.align.horizontal }), 1, 1),
	"#6c5ce7",
	gears.shape.rounded_rect
)
local battery_widget2 = wibox.container.background(
	wibox.container.margin(wibox.widget({ bat.widget, layout = wibox.layout.align.horizontal }), 0, 0),
	"#6c5ce7",
	gears.shape.rounded_rect
)

return {
	battery_widget1 = battery_widget1,
	battery_widget2 = battery_widget2,
}
