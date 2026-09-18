-- Pomodoro widget
-- Left-click:   start / pause
-- Right-click:  reset current session
-- Middle-click: skip to next session
local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")

local bg_widget = "#000000"
local fg_color  = "#D3C6AA"
local fg_active = "#A7C080"
local fg_paused = "#DBBC7F"

local WORK_TIME            = 25 * 60
local SHORT_BREAK          = 5  * 60
local LONG_BREAK           = 15 * 60
local SESSIONS_BEFORE_LONG = 4

local STATE = { IDLE = 0, WORK = 1, SHORT = 2, LONG = 3 }
local state         = STATE.IDLE
local remaining     = WORK_TIME
local sessions_done = 0
local running       = false

theme.widget_pomodoro = theme.dir .. "/icons/widgets/pomodoro.png"
local pomodoro_icon = wibox.widget.imagebox(theme.widget_pomodoro)
local label = wibox.widget.textbox()

local function fmt_time(secs)
    return string.format("%02d:%02d", math.floor(secs / 60), secs % 60)
end

local function refresh_label()
    local color = (state == STATE.IDLE) and fg_color or (running and fg_active or fg_paused)
    local t = (state == STATE.IDLE) and WORK_TIME or remaining
    label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> %s </span>',
        color, fmt_time(t)
    ))
end
refresh_label()

-- Single reusable timer
local ticker = gears.timer({ timeout = 1 })

local function transition_state()
    if state == STATE.WORK then
        sessions_done = sessions_done + 1
        if sessions_done % SESSIONS_BEFORE_LONG == 0 then
            state     = STATE.LONG
            remaining = LONG_BREAK
            naughty.notify({ title = "🍅 Long break — 15 minutes", silent = true })
        else
            state     = STATE.SHORT
            remaining = SHORT_BREAK
            naughty.notify({ title = "☕ Short break — 5 minutes", silent = true })
        end
    else
        state     = STATE.WORK
        remaining = WORK_TIME
    end
end

ticker:connect_signal("timeout", function()
    if not running then return end
    remaining = remaining - 1
    if remaining <= 0 then
        transition_state()
        -- auto-continue into next session
    end
    refresh_label()
end)

local function start_pause()
    if state == STATE.IDLE then
        state     = STATE.WORK
        remaining = WORK_TIME
    end
    running = not running
    if running then
        ticker:start()
    else
        ticker:stop()
    end
    refresh_label()
end

local function reset()
    running       = false
    ticker:stop()
    state         = STATE.IDLE
    remaining     = WORK_TIME
    sessions_done = 0
    refresh_label()
end

local function skip()
    ticker:stop()
    transition_state()
    if running then ticker:start() end
    refresh_label()
end

local margin = wibox.container.margin(
    wibox.widget({ pomodoro_icon, label, layout = wibox.layout.align.horizontal }),
    2, 2
)
local pomodoro_widget = wibox.container.background(
    margin,
    bg_widget,
    gears.shape.octogon
)

pomodoro_widget:buttons(awful.util.table.join(
    awful.button({}, 1, start_pause),
    awful.button({}, 2, skip),
    awful.button({}, 3, reset)
))

return pomodoro_widget
