-- Pomodoro widget
-- Left-click:  start / pause
-- Right-click: reset current session
-- Middle-click: skip to next session
local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")

-- Everforest colors
local bg_widget  = "#425047"
local fg_color   = "#D3C6AA"
local fg_active  = "#A7C080"  -- green  (running)
local fg_paused  = "#DBBC7F"  -- yellow (paused)

-- Durations in seconds
local WORK_TIME       = 25 * 60
local SHORT_BREAK     = 5  * 60
local LONG_BREAK      = 15 * 60
local SESSIONS_BEFORE_LONG = 4

-- State
local STATE = { IDLE = 0, WORK = 1, SHORT = 2, LONG = 3 }
local state         = STATE.IDLE
local remaining     = WORK_TIME
local sessions_done = 0
local ticker        = nil

local label = wibox.widget.textbox()

local function fmt_time(secs)
    return string.format("%02d:%02d", math.floor(secs / 60), secs % 60)
end

local function refresh_label()
    local icon, time
    if state == STATE.IDLE then
        icon = "🍅"
        time = fmt_time(WORK_TIME)
    elseif state == STATE.WORK then
        icon = "🍅"
        time = fmt_time(remaining)
    elseif state == STATE.SHORT then
        icon = "☕"
        time = fmt_time(remaining)
    elseif state == STATE.LONG then
        icon = "🛋"
        time = fmt_time(remaining)
    end
    local color = state == STATE.IDLE and fg_color
                  or ticker and fg_active
                  or fg_paused
    label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> %s %s </span>',
        color, icon, time
    ))
end
refresh_label()

local margin = wibox.container.margin(label, 2, 2)
local pomodoro_widget = wibox.container.background(
    margin,
    bg_widget,
    gears.shape.rounded_rect
)

local function stop_ticker()
    if ticker then
        ticker:stop()
        ticker = nil
    end
end

local function make_ticker()
    local t = gears.timer({ timeout = 1 })
    t:connect_signal("timeout", function()
        remaining = remaining - 1
        refresh_label()
        if remaining <= 0 then
            stop_ticker()
            -- transition to next session
            if state == STATE.WORK then
                sessions_done = sessions_done + 1
                if sessions_done % SESSIONS_BEFORE_LONG == 0 then
                    state     = STATE.LONG
                    remaining = LONG_BREAK
                    naughty.notify({ title = "🍅 Long break — 15 minutes" })
                else
                    state     = STATE.SHORT
                    remaining = SHORT_BREAK
                    naughty.notify({ title = "☕ Short break — 5 minutes" })
                end
            else
                state     = STATE.WORK
                remaining = WORK_TIME
            end
            refresh_label()
            ticker = make_ticker()
        end
    end)
    t:start()
    return t
end

local function start_pause()
    if state == STATE.IDLE then
        state     = STATE.WORK
        remaining = WORK_TIME
        ticker    = make_ticker()
    elseif ticker then
        stop_ticker()
    else
        ticker = make_ticker()
    end
    refresh_label()
end

local function reset()
    stop_ticker()
    state         = STATE.IDLE
    remaining     = WORK_TIME
    sessions_done = 0
    refresh_label()
end

local function skip()
    stop_ticker()
    if state == STATE.WORK then
        sessions_done = sessions_done + 1
        if sessions_done % SESSIONS_BEFORE_LONG == 0 then
            state     = STATE.LONG
            remaining = LONG_BREAK
        else
            state     = STATE.SHORT
            remaining = SHORT_BREAK
        end
    else
        state     = STATE.WORK
        remaining = WORK_TIME
    end
    ticker = make_ticker()
    refresh_label()
end

pomodoro_widget:buttons(awful.util.table.join(
    awful.button({}, 1, start_pause),
    awful.button({}, 2, skip),
    awful.button({}, 3, reset)
))

return pomodoro_widget
