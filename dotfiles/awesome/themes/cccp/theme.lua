local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local os, math, string = os, math, string

theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/cccp"
theme.wallpaper = theme.dir .. "/wallpapers/moon.jpg"
theme.font = "Meslo LGS Regular 10"
theme.taglist_font = "Meslo LGS Bold 10"
theme.tasklist_font = "Terminus 10"

-- CCCP color scheme
theme.bg_normal = "#1a1a1a"
theme.fg_normal = "#ffffff"
theme.bg_focus = "#8B0000" -- Dark red
theme.fg_focus = "#FFD700" -- Gold
theme.bg_urgent = "#DC143C" -- Crimson red
theme.fg_urgent = "#FFD700" -- Gold

theme.fg_widget = "#FFD700" -- Gold

-- Taglist colors with CCCP theme
theme.taglist_bg_focus = "#DC143C" -- Crimson red
theme.taglist_fg_focus = "#FFD700" -- Gold
theme.taglist_bg_occupied = "#8B0000" -- Dark red
theme.taglist_fg_occupied = "#FFD700" -- Gold
theme.taglist_bg_empty = "#4A4A4A" -- Dark gray
theme.taglist_fg_empty = "#FFD700" -- Gold
theme.taglist_bg_urgent = "#FF4500" -- Orange red
theme.taglist_fg_urgent = "#FFD700" -- Gold
theme.taglist_shape = gears.shape.rounded_rect

-- Tasklist colors
theme.tasklist_bg_normal = "#1a1a1a"
theme.tasklist_fg_normal = "#ffffff"
theme.tasklist_bg_focus = "#8B0000" -- Dark red
theme.tasklist_fg_focus = "#FFD700" -- Gold
theme.tasklist_bg_urgent = "#DC143C" -- Crimson red
theme.tasklist_fg_urgent = "#FFD700" -- Gold

theme.border_width = 0
theme.border_normal = "#8B0000" -- Dark red
theme.border_focus = "#DC143C" -- Crimson red
theme.border_marked = "#FF4500" -- Orange red

theme.titlebar_bg_normal = "#8B0000" -- Dark red
theme.titlebar_fg_normal = "#FFD700" -- Gold

theme.titlebar_bg_focus = "#DC143C" -- Crimson red
theme.titlebar_fg_focus = "#FFD700" -- Gold

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

-- CCCP colors
theme.green = "#228B22" -- Forest green
theme.red = "#DC143C" -- Crimson red
theme.yellow = "#FFD700" -- Gold
theme.blue = "#4169E1" -- Royal blue
theme.darkred = "#8B0000" -- Dark red
theme.darkgreen = "#006400" -- Dark green
theme.darkyellow = "#B8860B" -- Dark goldenrod
theme.gray = "#696969" -- Dim gray
theme.lightgrey = "#D3D3D3" -- Light gray
theme.violet = "#8A2BE2" -- Blue violet
theme.pink = "#FF1493" -- Deep pink
theme.black = theme.bg_normal

-- USSR Flag widget
local function create_ussr_flag()
	-- Create a simple text-based USSR flag
	local flag_text = wibox.widget.textbox("☭")
	flag_text.font = "Meslo LGS Regular 12"

	-- Wrap in a container with background for visibility
	return wibox.container.background(wibox.container.margin(flag_text, 4, 4), "#DC143C", gears.shape.rounded_rect)
end

-- Panel
local markup = lain.util.markup

