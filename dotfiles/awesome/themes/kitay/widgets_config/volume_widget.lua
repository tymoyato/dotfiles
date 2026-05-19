-- ALSA volume text
local wibox = require("wibox")
local awful = require("awful")
local lain = require("lain")
local gears = require("gears")
local markup = require("lain.util.markup")

theme.volume = lain.widget.alsa({
	notification_preset = { font = theme.font },
	settings = function()
		local level = tonumber(volume_now.level) or 0
		if volume_now.status == "off" then
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " 🔇 mute ")))
		elseif level == 0 then
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " 🔇 0% ")))
		else
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " 🔊 " .. level .. "% ")))
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
	wibox.container.margin(theme.volume.widget, 2, 4),
	"#425047",
	gears.shape.rounded_rect
)

return volume_widget
