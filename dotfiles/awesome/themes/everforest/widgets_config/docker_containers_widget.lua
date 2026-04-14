-- Docker Containers Widget
-- Shows running / total count, color-coded by status
-- Left-click: popup with container list + start / stop / restart per row
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")

local bg_widget = "#425047"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_yellow = "#DBBC7F"
local fg_red    = "#E67E80"
local fg_grey   = "#7A8478"
local fg_blue   = "#7FBBB3"

local CHECK_INTERVAL = 10

local containers = {}
local popup = nil

local label = wibox.widget.textbox()

local function refresh_label()
    local running, total = 0, #containers
    local has_unhealthy = false
    for _, c in ipairs(containers) do
        if c.running  then running = running + 1 end
        if c.unhealthy then has_unhealthy = true  end
    end
    local color = fg_green
    if has_unhealthy     then color = fg_red
    elseif running < total then color = fg_yellow
    end
    label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> 🐳 %d/%d </span>',
        color, running, total
    ))
end
refresh_label()

local docker_containers_widget = wibox.container.background(
    wibox.container.margin(label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

local function check_containers()
    awful.spawn.easy_async_with_shell(
        "docker ps -a --format '{{.Names}}|{{.Status}}|{{.RunningFor}}' 2>/dev/null",
        function(stdout, _, _, code)
            containers = {}
            if code ~= 0 then
                label:set_markup(string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> 🐳 off </span>', fg_grey
                ))
                return
            end
            for line in stdout:gmatch("[^\n]+") do
                local name, status, rf = line:match("^([^|]+)|([^|]+)|(.+)$")
                if name then
                    table.insert(containers, {
                        name        = name,
                        status      = status,
                        running_for = rf,
                        running     = status:lower():match("^up") ~= nil,
                        unhealthy   = status:lower():match("unhealthy") ~= nil,
                    })
                end
            end
            refresh_label()
        end
    )
end

check_containers()
gears.timer { timeout = CHECK_INTERVAL, autostart = true, callback = check_containers }

local function close_popup()
    if popup then popup.visible = false; popup = nil end
end

local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = string.format(
              '<span font="Meslo LGS Regular 10" color="%s"><b> 🐳 Docker Containers </b></span>',
              fg_green),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    if #containers == 0 then
        rows:add(wibox.widget {
            { markup = string.format(
                  '<span font="Meslo LGS Regular 10" color="%s"> No containers found </span>', fg_grey),
              widget = wibox.widget.textbox },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        for _, c in ipairs(containers) do
            local sc = c.running and fg_green or fg_grey
            if c.unhealthy then sc = fg_red end
            local dot  = c.running and "●" or "○"

            local action_text  = c.running and " ■ Stop " or " ▶ Start "
            local action_color = c.running and fg_red or fg_green
            local action_cmd   = c.running
                and ("docker stop " .. c.name .. " 2>/dev/null")
                or  ("docker start " .. c.name .. " 2>/dev/null")

            local function make_btn(markup_str, cmd_str)
                local btn = wibox.container.background(
                    wibox.container.margin(
                        wibox.widget { markup = markup_str, widget = wibox.widget.textbox },
                        4, 4, 1, 1
                    ),
                    "#374247",
                    gears.shape.rounded_rect
                )
                btn:connect_signal("mouse::enter", function() btn.bg = "#4a5e53" end)
                btn:connect_signal("mouse::leave", function() btn.bg = "#374247" end)
                btn:connect_signal("button::press", function()
                    close_popup()
                    awful.spawn.with_shell(cmd_str)
                    gears.timer.start_new(1.5, function() check_containers(); return false end)
                end)
                return btn
            end

            local act_btn = make_btn(
                string.format('<span font="Meslo LGS Regular 10" color="%s">%s</span>', action_color, action_text),
                action_cmd
            )
            local rst_btn = make_btn(
                string.format('<span font="Meslo LGS Regular 10" color="%s"> ↺ </span>', fg_blue),
                c.running and ("docker restart " .. c.name .. " 2>/dev/null") or "true"
            )

            local row = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        wibox.widget {
                            markup = string.format(
                                '<span font="Meslo LGS Regular 10" color="%s">%s </span>'
                                .. '<span font="Meslo LGS Regular 10" color="%s">%-22s </span>'
                                .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                                sc, dot,
                                fg_color, gears.string.xml_escape(c.name:sub(1, 22)),
                                fg_grey,  gears.string.xml_escape(c.status:sub(1, 30))
                            ),
                            widget = wibox.widget.textbox,
                        },
                        { layout = wibox.layout.flex.horizontal },
                        wibox.widget {
                            act_btn,
                            wibox.container.margin(rst_btn, 4, 0, 0, 0),
                            layout = wibox.layout.fixed.horizontal,
                        },
                        layout = wibox.layout.align.horizontal,
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
    local refresh_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = string.format('<span font="Meslo LGS Regular 10" color="%s"> ↺ Refresh </span>', fg_green),
                widget = wibox.widget.textbox,
            },
            4, 4, 2, 2
        ),
        bg_popup
    )
    refresh_btn:connect_signal("mouse::enter", function() refresh_btn.bg = "#3a4f40" end)
    refresh_btn:connect_signal("mouse::leave", function() refresh_btn.bg = bg_popup end)
    refresh_btn:connect_signal("button::press", function()
        close_popup()
        check_containers()
        gears.timer.start_new(0.5, function() show_popup(); return false end)
    end)
    rows:add(refresh_btn)

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
        minimum_width = 420,
        maximum_width = 620,
    }
    popup:connect_signal("mouse::leave", function() close_popup() end)
end

docker_containers_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end)
))

return docker_containers_widget
