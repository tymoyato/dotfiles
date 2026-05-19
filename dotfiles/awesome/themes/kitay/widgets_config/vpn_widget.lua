-- VPN / Public IP widget
-- Shows VPN status + public IP. Polls every 30s.
-- Left-click: force refresh
-- Right-click: show popup with full IP + location info
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local lain   = require("lain")
local markup = lain.util.markup

local bg_widget  = "#425047"
local bg_vpn_on  = "#374247"
local bg_vpn_off = "#514045"
local bg_popup   = "#2D353B"
local fg_color   = "#D3C6AA"
local fg_green   = "#A7C080"
local fg_red     = "#E67E80"
local fg_grey    = "#7A8478"
local fg_yellow  = "#DBBC7F"

local popup = nil
local last_ip   = "…"
local last_city = ""
local last_org  = ""
local is_vpn    = false

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

local vpn_label = wibox.widget {
    markup = markup.font(theme.font, markup.fg.color(fg_grey, " ⬡ … ")),
    widget = wibox.widget.textbox,
}

local vpn_widget = wibox.container.background(
    wibox.container.margin(vpn_label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

local function detect_vpn(org)
    if not org then return false end
    local org_lower = org:lower()
    return org_lower:find("vpn") or org_lower:find("mullvad") or org_lower:find("proton")
        or org_lower:find("nordvpn") or org_lower:find("expressvpn") or org_lower:find("tunnel")
        or org_lower:find("wireguard") or org_lower:find("openvpn")
end

local function also_check_interface()
    -- Quick check: if tun0 / wg0 / proton0 exists → VPN active
    local f = io.open("/proc/net/dev", "r")
    if not f then return false end
    local content = f:read("*all"); f:close()
    return content:find("tun%d") or content:find("wg%d") or content:find("proton%d")
end

local function refresh()
    awful.spawn.easy_async(
        "curl -s --max-time 8 https://ipinfo.io/json",
        function(stdout)
            local ip   = stdout:match('"ip"%s*:%s*"([^"]+)"')   or "?"
            local city = stdout:match('"city"%s*:%s*"([^"]+)"') or ""
            local org  = stdout:match('"org"%s*:%s*"([^"]+)"')  or ""

            last_ip   = ip
            last_city = city
            last_org  = org
            is_vpn    = detect_vpn(org) or also_check_interface()

            local label, bg
            if is_vpn then
                label = markup.fg.color(fg_green, " ⬡ VPN ")
                bg    = bg_vpn_on
            else
                label = markup.fg.color(fg_red, " ⬡ " .. (ip ~= "?" and ip or "no IP") .. " ")
                bg    = bg_vpn_off
            end
            vpn_label:set_markup(markup.font(theme.font, label))
            vpn_widget.bg = bg
        end
    )
end

-- Show detail popup
local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = markup.font(theme.font, markup.fg.color(fg_green, "<b> Network </b>")),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    local function row(key, val, val_color)
        return wibox.container.margin(
            wibox.widget {
                markup = markup.font(theme.font,
                    markup.fg.color(fg_grey, key .. "  ") ..
                    markup.fg.color(val_color or fg_color, val)),
                widget = wibox.widget.textbox,
            },
            6, 6, 2, 2
        )
    end

    rows:add(row("IP", last_ip, is_vpn and fg_green or fg_red))
    if last_city ~= "" then rows:add(row("City", last_city)) end
    rows:add(row("VPN", is_vpn and "active" or "not detected",
        is_vpn and fg_green or fg_yellow))

    -- Refresh button
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })
    local ref_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = markup.font(theme.font, markup.fg.color(fg_green, " ↺ Refresh ")),
                widget = wibox.widget.textbox,
            }, 4, 4, 2, 2
        ), bg_popup
    )
    ref_btn:connect_signal("mouse::enter", function() ref_btn.bg = "#3a4f40" end)
    ref_btn:connect_signal("mouse::leave", function() ref_btn.bg = bg_popup end)
    ref_btn:connect_signal("button::press", function()
        close_popup()
        refresh()
    end)
    rows:add(ref_btn)

    popup = awful.popup {
        widget = { rows, bg = bg_popup, widget = wibox.container.background },
        placement = function(w)
            awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
        end,
        shape        = gears.shape.rounded_rect,
        border_width = 2,
        border_color = is_vpn and fg_green or fg_red,
        ontop         = true,
        visible       = true,
        minimum_width = 160,
        maximum_width = 220,
    }
    popup:connect_signal("mouse::leave", close_popup)
end

-- Poll every 30s
gears.timer {
    timeout   = 30,
    call_now  = true,
    autostart = true,
    callback  = refresh,
}

vpn_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 3, function() refresh() end)
))

return vpn_widget
