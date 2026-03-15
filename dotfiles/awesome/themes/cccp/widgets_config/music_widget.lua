-- Music widget using playerctl (for browser/Spotify/etc)
local wibox = require("wibox")
local awful = require("awful")
local markup = require("lain.util.markup")
local gears = require("gears")

local music_text = wibox.widget.textbox()
music_text.align = "center"
music_text.forced_width = 24
local album_art = wibox.widget.imagebox()

local text_scroll = wibox.container.scroll.horizontal(music_text, 40)
local text_area = wibox.container.constraint(text_scroll, "exact", 24, nil)

-- Create control buttons
local prev_button = wibox.widget.textbox()
local next_button = wibox.widget.textbox()

-- Set initial button text
prev_button:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", "⏮")))
next_button:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", "⏭")))

-- Set initial state: collapsed with music note
prev_button.visible = false
next_button.visible = false
music_text:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", "♪")))

local function update_music()
	-- First check if any player is active
	awful.spawn.easy_async_with_shell(
		[[playerctl status 2>/dev/null]],
		function(status)
			status = status:gsub("\n", ""):gsub("\r", ""):gsub("^%s*(.-)%s*$", "%1")
			
			-- If no player is active or status is empty, show "No music playing"
			if not status or status == "" or status == "No players found" then
				album_art:set_image(nil)
				prev_button.visible = false
				next_button.visible = false
				text_area.width = 24
				music_text.forced_width = 24
				music_text.align = "center"
				music_text:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", "♪")))
				return
			end
			
			-- If player is active, get metadata
			awful.spawn.easy_async_with_shell(
				[[playerctl metadata --format '{{artist}} - {{title}}' 2>/dev/null]],
				function(stdout)
					local song = stdout:gsub("\n", ""):gsub("\r", ""):gsub("^%s*(.-)%s*$", "%1")

					-- Debug: print the values to see what we're getting
					-- print("Status: '" .. status .. "'")
					-- print("Song: '" .. song .. "'")

					-- Check if we have valid song data
					if song and song ~= "" and song ~= " - " and song ~= "No players found" and string.len(song) > 3 then
						prev_button.visible = true
						next_button.visible = true
						text_area.width = 150
						music_text.forced_width = nil
						music_text.align = "left"
						-- Get album art
						awful.spawn.easy_async_with_shell(
							[[playerctl metadata --format '{{mpris:artUrl}}' 2>/dev/null]],
							function(art_url)
								art_url = art_url:gsub("\n", ""):gsub("\r", "")
								if art_url and art_url ~= "" and art_url ~= "file://" then
									-- Remove file:// prefix if present
									local file_path = art_url:gsub("file://", "")
									album_art:set_image(file_path)
								else
									-- Fallback to music emoji if no album art
									album_art:set_image(nil)
								end
							end
						)
						music_text:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", " " .. song .. " ")))
					else
						-- No valid metadata (player may be closing), show music icon
						album_art:set_image(nil)
						prev_button.visible = false
						next_button.visible = false
						text_area.width = 24
						music_text.forced_width = 24
						music_text.align = "center"
						music_text:set_markup(markup.font(theme.font, markup.fg.color("#FFD700", "♪")))
					end
				end
			)
		end
	)
end

local music_widget = wibox.container.background(
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
	"#DC143C",
	gears.shape.rounded_rect
)

-- Make buttons clickable
prev_button:buttons(awful.util.table.join(awful.button({}, 1, function()
	awful.spawn("playerctl previous")
	-- Add a small delay before updating to allow the player to change
	gears.timer.delayed_call(function()
		update_music()
	end)
end)))

next_button:buttons(awful.util.table.join(awful.button({}, 1, function()
	awful.spawn("playerctl next")
	-- Add a small delay before updating to allow the player to change
	gears.timer.delayed_call(function()
		update_music()
	end)
end)))

-- Make music text clickable for play/pause
local function toggle_play_pause()
	awful.spawn("playerctl play-pause")
	gears.timer.delayed_call(function()
		update_music()
	end)
end
music_text:buttons(awful.util.table.join(awful.button({}, 1, toggle_play_pause)))
text_scroll:buttons(awful.util.table.join(awful.button({}, 1, toggle_play_pause)))

-- Initial update
update_music()

-- Update every 2 seconds
local timer = gears.timer({ timeout = 2 })
timer:connect_signal("timeout", update_music)
timer:start()

return music_widget
