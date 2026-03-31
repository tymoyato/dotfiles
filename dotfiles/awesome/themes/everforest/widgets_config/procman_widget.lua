-- Process Manager Widget
-- Left-click: show/hide floating window with running apps
-- Each app row has a Kill button with confirmation dialog
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")

-- Everforest colors
local bg_widget  = "#425047"
local bg_popup   = "#2D353B"
local bg_row     = "#374247"
local bg_header  = "#3D484D"
local fg_color   = "#D3C6AA"
local fg_green   = "#A7C080"
local fg_grey    = "#7A8478"
local fg_red     = "#E67E80"
local fg_yellow  = "#DBBC7F"

local popup   = nil
local confirm = nil  -- confirmation sub-popup

-- ── Label ──────────────────────────────────────────────────────────
local procman_label = wibox.widget.textbox()
procman_label:set_markup(
    '<span font="Meslo LGS Regular 10" color="' .. fg_color .. '"> ⚡ </span>'
)

local procman_widget = wibox.container.background(
    wibox.container.margin(procman_label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

-- ── Popup helpers ──────────────────────────────────────────────────
local function close_confirm()
    if confirm then
        confirm.visible = false
        confirm = nil
    end
end

local function close_popup()
    close_confirm()
    if popup then
        popup.visible = false
        popup = nil
    end
end

-- ── Confirmation dialog ────────────────────────────────────────────
local function show_confirm(pid, name, anchor_widget)
    close_confirm()

    local yes_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = '<span font="Meslo LGS Regular 10" color="' .. fg_red .. '"> Kill </span>',
                widget = wibox.widget.textbox,
            },
            8, 8, 3, 3
        ),
        "#4a3030",
        gears.shape.rounded_rect
    )
    yes_btn:connect_signal("mouse::enter", function() yes_btn.bg = "#6b3030" end)
    yes_btn:connect_signal("mouse::leave", function() yes_btn.bg = "#4a3030" end)
    yes_btn:connect_signal("button::press", function()
        awful.spawn("kill -9 " .. pid)
        close_confirm()
        -- Reopen popup after short delay to reflect the killed process
        gears.timer.start_new(0.4, function()
            if popup then
                close_popup()
                -- re-open handled by show_popup below
            end
            return false
        end)
        gears.timer.start_new(0.5, function()
            show_popup()
            return false
        end)
    end)

    local no_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = '<span font="Meslo LGS Regular 10" color="' .. fg_color .. '"> Cancel </span>',
                widget = wibox.widget.textbox,
            },
            8, 8, 3, 3
        ),
        bg_row,
        gears.shape.rounded_rect
    )
    no_btn:connect_signal("mouse::enter", function() no_btn.bg = "#4a5e53" end)
    no_btn:connect_signal("mouse::leave", function() no_btn.bg = bg_row end)
    no_btn:connect_signal("button::press", function() close_confirm() end)

    confirm = awful.popup {
        widget = wibox.container.margin(
            wibox.widget {
                {
                    markup = '<span font="Meslo LGS Regular 10" color="' .. fg_yellow .. '">Kill <b>'
                        .. gears.string.xml_escape(name) .. '</b>?</span>',
                    widget = wibox.widget.textbox,
                },
                {
                    yes_btn,
                    wibox.container.margin(wibox.widget.textbox(), 4, 4),
                    no_btn,
                    layout = wibox.layout.fixed.horizontal,
                },
                spacing = 6,
                layout  = wibox.layout.fixed.vertical,
            },
            10, 10, 8, 8
        ),
        placement = function(w)
            awful.placement.top_right(w, {
                honor_workarea = true,
                margins        = { top = 18, right = 0 },
            })
        end,
        shape        = gears.shape.rounded_rect,
        border_width = 2,
        border_color = fg_red,
        ontop        = true,
        visible      = true,
        bg           = bg_popup,
    }
end