-- Widgets --
local clock_widget     = require("themes.cccp.widgets_config.clock_widget")
local battery_widget   = require("themes.cccp.widgets_config.battery_widget")
local mem_widget       = require("themes.cccp.widgets_config.mem_widget")
local cpu_widget       = require("themes.cccp.widgets_config.cpu_widget")
local temp_widget      = require("themes.cccp.widgets_config.temp_widget")
local disk_widget      = require("themes.cccp.widgets_config.disk_widget")
local volume_widget    = require("themes.cccp.widgets_config.volume_widget")
local kbd_widget       = require("widgets.kbd_widget.kbd_widget")
local brightness_widget = require("themes.cccp.widgets_config.brightness_widget")
local music_widget     = require("themes.cccp.widgets_config.music_widget")
local crypto_widget    = require("themes.cccp.widgets_config.crypto_widget")
local notif_widget     = require("themes.cccp.widgets_config.notif_widget")
local pkg_widget       = require("themes.cccp.widgets_config.pkg_widget")
local pomodoro_widget  = require("themes.cccp.widgets_config.pomodoro_widget")
local todo_widget      = require("themes.cccp.widgets_config.todo_widget")
local procman_widget   = require("themes.cccp.widgets_config.procman_widget")
local docker_containers_widget = require("themes.cccp.widgets_config.docker_containers_widget")
local docker_resources_widget  = require("themes.cccp.widgets_config.docker_resources_widget")
local docker_health_widget     = require("themes.cccp.widgets_config.docker_health_widget")
local docker_compose_widget    = require("themes.cccp.widgets_config.docker_compose_widget")
local docker_disk_widget       = require("themes.cccp.widgets_config.docker_disk_widget")
local cpu_graph_widget = require("themes.cccp.widgets_config.cpu_graph_widget")
local vpn_widget       = require("themes.cccp.widgets_config.vpn_widget")
local display_widget   = require("themes.cccp.widgets_config.display_widget")
local journal_widget   = require("themes.cccp.widgets_config.journal_widget")

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
	local _net_speed_widget_mod = require("widgets.net_speed_widget.net_speed")

	s.mywibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left
			layout = wibox.layout.fixed.horizontal,
			create_ussr_flag(),
			wibox.widget.textbox(" "),
			s.mytaglist,
			s.mypromptbox,
		},
		{ -- Middle
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Right
			layout = wibox.layout.fixed.horizontal,
			music_widget,
			wibox.widget.textbox(" "),
			wibox.container.background(
				wibox.container.margin(_net_speed_widget_mod(), 2, 2),
				"#DC143C",
				gears.shape.rounded_rect
			),
			wibox.widget.textbox(" "),
			brightness_widget,
			wibox.widget.textbox(" "),
			volume_widget,
			wibox.widget.textbox(" "),
			disk_widget,
			wibox.widget.textbox(" "),
			temp_widget,
			wibox.widget.textbox(" "),
			cpu_graph_widget,
			wibox.widget.textbox(" "),
			mem_widget,
			wibox.widget.textbox(" "),
			battery_widget,
			wibox.widget.textbox(" "),
			crypto_widget,
			wibox.widget.textbox(" "),
			todo_widget,
			wibox.widget.textbox(" "),
			pomodoro_widget,
			wibox.widget.textbox(" "),
			pkg_widget,
			wibox.widget.textbox(" "),
			procman_widget,
			wibox.widget.textbox(" "),
			journal_widget,
			wibox.widget.textbox(" "),
			vpn_widget,
			wibox.widget.textbox(" "),
			display_widget,
			wibox.widget.textbox(" "),
			notif_widget,
			wibox.widget.textbox(" "),
			clock_widget,
			wibox.widget.textbox(" "),
			kbd_widget,
			wibox.widget.textbox(" "),
			s.mylayoutbox,
		},
	})

	s.mydockerwibox = awful.wibar({ position = "bottom", screen = s, height = 16, bg = "#00000000", fg = theme.fg_focus })
	s.mydockerwibox:setup({
		layout = wibox.layout.align.horizontal,
		{ -- Left
			layout = wibox.layout.fixed.horizontal,
			wibox.container.background(
				wibox.container.margin(
					wibox.widget {
						markup = '<span font="Meslo LGS Regular 10" color="' .. theme.fg_widget .. '"> 🐳 docker </span>',
						widget = wibox.widget.textbox,
					},
					2, 2
				),
				"#1a1a1a",
				gears.shape.rounded_rect
			),
			wibox.widget.textbox(" "),
		},
		{ -- Middle
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Right
			layout = wibox.layout.fixed.horizontal,
			docker_containers_widget,
			wibox.widget.textbox(" "),
			docker_resources_widget,
			wibox.widget.textbox(" "),
			docker_health_widget,
			wibox.widget.textbox(" "),
			docker_compose_widget,
			wibox.widget.textbox(" "),
			docker_disk_widget,
			wibox.widget.textbox(" "),
		},
	})
end

-- Hotkeys popup (Mod+S) -- bigger, high-contrast key labels
theme.hotkeys_bg = "#1a1a1a"
theme.hotkeys_fg = "#ffffff"
theme.hotkeys_border_width = 2
theme.hotkeys_border_color = "#FFD700"           -- gold
theme.hotkeys_shape = gears.shape.rounded_rect
theme.hotkeys_modifiers_fg = "#FF4500"           -- orange red (fallback for any other modifier)
theme.hotkeys_mod_colors = {
	Super = "#4169E1",                       -- royal blue
	Shift = "#228B22",                       -- forest green
}
theme.hotkeys_plus_fg = "#D3D3D3"                -- light grey
theme.hotkeys_label_bg = "#FFD700"               -- gold chip behind each key
theme.hotkeys_label_fg = "#1a1a1a"               -- dark text on chip
theme.hotkeys_font = "Monospace Bold 9"
theme.hotkeys_description_font = "Monospace 8"
theme.hotkeys_group_margin = 6

return theme
