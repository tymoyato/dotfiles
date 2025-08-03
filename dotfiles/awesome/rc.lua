local awesome, client, mouse, screen, tag = awesome, client, mouse, screen, tag
local ipairs, string, os, table, tostring, tonumber, type = ipairs, string, os, table, tostring, tonumber, type
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- Load Debian menu entries
-- local debian = require("debian.menu")
local has_fdo, freedesktop = pcall(require, "freedesktop")
local lain = require("lain")
-- local scratch = require("scratch")

-- {{{ Error handling
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- Naughty presets
naughty.config.defaults.timeout = 5
naughty.config.defaults.screen = 1
naughty.config.defaults.position = "top_right"
naughty.config.defaults.margin = 8
naughty.config.defaults.gap = 1
naughty.config.defaults.ontop = true
naughty.config.defaults.font = "Meslo LGS Regular 10"
naughty.config.defaults.icon = nil
naughty.config.defaults.icon_size = 32
naughty.config.defaults.fg = beautiful.fg_tooltip
naughty.config.defaults.bg = beautiful.bg_tooltip
naughty.config.defaults.border_color = beautiful.border_tooltip
naughty.config.defaults.border_width = 2
naughty.config.defaults.hover_timeout = nil

lain.layout.termfair.nmaster = 3
lain.layout.termfair.ncol = 1
lain.layout.termfair.center.nmaster = 3
lain.layout.termfair.center.ncol = 1
lain.layout.cascade.tile.offset_x = 2
lain.layout.cascade.tile.offset_y = 32
lain.layout.cascade.tile.extra_padding = 5
lain.layout.cascade.tile.nmaster = 5
lain.layout.cascade.tile.ncol = 2

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
local themes = {
	"kitay",
	"cccp",
}
local i3lock_settings = "i3lock-fancy"
-- Try to read saved theme index from file
local current_theme_index = 1
local theme_file = io.open("/tmp/awesome_current_theme", "r")
if theme_file then
	local saved_index = tonumber(theme_file:read("*line"))
	if saved_index and saved_index >= 1 and saved_index <= #themes then
		current_theme_index = saved_index
	end
	theme_file:close()
end

local chosen_theme = themes[current_theme_index]

local function switch_theme()
	current_theme_index = current_theme_index % #themes + 1
	chosen_theme = themes[current_theme_index]

	-- Save current tag state
	local current_tag = awful.screen.focused().selected_tag
	local current_tag_index = current_tag and current_tag.index or 1

	-- Show notification before restart
	naughty.notify({
		title = "Theme Changed",
		text = "Switching to " .. chosen_theme .. " theme...",
		timeout = 1,
	})

	-- Save current theme index and tag to temporary files
	local theme_file = io.open("/tmp/awesome_current_theme", "w")
	if theme_file then
		theme_file:write(current_theme_index)
		theme_file:close()
	end

	local tag_file = io.open("/tmp/awesome_current_tag", "w")
	if tag_file then
		tag_file:write(current_tag_index)
		tag_file:close()
	end

	-- Create a flag file to indicate this is a theme switch restart
	local flag_file = io.open("/tmp/awesome_theme_switch", "w")
	if flag_file then
		flag_file:write("1")
		flag_file:close()
	end

	-- Restart awesome to apply theme change
	awesome.restart()
end

local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), chosen_theme)
beautiful.init(theme_path)

TERMINAL = "kitty"
local editor = os.getenv("EDITOR") or "editor"
local editor_cmd = TERMINAL .. " -e " .. editor
awful.spawn.with_shell("picom --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("~/.config/awesome/utils/apps.sh")
-- Run package checker with output logging and delay
awful.spawn.with_shell("sleep 2 && ~/.Kitay-Gorod/dotfiles/awesome/utils/package-checker.sh >> ~/.Kitay-Gorod/linux/package-checker-debug.log 2>&1")
awful.spawn.with_shell("~/.config/awesome/display-setup.sh")
-- awful.spawn.with_shell("sudo -u ervin DISPLAY=:0 /home/ervin/.utils/home_reset_display.sh")
-- awful.spawn.with_shell("~/.utils/apps.sh")
-- awful.spawn.with_shell("~/.utils/vpn.sh")
-- awful.spawn.with_shell("~/.utils/touchpad.sh")

MODKEY = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	awful.layout.suit.max,
	lain.layout.centerwork,
	awful.layout.suit.spiral,
	awful.layout.suit.magnifier,
	awful.layout.suit.fair,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", TERMINAL .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", TERMINAL }
local mymainmenu

if has_fdo then
	mymainmenu = freedesktop.menu.build({
		before = { menu_awesome },
		after = { menu_terminal },
	})
else
	mymainmenu = awful.menu({
		items = {
			menu_awesome,
			--{ "Debian", debian.menu.Debian_menu.Debian },
			menu_terminal,
		},
	})
end

-- Menubar configuration
menubar.utils.terminal = TERMINAL
-- }}}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar

