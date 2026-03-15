local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local os, math, string = os, math, string

theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/kitay"
theme.wallpaper = theme.dir .. "/wallpapers/iceland.jpg"
theme.font = "Meslo LGS Regular 10"
theme.taglist_font = "Meslo LGS Bold 10"
theme.tasklist_font = "Terminus 10"

theme.bg_normal = "#000000"
theme.fg_normal = "#ffffff"
theme.bg_focus = "#32302f"
theme.fg_focus = "#232323"
theme.bg_urgent = "#C92132"
theme.fg_urgent = "#282828"

theme.fg_widget = "#32302f"

theme.taglist_bg_focus = "#6c5ce7"
theme.taglist_fg_focus = "#ffffff"
theme.taglist_bg_occupied = "#2d3436"
theme.taglist_fg_occupied = "#b2bec3"
theme.taglist_bg_empty = "#636e72"
theme.taglist_fg_empty = "#ffffff"
theme.taglist_bg_urgent = "#e17055"
theme.taglist_fg_urgent = "#ffffff"
theme.taglist_shape = gears.shape.rounded_rect

theme.tasklist_bg_normal = "#000000"
theme.tasklist_fg_normal = "#ffffff"
theme.tasklist_bg_focus = "#28282B"
theme.tasklist_fg_focus = "#ffffff"
theme.tasklist_bg_urgent = "#C92132"
theme.tasklist_fg_urgent = "#32302f"

theme.border_width = 0
theme.border_normal = "#32302f"
theme.border_focus = "#3f3f3f"
theme.border_marked = "#CC9393"

theme.titlebar_bg_normal = "#3f3f3f"
theme.titlebar_fg_normal = "#282828"

theme.titlebar_bg_focus = "#000000"
theme.titlebar_fg_focus = "#282828"

theme.menu_height = 16
theme.menu_width = 140

theme.notification_font = "Meslo LGS Regular 12"
theme.notification_bg = theme.bg_normal
theme.notification_fg = theme.fg_normal
theme.notification_border_width = 0
theme.notification_border_color = theme.bg_normal
theme.notification_shape = gears.shape.infobubble
theme.notification_opacity = 1
theme.notification_margin = 30
--theme.warning                                   = theme.dir .. "/icons/status/warning.png"
--theme.notification_width                        = 300
--theme.notification_height                       = 200

theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"
-- theme.awesome_icon                              = theme.dir .. "/icons/awesome.png"

-- Layout icons
theme.layout_tile = theme.dir .. "/icons/layouts/tile.png"
theme.layout_tileleft = theme.dir .. "/icons/layouts/tileleft.png"
theme.layout_tilebottom = theme.dir .. "/icons/layouts/tilebottom.png"
theme.layout_tiletop = theme.dir .. "/icons/layouts/tiletop.png"
theme.layout_fairv = theme.dir .. "/icons/layouts/fairv.png"
theme.layout_fairh = theme.dir .. "/icons/layouts/fairh.png"
theme.layout_spiral = theme.dir .. "/icons/layouts/spiral.png"
theme.layout_centerwork = theme.dir .. "/icons/layouts/centerwork.png"
theme.layout_dwindle = theme.dir .. "/icons/layouts/dwindle.png"
theme.layout_max = theme.dir .. "/icons/layouts/max.png"
theme.layout_fullscreen = theme.dir .. "/icons/layouts/fullscreen.png"
theme.layout_magnifier = theme.dir .. "/icons/layouts/magnifier.png"
theme.layout_floating = theme.dir .. "/icons/layouts/floating.png"

--Widget icons
theme.widget_music = theme.dir .. "/icons/widgets/note.png"
theme.widget_music_on = theme.dir .. "/icons/widgets/note_on.png"
theme.widget_music_pause = theme.dir .. "/icons/widgets/pause.png"
theme.widget_music_stop = theme.dir .. "/icons/widgets/stop.png"

theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.useless_gap = 6

theme.titlebar_close_button_focus = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_ontop_button_focus_active = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_focus_inactive = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_sticky_button_focus_active = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_focus_inactive = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_floating_button_focus_active = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_focus_inactive = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_maximized_button_focus_active = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_focus_inactive = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"

-- colors
theme.green = "#00b159"
theme.red = "#d64d4d"
theme.yellow = "#cc9c00"
theme.blue = "#428bca"
theme.darkred = "#c92132"
theme.darkgreen = "#4d7358"
theme.darkyellow = "#f18e38"
theme.gray = "#5e5e5e"
theme.lightgrey = "#b3b3cc"
theme.violet = "#8c8ccd"
theme.pink = "#B85C8A"
theme.black = theme.bg_normal

-- Panel
local markup = lain.util.markup

-- Widgets --

-- Clock
local clock_widget = require("widgets_config.clock_widget")
-- Battery
local battery_widget = require("widgets_config.battery_widget")
-- MEM
local mem_widget = require("widgets_config.mem_widget")
-- CPU
local cpu_widget = require("widgets_config.cpu_widget")
-- Coretemp
local temp_widget = require("widgets_config.temp_widget")
-- ALSA volume bar
local volume_widget = require("widgets_config.volume_widget")
-- Keyboard layout switcher
local kbd_widget = require("widgets.kbd_widget.kbd_widget")
-- brightness
local brightness_widget = require("widgets_config.brightness_widget")
-- music
local music_widget = require("widgets_config.music_widget")
-- package log
local package_log_widget = require("themes.kitay.widgets_config.package_log_widget")

function theme.connect(s)
	-- Quake application
	s.quake = lain.util.quake({ app = awful.util.terminal })

	-- If wallpaper is a function, call it with the screen
	local wallpaper = theme.wallpaper
	if type(wallpaper) == "function" then
		wallpaper = wallpaper(s)
	end
	gears.wallpaper.maximized(wallpaper, 1, true)

	-- Tags
	--awful.tag(awful.util.tagnames, s, awful.layout.layouts[1])
	layout = {
		awful.layout.layouts[1],
		awful.layout.layouts[1],
		awful.layout.layouts[1],
		awful.layout.layouts[3],
		awful.layout.layouts[3],
		awful.layout.layouts[5],
	}
	awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, layout)

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contains an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(awful.util.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

	-- Create a tasklist widget
	--s.mytasklist = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, awful.util.tasklist_buttons)

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "top", screen = s, height = 16, bg = "#00000000", fg = theme.fg_focus })
	local net_speed_widget = require("widgets.net_speed_widget.net_speed")

	-- Add widgets to the wibox
	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left widgets
			layout = wibox.layout.fixed.horizontal,
			s.mytaglist,
			s.mypromptbox,
		},
		-- s.mytasklist, -- Middle widget
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			-- default
		},
		{ -- Right widgets
			layout = wibox.layout.fixed.horizontal,
			-- Music widget
			music_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Net speed widget
			wibox.container.background(
				wibox.container.margin(net_speed_widget(), 2, 2),
				"#55a3ff",
				gears.shape.rounded_rect
			),
			-- Spacer
			wibox.widget.textbox(" "),
			-- Keyboard
			kbd_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Volume
			brightness_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			volume_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Temp
			temp_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- CPU widget
			cpu_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Mem widget
			mem_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Battery widget
			battery_widget.battery_widget1,
			battery_widget.battery_widget2,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Package log widget
			package_log_widget.widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Clock
			clock_widget,
			-- Spacer
			wibox.widget.textbox(" "),
			-- Layout box
			s.mylayoutbox,
		},
	})
end

return theme
