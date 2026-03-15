-- Keyboard layout switcher
local wibox = require("wibox")
local awful = require("awful")
local lain = require("lain")
local gears = require("gears")
local markup = require("lain.util.markup")

local kbd_widget = wibox.widget.textbox()

local kbdstrings = { [0] = "us", [1] = "fr" }
local current_layout = 0

-- Function to update the keyboard layout widget
local function update_kbd_widget()
	kbd_widget:set_markup(markup.font(theme.font, markup.fg.color(theme.fg_normal, " " .. kbdstrings[current_layout] .. " ")))
end

-- Function to switch the keyboard layout
local function switch_kbd_layout()
	current_layout = 1 - current_layout
	awful.spawn.with_shell("setxkbmap " .. kbdstrings[current_layout]:match("%S+"))
	-- Update the widget after switching the layout
	update_kbd_widget()
end

-- Initial layout
update_kbd_widget()

-- Add right-click functionality to switch keyboard layout
kbd_widget:buttons(awful.util.table.join(awful.button({}, 3, function()
	switch_kbd_layout()
end)))

local kbd_widget_container = wibox.container.background(
	wibox.container.margin(kbd_widget, 2, 4),
	theme.bg_focus,
	gears.shape.rounded_rect
)

return kbd_widget_container
