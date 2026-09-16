-- Claude Code usage: current model (from statusline cache) + real rate-limit
-- usage percentage (same numbers as running /usage inside Claude Code).
local wibox = require("wibox")
local watch = require("awful.widget.watch")
local gears = require("gears")
local lain = require("lain")
local markup = lain.util.markup

local claude_text = wibox.widget.textbox()
local status_file = os.getenv("HOME") .. "/.cache/claude_status.json"
local usage_cache_file = os.getenv("HOME") .. "/.cache/claude_usage_widget_cache"

local model = "-"
local session_pct = nil
local week_pct = nil

-- Survive awesome restarts: seed from last known-good values so the widget
-- doesn't drop to "-" and sit there for up to 5min until the next slow poll.
local function load_cache()
	local f = io.open(usage_cache_file, "r")
	if not f then return end
	local line = f:read("*l")
	f:close()
	if not line then return end
	local s, w = line:match("(%S+)%s+(%S+)")
	session_pct = tonumber(s)
	week_pct = tonumber(w)
end

local function save_cache()
	local f = io.open(usage_cache_file, "w")
	if not f then return end
	f:write(string.format("%d %d\n", session_pct, week_pct or 0))
	f:close()
end

load_cache()

local function color_for(pct)
	if not pct then
		return theme.fg_normal
	elseif pct >= 80 then
		return "#e06c75"
	elseif pct >= 50 then
		return "#e5c07b"
	else
		return theme.fg_normal
	end
end

local claude_usage_widget = wibox.container.background(
	wibox.container.margin(claude_text, 2, 2),
	"#000000",
	gears.shape.octogon
)

local function render()
	local text
	if not session_pct then
		text = markup.fg.color(theme.fg_normal, " - ")
	else
		text = markup.fg.color(
			color_for(session_pct),
			string.format(" %s %d%% (wk %d%%) ", model, session_pct, week_pct or 0)
		)
	end
	claude_text:set_markup(markup.font(theme.font, text))
	claude_usage_widget.bg = (session_pct and session_pct >= 80) and "#e06c75" or "#000000"
end

-- Fast: pick up the current model from the statusline cache
watch(string.format("bash -c 'cat %s 2>/dev/null'", status_file), 5, function(_, stdout)
	local m = stdout:match('"model"%s*:%s*"(.-)"')
	local ts = tonumber(stdout:match('"ts"%s*:%s*(%d+)'))
	if m and ts and (os.time() - ts) < 1800 then
		model = m
	end
	render()
end)

-- Slow: real rate-limit usage, spawns a claude process so don't poll often.
-- On a bad/failed poll (script prints "?"), keep the last known-good value
-- instead of clobbering it with nil -- avoids flashing back to "-".
watch("bash -c '~/.local/bin/claude-usage-poll.sh'", 300, function(_, stdout)
	local s, w = stdout:match("(%S+)%s+(%S+)")
	local new_session = tonumber(s)
	local new_week = tonumber(w)
	if new_session then
		session_pct = new_session
		week_pct = new_week
		save_cache()
	end
	render()
end)

return claude_usage_widget
