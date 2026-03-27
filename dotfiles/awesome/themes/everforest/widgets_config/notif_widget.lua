-- Notification history widget
-- Left-click: show history popup
-- Right-click: clear all notifications
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

-- Everforest colors
local bg_widget  = "#425047"
local bg_popup   = "#2D353B"
local bg_latest  = "#374247"
local fg_color   = "#D3C6AA"
local fg_green   = "#A7C080"
local fg_grey    = "#7A8478"

local MAX_HISTORY = 20
local history = {}
local popup = nil

-- Widget label: only shows count
local notif_label = wibox.widget.textbox()
local function refresh_label()
    local count = #history
    notif_label:set_markup(
        string.format('<span font="Meslo LGS Regular 10" color="%s"> 🔔 %d </span>', fg_color, count)
    )
end
refresh_label()

local notif_widget = wibox.container.background(
    wibox.container.margin(notif_label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

-- Close the history popup
local function close_popup()
    if popup then
        popup.visible = false
        popup = nil
    end
end

-- Intercept naughty.notify to capture notifications (legacy naughty API)
local _orig_notify = naughty.notify
naughty.notify = function(args)
    local title   = (args and args.title) or ""
    local message = (args and (args.text or args.message)) or ""
    if (title ~= "" or message ~= "") and not title:find("🍅", 1, true) and not title:find("☕", 1, true) then
        table.insert(history, {
            title   = title,
            message = message,
            time    = os.date("%H:%M"),
        })
        if #history > MAX_HISTORY then table.remove(history, 1) end
        refresh_label()
    end
    return _orig_notify(args)
end

-- Build and show the history popup
local function show_popup()
    close_popup()

    local rows = wibox.layout.fixed.vertical()

    -- Title row
    rows:add(wibox.widget {
        {
            markup = string.format(
                '<span font="Meslo LGS Regular 10" color="%s"><b> Notification history </b></span>',
                fg_green
            ),
            widget = wibox.widget.textbox,
        },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })

    -- Separator
    rows:add(wibox.widget {
        color         = fg_grey,
        forced_height = 1,
        widget        = wibox.widget.separator,
    })

    if #history == 0 then
        rows:add(wibox.widget {
            {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> No notifications </span>',
                    fg_grey
                ),
                widget = wibox.widget.textbox,
            },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        for i = #history, 1, -1 do
            local n      = history[i]
            local msg    = (n.title ~= "" and (n.title .. ": ") or "") .. n.message
            local row_bg = (i == #history) and bg_latest or bg_popup

            rows:add(wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        markup = string.format(
                            '<span font="Meslo LGS Regular 10" color="%s">%s  </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                            fg_grey,  gears.string.xml_escape(n.time),
                            fg_color, gears.string.xml_escape(msg)
                        ),
                        wrap   = "word_char",
                        widget = wibox.widget.textbox,
                    },
                    6, 6, 4, 4
                ),
                row_bg
            ))
        end
    end

    popup = awful.popup {
        widget = {
            rows,
            bg     = bg_popup,
            widget = wibox.container.background,
        },
        placement    = function(w)
            awful.placement.top_right(w, {
                honor_workarea = true,
                margins        = { top = 18, right = 0 },
            })
        end,
        shape        = gears.shape.rounded_rect,
        border_width = 2,
        border_color = fg_green,
        ontop        = true,
        visible      = true,
        minimum_width = 200,
        maximum_width = 400,
    }

    popup:connect_signal("button::press", function() close_popup() end)
    popup:connect_signal("mouse::leave",  function() close_popup() end)
end

-- Button bindings
notif_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 3, function()
        local confirm_popup

        local yes_btn = wibox.container.background(
            wibox.container.margin(
                wibox.widget {
                    markup = string.format('<span font="Meslo LGS Regular 10" color="%s">Yes</span>', fg_green),
                    widget = wibox.widget.textbox,
                },
                8, 8, 3, 3
            ),
            "#374247",
            gears.shape.rounded_rect
        )

        local no_btn = wibox.container.background(
            wibox.container.margin(
                wibox.widget {
                    markup = string.format('<span font="Meslo LGS Regular 10" color="%s">No</span>', "#E67E80"),
                    widget = wibox.widget.textbox,
                },
                8, 8, 3, 3
            ),
            "#374247",
            gears.shape.rounded_rect
        )

        yes_btn:connect_signal("button::press", function()
            confirm_popup.visible = false
            history = {}
            close_popup()
            refresh_label()
        end)
        yes_btn:connect_signal("mouse::enter", function() yes_btn.bg = "#4a5e53" end)
        yes_btn:connect_signal("mouse::leave", function() yes_btn.bg = "#374247" end)

        no_btn:connect_signal("button::press", function()
            confirm_popup.visible = false
        end)
        no_btn:connect_signal("mouse::enter", function() no_btn.bg = "#4a5e53" end)
        no_btn:connect_signal("mouse::leave", function() no_btn.bg = "#374247" end)

        confirm_popup = awful.popup {
            widget = wibox.container.margin(
                wibox.widget {
                    wibox.container.margin(
                        wibox.widget {
                            markup = string.format(
                                '<span font="Meslo LGS Regular 10" color="%s">Clear all notifications?</span>',
                                fg_color
                            ),
                            widget = wibox.widget.textbox,
                        },
                        0, 0, 0, 6
                    ),
                    wibox.container.place(
                        wibox.widget {
                            yes_btn,
                            wibox.container.margin(no_btn, 8, 0, 0, 0),
                            layout = wibox.layout.fixed.horizontal,
                        }
                    ),
                    layout = wibox.layout.fixed.vertical,
                },
                10, 10, 8, 8
            ),
            placement    = function(w)
                awful.placement.top_right(w, {
                    honor_workarea = true,
                    margins        = { top = 18, right = 0 },
                })
            end,
            shape        = gears.shape.rounded_rect,
            border_width = 2,
            border_color = fg_green,
            bg           = bg_popup,
            ontop        = true,
            visible      = true,
        }

        confirm_popup:connect_signal("mouse::leave", function()
            confirm_popup.visible = false
        end)
    end)
))

return notif_widget
