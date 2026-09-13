-- Docker Health Widget (uses shared_docker poller)
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

local health_data = {}
local popup = nil

local label = wibox.widget.textbox()

local function state_dot(state)
    if state == "healthy"   then return '<span color="' .. fg_green  .. '">●</span>'
    elseif state == "unhealthy" then return '<span color="' .. fg_red    .. '">●</span>'
    elseif state == "starting"  then return '<span color="' .. fg_yellow .. '">●</span>'
    else                         return '<span color="' .. fg_grey   .. '">○</span>'
    end
end

local function refresh_label()
    if #health_data == 0 then
        label:set_markup('<span font="Meslo LGS Regular 10" color="' .. fg_grey .. '"> ♥ -- </span>')
        return
    end
    local dots = {}
    for _, h in ipairs(health_data) do table.insert(dots, state_dot(h.state)) end
    label:set_markup('<span font="Meslo LGS Regular 10"> ♥ ' .. table.concat(dots, " ") .. ' </span>')
end
refresh_label()

local docker_health_widget = wibox.container.background(
    wibox.container.margin(label, 2, 2),
    bg_widget,
    gears.shape.octogon
)

docker.subscribe(function(data)
    health_data = {}
    if not data.available then
        label:set_markup(string.format('<span font="Meslo LGS Regular 10" color="%s"> ♥ off </span>', fg_grey))
        return
    end
    for _, c in ipairs(data.containers) do
        if c.running then
            local state = "none"
            if c.healthy   then state = "healthy"
            elseif c.unhealthy then state = "unhealthy"
            elseif c.starting  then state = "starting"
            end
            table.insert(health_data, { name = c.name, status = c.status, state = state })
        end
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
        { markup = string.format('<span font="Meslo LGS Regular 10" color="%s"><b> ♥ Container Health </b></span>', fg_green),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6, widget = wibox.container.margin,
    })
    rows:add(wibox.widget { color = fg_grey, forced_height = 1, widget = wibox.widget.separator })

    if #health_data == 0 then
        rows:add(wibox.widget {
            { markup = string.format('<span font="Meslo LGS Regular 10" color="%s"> No running containers </span>', fg_grey),
              widget = wibox.widget.textbox },
            top = 4, bottom = 4, left = 6, right = 6, widget = wibox.container.margin,
        })
    else
        for _, h in ipairs(health_data) do
            local state_color = fg_grey
            local state_label = "no healthcheck"
            if h.state == "healthy"   then state_color = fg_green;  state_label = "healthy"
            elseif h.state == "unhealthy" then state_color = fg_red;    state_label = "unhealthy"
            elseif h.state == "starting"  then state_color = fg_yellow; state_label = "starting"
            end
            local row = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        markup = string.format(
                            '<span font="Meslo LGS Regular 10" color="%s">%s </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%-25s </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                            state_color, state_dot(h.state),
                            fg_color, gears.string.xml_escape(h.name:sub(1,25)),
                            state_color, state_label),
                        widget = wibox.widget.textbox,
                    }, 6, 6, 3, 3),
                bg_row)
            row:connect_signal("mouse::enter", function() row.bg = "#424f45" end)
            row:connect_signal("mouse::leave", function() row.bg = bg_row end)
            rows:add(row)
        end
    end

    rows:add(wibox.widget { color = fg_grey, forced_height = 1, widget = wibox.widget.separator })
    local refresh_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = string.format('<span font="Meslo LGS Regular 10" color="%s"> ↺ Refresh </span>', fg_green),
                widget = wibox.widget.textbox,
            }, 4, 4, 2, 2),
        bg_popup)
    refresh_btn:connect_signal("mouse::enter", function() refresh_btn.bg = "#3a4f40" end)
    refresh_btn:connect_signal("mouse::leave", function() refresh_btn.bg = bg_popup end)
    refresh_btn:connect_signal("button::press", function()
        close_popup()
        docker.refresh()
        gears.timer.start_new(0.5, function() show_popup(); return false end)
    end)
    rows:add(refresh_btn)

    popup = awful.popup {
        widget   = { rows, bg = bg_popup, widget = wibox.container.background },
        placement = function(w)
            awful.placement.top_right(w, { honor_workarea = true, margins = { top = 18, right = 0 } })
        end,
        shape = gears.shape.octogon, border_width = 2, border_color = fg_green,
        ontop = true, visible = true, minimum_width = 300, maximum_width = 500,
    }
    popup:connect_signal("mouse::leave", function() close_popup() end)
end

docker_health_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end)
))

return docker_health_widget
