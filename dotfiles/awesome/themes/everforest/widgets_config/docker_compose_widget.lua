-- Docker Compose Widget
-- Auto-detects compose projects from running container labels
-- Shows "⚙ project N/M" cycling through active projects
-- Left-click: popup with per-project service list + inline Up/Down/Restart/Pull buttons
-- Scroll on wibar widget: cycle through projects
local wibox   = require("wibox")
local awful   = require("awful")
local gears   = require("gears")
local naughty = require("naughty")

local bg_widget = "#425047"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_yellow = "#DBBC7F"
local fg_red    = "#E67E80"
local fg_grey   = "#7A8478"
local fg_blue   = "#7FBBB3"

local CHECK_INTERVAL = 15

local projects      = {}
local project_names = {}
local current_idx   = 1
local popup         = nil
local close_timer   = nil

local label = wibox.widget.textbox()

local function refresh_label()
    if #project_names == 0 then
        label:set_markup(string.format(
            '<span font="Meslo LGS Regular 10" color="%s"> ⚙ no compose </span>', fg_grey
        ))
        return
    end
    local pname = project_names[current_idx]
    local p     = projects[pname]
    local total, running = #p.services, 0
    for _, s in ipairs(p.services) do
        if s.running then running = running + 1 end
    end
    local color = running == total and fg_green or (running == 0 and fg_red or fg_yellow)
    label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> ⚙ %s </span>'
        .. '<span font="Meslo LGS Regular 10" color="%s">%d/%d </span>',
        fg_color, gears.string.xml_escape(pname:sub(1, 14)),
        color, running, total
    ))
end
refresh_label()

local docker_compose_widget = wibox.container.background(
    wibox.container.margin(label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

local function check_compose()
    awful.spawn.easy_async_with_shell(
        "docker ps -a --format '{{.Label \"com.docker.compose.project\"}}|{{.Label \"com.docker.compose.service\"}}|{{.Names}}|{{.Status}}' 2>/dev/null",
        function(stdout, _, _, code)
            projects      = {}
            project_names = {}
            if code ~= 0 then
                label:set_markup(string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> ⚙ off </span>', fg_grey
                ))
                return
            end
            for line in stdout:gmatch("[^\n]+") do
                local proj, svc, cname, status = line:match("^([^|]*)|([^|]*)|([^|]+)|(.+)$")
                if proj and proj ~= "" then
                    if not projects[proj] then
                        projects[proj] = { name = proj, services = {} }
                        table.insert(project_names, proj)
                    end
                    table.insert(projects[proj].services, {
                        name    = svc ~= "" and svc or cname,
                        cname   = cname,
                        status  = status,
                        running = status:lower():match("^up") ~= nil,
                    })
                end
            end
            if current_idx > #project_names then current_idx = 1 end
            refresh_label()
        end
    )
end

check_compose()
gears.timer { timeout = CHECK_INTERVAL, autostart = true, callback = check_compose }

local function cancel_close()
    if close_timer then close_timer:stop(); close_timer = nil end
end

local function close_popup()
    cancel_close()
    if popup then popup.visible = false; popup = nil end
end

local function schedule_close()
    cancel_close()
    close_timer = gears.timer.start_new(0.4, function()
        close_timer = nil
        close_popup()
        return false
    end)
end

local function run_compose_cmd(project_name, action)
    local svc = projects[project_name] and projects[project_name].services[1]
    if not svc then return end
    awful.spawn.easy_async_with_shell(
        "docker inspect --format '{{index .Config.Labels \"com.docker.compose.project.working_dir\"}}' "
        .. svc.cname .. " 2>/dev/null",
        function(dir)
            dir = dir:gsub("%s+$", "")
            local cmd = (dir and dir ~= "")
                and ("cd " .. dir .. " && docker compose " .. action .. " 2>&1")
                or  ("docker compose -p " .. project_name .. " " .. action .. " 2>&1")
            naughty.notify({ title = "Docker Compose", text = project_name .. ": " .. action .. "…" })
            awful.spawn.easy_async_with_shell(cmd, function(out, _, _, ec)
                if ec == 0 then
                    naughty.notify({ title = "Docker Compose", text = project_name .. ": done." })
                else
                    naughty.notify({
                        title   = "Docker Compose",
                        text    = project_name .. " " .. action .. " failed:\n" .. out:sub(1, 200),
                        timeout = 10,
                    })
                end
                check_compose()
            end)
        end
    )
end

-- Build a small inline action button
local function action_btn(lbl, color, bg, project_name, action)
    local btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s">%s</span>', color, lbl),
                widget = wibox.widget.textbox,
            },
            5, 5, 1, 1
        ),
        bg,
        gears.shape.rounded_rect
    )
    btn:connect_signal("mouse::enter", function() btn.bg = "#4a5e53" end)
    btn:connect_signal("mouse::leave", function() btn.bg = bg end)
    btn:connect_signal("button::press", function()
        close_popup()
        run_compose_cmd(project_name, action)
    end)
    return btn
