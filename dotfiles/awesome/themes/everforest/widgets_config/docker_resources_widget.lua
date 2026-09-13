-- Docker Resources Widget (uses shared_docker poller)
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local docker = require("themes.everforest.widgets_config.shared_docker")

local bg_widget = "#000000"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_yellow = "#DBBC7F"
local fg_red    = "#E67E80"
local fg_grey   = "#7A8478"

local stat_rows = {}
local total_cpu = 0.0
local total_mem = 0.0
local popup = nil

local label = wibox.widget.textbox()

local function refresh_label()
    local color = fg_green
    if total_cpu > 80 then color = fg_red
    elseif total_cpu > 40 then color = fg_yellow
    end
    label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> CPU %.1f%% </span>'
        .. '<span font="Meslo LGS Regular 10" color="%s">MEM %.0fMiB </span>',
        color, total_cpu, fg_color, total_mem
    ))
end
refresh_label()

local docker_resources_widget = wibox.container.background(
    wibox.container.margin(label, 2, 2),
    bg_widget,
    gears.shape.octogon
)

docker.subscribe(function(data)
    stat_rows = {}
    total_cpu = data.total_cpu
    total_mem = data.total_mem
    if not data.available then
        label:set_markup(string.format(
            '<span font="Meslo LGS Regular 10" color="%s"> CPU --  MEM -- </span>', fg_grey))
        return
    end
    for name, s in pairs(data.stats) do
        table.insert(stat_rows, {
            name      = name,
            cpu       = s.cpu,
            cpu_str   = s.cpu_str,
            mem_used  = s.mem_used,
            mem_limit = s.mem_limit,
            mem_perc  = s.mem_perc,
            mem_mb    = s.mem_mb,
        })
    end
    refresh_label()
end)

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = string.format('<span font="Meslo LGS Regular 10" color="%s"><b> 📊 Container Resources </b></span>', fg_green),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6, widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        { markup = string.format('<span font="Meslo LGS Regular 10" color="%s"> %-22s %8s  %s </span>',
              fg_grey, "NAME", "CPU", "MEMORY"),
          widget = wibox.widget.textbox },
        top = 2, bottom = 2, left = 4, right = 4, widget = wibox.container.margin,
    })
    rows:add(wibox.widget { color = fg_grey, forced_height = 1, widget = wibox.widget.separator })

    if #stat_rows == 0 then
        rows:add(wibox.widget {
            { markup = string.format('<span font="Meslo LGS Regular 10" color="%s"> No running containers </span>', fg_grey),
              widget = wibox.widget.textbox },
            top = 4, bottom = 4, left = 6, right = 6, widget = wibox.container.margin,
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
                            fg_color, gears.string.xml_escape(r.name:sub(1,22)),
                            cpu_color, gears.string.xml_escape(r.cpu_str),
                            fg_color,  gears.string.xml_escape(r.mem_used),
                                       gears.string.xml_escape(r.mem_limit)),
                        widget = wibox.widget.textbox,
                    }, 6, 6, 3, 3),
                bg_row)
            row:connect_signal("mouse::enter", function() row.bg = "#424f45" end)
            row:connect_signal("mouse::leave", function() row.bg = bg_row end)
            rows:add(row)
        end

        rows:add(wibox.widget { color = fg_grey, forced_height = 1, widget = wibox.widget.separator })
        rows:add(wibox.widget {
            { markup = string.format(
                  '<span font="Meslo LGS Regular 10" color="%s"> Total: </span>'
                  .. '<span font="Meslo LGS Regular 10" color="%s">%.1f%%  </span>'
                  .. '<span font="Meslo LGS Regular 10" color="%s">%.0f MiB </span>',
                  fg_grey, fg_yellow, total_cpu, fg_color, total_mem),
              widget = wibox.widget.textbox },
            top = 3, bottom = 3, left = 6, right = 6, widget = wibox.container.margin,
        })
    end

    popup = awful.popup {
        widget   = { rows, bg = bg_popup, widget = wibox.container.background },
        placement = function(w)
            awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
        end,
        shape = gears.shape.octogon, border_width = 2, border_color = fg_green,
        ontop = true, visible = true, minimum_width = 360, maximum_width = 560,
    }
    popup:connect_signal("mouse::leave", function() close_popup() end)
end

docker_resources_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end)
))

return docker_resources_widget
