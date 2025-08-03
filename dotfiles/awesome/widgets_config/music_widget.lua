-- Music widget using playerctl (for browser/Spotify/etc)
local wibox = require("wibox")
local awful = require("awful")
local markup = require("lain.util.markup")
local gears = require("gears")

local music_text = wibox.widget.textbox()
local album_art = wibox.widget.imagebox()

-- Create control buttons
local prev_button = wibox.widget.textbox()
local next_button = wibox.widget.textbox()

-- Set initial button text
prev_button:set_markup(markup.font(theme.font, markup.fg.color("#ffffff", "⏮")))
next_button:set_markup(markup.font(theme.font, markup.fg.color("#ffffff", "⏭")))

-- Set initial music text
music_text:set_markup(markup.font(theme.font, markup.fg.color("#ffffff", " Loading... ")))

local function update_music()
	-- First check if any player is active
	awful.spawn.easy_async_with_shell(
		[[playerctl status 2>/dev/null]],
		function(status)
			status = status:gsub("\n", ""):gsub("\r", ""):gsub("^%s*(.-)%s*$", "%1")
			
			-- If no player is active or status is empty, show "No music playing"
			if not status or status == "" or status == "No players found" then
				album_art:set_image(nil)
				music_text:set_markup(markup.font(theme.font, markup.fg.color("#ffffff", " No music playing ")))
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
						music_text:set_markup(markup.font(theme.font, markup.fg.color("#ffffff", " " .. song .. " ")))
					else
						-- If no valid metadata but player is active, show "Unknown track"
						album_art:set_image(nil)
						music_text:set_markup(markup.font(theme.font, markup.fg.color("#ffffff", " Unknown track ")))
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
			-- Center with album art and music text
			{
				album_art,
				music_text,
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
	"#e84393",
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
music_text:buttons(awful.util.table.join(awful.button({}, 1, function()
	awful.spawn("playerctl play-pause")
	-- Add a small delay before updating to allow the player to change
	gears.timer.delayed_call(function()
		update_music()
	end)
end)))

-- Initial update
update_music()

-- Update every 2 seconds
local timer = gears.timer({ timeout = 2 })
timer:connect_signal("timeout", update_music)
timer:start()

return music_widget
