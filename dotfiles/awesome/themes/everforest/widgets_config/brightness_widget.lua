-- Brightness control using ddcutil (DDC/CI)
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local markup = require("lain.util.markup")

local brightness_text = wibox.widget.textbox()
local busy = false

local function update_brightness()
	awful.spawn.easy_async_with_shell("ddcutil --sleep-multiplier 0.1 getvcp 10 --brief 2>/dev/null | awk '{print $4}'", function(stdout)
		local brightness = tonumber(stdout:match("(%d+)")) or 0
		brightness_text:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " 🔆 " .. brightness .. "% ")))
	end)
end

local function set_brightness(cmd)
	if busy then return end
	busy = true
	awful.spawn.easy_async_with_shell(cmd, function()
		busy = false
		update_brightness()
	end)
end

update_brightness()

brightness_text:buttons(awful.util.table.join(
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

local brightness_final_widget = wibox.container.background(
	wibox.container.margin(brightness_text, 2, 4),
	"#425047",
	gears.shape.rounded_rect
)

return brightness_final_widget
