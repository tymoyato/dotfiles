-- Brightness control using ddcutil (DDC/CI)
-- DDC/CI is a slow protocol (each ddcutil call is a few hundred ms I2C round
-- trip by design, --sleep-multiplier can't shrink that much further) — so
-- the label updates instantly from a locally-tracked value instead of
-- waiting on ddcutil, and the actual writes are queued/coalesced in the
-- background so a fast scroll-wheel burst doesn't get dropped or stack up
-- one slow round trip per tick.
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local markup = require("lain.util.markup")

theme.widget_brightness = theme.dir .. "/icons/widgets/brightness.png"
local brightness_icon = wibox.widget.imagebox(theme.widget_brightness)
local brightness_text = wibox.widget.textbox()

local brightness = 50
local function render()
	brightness_text:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", " " .. brightness .. "% ")))
end

-- Resync with the monitor's actual value once input settles: catches 0/100
-- clamping and any write that failed, without gating every click on it.
local resync_timer = nil
local function resync()
	awful.spawn.easy_async_with_shell(
		"ddcutil --sleep-multiplier 0.1 getvcp 10 --brief 2>/dev/null | awk '{print $4}'",
		function(stdout)
			local actual = tonumber(stdout:match("(%d+)"))
			if actual then
				brightness = actual
				render()
			end
		end
	)
end
local function schedule_resync()
	if resync_timer then resync_timer:stop() end
	resync_timer = gears.timer.start_new(1, function()
		resync_timer = nil
		resync()
		return false
	end)
end

-- Only one ddcutil write in flight at a time (concurrent calls can corrupt
-- DDC/CI comms on the same display); further changes while one is running
-- just accumulate and get coalesced into the next single write.
local writing = false
local pending_delta = 0
local pending_abs = nil

local function flush()
	if writing then return end
	local cmd
	if pending_abs then
		cmd = "ddcutil --sleep-multiplier 0.1 setvcp 10 " .. pending_abs
		pending_abs = nil
	elseif pending_delta ~= 0 then
		cmd = "ddcutil --sleep-multiplier 0.1 setvcp 10 "
			.. (pending_delta > 0 and "+ " or "- ") .. math.abs(pending_delta)
		pending_delta = 0
	else
		return
	end
	writing = true
	awful.spawn.easy_async_with_shell(cmd, function()
		writing = false
		flush() -- pick up anything that queued while this write was in flight
	end)
end

local function bump(delta)
	brightness = math.max(0, math.min(100, brightness + delta))
	render()
	pending_delta = pending_delta + delta
	flush()
	schedule_resync()
end

local function set_absolute(value)
	brightness = math.max(0, math.min(100, value))
	render()
	pending_abs = value
	pending_delta = 0
	flush()
	schedule_resync()
end

resync()

brightness_text:buttons(awful.util.table.join(
	awful.button({}, 1, function() set_absolute(100) end),
	awful.button({}, 3, function() bump(-25) end),
	awful.button({}, 4, function() bump(5) end),
	awful.button({}, 5, function() bump(-5) end)
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
