-- Package update widget
-- Left-click:  show available updates popup
-- Right-click: confirm and run paru -Syu
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

-- Everforest colors
local bg_widget = "#425047"
local bg_popup  = "#2D353B"
local bg_row    = "#374247"
local fg_color  = "#D3C6AA"
local fg_green  = "#A7C080"
local fg_yellow = "#DBBC7F"
local fg_grey   = "#7A8478"

local CHECK_INTERVAL = 300  -- seconds between checks

local updates = {}  -- list of { name, current, latest }
local popup   = nil

-- Widget label
local pkg_label = wibox.widget.textbox()
local function refresh_label()
    local count = #updates
    pkg_label:set_markup(
        string.format('<span font="Meslo LGS Regular 10" color="%s"> 📦 %d </span>', fg_color, count)
    )
end
refresh_label()

local pkg_widget = wibox.container.background(
    wibox.container.margin(pkg_label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

local close_detail   -- forward declaration
local close_timer = nil

local function cancel_close()
    if close_timer then
        close_timer:stop()
        close_timer = nil
    end
end

local function schedule_close()
    cancel_close()
    close_timer = gears.timer.start_new(0.3, function()
        close_timer = nil
        if close_detail then close_detail() end
        if popup then
            popup.visible = false
            popup = nil
        end
        return false
    end)
end

-- Immediate close (used when explicitly dismissing)
local function close_popup()
    cancel_close()
    if close_detail then close_detail() end
    if popup then
        popup.visible = false
        popup = nil
    end
end

-- Async check for updates using paru -Qu
local function check_updates()
    awful.spawn.easy_async_with_shell("paru -Qu 2>/dev/null", function(stdout)
        updates = {}
        for line in stdout:gmatch("[^\n]+") do
            -- paru -Qu format: "pkgname current_ver -> new_ver"
            local name, cur, new = line:match("^(%S+)%s+(%S+)%s+%->%s+(%S+)")
            if name then
                table.insert(updates, { name = name, current = cur, latest = new })
            end
        end
        refresh_label()
    end)
end

-- Initial check + timer
check_updates()
gears.timer {
    timeout   = CHECK_INTERVAL,
    autostart = true,
    callback  = check_updates,
}

local VISIBLE_ROWS = 15
local scroll_offset = 0
local list_layout   = nil  -- reused to update rows in-place
local detail_popup  = nil

close_detail = function()
    cancel_close()
    if detail_popup then
        detail_popup.visible = false
        detail_popup = nil
    end
end

-- Fields from paru -Si we care about
local DETAIL_FIELDS = {
    "Description", "URL", "Version", "Licenses",
    "Maintainer", "Last Modified", "Out-of-date",
}

local function show_detail(pkg)
    close_detail()
    awful.spawn.easy_async_with_shell(
        "paru -Si " .. pkg.name .. " 2>/dev/null",
        function(stdout)
            local rows = wibox.layout.fixed.vertical()

            -- Title
            rows:add(wibox.widget {
                {
                    markup = string.format(
                        '<span font="Meslo LGS Regular 10" color="%s"><b> %s </b></span>'
                        .. '<span font="Meslo LGS Regular 10" color="%s">%s → %s</span>',
                        fg_green, gears.string.xml_escape(pkg.name),
                        fg_grey,  gears.string.xml_escape(pkg.current),
                                  gears.string.xml_escape(pkg.latest)
                    ),
                    widget = wibox.widget.textbox,
                },
                top = 4, bottom = 4, left = 6, right = 6,
                widget = wibox.container.margin,
            })
            rows:add(wibox.widget {
                color = fg_grey, forced_height = 1,
                widget = wibox.widget.separator,
            })

            -- Parse and show selected fields
            local found_any = false
            for _, field in ipairs(DETAIL_FIELDS) do
                local val = stdout:match(field .. "%s*:%s*([^\n]+)")
                if val and val ~= "None" and val ~= "" then
                    found_any = true
                    local trimmed = val:match("^%s*(.-)%s*$")
                    local is_url  = field == "URL"
                    local row = wibox.container.background(
                        wibox.container.margin(
                            wibox.widget {
                                markup = string.format(
                                    '<span font="Meslo LGS Regular 10" color="%s">%-14s </span>'
                                    .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                                    fg_grey,
                                    gears.string.xml_escape(field),
                                    is_url and "#7FBBB3" or fg_color,
                                    gears.string.xml_escape(trimmed)
                                ),
                                wrap   = "word_char",
                                widget = wibox.widget.textbox,
                            },
                            6, 6, 2, 2
                        ),
                        "#232A2E"
                    )
                    if is_url then
                        local url = trimmed
                        row:connect_signal("mouse::enter", function() row.bg = "#2e3e43" end)
                        row:connect_signal("mouse::leave", function() row.bg = "#232A2E" end)
                        row:connect_signal("button::press", function(_, _, _, btn)
                            if btn == 1 then
                                awful.spawn("xdg-open " .. url)
                                close_detail()
                            end
                        end)
                    end
                    rows:add(row)
                end
            end

            if not found_any then
                rows:add(wibox.widget {
                    {
                        markup = string.format(
                            '<span font="Meslo LGS Regular 10" color="%s"> No details available </span>',
                            fg_grey
                        ),
                        widget = wibox.widget.textbox,
                    },
                    top = 4, bottom = 4, left = 6, right = 6,
                    widget = wibox.container.margin,
                })
            end

            detail_popup = awful.popup {
                widget = {
                    rows,
                    bg     = "#232A2E",
                    widget = wibox.container.background,
                },
                placement = function(w)
                    awful.placement.top_right(w, {
                        honor_workarea = true,
                        margins        = { top = 18, right = 410 },
                    })
                end,
                shape        = gears.shape.rounded_rect,
                border_width = 2,
                border_color = fg_green,
                ontop        = true,
                visible      = true,
                minimum_width = 260,
                maximum_width = 420,
            }
            detail_popup:connect_signal("mouse::enter", function() cancel_close() end)
            detail_popup:connect_signal("mouse::leave", function() schedule_close() end)
        end
    )
end

local function make_pkg_row(pkg)
    local row_bg = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s">%-30s </span>'
                    .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>'
                    .. '<span font="Meslo LGS Regular 10" color="%s"> → </span>'
                    .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                    fg_color,  gears.string.xml_escape(pkg.name),
                    fg_grey,   gears.string.xml_escape(pkg.current),
                    fg_grey,
                    fg_yellow, gears.string.xml_escape(pkg.latest)
                ),
                wrap   = "word_char",
                widget = wibox.widget.textbox,
            },
            6, 6, 3, 3
        ),
        bg_row
    )
    row_bg:connect_signal("mouse::enter", function() row_bg.bg = "#4a5e53" end)
    row_bg:connect_signal("mouse::leave", function() row_bg.bg = bg_row end)
    row_bg:connect_signal("button::press", function(_, _, _, btn)
        if btn == 1 then show_detail(pkg) end
    end)
    return row_bg