local function set_wallpaper(s)
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

awful.screen.connect_for_each_screen(function(s)
	beautiful.connect(s)
end)

-- Restore tag state after restart
local tag_file = io.open("/tmp/awesome_current_tag", "r")
if tag_file then
	local saved_tag_index = tonumber(tag_file:read("*line"))
	if saved_tag_index and saved_tag_index >= 1 and saved_tag_index <= 9 then
		-- Use a timer with longer timeout to ensure everything is initialized
		local restore_timer = gears.timer({ timeout = 1 })
		restore_timer:connect_signal("timeout", function()
			local screen = awful.screen.focused()
			if screen and screen.tags[saved_tag_index] then
				screen.tags[saved_tag_index]:view_only()
				-- Show notification for debugging
				naughty.notify({
					title = "Tag Restored",
					text = "Restored to tag " .. saved_tag_index,
					timeout = 2,
				})
			end
			restore_timer:stop()
		end)
		restore_timer:start()
	end
	tag_file:close()
	-- Clean up the temporary files
	os.remove("/tmp/awesome_current_tag")
	os.remove("/tmp/awesome_theme_switch")
	os.remove("/tmp/awesome_normal_restart")
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
GLOBALKEYS = gears.table.join(
	-- Show/Hide Wibox
	awful.key({ MODKEY }, "b", function()
		awful.screen.connect_for_each_screen(function(s)
			if s.mywibox then
				s.mywibox.visible = not s.mywibox.visible
			end
			if s.mybottomwibox then
				s.mybottomwibox.visible = not s.mybottomwibox.visible
			end
		end)
	end, { description = "toggle wibox", group = "awesome" }),

	awful.key({ MODKEY, "Control" }, "x", function()
		awful.util.spawn(i3lock_settings)
	end),
	awful.key({ MODKEY }, "s", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ MODKEY }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ MODKEY }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
	awful.key({ MODKEY }, "Escape", awful.tag.history.restore, { description = "go back", group = "tag" }),

	awful.key({ MODKEY }, "j", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ MODKEY }, "k", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),
	awful.key({ MODKEY }, "w", function()
		mymainmenu:show()
	end, { description = "show main menu", group = "awesome" }),

	-- Layout manipulation
	awful.key({ MODKEY, "Shift" }, "j", function()
		awful.client.swap.byidx(1)
	end, { description = "swap with next client by index", group = "client" }),
	awful.key({ MODKEY, "Shift" }, "k", function()
		awful.client.swap.byidx(-1)
	end, { description = "swap with previous client by index", group = "client" }),
	awful.key({ MODKEY, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ MODKEY, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),
	awful.key({ MODKEY }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ MODKEY }, "Tab", function()
		awful.client.focus.history.previous()
		if client.focus then
			client.focus:raise()
		end
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ MODKEY }, "Return", function()
		awful.spawn(TERMINAL)
	end, { description = "open a terminal", group = "launcher" }),
	awful.key({ MODKEY, "Control" }, "r", function()
		-- Save current tag state
		local current_tag = awful.screen.focused().selected_tag
		local current_tag_index = current_tag and current_tag.index or 1

		-- Save current tag to temporary file
		local tag_file = io.open("/tmp/awesome_current_tag", "w")
		if tag_file then
			tag_file:write(current_tag_index)
			tag_file:close()
		end

		-- Create a flag file to indicate this is a normal restart
		local flag_file = io.open("/tmp/awesome_normal_restart", "w")
		if flag_file then
			flag_file:write("1")
			flag_file:close()
		end

		-- Restart awesome
		awesome.restart()
	end, { description = "reload awesome", group = "awesome" }),
	awful.key({ MODKEY, "Shift" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ MODKEY }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ MODKEY }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),
	awful.key({ MODKEY, "Shift" }, "h", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ MODKEY, "Shift" }, "l", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),
	awful.key({ MODKEY, "Control" }, "h", function()
		awful.tag.incncol(1, nil, true)
	end, { description = "increase the number of columns", group = "layout" }),
	awful.key({ MODKEY, "Control" }, "l", function()
		awful.tag.incncol(-1, nil, true)
	end, { description = "decrease the number of columns", group = "layout" }),
	awful.key({ MODKEY }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ MODKEY, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ MODKEY, "Control" }, "n", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	awful.key({ MODKEY }, "r", function()
		awful.screen.focused().mypromptbox:run()
	end, { description = "run prompt", group = "launcher" }),

	awful.key({ MODKEY }, "x", function()
		awful.prompt.run({
			prompt = "Run Lua code: ",
			textbox = awful.screen.focused().mypromptbox.widget,
			exe_callback = awful.util.eval,
			history_path = awful.util.get_cache_dir() .. "/history_eval",
		})
	end, { description = "lua execute prompt", group = "awesome" }),
	-- Menubar
	-- awful.key({ MODKEY }, "o", function() menubar.show() end,
	--           {description = "show the menubar", group = "launcher"}),
	awful.key({ MODKEY }, "p", function()
		awful.util.spawn(string.format("rofi -show drun"))
	end),

	-- Theme switching
	awful.key({ MODKEY }, "t", function()
		switch_theme()
	end, { description = "switch theme", group = "awesome" }),

	-- awful.key({ MODKEY }, "o", function () scratch.drop("kitty", "bottom", "left", 0.60, 0.60, true, mouse.screen) end),
	-- Custom
	awful.key({ MODKEY }, "o", function()
		awful.spawn("flameshot gui")
	end, { description = "start flameshot", group = "launcher" }),
	awful.key({ "Control", altkey, "Shift" }, "Right", function()
		lain.util.useless_gaps_resize(7)
	end, { description = "increment useless gaps", group = "tag" }),
	awful.key({ "Control", altkey, "Shift" }, "Left", function()
		lain.util.useless_gaps_resize(-7)
	end, { description = "decrement useless gaps", group = "tag" }),
	-- Dynamic tagging
	awful.key({ MODKEY, "Shift" }, "n", function()
		lain.util.add_tag()
	end, { description = "add new tag", group = "tag" }),
	awful.key({ MODKEY, "Shift" }, "r", function()
		lain.util.rename_tag()
	end, { description = "rename tag", group = "tag" }),
	awful.key({ MODKEY, "Shift" }, "Left", function()
		lain.util.move_tag(-1)
	end, { description = "move tag to the left", group = "tag" }),
	awful.key({ MODKEY, "Shift" }, "Right", function()
		lain.util.move_tag(1)
	end, { description = "move tag to the right", group = "tag" }),
	awful.key({ MODKEY, "Shift" }, "d", function()
		lain.util.delete_tag()
	end, { description = "delete tag", group = "tag" }),

	-- Volume control
	awful.key({ MODKEY, "Shift" }, "=", function()
		awful.spawn("amixer set Master 5%+")
		-- Update volume widget if it exists
		if theme.volume and theme.volume.update then
			theme.volume.update()
		end
	end, { description = "volume up", group = "audio" }),
	awful.key({ MODKEY, "Shift" }, "-", function()
		awful.spawn("amixer set Master 5%-")
		-- Update volume widget if it exists
		if theme.volume and theme.volume.update then
			theme.volume.update()
		end
	end, { description = "volume down", group = "audio" }),

	-- Music control
	awful.key({ MODKEY, altkey }, "Right", function()
		awful.spawn("playerctl next")
	end, { description = "next track", group = "audio" }),
	awful.key({ MODKEY, altkey }, "Left", function()
		awful.spawn("playerctl previous")
	end, { description = "previous track", group = "audio" }),
	awful.key({ MODKEY, altkey }, "space", function()
		awful.spawn("playerctl play-pause")
	end, { description = "play/pause", group = "audio" })
)

