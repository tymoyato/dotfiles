-- Widget manager: left-click shows list of registered widgets.
-- Click a row in the list to toggle that widget's visibility.
local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")

-- Everforest colors (match volume/pkg popup style)
local bg_popup = "#000000"
local bg_row   = "#000000"
local bg_hover = "#374247"
local fg_color = "#D3C6AA"
local fg_green = "#A7C080"
local fg_grey  = "#7A8478"

local M = {}

local registry = {}  -- list of { name = string, widget = wibox widget instance }

local HIDDEN_FILE = os.getenv("HOME") .. "/.cache/awesome/widget_manager_hidden"

local function load_hidden()
    local hidden = {}
    local f = io.open(HIDDEN_FILE, "r")
    if f then
        for line in f:lines() do
            if line ~= "" then hidden[line] = true end
        end
        f:close()
    end
    return hidden
end

-- Names hidden on a previous run; applied to widgets as they register.
local hidden_names = load_hidden()

local function save_hidden()
    local f = io.open(HIDDEN_FILE, "w")
    if not f then return end
    for _, entry in ipairs(registry) do
        if entry.widget.visible == false then
            f:write(entry.name, "\n")
        end
    end
    f:close()
end

local VISIBLE_ROWS = 12

local popup        = nil
local list_layout  = nil
local close_timer  = nil
local scroll_offset = 0

local function cancel_close()
    if close_timer then
        close_timer:stop()
        close_timer = nil
    end
end

local function close_popup()
    cancel_close()
    if popup then
        popup.visible = false
        popup = nil
    end
end

local function schedule_close()
    cancel_close()
    close_timer = gears.timer.start_new(0.4, function()
        close_timer = nil
        close_popup()
        return false
    end)
end

local fill_list  -- forward declaration, make_row calls back into it

local function make_row(entry)
    local active = entry.widget.visible ~= false
    local dot_color = active and fg_green or fg_grey
    local text_color = active and fg_color or fg_grey

    local row = wibox.container.background(
        wibox.container.margin(
            wibox.widget {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s">%s </span>'
                    .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                    dot_color, active and "●" or "○",
                    text_color, gears.string.xml_escape(entry.name)
                ),
                widget = wibox.widget.textbox,
            },
            6, 6, 2, 2
        ),
        bg_row
    )
    row:connect_signal("mouse::enter", function() row.bg = bg_hover end)
    row:connect_signal("mouse::leave", function() row.bg = bg_row end)
    row:connect_signal("button::press", function(_, _, _, btn)
        if btn == 1 then
            entry.widget.visible = not active
            save_hidden()
            fill_list()
        end
    end)
    return row
end

fill_list = function()
    list_layout:reset()
    local total = #registry
    local last  = math.min(scroll_offset + VISIBLE_ROWS, total)
    for i = scroll_offset + 1, last do
        list_layout:add(make_row(registry[i]))
    end
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

local function show_popup(anchor_geometry)
    close_popup()
    scroll_offset = 0
    list_layout = wibox.layout.fixed.vertical()

    local header = wibox.widget {
        {
            markup = string.format('<span font="Meslo LGS Regular 10" color="%s"><b> Widgets </b></span>', fg_green),
            widget = wibox.widget.textbox,
        },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    }
    local sep = wibox.widget {
        color         = fg_grey,
        forced_height = 1,
        widget        = wibox.widget.separator,
    }

    fill_list()

    local root = wibox.layout.fixed.vertical()
    root:add(header)
    root:add(sep)
    root:add(list_layout)

    popup = awful.popup {
        widget = {
            root,
            bg     = bg_popup,
            widget = wibox.container.background,
        },
        placement = function(w)
            -- awful.placement.next_to's "geometry" mode collapses to (0,0)
            -- on this awesome build regardless of input, so position by hand:
            -- centered under the widget, clamped to stay on-screen.
            local g = anchor_geometry
            if not g then return end
            local scr = (screen.primary or awful.screen.focused()).geometry
            local x = g.x + g.width / 2 - w.width / 2
            x = math.max(scr.x, math.min(x, scr.x + scr.width - w.width))
            w.x = math.floor(x)
            w.y = g.y + g.height + 6
        end,
        shape          = gears.shape.octogon,
        border_width   = 0,
        ontop          = true,
        visible        = true,
        minimum_width  = 160,
        maximum_width  = 220,
    }
    popup:connect_signal("mouse::enter", cancel_close)
    popup:connect_signal("mouse::leave", schedule_close)
    popup:buttons(gears.table.join(
        awful.button({}, 4, function()
            if scroll_offset > 0 then
                scroll_offset = math.max(0, scroll_offset - 3)
                fill_list()
            end
        end),
        awful.button({}, 5, function()
            if scroll_offset + VISIBLE_ROWS < #registry then
                scroll_offset = scroll_offset + 3
                fill_list()
            end
        end)
    ))
end

-- Register a widget instance under a display name. Call before the widget
-- manager's own widget is built into the wibar.
function M.register(name, widget)
    table.insert(registry, { name = name, widget = widget })
    if hidden_names[name] then
        widget.visible = false
    end
end

local label = wibox.widget.textbox()
label:set_markup(string.format('<span font="Meslo LGS Regular 10" color="%s"> 🧩 </span>', fg_color))

local manager_widget = wibox.container.background(
    wibox.container.margin(label, 2, 2),
    "#000000",
    gears.shape.octogon
)

manager_widget:buttons(awful.util.table.join(
    awful.button({}, 1, function()
        if popup then
            close_popup()
        else
            -- Snapshot now: mouse.current_widget_geometry is live and would
            -- track whatever's under the cursor once inside the popup,
            -- making it open in the wrong spot instead of under this widget.
            show_popup(mouse.current_widget_geometry)
        end
    end)
))

M.widget = manager_widget

return M
