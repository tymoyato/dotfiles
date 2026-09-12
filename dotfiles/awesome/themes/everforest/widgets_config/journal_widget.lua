-- journalctl error notifier widget
-- Watches systemd journal for error/critical/emergency lines.
-- Shows a badge with error count. Left-click: popup list. Right-click: clear.
-- Uses `journalctl -f -p err` piped through awful.spawn.with_line_callback.
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local lain   = require("lain")
local markup = lain.util.markup
local naughty = require("naughty")

local bg_ok     = "#000000"
local bg_err    = "#514045"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_red    = "#E67E80"
local fg_grey   = "#7A8478"
local fg_yellow = "#DBBC7F"

local MAX_ERRORS = 30
local errors = {}
local popup  = nil

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

local journal_label = wibox.widget {
    markup = markup.font(theme.font, markup.fg.color(fg_green, " ✓ ")),
    widget = wibox.widget.textbox,
}
local journal_widget = wibox.container.background(
    wibox.container.margin(journal_label, 2, 2),
    bg_ok,
    gears.shape.rounded_rect
)

local function refresh_label()
    local n = #errors
    if n == 0 then
        journal_label:set_markup(markup.font(theme.font, markup.fg.color(fg_green, " ✓ ")))
        journal_widget.bg = bg_ok
    else
        journal_label:set_markup(markup.font(theme.font,
            markup.fg.color(fg_red, " ⚠ " .. n .. " ")))
        journal_widget.bg = bg_err
    end
end

local function add_error(line)
    -- strip journalctl timestamp prefix if present
    local msg = line:match("^%S+%s+%S+%s+%S+%s+(.+)") or line
    -- skip very noisy/low-value lines
    if msg:find("Failed to connect to lvmetad") then return end

    table.insert(errors, { msg = msg, time = os.date("%H:%M:%S") })
    if #errors > MAX_ERRORS then table.remove(errors, 1) end
    refresh_label()

    -- fire a naughty notification for new errors (silent so it doesn't loop)
    local short = #msg > 80 and (msg:sub(1, 77) .. "…") or msg
    naughty.notify({
        title   = "systemd error",
        text    = short,
        preset  = naughty.config.presets.critical,
        timeout = 6,
        silent  = true,
    })
end

-- Follow journal in background
awful.spawn.with_line_callback(
    "journalctl -f -p err -o cat -n 0",
    {
        stdout = function(line)
            if line and line ~= "" then add_error(line) end
        end,
    }
)

local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = markup.font(theme.font, markup.fg.color(fg_red, "<b> Journal errors </b>")),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    if #errors == 0 then
        rows:add(wibox.container.margin(wibox.widget {
            markup = markup.font(theme.font, markup.fg.color(fg_green, " No errors ")),
            widget = wibox.widget.textbox,
        }, 6, 6, 4, 4))
    else
        for i = #errors, 1, -1 do
            local e = errors[i]
            local msg = #e.msg > 60 and (e.msg:sub(1, 57) .. "…") or e.msg
            rows:add(wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        markup = markup.font(theme.font,
                            markup.fg.color(fg_grey, e.time .. "  ") ..
                            markup.fg.color(fg_color, gears.string.xml_escape(msg))),
                        wrap   = "word_char",
                        widget = wibox.widget.textbox,
                    }, 6, 6, 3, 3
                ), bg_row
            ))
        end
    end

    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    -- Clear button
    local clear_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = markup.font(theme.font, markup.fg.color(fg_red, " ✕ Clear ")),
                widget = wibox.widget.textbox,
            }, 4, 4, 2, 2
        ), bg_popup
    )
    clear_btn:connect_signal("mouse::enter", function() clear_btn.bg = "#4a3030" end)
    clear_btn:connect_signal("mouse::leave", function() clear_btn.bg = bg_popup end)
    clear_btn:connect_signal("button::press", function()
        errors = {}
        refresh_label()
        close_popup()
    end)
    rows:add(clear_btn)

    popup = awful.popup {
        widget = { rows, bg = bg_popup, widget = wibox.container.background },
        placement = function(w)
            awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
        end,
        shape        = gears.shape.rounded_rect,
        border_width = 2,
        border_color = #errors > 0 and fg_red or fg_green,
        ontop        = true,
        visible      = true,
        minimum_width = 300,
        maximum_width = 500,
    }
    popup:connect_signal("mouse::leave", close_popup)
end

journal_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 3, function()
        errors = {}
        refresh_label()
        close_popup()
    end)
))

return journal_widget
