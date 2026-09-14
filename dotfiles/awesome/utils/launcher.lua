-- Native launcher: replaces rofi (drun/window) and dmenu_run.
-- No external process spawn to open — app/run lists are cached in memory
-- and rebuilt in the background, so opening the picker is just showing
-- an already-built popup. Keyboard-driven: type to fuzzy filter, Up/Down
-- to move selection, Enter to activate, Escape to close, click also works.

local wibox    = require("wibox")
local awful    = require("awful")
local gears    = require("gears")
local beautiful = require("beautiful")
local menubar  = require("menubar")
local naughty  = require("naughty")

local M = {}

-- ── palette (matches procman/volume everforest popups) ───────────────
local bg_popup  = "#000000"
local bg_row    = "#000000"
local bg_sel    = "#425047"
local fg_color  = beautiful.fg_normal or "#D3C6AA"
local fg_green  = beautiful.fg_focus  or "#A7C080"
local fg_grey   = "#7A8478"
local font      = beautiful.font or "Meslo LGS Regular 10"

local TERMINAL_CMD = "kitty"

local VISIBLE_ROWS = 9
local POPUP_WIDTH  = 480

-- ── shared picker state ────────────────────────────────────────────
local state = nil

local shifted_symbols = {
	exclam = "!", at = "@", numbersign = "#", dollar = "$", percent = "%",
	asciicircum = "^", ampersand = "&", asterisk = "*", parenleft = "(",
	parenright = ")", underscore = "_", plus = "+", braceleft = "{",
	braceright = "}", bar = "|", colon = ":", quotedbl = '"', less = "<",
	greater = ">", question = "?", asciitilde = "~", backslash = "\\",
}

local function close()
	if not state then return end
	if state.grabber then awful.keygrabber.stop(state.grabber) end
	if state.popup then state.popup.visible = false end
	state = nil
end
M.close = close

-- Substring match ranks above fuzzy subsequence match; smaller score wins.
local function score(text, query)
	if query == "" then return 0 end
	local t, q = text:lower(), query:lower()
	local idx = t:find(q, 1, true)
	if idx then return idx end

	local ti, first, last = 1, nil, nil
	for i = 1, #q do
		local c = q:sub(i, i)
		local found = t:find(c, ti, true)
		if not found then return nil end
		first = first or found
		last = found
		ti = found + 1
	end
	return 1000 + (last - first)
end

local function filter_items()
	local scored = {}
	for idx, it in ipairs(state.items) do
		local s = score(it.name, state.query)
		if s then table.insert(scored, { item = it, s = s, idx = idx }) end
	end
	-- Tie-break by original position, not name, so a provider's own
	-- ordering (e.g. scripts-then-apps in app_cache) survives filtering.
	table.sort(scored, function(a, b)
		if a.s ~= b.s then return a.s < b.s end
		return a.idx < b.idx
	end)
	state.filtered = {}
	for _, e in ipairs(scored) do table.insert(state.filtered, e.item) end
	state.selected = 1
end

local function activate(item)
	local on_activate = state.opts.on_activate
	close()
	if on_activate then on_activate(item) end
end

local function make_icon(path)
	if not path then return nil end
	local ok, w = pcall(function()
		return wibox.widget {
			image         = path,
			resize        = true,
			forced_width  = 22,
			forced_height = 22,
			widget        = wibox.widget.imagebox,
		}
	end)
	if ok then return w end
	return nil
end

local function make_row(item, is_selected)
	local name_w = wibox.widget {
		markup = string.format('<span font="%s" color="%s">%s</span>',
			font, fg_color, gears.string.xml_escape(item.name)),
		ellipsize = "end",
		widget = wibox.widget.textbox,
	}

	local content
	local icon_w = make_icon(item.icon)
	if icon_w then
		content = wibox.widget {
			icon_w,
			wibox.container.margin(name_w, 6, 0),
			layout = wibox.layout.fixed.horizontal,
		}
	else
		content = name_w
	end

	local row = wibox.container.background(
		wibox.container.margin(content, 8, 8, 4, 4),
		is_selected and bg_sel or bg_row
	)
	row:connect_signal("mouse::enter", function() row.bg = bg_sel end)
	row:connect_signal("mouse::leave", function() row.bg = is_selected and bg_sel or bg_row end)
	row:connect_signal("button::press", function() activate(item) end)
	return row
end

