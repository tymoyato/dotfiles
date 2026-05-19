-- Todo widget
-- Left-click:        show/hide todo list
-- Right-click:       add new todo (prompt)
-- Click todo item:   toggle done
-- Right-click item:  delete
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")

-- Everforest colors
local bg_widget  = "#425047"
local bg_popup   = "#2D353B"
local bg_row     = "#374247"
local bg_done    = "#2D353B"
local fg_color   = "#D3C6AA"
local fg_green   = "#A7C080"
local fg_grey    = "#7A8478"
local fg_red     = "#E67E80"
local fg_yellow  = "#DBBC7F"

local TODO_FILE = os.getenv("HOME") .. "/.config/awesome/todos.txt"
local todos     = {}   -- list of { text, done }
local popup     = nil

-- ── Persistence ────────────────────────────────────────────────────
local function save_todos()
    local f = io.open(TODO_FILE, "w")
    if not f then return end
    for _, t in ipairs(todos) do
        f:write((t.done and "1" or "0") .. "|" .. t.text .. "\n")
    end
    f:close()
end

local function load_todos()
    todos = {}
    local f = io.open(TODO_FILE, "r")
    if not f then return end
    for line in f:lines() do
        local done, text = line:match("^([01])|(.+)$")
        if text then
            table.insert(todos, { text = text, done = done == "1" })
        end
    end
    f:close()
end

load_todos()

-- ── Label ──────────────────────────────────────────────────────────
local todo_label = wibox.widget.textbox()

local function pending_count()
    local n = 0
    for _, t in ipairs(todos) do
        if not t.done then n = n + 1 end
    end
    return n
end

local function refresh_label()
    local count = pending_count()
    todo_label:set_markup(string.format(
        '<span font="Meslo LGS Regular 10" color="%s"> ✅ %d </span>',
        fg_color, count
    ))
end
refresh_label()

local todo_widget = wibox.container.background(
    wibox.container.margin(todo_label, 2, 2),
    bg_widget,
    gears.shape.rounded_rect
)

-- ── Popup ──────────────────────────────────────────────────────────
local function close_popup()
    if popup then
        popup.visible = false
        popup = nil
    end
end

local function show_popup()
    close_popup()

    local rows = wibox.layout.fixed.vertical()

    -- Header
    local header_row = wibox.widget {
        {
            markup = string.format(
                '<span font="Meslo LGS Regular 10" color="%s"><b> ✅ Todo (%d pending) </b></span>',
                fg_green, pending_count()
            ),
            widget = wibox.widget.textbox,
        },
        top = 4, bottom = 4, left = 6, right = 6,
        widget = wibox.container.margin,
    }
    rows:add(header_row)
    rows:add(wibox.widget {
        color = fg_grey, forced_height = 1,
        widget = wibox.widget.separator,
    })

    if #todos == 0 then
        rows:add(wibox.widget {
            {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> No todos </span>',
                    fg_grey
                ),
                widget = wibox.widget.textbox,
            },
            top = 4, bottom = 4, left = 6, right = 6,
            widget = wibox.container.margin,
        })
    else
        for i, t in ipairs(todos) do
            local checkbox = t.done and "☑" or "☐"
            local text_color = t.done and fg_grey or fg_color
            local row_color  = t.done and bg_done or bg_row
            local text = t.done
                and string.format('<span strikethrough="true">%s</span>', gears.string.xml_escape(t.text))
                or  gears.string.xml_escape(t.text)

            local row = wibox.container.background(
                wibox.container.margin(
                    wibox.widget {
                        markup = string.format(
                            '<span font="Meslo LGS Regular 10" color="%s">%s </span>'
                            .. '<span font="Meslo LGS Regular 10" color="%s">%s</span>',
                            fg_green, checkbox,
                            text_color, text
                        ),
                        wrap   = "word_char",
                        widget = wibox.widget.textbox,
                    },
                    6, 6, 3, 3
                ),
                row_color
            )

            local idx = i
            row:connect_signal("mouse::enter", function() row.bg = "#4a5e53" end)
            row:connect_signal("mouse::leave", function()
                row.bg = todos[idx].done and bg_done or bg_row
            end)
            row:connect_signal("button::press", function(_, _, _, btn)
                if btn == 1 then
                    todos[idx].done = not todos[idx].done
                    save_todos()
                    refresh_label()
                    show_popup()
                elseif btn == 3 then
                    table.remove(todos, idx)
                    save_todos()
                    refresh_label()
                    show_popup()
                end
            end)

            rows:add(row)
        end
    end

    -- Separator + clear done button
    local has_done = false
    for _, t in ipairs(todos) do if t.done then has_done = true break end end
    if has_done then
        rows:add(wibox.widget {
            color = fg_grey, forced_height = 1,
            widget = wibox.widget.separator,
        })
        local clear_btn = wibox.container.background(
            wibox.container.margin(
                wibox.widget {
                    markup = string.format(
                        '<span font="Meslo LGS Regular 10" color="%s"> 🗑 Clear done </span>',
                        fg_red
                    ),
                    widget = wibox.widget.textbox,
                },
                4, 4, 2, 2
            ),
            bg_popup
        )
        clear_btn:connect_signal("mouse::enter", function() clear_btn.bg = "#4a3030" end)
        clear_btn:connect_signal("mouse::leave", function() clear_btn.bg = bg_popup end)
        clear_btn:connect_signal("button::press", function(_, _, _, btn)
            if btn == 1 then
                local kept = {}
                for _, t in ipairs(todos) do
                    if not t.done then table.insert(kept, t) end
                end
                todos = kept
                save_todos()
                refresh_label()
                show_popup()
            end
        end)
        rows:add(clear_btn)
    end

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
        minimum_width = 240,
        maximum_width = 420,
    }

    popup:connect_signal("mouse::leave", function() close_popup() end)
end

-- ── Prompt popup for adding todos ──────────────────────────────────
local prompt_popup = awful.popup {
    widget  = wibox.widget.textbox(),  -- placeholder, replaced in setup
    visible = false,
    ontop   = true,
    bg      = bg_popup,
    border_color = fg_green,
    border_width = 2,
    shape   = gears.shape.rounded_rect,
    minimum_width = 320,
    placement = function(w)
        awful.placement.top_right(w, {
            honor_workarea = true,
            margins        = { top = 18, right = 0 },
        })
    end,
}
local prompt_wibox = prompt_popup

local prompt_widget = awful.widget.prompt()
prompt_popup:setup({
    wibox.container.margin(
        wibox.widget {
            {
                markup = string.format(
                    '<span font="Meslo LGS Regular 10" color="%s"> New todo: </span>',
                    fg_yellow
                ),
                widget = wibox.widget.textbox,
            },
            prompt_widget,
            layout = wibox.layout.fixed.horizontal,
        },
        4, 4, 2, 2
    ),
    layout = wibox.layout.fixed.horizontal,
})

local function add_todo()
    close_popup()
    prompt_wibox.visible = true
    awful.prompt.run({
        prompt       = "",
        textbox      = prompt_widget.widget,
        exe_callback = function(text)
            text = text:match("^%s*(.-)%s*$")
            if text ~= "" then
                table.insert(todos, { text = text, done = false })
                save_todos()
                refresh_label()
            end
            prompt_wibox.visible = false
        end,
        done_callback = function()
            prompt_wibox.visible = false
        end,
    })
end

-- ── Buttons ────────────────────────────────────────────────────────
todo_widget:buttons(gears.table.join(
    awful.button({}, 1, function()
        if popup then close_popup() else show_popup() end
    end),
    awful.button({}, 3, add_todo)
))

return todo_widget
