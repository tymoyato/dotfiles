-- Music widget using playerctl (for browser/Spotify/etc). Shared across
-- themes; each theme passes its own bg/shape/colors via M.new(opts), same
-- exact values each theme had before this was deduped.
local wibox = require("wibox")
local awful = require("awful")
local markup = require("lain.util.markup")
local gears = require("gears")

local M = {}

local ART_CACHE_FILE = os.getenv("HOME") .. "/.cache/awesome/music_art_cache"
os.execute("mkdir -p " .. os.getenv("HOME") .. "/.cache/awesome")

-- opts: { bg, shape, accent, fg, idle_fg, icon_suffix, poll_interval }
function M.new(opts)
	local accent        = opts.accent or "#A7C080"
	local fg            = opts.fg or "#D3C6AA"
	local idle_fg       = opts.idle_fg or "#859289"
	local icon_suffix   = opts.icon_suffix or "\u{FE0E}"
	local poll_interval = opts.poll_interval or 8

	local music_text = wibox.widget.textbox()
	music_text.align = "center"
	music_text.forced_width = 24
	local album_art = wibox.widget.imagebox()

	local text_scroll = wibox.container.scroll.horizontal(music_text, 40)
	local text_area = wibox.container.constraint(text_scroll, "exact", 24, nil)

	local prev_button = wibox.widget.textbox()
	local next_button = wibox.widget.textbox()

	prev_button:set_markup(markup.font(theme.font, markup.fg.color(accent, "⏮" .. icon_suffix)))
	next_button:set_markup(markup.font(theme.font, markup.fg.color(accent, "⏭" .. icon_suffix)))

	prev_button.visible = false
	next_button.visible = false
	music_text:set_markup(markup.font(theme.font, markup.fg.color(idle_fg, "♪")))

	-- Name of whichever player's track is currently shown, so controls act on
	-- the same player as the display instead of playerctl's own default pick
	-- (which can silently be a different, e.g. paused, player).
	local active_player = nil
	-- Last art URL we set/downloaded, so an unchanged http(s) URL doesn't
	-- get re-fetched every 8s poll.
	local last_art_url = nil

	local widget -- forward decl: update_music checks widget.visible

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

	local function update_music()
		if widget and widget.visible == false then return end

		-- Query all players, get the first one that is Playing or Paused
		awful.spawn.easy_async_with_shell(
			[[playerctl -a metadata --format '{{status}}|||{{artist}}|||{{title}}|||{{xesam:url}}|||{{mpris:artUrl}}|||{{playerName}}' 2>/dev/null | grep -m1 '^Playing\|^Paused']],
			function(stdout)
				stdout = stdout:gsub("\n", ""):gsub("\r", ""):gsub("^%s*(.-)%s*$", "%1")

				if stdout == "" then
					active_player = nil
					album_art:set_image(nil)
					prev_button.visible = false
					next_button.visible = false
					text_area.width = 24
					music_text.forced_width = 24
					music_text.align = "center"
					music_text:set_markup(markup.font(theme.font, markup.fg.color(idle_fg, "♪")))
					return
				end

				local artist, title, url, art_url, player =
					stdout:match("^[^|]+|||(.-)|||(.-)|||(.-)|||(.-)|||(.-)$")
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

				if song ~= "" and string.len(song) > 3 then
					prev_button.visible = true
					next_button.visible = true
					text_area.width = 150
					music_text.forced_width = nil
					music_text.align = "left"
					load_art(art_url)
					local display = song:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
					music_text:set_markup(markup.font(theme.font, markup.fg.color(fg, " " .. display .. " ")))
				else
					album_art:set_image(nil)
					prev_button.visible = false
					next_button.visible = false
					text_area.width = 24
					music_text.forced_width = 24
					music_text.align = "center"
					music_text:set_markup(markup.font(theme.font, markup.fg.color(idle_fg, "♪")))
				end
			end
		)
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
				-- Left side with prev button
				{
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

	-- Make buttons clickable
	prev_button:buttons(awful.util.table.join(awful.button({}, 1, function()
		spawn_playerctl("previous")
		-- Add a small delay before updating to allow the player to change
		gears.timer.delayed_call(function()
			update_music()
		end)
	end)))

	next_button:buttons(awful.util.table.join(awful.button({}, 1, function()
		spawn_playerctl("next")
		-- Add a small delay before updating to allow the player to change
		gears.timer.delayed_call(function()
			update_music()
		end)
	end)))

	-- Make music text clickable for play/pause
	local function toggle_play_pause()
		spawn_playerctl("play-pause")
		gears.timer.delayed_call(function()
			update_music()
		end)
	end
	music_text:buttons(awful.util.table.join(awful.button({}, 1, toggle_play_pause)))
	text_scroll:buttons(awful.util.table.join(awful.button({}, 1, toggle_play_pause)))

	-- Initial update
	update_music()

	local timer = gears.timer({ timeout = poll_interval })
	timer:connect_signal("timeout", update_music)
	timer:start()

	return widget
end

return M
