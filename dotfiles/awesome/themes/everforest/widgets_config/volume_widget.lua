-- ALSA volume text
local wibox = require("wibox")
local awful = require("awful")
local lain = require("lain")
local gears = require("gears")
local markup = require("lain.util.markup")

-- Everforest colors (match pkg widget popup style)
local bg_popup = "#000000"
local bg_row   = "#374247"
local fg_color = "#D3C6AA"
local fg_green = "#A7C080"

theme.widget_vol = theme.dir .. "/icons/widgets/vol.png"
local vol_icon = wibox.widget.imagebox(theme.widget_vol)

local vol_popup   = nil
local close_timer = nil

local vol_bar = wibox.widget {
	max_value        = 100,
	value            = 0,
	forced_height    = 14,
	forced_width     = 160,
	shape            = gears.shape.rounded_bar,
	bar_shape        = gears.shape.rounded_bar,
	color            = fg_green,
	background_color = bg_row,
	widget           = wibox.widget.progressbar,
}
local vol_label = wibox.widget.textbox()

local function refresh_vol_popup()
	local level = tonumber(volume_now and volume_now.level) or 0
	local muted = volume_now and volume_now.status == "off"
	vol_bar.value = muted and 0 or level
	vol_label:set_markup(string.format(
		'<span font="Meslo LGS Regular 10" color="%s">%s%%</span>',
		fg_color, muted and 0 or level
	))
end
refresh_vol_popup()

theme.volume = lain.widget.alsa({
	notification_preset = { font = theme.font },
	settings = function()
		local level = tonumber(volume_now.level) or 0
		if volume_now.status == "off" then
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " mute ")))
		elseif level == 0 then
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " 0% ")))
		else
			widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " " .. level .. "% ")))
		end
		refresh_vol_popup()
	end,
})

local function cancel_close()
	if close_timer then
		close_timer:stop()
		close_timer = nil
	end
end

local function close_vol_popup()
	cancel_close()
	if vol_popup then
		vol_popup.visible = false
		vol_popup = nil
	end
end

local function schedule_close()
	cancel_close()
	close_timer = gears.timer.start_new(0.5, function()
		close_timer = nil
		close_vol_popup()
		return false
	end)
end

-- Shared scroll behaviour: works both on the widget and on the open popup
local scroll_buttons = awful.util.table.join(
	awful.button({}, 4, function()
		awful.spawn(string.format("%s set %s 1%%+", theme.volume.cmd, theme.volume.channel))
		theme.volume.update()
	end),
	awful.button({}, 5, function()
		awful.spawn(string.format("%s set %s 1%%-", theme.volume.cmd, theme.volume.channel))
		theme.volume.update()
	end)
)

-- Click-drag on the bar: set volume to the pointer's position, live while held
local last_drag_level = nil

local function set_volume_from_pointer_x(x, bar_geo)
	local pct = (x - bar_geo.x) / bar_geo.width
	pct = math.max(0, math.min(1, pct))
	local level = math.floor(pct * 100 + 0.5)
	if level == last_drag_level then return end
	last_drag_level = level
	vol_bar.value = level
	awful.spawn(string.format("%s set %s %d%%", theme.volume.cmd, theme.volume.channel, level))
	theme.volume.update()
end

vol_bar:connect_signal("button::press", function(_, _, _, button)
	if button ~= 1 or not vol_popup then return end

	-- mouse.current_widget_geometry can't be trusted here: the popup appears
	-- right under the pointer with no intervening mouse::move, so it still
	-- points at whatever was hovered before the popup existed. Compute the
	-- bar's rect ourselves from the popup's real position + known layout.
	local popup_geo = vol_popup:geometry()
	local bar_geo = { x = popup_geo.x + 8, width = vol_bar.forced_width }

	last_drag_level = nil
	set_volume_from_pointer_x(mouse.coords().x, bar_geo)

	mousegrabber.run(function(m)
		if not m.buttons[1] then return false end
		set_volume_from_pointer_x(m.x, bar_geo)
		return true
	end, "sb_h_double_arrow")
end)

local function show_vol_popup()
	close_vol_popup()
	refresh_vol_popup()

	-- Snapshot once: mouse.current_widget_geometry is live and would track
	-- whatever's under the cursor *inside the popup* on every later redraw,
	-- making the popup jump away from the pointer as soon as the bar updates.
	local anchor_geometry = mouse.current_widget_geometry

	local content = wibox.container.background(
		wibox.widget {
			wibox.container.margin(vol_label, 8, 8, 4, 4),
			wibox.container.margin(vol_bar, 8, 8, 0, 8),
			layout = wibox.layout.fixed.vertical,
		},
		bg_popup
	)

	vol_popup = awful.popup {
		widget = content,
		placement = function(w)
			awful.placement.next_to(w, {
				preferred_positions = "bottom",
				preferred_anchors   = "middle",
				geometry            = anchor_geometry,
				margins             = 6,
			})
		end,
		shape        = gears.shape.octogon,
		border_width = 0,
		ontop        = true,
		visible      = true,
	}
	vol_popup:buttons(scroll_buttons)
	vol_popup:connect_signal("mouse::enter", cancel_close)
	vol_popup:connect_signal("mouse::leave", schedule_close)
end

local volume_widget = wibox.container.background(
	wibox.container.margin(
		wibox.widget({ vol_icon, theme.volume.widget, layout = wibox.layout.align.horizontal }),
		2, 4
	),
	"#000000",
	gears.shape.octogon
)

volume_widget:buttons(awful.util.table.join(
	scroll_buttons,
	awful.button({}, 1, function()
		if vol_popup then close_vol_popup() else show_vol_popup() end
	end),
	awful.button({}, 2, function()
		awful.spawn(string.format("%s set %s 100%%", theme.volume.cmd, theme.volume.channel))
		theme.volume.update()
	end),
	awful.button({}, 3, function()
		awful.spawn(string.format("%s set %s toggle", theme.volume.cmd, theme.volume.togglechannel or theme.volume.channel))
		theme.volume.update()
	end)
))

return volume_widget