CLIENTKEYS = gears.table.join(
	awful.key({ altkey, "Shift" }, "m", lain.util.magnify_client, { description = "magnify client", group = "client" }),
	awful.key({ MODKEY }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),
	awful.key({ MODKEY, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ MODKEY, "Control" },
		"space",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ MODKEY, "Control" }, "Return", function(c)
		c:swap(awful.client.getmaster())
	end, { description = "move to master", group = "client" }),
	awful.key({ MODKEY }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),
	awful.key({ MODKEY }, "t", function(c)
		c.ontop = not c.ontop
	end, { description = "toggle keep on top", group = "client" }),
	awful.key({ MODKEY }, "n", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ MODKEY }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ MODKEY, "Control" }, "m", function(c)
		c.maximized_vertical = not c.maximized_vertical
		c:raise()
	end, { description = "(un)maximize vertically", group = "client" }),
	awful.key({ MODKEY, "Shift" }, "m", function(c)
		c.maximized_horizontal = not c.maximized_horizontal
		c:raise()
	end, { description = "(un)maximize horizontally", group = "client" })
)

-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	GLOBALKEYS = gears.table.join(
		GLOBALKEYS,
		-- View tag only.
		awful.key({ MODKEY }, "#" .. i + 9, function()
			screen = awful.screen.focused()
			tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ MODKEY, "Control" }, "#" .. i + 9, function()
			screen = awful.screen.focused()
			tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ MODKEY, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ MODKEY, "Control", "Shift" }, "#" .. i + 9, function()
			if client.focus then
				tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

local clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ MODKEY }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ MODKEY }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(GLOBALKEYS)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).

-- Function to check the number of displays
-- local function get_screen_count()
-- 	return screen.count()
-- end
--
-- -- Define the rules based on the number of displays
-- local rules = {}

-- if get_screen_count() == 2 then
-- 	table.insert(rules, { rule = { class = "Brave-browser" }, properties = { screen = 1, tag = "2" } })
-- 	table.insert(rules, { rule = { class = "kitty" }, properties = { screen = 1, tag = "1" } })
-- 	table.insert(rules, { rule = { class = "Postman" }, properties = { screen = 1, tag = "3" } })
-- 	table.insert(rules, { rule = { class = "Slack" }, properties = { screen = 2, tag = "1" } })
-- else
-- table.insert(rules, { rule = { class = "Brave-browser" }, properties = { screen = 1, tag = "2" } })
-- table.insert(rules, { rule = { class = "kitty" }, properties = { screen = 1, tag = "1" } })
-- table.insert(rules, { rule = { class = "Postman" }, properties = { screen = 1, tag = "3" } })
-- table.insert(rules, { rule = { class = "Slack" }, properties = { screen = 1, tag = "4" } })
-- end

-- Check if this is a theme switch restart or normal restart
local is_theme_switch = io.open("/tmp/awesome_theme_switch", "r") ~= nil
local is_normal_restart = io.open("/tmp/awesome_normal_restart", "r") ~= nil
local is_any_restart = is_theme_switch or is_normal_restart

awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = CLIENTKEYS,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	-- Only apply tag rules if this is NOT any kind of restart
	{ rule = { class = "kitty" }, properties = { screen = 1, tag = "1" }, rule_any = { is_any_restart = false } },
	{ rule = { class = "rubymine" }, properties = { screen = 1, tag = "2" }, rule_any = { is_any_restart = false } },
	{
		rule = { class = "Brave-browser" },
		properties = { screen = 1, tag = "3" },
		rule_any = { is_any_restart = false },
	},
	{ rule = { class = "bruno" }, properties = { screen = 1, tag = "4" }, rule_any = { is_any_restart = false } },
	{ rule = { class = "firefox" }, properties = { screen = 1, tag = "5" }, rule_any = { is_any_restart = false } },
	{ rule = { class = "Slack" }, properties = { screen = 1, tag = "6" }, rule_any = { is_any_restart = false } },

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	-- if not awesome.startup then awful.client.setslave(c) end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end

	-- Debug: Check if we're restoring a tag and prevent client from changing focus
	local tag_file = io.open("/tmp/awesome_current_tag", "r")
	if tag_file then
		tag_file:close()
		-- Don't focus this client if we're restoring a tag
		c:emit_signal("request::activate", "manage", { raise = false })
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- Custom
	if beautiful.titlebar_fun then
		beautiful.titlebar_fun(c)
		return
	end

	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			-- { -- Title
			--     align  = "center",
			--     widget = awful.titlebar.widget.titlewidget(c)
			-- },
			-- buttons = buttons,
			-- layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)
-- }}}
