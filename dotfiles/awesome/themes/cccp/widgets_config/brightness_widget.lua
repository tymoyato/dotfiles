-- Brightness control using the 'light' program
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local markup = require("lain.util.markup")

theme.widget_brightness = theme.dir .. "/icons/widgets/brightness.png"
local brightness_icon = wibox.widget.imagebox(theme.widget_brightness)
local brightness_text = wibox.widget.textbox()

local function update_brightness()
	awful.spawn.easy_async_with_shell("light -G", function(stdout)
		local brightness = tonumber(stdout:match("(%d+)")) or 0
		brightness_text:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", " " .. brightness .. "% ")))
	end)
end

update_brightness()

brightness_text:buttons(awful.util.table.join(
	awful.button({}, 1, function()
		awful.spawn.with_shell("light -S 100")
		update_brightness()
	end),
	awful.button({}, 3, function()
		awful.spawn.with_shell("light -U 25")
		update_brightness()
	end),
	awful.button({}, 4, function()
		awful.spawn.with_shell("light -A 1")
		update_brightness()
	end),
	awful.button({}, 5, function()
		awful.spawn.with_shell("light -U 1")
		update_brightness()
	end)
))

local brightness_final_widget = wibox.container.background(
	wibox.container.margin(
		wibox.widget({ brightness_icon, brightness_text, layout = wibox.layout.align.horizontal }),
		2, 4
	),
	"#DC143C",
	gears.shape.rounded_rect
)

return brightness_final_widget
