-- Docker Resources Widget
-- Shows aggregate CPU% and memory usage across all running containers
-- Left-click: per-container breakdown popup
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

local bg_widget = "#425047"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_yellow = "#DBBC7F"
local fg_red    = "#E67E80"
local fg_grey   = "#7A8478"

local CHECK_INTERVAL = 8

local stat_rows = {}   -- list of { name, cpu, mem_used, mem_limit, mem_perc }
local total_cpu = 0.0
local popup = nil

local label = wibox.widget.textbox()

local function refresh_label()
    local color = fg_green
    if total_cpu > 80 then color = fg_red
    elseif total_cpu > 40 then color = fg_yellow
    end
    -- Sum memory used (show in MiB)
    local mem_mb = 0
    for _, r in ipairs(stat_rows) do
        mem_mb = mem_mb + (r.mem_mb or 0)
    end
    label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> CPU %.1f%% </span>'
        .. '<span font="Meslo LGS Regular 10" color="%s">MEM %.0fMiB </span>',
        color, total_cpu,
        fg_color, mem_mb
    ))
end
refresh_label()

local docker_resources_widget = wibox.container.background(
    wibox.container.margin(label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

-- Parse "256MiB" / "1.5GiB" / "512kB" → MiB float
local function to_mib(str)
    if not str then return 0 end
    local val, unit = str:match("^([%d%.]+)%s*([A-Za-z]+)$")
    val = tonumber(val) or 0
    if not unit then return val end
    unit = unit:lower()
    if unit == "gib" or unit == "gb"  then return val * 1024
    elseif unit == "mib" or unit == "mb"  then return val
    elseif unit == "kib" or unit == "kb"  then return val / 1024
    elseif unit == "b"                     then return val / (1024 * 1024)
    end
    return val
end

local function check_stats()
    awful.spawn.easy_async_with_shell(
        "docker stats --no-stream --format '{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}|{{.MemPerc}}' 2>/dev/null",
        function(stdout, _, _, code)
            stat_rows  = {}
            total_cpu  = 0.0
            if code ~= 0 then
                label:set_markup(string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> CPU --  MEM -- </span>', fg_grey
                ))
                return
            end
            for line in stdout:gmatch("[^\n]+") do
                local name, cpu_s, mem_s, mem_p = line:match("^([^|]+)|([^|]+)|([^|]+)|(.+)$")
                if name then
                    local cpu_val = tonumber(cpu_s:match("([%d%.]+)")) or 0
                    local used, limit = mem_s:match("([%d%.%a]+)%s*/%s*([%d%.%a]+)")
                    total_cpu = total_cpu + cpu_val
                    table.insert(stat_rows, {
                        name      = name,
                        cpu       = cpu_val,
                        cpu_str   = cpu_s,
                        mem_used  = used  or "?",
                        mem_limit = limit or "?",
                        mem_perc  = mem_p,
                        mem_mb    = to_mib(used),
                    })
                end
            end
            refresh_label()
        end
    )
end

check_stats()
gears.timer { timeout = CHECK_INTERVAL, autostart = true, callback = check_stats }

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = string.format(
              '<span font="Meslo LGS Regular 10" color="%s"><b> 📊 Container Resources </b></span>',
              fg_green),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    -- Column headers
    rows:add(wibox.widget {
        { markup = string.format(
              '<span font="Meslo LGS Regular 10" color="%s"> %-22s %8s  %s </span>',
              fg_grey, "NAME", "CPU", "MEMORY"),
          widget = wibox.widget.textbox },
        top = 2, bottom = 2, left = 4, right = 4,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    if #stat_rows == 0 then
        rows:add(wibox.widget {
            { markup = string.format(
                  '<span font="Meslo LGS Regular 10" color="%s"> No running containers </span>', fg_grey),
              widget = wibox.widget.textbox },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        for _, r in ipairs(stat_rows) do
            local cpu_color = fg_green
            if r.cpu > 80 then cpu_color = fg_red
            elseif r.cpu > 40 then cpu_color = fg_yellow
            end
            local row = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        markup = string.format(
                            '<span font="Meslo LGS Regular 10" color="%s">%-22s </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%8s  </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%s / %s</span>',
                            fg_color, gears.string.xml_escape(r.name:sub(1, 22)),
                            cpu_color, gears.string.xml_escape(r.cpu_str),
                            fg_color,  gears.string.xml_escape(r.mem_used),
                                       gears.string.xml_escape(r.mem_limit)
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

        -- Total row
        rows:add(wibox.widget {
            color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
        })
        local total_mem = 0
        for _, r in ipairs(stat_rows) do total_mem = total_mem + (r.mem_mb or 0) end
        rows:add(wibox.widget {
            { markup = string.format(
                  '<span font="Meslo LGS Regular 10" color="%s"> Total: </span>'
                  .. '<span font="Meslo LGS Regular 10" color="%s">%.1f%%  </span>'
                  .. '<span font="Meslo LGS Regular 10" color="%s">%.0f MiB </span>',
                  fg_grey,
                  fg_yellow, total_cpu,
                  fg_color,  total_mem),
              widget = wibox.widget.textbox },
            top = 3, bottom = 3, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    end

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
        minimum_width = 360,
        maximum_width = 560,
    }
    popup:connect_signal("mouse::leave", function() close_popup() end)
end

docker_resources_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end)
))

return docker_resources_widget