local function render()
	state.list_layout:reset()
	local total = #state.filtered

	if total == 0 then
		state.list_layout:add(wibox.widget {
			markup = string.format('<span font="%s" color="%s"> %s </span>',
				font, fg_grey, gears.string.xml_escape(state.opts.empty_text or "No results")),
			widget = wibox.widget.textbox,
		})
		return
	end

	if state.selected < 1 then state.selected = 1 end
	if state.selected > total then state.selected = total end

	local window_start = math.max(1, math.min(state.selected - math.floor(VISIBLE_ROWS / 2), total - VISIBLE_ROWS + 1))
	local window_end = math.min(total, window_start + VISIBLE_ROWS - 1)

	for i = window_start, window_end do
		state.list_layout:add(make_row(state.filtered[i], i == state.selected))
	end

	if total > VISIBLE_ROWS then
		state.list_layout:add(wibox.widget {
			markup = string.format('<span font="%s" color="%s"> %d/%d </span>', font, fg_grey, state.selected, total),
			widget = wibox.widget.textbox,
		})
	end
end

local function render_input()
	local prompt_span = string.format('<span font="%s" color="%s">%s </span>',
		font, fg_green, gears.string.xml_escape(state.opts.prompt or ""))
	local query_span = string.format('<span font="%s" color="%s">%s</span>',
		font, fg_color, gears.string.xml_escape(state.query))
	local cursor_span = string.format('<span font="%s" color="%s">▏</span>', font, fg_green)
	state.input_widget:set_markup(prompt_span .. query_span .. cursor_span)
end

local function build_ui()
	state.input_widget = wibox.widget.textbox()
	state.list_layout = wibox.layout.fixed.vertical()

	local root = wibox.widget {
		wibox.container.margin(state.input_widget, 10, 10, 8, 8),
		wibox.widget { color = fg_grey, forced_height = 1, widget = wibox.widget.separator },
		wibox.container.margin(state.list_layout, 4, 4, 4, 4),
		layout = wibox.layout.fixed.vertical,
	}

	state.popup = awful.popup {
		widget = wibox.container.background(root, bg_popup),
		placement = function(w)
			awful.placement.centered(w, { honor_workarea = true })
		end,
		shape         = gears.shape.octogon,
		border_width  = 0,
		ontop         = true,
		visible       = true,
		minimum_width = POPUP_WIDTH,
		maximum_width = POPUP_WIDTH,
	}
end