end

local function fill_list()
    list_layout:reset()
    local total = #updates
    local last  = math.min(scroll_offset + VISIBLE_ROWS, total)
    for i = scroll_offset + 1, last do
        list_layout:add(make_pkg_row(updates[i]))
    end
    -- Scroll hint
    if total > VISIBLE_ROWS then
        list_layout:add(wibox.widget {
            {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> ↕ %d–%d of %d </span>',
                    fg_grey, scroll_offset + 1, last, total
                ),
                widget = wibox.widget.textbox,
            },
            top = 2, bottom = 2, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    end
end

-- Build and show the updates popup
local function show_popup()
    close_popup()
    scroll_offset = 0
    list_layout   = wibox.layout.fixed.vertical()

    local header = wibox.layout.fixed.vertical()

    -- Title row
    header:add(wibox.widget {
        {
            markup = string.format(
                '<span font="Meslo LGS Regular 10" color="%s"><b> Available updates (%d) </b></span>',
                fg_green, #updates
            ),
            widget = wibox.widget.textbox,
        },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    })
    header:add(wibox.widget {
        color         = fg_grey,
        forced_height = 1,
        widget        = wibox.widget.separator,
    })

    if #updates == 0 then
        list_layout:add(wibox.widget {
            {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> System is up to date </span>',
                    fg_grey
                ),
                widget = wibox.widget.textbox,
            },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        fill_list()
    end

    local root_layout = wibox.layout.fixed.vertical()
    root_layout:add(header)
    root_layout:add(list_layout)

    popup = awful.popup {
        widget = {
            root_layout,
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
        minimum_width = 300,
        maximum_width = 500,
    }

    popup:connect_signal("mouse::enter", function() cancel_close() end)
    popup:connect_signal("mouse::leave", function() schedule_close() end)
    popup:buttons(gears.table.join(
        -- scroll down
        awful.button({}, 5, function()
            if scroll_offset + VISIBLE_ROWS < #updates then
                scroll_offset = scroll_offset + 3
                fill_list()
            end
        end),
        -- scroll up
        awful.button({}, 4, function()
            if scroll_offset > 0 then
                scroll_offset = math.max(0, scroll_offset - 3)
                fill_list()
            end
        end)
    ))
end

-- Button bindings
pkg_widget:buttons(gears.table.join(
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
            close_popup()
            naughty.notify({ title = "Packages", text = "Update started…" })
            awful.spawn.easy_async_with_shell("paru -Syu --noconfirm 2>&1", function(stdout, _, _, code)
                if code == 0 then
                    naughty.notify({ title = "Packages", text = "System updated successfully." })
                else
                    naughty.notify({
                        title   = "Packages",
                        text    = "Update failed:\n" .. stdout:sub(1, 200),
                        timeout = 10,
                    })
                end
                check_updates()
            end)
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
                                '<span font="Meslo LGS Regular 10" color="%s">Run paru -Syu (%d updates)?</span>',
                                fg_color, #updates
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
            placement = function(w)
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

return pkg_widget