end

local function show_popup()
    close_popup()
    local rows = wibox.layout.fixed.vertical()

    rows:add(wibox.widget {
        { markup = string.format(
              '<span font="Meslo LGS Regular 10" color="%s"><b> ⚙ Docker Compose </b></span>',
              fg_green),
          widget = wibox.widget.textbox },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1, widget = wibox.widget.separator,
    })

    if #project_names == 0 then
        rows:add(wibox.widget {
            { markup = string.format(
                  '<span font="Meslo LGS Regular 10" color="%s"> No compose projects found </span>', fg_grey),
              widget = wibox.widget.textbox },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        for _, pname in ipairs(project_names) do
            local p = projects[pname]
            local total, running = #p.services, 0
            for _, s in ipairs(p.services) do
                if s.running then running = running + 1 end
            end
            local count_color = running == total and fg_green
                or (running == 0 and fg_red or fg_yellow)

            -- Inline action buttons on the project header row
            local btn_up      = action_btn(" ▶ ", fg_green,  "#2e4033", pname, "up -d")
            local btn_down    = action_btn(" ■ ", fg_red,    "#4a2e2e", pname, "down")
            local btn_restart = action_btn(" ↺ ", fg_yellow, "#3d3d2a", pname, "restart")
            local btn_pull    = action_btn(" ⬇ ", fg_blue,   "#2a3a3d", pname, "pull")

            local proj_row = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        wibox.widget {
                            markup = string.format(
                                '<span font="Meslo LGS Regular 10" color="%s"><b> %s </b></span>'
                                .. '<span font="Meslo LGS Regular 10" color="%s">%d/%d</span>',
                                fg_blue,      gears.string.xml_escape(pname),
                                count_color,  running, total
                            ),
                            widget = wibox.widget.textbox,
                        },
                        { layout = wibox.layout.flex.horizontal },
                        wibox.widget {
                            btn_up,
                            wibox.container.margin(btn_down,    3, 0, 0, 0),
                            wibox.container.margin(btn_restart, 3, 0, 0, 0),
                            wibox.container.margin(btn_pull,    3, 0, 0, 0),
                            layout = wibox.layout.fixed.horizontal,
                        },
                        layout = wibox.layout.align.horizontal,
                    },
                    6, 6, 4, 4
                ),
                "#2e3f34"
            )
            rows:add(proj_row)

            -- Service rows
            for _, s in ipairs(p.services) do
                local sc  = s.running and fg_green or fg_grey
                local dot = s.running and "●" or "○"
                local srow = wibox.container.background(
                    wibox.container.margin(
                        wibox.widget {
                            markup = string.format(
                                '<span font="Meslo LGS Regular 10" color="%s">  %s </span>'
                                .. '<span font="Meslo LGS Regular 10" color="%s">%-22s </span>'
                                .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                                sc,       dot,
                                fg_color, gears.string.xml_escape(s.name:sub(1, 22)),
                                fg_grey,  gears.string.xml_escape(s.status:sub(1, 28))
                            ),
                            widget = wibox.widget.textbox,
                        },
                        8, 6, 2, 2
                    ),
                    bg_row
                )
                srow:connect_signal("mouse::enter", function() srow.bg = "#424f45" end)
                srow:connect_signal("mouse::leave", function() srow.bg = bg_row end)
                rows:add(srow)
            end

            rows:add(wibox.widget {
                color = "#374247", forced_height = 1,
                widget = wibox.widget.separator,
            })
        end
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
        minimum_width = 380,
        maximum_width = 580,
    }
    popup:connect_signal("mouse::enter", function() cancel_close() end)
    popup:connect_signal("mouse::leave", function() schedule_close() end)
end

docker_compose_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 4, function()
        if #project_names > 0 then
            current_idx = (current_idx % #project_names) + 1
            refresh_label()
        end
    end),
    awful.button({}, 5, function()
        if #project_names > 0 then
            current_idx = ((current_idx - 2) % #project_names) + 1
            refresh_label()
        end
    end)
))

return docker_compose_widget
