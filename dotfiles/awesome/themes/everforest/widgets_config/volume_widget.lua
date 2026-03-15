-- ALSA volume text
local wibox = require("wibox")
local awful = require("awful")
local lain = require("lain")
local gears = require("gears")
local markup = require("lain.util.markup")

theme.widget_vol = theme.dir .. "/icons/widgets/vol.png"
theme.widget_vol_low = theme.dir .. "/icons/widgets/vol_low.png"
theme.widget_vol_no = theme.dir .. "/icons/widgets/vol_no.png"
theme.widget_vol_mute = theme.dir .. "/icons/widgets/vol_mute.png"
local vol_icon = wibox.widget.imagebox(theme.widget_vol)

theme.volume = lain.widget.alsa({
	notification_preset = { font = theme.font },
	settings = function()
		local level = tonumber(volume_now.level) or 0
		if volume_now.status == "off" then
			vol_icon:set_image(theme.widget_vol_mute)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " mute ")))
		elseif level == 0 then
			vol_icon:set_image(theme.widget_vol_no)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " 0% ")))
		elseif level <= 50 then
			vol_icon:set_image(theme.widget_vol_low)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " " .. level .. "% ")))
		else
			vol_icon:set_image(theme.widget_vol)
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " " .. level .. "% ")))
		end
	end,
})

theme.volume.widget:buttons(awful.util.table.join(
	awful.button({}, 2, function()
		awful.spawn(string.format("%s set %s 100%%", theme.volume.cmd, theme.volume.channel))
		theme.volume.update()
	end),
	awful.button({}, 3, function()
		awful.spawn(string.format("%s set %s toggle", theme.volume.cmd, theme.volume.togglechannel or theme.volume.channel))
		theme.volume.update()
	end),
	awful.button({}, 4, function()
		awful.spawn(string.format("%s set %s 1%%+", theme.volume.cmd, theme.volume.channel))
		theme.volume.update()
	end),
	awful.button({}, 5, function()
		awful.spawn(string.format("%s set %s 1%%-", theme.volume.cmd, theme.volume.channel))
		theme.volume.update()
	end)
))

local volume_widget = wibox.container.background(
	wibox.container.margin(wibox.widget({ vol_icon, theme.volume.widget, layout = wibox.layout.align.horizontal }), 2, 4),
	"#425047",
	gears.shape.rounded_rect
)

return volume_widget