local function open_grabber()
	state.grabber = awful.keygrabber.run(function(_, key, event)
		if not state or event ~= "press" then return end

		if key == "Escape" then
			if #state.query > 0 then
				state.query = ""
				filter_items()
				render()
				render_input()
				return
			end
			local on_cancel = state.opts.on_cancel
			close()
			if on_cancel then on_cancel() end
			return
		end

		if key == "Return" or key == "KP_Enter" then
			local it = state.filtered[state.selected]
			if it then
				activate(it)
			elseif state.opts.allow_custom then
				activate({ name = state.query, cmd = state.query })
			end
			return
		end

		if key == "Down" or key == "Tab" then
			state.selected = math.min(state.selected + 1, math.max(1, #state.filtered))
			render()
			return
		end

		if key == "Up" then
			state.selected = math.max(state.selected - 1, 1)
			render()
			return
		end

		local literal = nil
		if key == "space" then
			literal = " "
		elseif #key == 1 then
			literal = key
		elseif shifted_symbols[key] then
			literal = shifted_symbols[key]
		end

		local changed = false
		if key == "BackSpace" then
			if #state.query > 0 then
				state.query = state.query:sub(1, -2)
				changed = true
			end
		elseif literal then
			state.query = state.query .. literal
			changed = true
		end

		if changed then
			filter_items()
			render()
			render_input()
		end
	end)
end

local function open(opts)
	close()

	local function start(items)
		state = {
			opts     = opts,
			items    = items,
			query    = opts.prefill or "",
			selected = 1,
			filtered = {},
		}
		filter_items()
		build_ui()
		open_grabber()
		render()
		render_input()
	end

	if opts.get_items then
		opts.get_items(start)
	else
		start(opts.items or {})
	end
end

-- ── app launcher (drun + custom rofi scripts replacement) ──────────
local HOME = os.getenv("HOME")
local SCRIPTS_DIR = HOME .. "/.config/rofi/scripts"
local POWERMENU_ENTRY = SCRIPTS_DIR .. "/powermenu_entry"

-- Mirrors rofi's old `combi-modes: "script:powermenu_entry,drun"` setup:
-- reads the same KNOWN_ENTRIES list straight from powermenu_entry so the
-- two stay in sync, no duplicated list to maintain here.
local function build_script_items()
	local items = {}
	local f = io.open(POWERMENU_ENTRY, "r")
	if f then
		local content = f:read("*a")
		f:close()
		local known = content:match('KNOWN_ENTRIES="([^"]*)"')
		if known then
			for name in known:gmatch("%S+") do
				table.insert(items, { name = name, kind = "script", cmd = name })
			end
		end
	end
	return items
end

local function run_script_entry(name)
	awful.spawn({ POWERMENU_ENTRY, name })
end

local function activate_app_item(item)
	if item.kind == "script" then
		run_script_entry(item.cmd)
	else
		awful.spawn(item.cmdline)
	end
end

local app_cache = nil

-- Case-insensitive substring match against the .desktop Name. Add to this
-- to hide more system/DE noise; doesn't touch dmenu scripts or $PATH run list.
local APP_BLACKLIST = {
	"avahi",
	"about xfce",
	"thunar preferences",
	"bulk rename",
	"removable drives and media",
	"user folders update",
}

local function is_blacklisted(name)
	local lower = name:lower()
	for _, pat in ipairs(APP_BLACKLIST) do
		if lower:find(pat, 1, true) then return true end
	end
	return false
end

local function build_app_cache(cb)
	menubar.utils.terminal = TERMINAL_CMD
	menubar.menu_gen.generate(function(entries)
		local items = build_script_items()
		-- dedup by name: some scripts also have a matching .desktop file
		-- (~/.local/share/applications/wifi.desktop etc) that menu_gen
		-- would otherwise surface as a second, separate entry.
		local seen = {}
		for _, it in ipairs(items) do seen[it.name:lower()] = true end
		for _, e in ipairs(entries) do
			local key = e.name:lower()
			if not seen[key] and not is_blacklisted(e.name) then
				seen[key] = true
				table.insert(items, { name = e.name, icon = e.icon, cmdline = e.cmdline })
			end
		end
		-- scripts first (as a group), then apps, each group alphabetical
		table.sort(items, function(a, b)
			local a_script, b_script = a.kind == "script", b.kind == "script"
			if a_script ~= b_script then return a_script end
			return a.name:lower() < b.name:lower()
		end)
		app_cache = items
		if cb then cb(items) end
	end)
end

function M.show_apps(prefill)
	if app_cache then
		open({
			prompt      = "apps",
			items       = app_cache,
			empty_text  = "No apps found",
			prefill     = prefill,
			on_activate = activate_app_item,
		})
	else
		build_app_cache(function(items)
			open({
				prompt      = "apps",
				items       = items,
				empty_text  = "No apps found",
				prefill     = prefill,
				on_activate = activate_app_item,
			})
		end)
	end
end

-- ── window switcher (rofi -show window replacement) ───────────────
function M.show_windows()
	local items = {}
	for _, c in ipairs(client.get()) do
		local label = c.class or c.name or "?"
		if c.name and c.name ~= c.class then
			label = label .. "  —  " .. c.name
		end
		table.insert(items, { name = label, client = c })
	end

	open({
		prompt      = "windows",
		items       = items,
		empty_text  = "No open windows",
		on_activate = function(item)
			item.client:jump_to()
		end,
	})
end

-- ── run launcher (dmenu_run replacement, $PATH executables) ───────
local run_cache = nil

local function build_run_cache()
	local items, seen = {}, {}
	local handle = io.popen("bash -c 'compgen -c' 2>/dev/null | sort -u")
	if handle then
		for line in handle:lines() do
			if line ~= "" and not seen[line] then
				seen[line] = true
				table.insert(items, { name = line, cmd = line })
			end
		end
		handle:close()
	end
	run_cache = items
	return items
end

function M.show_run()
	local items = run_cache or build_run_cache()
	open({
		prompt      = "run",
		items       = items,
		empty_text  = "No matches",
		on_activate = function(item) awful.spawn(item.cmd) end,
	})
end

-- ── dmenu bridge, for the `rofi` shim in dmenu_scripts/rofi ───────
-- The 22 custom rofi/scripts/* stay untouched — they still call
-- `rofi -dmenu`/`-e`/`-show combi`, but that command now resolves to the
-- shim, which routes here instead of spawning real rofi. Response is
-- handed back over a plain temp file (`.done` marker signals "answered",
-- since an empty answer is itself valid and can't use file-size as the
-- signal). Writes are instant regular-file writes, never a blocking
-- open, so this can't stall the awesome event loop even if the shim
-- process were killed before reading it.
function M.show_dmenu(items_path, response_path, prompt)
	local items = {}
	local f = io.open(items_path, "r")
	if f then
		for line in f:lines() do
			if line ~= "" then table.insert(items, { name = line, cmd = line }) end
		end
		f:close()
	end

	local function write_response(text)
		local out = io.open(response_path, "w")
		if out then
			out:write(text or "")
			out:close()
		end
		local marker = io.open(response_path .. ".done", "w")
		if marker then marker:close() end
	end

	open({
		prompt       = prompt or "",
		items        = items,
		empty_text   = "type to submit",
		allow_custom = true,
		on_activate  = function(item) write_response(item.cmd) end,
		on_cancel    = function() write_response("") end,
	})
end

function M.show_message(text)
	naughty.notify({ title = "rofi", text = text or "" })
end

-- ── warm caches at startup, refresh periodically in the background ─
build_app_cache()
build_run_cache()
gears.timer {
	timeout   = 600,
	autostart = true,
	callback  = function()
		build_app_cache()
		build_run_cache()
	end,
}

return M
