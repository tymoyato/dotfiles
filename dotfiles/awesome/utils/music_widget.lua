-- Music widget using playerctl (for browser/Spotify/etc). Shared across
-- themes; each theme passes its own bg/shape/colors via M.new(opts), same
-- exact values each theme had before this was deduped.
--
-- Event-driven: `playerctl --follow` streams updates via playerctld (a small
-- daemon, D-Bus-activated on first use) which tracks whichever player is
-- currently active across apps. No polling process runs in the steady
-- state; poll_interval only drives a slow safety resync in case a D-Bus
-- signal is ever missed.
local wibox = require("wibox")
local awful = require("awful")
local markup = require("lain.util.markup")
local gears = require("gears")

local M = {}

local ART_CACHE_FILE = os.getenv("HOME") .. "/.cache/awesome/music_art_cache"
os.execute("mkdir -p " .. os.getenv("HOME") .. "/.cache/awesome")

-- Unique marker prefixed onto every line so a stale follow process from a
-- previous awesome session can be pkilled: awesome.restart() re-execs in
-- place and never reaps old children.
local FOLLOW_MARKER = "#awesome_music_widget#"
local FOLLOW_FORMAT = FOLLOW_MARKER
	.. "{{status}}|||{{artist}}|||{{title}}|||{{xesam:url}}|||{{mpris:artUrl}}|||{{playerName}}"

