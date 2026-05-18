-- Net Speed Widget — reads /proc/net/dev directly, zero subprocesses.
-- One shared timer; each call to worker() gets its own display widget
-- updated by the shared timer callback. Safe for multi-monitor setups.
local wibox     = require("wibox")
local gears     = require("gears")
local beautiful = require("beautiful")
local markup    = require("lain.util.markup")

local ICONS_DIR = os.getenv("HOME") .. "/.config/awesome/widgets/net_speed_widget/icons/"

local function fmt_speed(bytes_per_sec)
    local bits = bytes_per_sec * 8
    if bits < 1000 then
        return string.format("%d b/s", math.floor(bits))
    elseif bits < 1e6 then
        return string.format("%d kb/s", math.floor(bits / 1000 + 0.5))
    elseif bits < 1e9 then
        return string.format("%.1f Mb/s", bits / 1e6)
    else
        return string.format("%.2f Gb/s", bits / 1e9)
    end
end

local function read_net_stats(iface)
    local rx, tx = 0, 0
    local f = io.open("/proc/net/dev", "r")
    if not f then return 0, 0 end
    for line in f:lines() do
        local name, rbytes, tbytes = line:match(
            "^%s*(%S+):%s*(%d+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+(%d+)")
        if name then
            local skip = (name == "lo")
            if iface ~= "*" then skip = (name ~= iface) end
            if not skip then
                rx = rx + (tonumber(rbytes) or 0)
                tx = tx + (tonumber(tbytes) or 0)
            end
        end
    end
    f:close()
    return rx, tx
end

-- Shared state per interface
local _shared = {}   -- [iface] = { timer, prev_rx, prev_tx, displays=[] }

local net_speed_widget = {}

local function worker(user_args)
    local args    = user_args or {}
    local iface   = args.interface or "*"
    local timeout = args.timeout or 2
    local width   = args.width or 55

    -- Per-screen display widget
    local widget = wibox.widget({
        {
            id           = "rx_speed",
            forced_width = width,
            align        = "right",
            widget       = wibox.widget.textbox,
        },
        {
            image  = ICONS_DIR .. "down.svg",
            widget = wibox.widget.imagebox,
        },
        {
            image  = ICONS_DIR .. "up.svg",
            widget = wibox.widget.imagebox,
        },
        {
            id           = "tx_speed",
            forced_width = width,
            align        = "left",
            widget       = wibox.widget.textbox,
        },
        layout = wibox.layout.fixed.horizontal,
        set_rx_text = function(self, v)
            self:get_children_by_id("rx_speed")[1]:set_markup(
                markup.font(beautiful.font, markup.fg.color(beautiful.fg_normal, tostring(v))))
        end,
        set_tx_text = function(self, v)
            self:get_children_by_id("tx_speed")[1]:set_markup(
                markup.font(beautiful.font, markup.fg.color(beautiful.fg_normal, tostring(v))))
        end,
    })

    -- Create shared timer for this interface if not yet done
    if not _shared[iface] then
        local prev_rx, prev_tx = read_net_stats(iface)
        _shared[iface] = {
            prev_rx   = prev_rx,
            prev_tx   = prev_tx,
            displays  = {},
            rx_text   = "0 b/s",
            tx_text   = "0 b/s",
        }
        gears.timer({
            timeout   = timeout,
            autostart = true,
            callback  = function()
                local sh = _shared[iface]
                local cur_rx, cur_tx = read_net_stats(iface)
                sh.rx_text = fmt_speed((cur_rx - sh.prev_rx) / timeout)
                sh.tx_text = fmt_speed((cur_tx - sh.prev_tx) / timeout)
                sh.prev_rx, sh.prev_tx = cur_rx, cur_tx
                for _, w in ipairs(sh.displays) do
                    w:set_rx_text(sh.rx_text)
                    w:set_tx_text(sh.tx_text)
                end
            end,
        })
    end

    table.insert(_shared[iface].displays, widget)
    return widget
end

return setmetatable(net_speed_widget, {
    __call = function(_, ...) return worker(...) end,
})
