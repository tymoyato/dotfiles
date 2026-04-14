-- Docker Disk Widget
-- Shows total space used by Docker (images + containers + volumes + build cache)
-- Left-click: detailed breakdown popup
-- Right-click: confirm and run docker system prune
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local naughty = require("naughty")

local bg_widget = "#425047"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_yellow = "#DBBC7F"
local fg_red    = "#E67E80"
local fg_grey   = "#7A8478"

local CHECK_INTERVAL = 300  -- 5 minutes

-- Parsed rows from docker system df
-- { type=, total=, active=, size=, reclaimable= }
local df_rows = {}
local total_size = "?"
local popup = nil

local label = wibox.widget.textbox()
local function refresh_label()
    label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> 💾 %s </span>',
        fg_color, total_size
    ))
end
refresh_label()

local docker_disk_widget = wibox.container.background(
    wibox.container.margin(label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

-- Parse "1.2GB" / "500MB" / "0B" → bytes (float) for summing
local function to_bytes(str)
    if not str then return 0 end
    local val, unit = str:match("^([%d%.]+)%s*([A-Za-z]*)$")
    val = tonumber(val) or 0
    if not unit or unit == "" or unit:lower() == "b" then return val end
    unit = unit:lower()
    if unit == "kb" or unit == "kib" then return val * 1024
    elseif unit == "mb" or unit == "mib" then return val * 1024^2
    elseif unit == "gb" or unit == "gib" then return val * 1024^3
    elseif unit == "tb" or unit == "tib" then return val * 1024^4
    end
    return val
end

local function fmt_bytes(b)
    if b >= 1024^3 then return string.format("%.1f GB", b / 1024^3)
    elseif b >= 1024^2 then return string.format("%.0f MB", b / 1024^2)
    elseif b >= 1024   then return string.format("%.0f KB", b / 1024)
    else                     return string.format("%d B", b)
    end
end

local function check_disk()
    awful.spawn.easy_async_with_shell(
        "docker system df 2>/dev/null",
        function(stdout, _, _, code)
            df_rows = {}
            if code ~= 0 then
                total_size = "off"
                refresh_label()
                return
            end
            local total_b = 0
            -- Parse lines like:
            -- Images          5         3         2.512GB   1.073GB (42%)
            -- Containers      8         2         1.234MB   0B (0%)
            -- Local Volumes   3         2         512MB     200MB (39%)
            -- Build Cache     12        0         1.234GB   1.234GB
            for line in stdout:gmatch("[^\n]+") do
                -- Skip header
                if not line:match("^TYPE") then
                    -- TYPE is variable-length; use pattern that captures the SIZE column
                    local typ, rest = line:match("^(.-[%a]+)%s+(.*)")
                    if typ and rest then
                        local parts = {}
                        for tok in rest:gmatch("%S+") do
                            table.insert(parts, tok)
                        end
                        -- parts: [total, active, size, reclaimable...]
                        if #parts >= 3 then
                            local size_str = parts[3]
                            local recl_str = parts[4] or "0B"
                            -- strip trailing parenthetical percentage if it merged
                            recl_str = recl_str:match("^([%d%.A-Za-z]+)")
                            total_b = total_b + to_bytes(size_str)
                            table.insert(df_rows, {
                                type_        = typ:match("^%s*(.-)%s*$"),
                                total        = parts[1],
                                active       = parts[2],
                                size         = size_str,
                                reclaimable  = recl_str or "0B",
                            })
                        end
                    end
                end
            end
            total_size = fmt_bytes(total_b)
            refresh_label()
        end
    )
end

check_disk()
gears.timer { timeout = CHECK_INTERVAL, autostart = true, callback = check_disk }

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

local function show_prune_confirm()
    local confirm_popup

    local function make_btn(text, color, bg_default, on_press)
        local btn = wibox.container.background(
            wibox.container.margin(
                wibox.widget {
                    markup = string.format('<span font="Meslo LGS Regular 10" color="%s">%s</span>', color, text),
                    widget = wibox.widget.textbox,
                },
                8, 8, 3, 3
            ),
            bg_default,
            gears.shape.rounded_rect
        )
        btn:connect_signal("mouse::enter", function() btn.bg = "#4a5e53" end)
        btn:connect_signal("mouse::leave", function() btn.bg = bg_default end)
        btn:connect_signal("button::press", function() on_press() end)
        return btn
    end

    local yes_btn = make_btn(" Prune ", fg_red, "#4a3030", function()
        confirm_popup.visible = false
        naughty.notify({ title = "Docker", text = "Running system prune…" })
        awful.spawn.easy_async_with_shell("docker system prune -f 2>&1", function(out, _, _, ec)
            if ec == 0 then
                naughty.notify({ title = "Docker", text = "Prune complete.\n" .. out:sub(1, 120) })
            else
                naughty.notify({ title = "Docker", text = "Prune failed:\n" .. out:sub(1, 200), timeout = 10 })
            end
            check_disk()
        end)
    end)

    local no_btn = make_btn(" Cancel ", fg_color, "#374247", function()
        confirm_popup.visible = false
    end)

    confirm_popup = awful.popup {
        widget = wibox.container.margin(
            wibox.widget {
                {
                    markup = string.format('<span font="Meslo LGS Regular 10" color="%s">Run <b>docker system prune</b>?</span>', fg_yellow),
                    widget = wibox.widget.textbox,
                },
                wibox.container.place(wibox.widget {
                    yes_btn,
                    wibox.container.margin(no_btn, 8, 0, 0, 0),
                    layout = wibox.layout.fixed.horizontal,
                }),
                spacing = 8,
                layout  = wibox.layout.fixed.vertical,
            },
            10, 10, 8, 8
        ),
        placement = function(w)
            awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
        end,
        shape        = gears.shape.rounded_rect,
        border_width = 2,
        border_color = fg_red,
        ontop        = true,
        visible      = true,
        bg           = bg_popup,
    }
    confirm_popup:connect_signal("mouse::leave", function()
        confirm_popup.visible = false
    end)
end

local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = string.format(
              '<span font="Meslo LGS Regular 10" color="%s"><b> 💾 Docker Disk Usage </b></span>'
              .. '<span font="Meslo LGS Regular 10" color="%s">(%s)</span>',
              fg_green, fg_yellow, total_size),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    -- Column headers
    rows:add(wibox.widget {
        { markup = string.format(
              '<span font="Meslo LGS Regular 10" color="%s"> %-18s %6s  %6s  %6s  %s </span>',
              fg_grey, "TYPE", "TOTAL", "ACTIVE", "SIZE", "RECLAIMABLE"),
          widget = wibox.widget.textbox },
        top = 2, bottom = 2, left = 4, right = 4,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    if #df_rows == 0 then
        rows:add(wibox.widget {
            { markup = string.format(
                  '<span font="Meslo LGS Regular 10" color="%s"> Docker not available </span>', fg_grey),
              widget = wibox.widget.textbox },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        for _, r in ipairs(df_rows) do
            local row = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        markup = string.format(
                            '<span font="Meslo LGS Regular 10" color="%s">%-18s </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%6s  %6s  </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%6s  </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                            fg_color, gears.string.xml_escape(r.type_),
                            fg_grey,  r.total, r.active,
                            fg_yellow, r.size,
                            fg_green,  r.reclaimable
                        ),
                        widget = wibox.widget.textbox,
                    },
                    6, 6, 3, 3
                ),
                bg_row
            )
            row:connect_signal("mouse::enter", function() row.bg = "#424f45" end)
            row:connect_signal("mouse::leave", function() row.bg = bg_row end)
            rows:add(row)
        end
    end

    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    local prune_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = string.format('<span font="Meslo LGS Regular 10" color="%s"> 🗑 Prune (right-click to confirm) </span>', fg_red),
                widget = wibox.widget.textbox,
            },
            4, 4, 2, 2
        ),
        bg_popup
    )
    prune_btn:connect_signal("mouse::enter", function() prune_btn.bg = "#4a3030" end)
    prune_btn:connect_signal("mouse::leave", function() prune_btn.bg = bg_popup end)
    prune_btn:connect_signal("button::press", function(_, _, _, btn)
        if btn == 1 then
            close_popup()
            show_prune_confirm()
        end
    end)
    rows:add(prune_btn)

    popup = awful.popup {
        widget   = { rows, bg = bg_popup, widget = wibox.container.background },
        placement = function(w)
            awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
        end,
        shape         = gears.shape.rounded_rect,
        border_width  = 2,
        border_color  = fg_green,
        ontop         = true,
        visible       = true,
        minimum_width = 440,
        maximum_width = 640,
    }
    popup:connect_signal("mouse::leave", function() close_popup() end)
end

docker_disk_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 3, function()
        close_popup()
        show_prune_confirm()
    end)
))

return docker_disk_widget
