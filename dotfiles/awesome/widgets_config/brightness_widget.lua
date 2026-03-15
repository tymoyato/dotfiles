-- Brightness control bar using the 'light' program
local wibox = require("wibox")
local awful = require("awful")
local lain = require("lain")
local gears = require("gears")
local naughty = require("naughty")

-- Icons for brightness states
theme.widget_brightness = theme.dir .. "/icons/widgets/brightness.png"
local brightness_icon = wibox.widget.imagebox(theme.widget_brightness)

-- Function to get current brightness level
local function get_brightness()
	awful.spawn.easy_async_with_shell("light -G", function(stdout)
		local brightness = tonumber(stdout:match("(%d+)"))
		brightness_icon:set_image(theme.widget_brightness)
	end)
end

-- Initial brightness check
get_brightness()

-- Brightness bar widget
local brightness_bar = wibox.widget({
	{
		id = "brightness_bar",
		max_value = 100,
		value = 50, -- Initial value, will be updated
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

-- Update brightness bar
local function update_brightness_bar()
	awful.spawn.easy_async_with_shell("light -G", function(stdout)
		local brightness = tonumber(stdout:match("(%d+)"))
		if brightness then
			brightness_bar:get_children_by_id("brightness_bar")[1].value = brightness
		end
	end)
end

-- Initial update
update_brightness_bar()

-- Brightness control buttons
brightness_bar:buttons(awful.util.table.join(
	awful.button({}, 1, function()
		awful.spawn.with_shell("sudo light -S 100")
		get_brightness()
		update_brightness_bar()
	end),
	awful.button({}, 2, function()
		awful.spawn.with_shell("sudo light -A 1")
		update_brightness_bar()
		get_brightness()
	end),
	awful.button({}, 3, function()
		awful.spawn.with_shell("sudo light -U 25")
		update_brightness_bar()
		get_brightness()
	end),
	awful.button({}, 4, function()
		awful.spawn.with_shell("sudo light -A 1")
		update_brightness_bar()
		get_brightness()
	end),
	awful.button({}, 5, function()
		awful.spawn.with_shell("sudo light -U 1")
		update_brightness_bar()
		get_brightness()
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