-- ── Main popup ─────────────────────────────────────────────────────
function show_popup()
    close_popup()

    -- Fetch running graphical processes: name + pid, sorted by name
    -- We list windows tracked by the window manager (clients)
    local clients = client.get()

    local rows = wibox.layout.fixed.vertical()

    -- Header
    rows:add(wibox.widget {
        {
            markup = '<span font="Meslo LGS Regular 10" color="' .. fg_green .. '"><b> ⚙ Running Apps </b></span>',
            widget = wibox.widget.textbox,
        },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1,
        widget = wibox.widget.separator,
    })

    if #clients == 0 then
        rows:add(wibox.widget {
            {
                markup = '<span font="Meslo LGS Regular 10" color="' .. fg_grey .. '"> No windows </span>',
                widget = wibox.widget.textbox,
            },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        -- Deduplicate by pid so we don't show multiple windows for same app
        local seen_pids = {}
        local unique_clients = {}
        for _, c in ipairs(clients) do
            local pid = c.pid
            if pid and not seen_pids[pid] then
                seen_pids[pid] = true
                table.insert(unique_clients, c)
            elseif not pid then
                -- No pid info, still show the window
                table.insert(unique_clients, c)
            end
        end

        for _, c in ipairs(unique_clients) do
            local name = c.class or c.name or "Unknown"
            -- Truncate long names
            if #name > 40 then name = name:sub(1, 37) .. "..." end
            local pid  = c.pid

            -- App name label
            local name_label = wibox.widget {
                markup = '<span font="Meslo LGS Regular 10" color="' .. fg_color .. '"> '
                    .. gears.string.xml_escape(name) .. ' </span>',
                wrap   = "char",
                widget = wibox.widget.textbox,
            }

            -- Kill button
            local kill_btn = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        markup = '<span font="Meslo LGS Regular 10" color="' .. fg_red .. '"> ✕ </span>',
                        widget = wibox.widget.textbox,
                    },
                    4, 4, 1, 1
                ),
                "#4a3030",
                gears.shape.rounded_rect
            )
            kill_btn:connect_signal("mouse::enter", function() kill_btn.bg = "#6b3030" end)
            kill_btn:connect_signal("mouse::leave", function() kill_btn.bg = "#4a3030" end)

            local captured_pid  = pid
            local captured_name = name
            kill_btn:connect_signal("button::press", function()
                show_confirm(captured_pid, captured_name, kill_btn)
            end)

            local row = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        name_label,
                        { layout = wibox.layout.flex.horizontal },  -- spacer
                        kill_btn,
                        layout = wibox.layout.align.horizontal,
                    },
                    4, 4, 2, 2
                ),
                bg_row
            )
            row:connect_signal("mouse::enter", function() row.bg = "#4a5e53" end)
            row:connect_signal("mouse::leave", function() row.bg = bg_row end)

            rows:add(row)
        end
    end

    -- Refresh button at the bottom
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1,
        widget = wibox.widget.separator,
    })
    local refresh_btn = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = '<span font="Meslo LGS Regular 10" color="' .. fg_green .. '"> ↺ Refresh </span>',
                widget = wibox.widget.textbox,
            },
            4, 4, 2, 2
        ),
        bg_popup
    )
    refresh_btn:connect_signal("mouse::enter", function() refresh_btn.bg = "#3a4f40" end)
    refresh_btn:connect_signal("mouse::leave", function() refresh_btn.bg = bg_popup end)
    refresh_btn:connect_signal("button::press", function() show_popup() end)
    rows:add(refresh_btn)

    popup = awful.popup {
        widget = {
            rows,
            bg     = bg_popup,
            widget = wibox.container.background,
        },
        placement = function(w)
            awful.placement.top_right(w, {
                honor_workarea = true,
                margins        = { top = 18, right = 0 },
            })
        end,
        shape         = gears.shape.rounded_rect,
        border_width  = 2,
        border_color  = fg_green,
        ontop         = true,
        visible       = true,
        minimum_width = 280,
        maximum_width = 460,
    }

    popup:connect_signal("mouse::leave", function()
        -- Only close if confirm is also not open
        if not confirm then
            close_popup()
        end
    end)
end

-- ── Buttons ────────────────────────────────────────────────────────
procman_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end)
))

return procman_widget