-- opts: { bg, shape, fg, idle_fg, poll_interval }
function M.new(opts)
	local fg            = opts.fg or "#D3C6AA"
	local idle_fg       = opts.idle_fg or "#859289"
	local poll_interval = opts.poll_interval or 30

	local music_icon = wibox.widget.imagebox(os.getenv("HOME") .. "/icons/music.png")
	local music_text = wibox.widget.textbox()
	music_text.align = "center"
	music_text.forced_width = 24
	local album_art = wibox.widget.imagebox()

	-- scroll.horizontal(widget, fps, speed, extra_space, ...) — the `40` here
	-- used to land in the fps slot (double the 20fps default), redrawing the
	-- wibar nonstop at 40Hz for any track with a long title.
	local text_scroll = wibox.container.scroll.horizontal(music_text, 6, 20, 40)
	local text_area = wibox.container.constraint(text_scroll, "exact", 24, nil)

	local prev_button = wibox.widget.imagebox(os.getenv("HOME") .. "/icons/left-arrow.png")
	local next_button = wibox.widget.imagebox(os.getenv("HOME") .. "/icons/right-arrow.png")

	prev_button.visible = false
	next_button.visible = false
	music_text:set_markup("")

	-- Name of whichever player's track is currently shown, so controls act on
	-- the same player as the display instead of playerctl's own default pick
	-- (which can silently be a different, e.g. paused, player).
	local active_player = nil
	-- Last art URL we set/downloaded, so an unchanged http(s) URL doesn't
	-- get re-fetched on every update.
	local last_art_url = nil

	local widget -- forward decl
	local tooltip -- forward decl: shows full "artist - title" when the scrolling text is truncated

	local function load_art(art_url)
		if art_url == "" or art_url == "file://" then
			album_art:set_image(nil)
			last_art_url = art_url
			return
		end
		if art_url:match("^file://") then
			album_art:set_image(art_url:gsub("^file://", ""))
			last_art_url = art_url
			return
		end
		if art_url:match("^https?://") then
			if art_url == last_art_url then return end
			last_art_url = art_url
			awful.spawn.easy_async(
				{ "curl", "-sL", "--max-time", "5", "-o", ART_CACHE_FILE, art_url },
				function(_, _, exitreason, exitcode)
					if exitreason == "exit" and exitcode == 0 and last_art_url == art_url then
						album_art:set_image(ART_CACHE_FILE)
					end
				end
			)
			return
		end
		album_art:set_image(nil)
	end

	local function set_idle()
		active_player = nil
		album_art:set_image(nil)
		prev_button.visible = false
		next_button.visible = false
		text_area.width = 0
		music_text.forced_width = 0
		music_text.align = "center"
		music_text:set_markup("")
		if tooltip then tooltip:set_text("") end
	end

	-- Parses one `status|||artist|||title|||url|||art_url|||player` line,
	-- from either the one-shot query or the --follow stream, and updates
	-- the widget.
	local function apply_line(line)
		line = line:gsub(FOLLOW_MARKER, "", 1):gsub("\r", ""):gsub("^%s*(.-)%s*$", "%1")

		if line == "" then
			set_idle()
			return
		end

		local status, artist, title, url, art_url, player =
			line:match("^(.-)|||(.-)|||(.-)|||(.-)|||(.-)|||(.-)$")
		if not status then
			set_idle()
			return
		end
		artist = artist or ""
		title = title or ""
		url = url or ""
		art_url = art_url or ""
		active_player = player ~= "" and player or nil

		-- Fallback to filename from URL if title is empty
		if title == "" and url ~= "" then
			title = url:match("([^/]+)$") or url
			title = title:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end)
			title = title:gsub("%.[^%.]+$", "")
		end

		local song
		if artist ~= "" and title ~= "" then
			song = artist .. " - " .. title
		elseif title ~= "" then
			song = title
		else
			song = ""
		end

		if song ~= "" and string.len(song) > 3 and status ~= "Stopped" then
			prev_button.visible = true
			next_button.visible = true
			text_area.width = 150
			music_text.forced_width = nil
			music_text.align = "left"
			load_art(art_url)
			local display = song:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
			local text_color = status == "Playing" and fg or idle_fg
			music_text:set_markup(markup.font(theme.font, markup.fg.color(text_color, " " .. display .. " ")))
			if tooltip then tooltip:set_text(song) end
		else
			set_idle()
		end
	end

	-- One-shot query: used for the initial state and as a periodic safety
	-- resync in case a D-Bus signal is ever missed by the follow stream.
	local function refresh_now()
		if widget and widget.visible == false then return end
		awful.spawn.easy_async({ "playerctl", "metadata", "--format", FOLLOW_FORMAT }, apply_line)
	end

	-- Runs `playerctl <action>` targeted at whichever player is currently
	-- shown, so the buttons never end up controlling a different player.
	local function spawn_playerctl(action)
		if active_player then
			awful.spawn({ "playerctl", "-p", active_player, action })
		else
			awful.spawn({ "playerctl", action })
		end
	end

	widget = wibox.container.background(
		wibox.container.margin(
			wibox.widget({
				-- Left side with icon and prev button
				{
					music_icon,
					prev_button,
					layout = wibox.layout.fixed.horizontal,
				},
				-- Center with album art and scrolling music text
				{
					album_art,
					text_area,
					layout = wibox.layout.fixed.horizontal,
				},
				-- Right side with next button
				{
					next_button,
					layout = wibox.layout.fixed.horizontal,
				},
				layout = wibox.layout.align.horizontal,
			}),
			2,
			4
		),
		opts.bg,
		opts.shape
	)

	tooltip = awful.tooltip({ objects = { widget } })

	-- Make buttons clickable. No manual refresh needed after these: the
	-- --follow stream picks up the resulting MPRIS change on its own.
	prev_button:buttons(awful.util.table.join(awful.button({}, 1, function()
		spawn_playerctl("previous")
	end)))

	next_button:buttons(awful.util.table.join(awful.button({}, 1, function()
		spawn_playerctl("next")
	end)))

	-- Make music text clickable for play/pause
	local function toggle_play_pause()
		spawn_playerctl("play-pause")
	end
	music_text:buttons(awful.util.table.join(awful.button({}, 1, toggle_play_pause)))
	text_scroll:buttons(awful.util.table.join(awful.button({}, 1, toggle_play_pause)))

	-- Resync on hover too, so any missed event is never visible for longer
	-- than it takes to glance at the bar.
	widget:connect_signal("mouse::enter", refresh_now)

	-- Initial state, then start the event-driven stream.
	refresh_now()

	local function start_follow()
		awful.spawn.with_line_callback(
			{ "playerctl", "--follow", "metadata", "--format", FOLLOW_FORMAT },
			{
				stdout = apply_line,
				exit = function()
					-- playerctld restarted, D-Bus hiccup, etc — reconnect.
					gears.timer.start_new(2, function()
						start_follow()
						return false
					end)
				end,
			}
		)
	end

	-- Kill any follow process left over from a previous awesome session
	-- before starting a fresh one.
	awful.spawn.easy_async({ "pkill", "-f", FOLLOW_MARKER }, start_follow)

	-- Slow safety-resync poll: the follow stream should catch everything,
	-- this only guards against a missed/dropped D-Bus signal.
	local timer = gears.timer({ timeout = poll_interval })
	timer:connect_signal("timeout", refresh_now)
	timer:start()

	return widget
end

return M
