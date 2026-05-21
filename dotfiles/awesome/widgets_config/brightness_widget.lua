-- Brightness control using ddcutil (DDC/CI)
local wibox = require("wibox")
local awful = require("awful")
local lain = require("lain")
local gears = require("gears")
local naughty = require("naughty")

theme.widget_brightness = theme.dir .. "/icons/widgets/brightness.png"
local brightness_icon = wibox.widget.imagebox(theme.widget_brightness)
local busy = false

local brightness_bar = wibox.widget({
	{
		id = "brightness_bar",
		max_value = 100,
		value = 50,
		forced_width = 45,
		shape = gears.shape.rectangle,
		bar_shape = gears.shape.rectangle,
		color = "#cc9c00",
		background_color = theme.bg_normal,
		border_width = 0,
		widget = wibox.widget.progressbar,
	},
	layout = wibox.layout.align.horizontal,
})

local function update_brightness_bar()
	awful.spawn.easy_async_with_shell("ddcutil --sleep-multiplier 0.1 getvcp 10 --brief 2>/dev/null | awk '{print $4}'", function(stdout)
		local brightness = tonumber(stdout:match("(%d+)"))
		if brightness then
			brightness_bar:get_children_by_id("brightness_bar")[1].value = brightness
		end
	end)
end

local function set_brightness(cmd)
	if busy then return end
	busy = true
	awful.spawn.easy_async_with_shell(cmd, function()
		busy = false
		update_brightness_bar()
	end)
end

update_brightness_bar()

brightness_bar:buttons(awful.util.table.join(
	awful.button({}, 1, function()
		set_brightness("ddcutil --sleep-multiplier 0.1 setvcp 10 100")
	end),
	awful.button({}, 3, function()
		set_brightness("ddcutil --sleep-multiplier 0.1 setvcp 10 - 25")
	end),
	awful.button({}, 4, function()
		set_brightness("ddcutil --sleep-multiplier 0.1 setvcp 10 + 5")
	end),
	awful.button({}, 5, function()
		set_brightness("ddcutil --sleep-multiplier 0.1 setvcp 10 - 5")
	end)
))

local brightnessbg = wibox.container.background(brightness_bar, "#888888", gears.shape.rounded_rect)
local brightness_widget = wibox.container.margin(brightnessbg, 2, 7, 4, 4)
local brightness_final_widget = wibox.container.background(
	wibox.container.margin(
		wibox.widget({ brightness_icon, brightness_widget, layout = wibox.layout.align.horizontal }),
		2,
		2
	),
	"#00cec9",
	gears.shape.rounded_rect
)

return brightness_final_widget
