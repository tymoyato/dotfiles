local gears = require("gears")
local lain = require("lain")
local awful = require("awful")
local wibox = require("wibox")
local os, math, string = os, math, string

theme = {}
theme.dir = os.getenv("HOME") .. "/.config/awesome/themes/everforest"
theme.wallpaper = "#A7C080" -- Solid color background
theme.font = "Meslo LGS Regular 10"
theme.taglist_font = "Meslo LGS Bold 10"
theme.tasklist_font = "Terminus 10"

-- Everforest color scheme (Dark Medium Contrast)
theme.bg_normal = "#2D353B"     -- bg0
theme.fg_normal = "#D3C6AA"     -- fg
theme.bg_focus = "#425047"      -- bg_green
theme.fg_focus = "#A7C080"      -- green
theme.bg_urgent = "#514045"     -- bg_red
theme.fg_urgent = "#E67E80"     -- red

theme.fg_widget = "#A7C080"     -- green

-- Taglist colors with Everforest theme
theme.taglist_bg_focus = "#425047"      -- bg_green
theme.taglist_fg_focus = "#D3C6AA"      -- fg
theme.taglist_bg_occupied = "#3D484D"   -- bg2
theme.taglist_fg_occupied = "#A7C080"   -- green
theme.taglist_bg_empty = "#475258"      -- bg3
theme.taglist_fg_empty = "#859289"      -- grey1
theme.taglist_bg_urgent = "#514045"     -- bg_red
theme.taglist_fg_urgent = "#E67E80"     -- red
theme.taglist_shape = gears.shape.rounded_rect

-- Tasklist colors
theme.tasklist_bg_normal = "#2D353B"    -- bg0
theme.tasklist_fg_normal = "#D3C6AA"    -- fg
theme.tasklist_bg_focus = "#425047"     -- bg_green
theme.tasklist_fg_focus = "#D3C6AA"     -- fg
theme.tasklist_bg_urgent = "#514045"    -- bg_red
theme.tasklist_fg_urgent = "#E67E80"    -- red

theme.border_width = 0
theme.border_normal = "#3D484D"         -- bg2
theme.border_focus = "#A7C080"          -- green
theme.border_marked = "#E69875"         -- orange

theme.titlebar_bg_normal = "#3D484D"    -- bg2
theme.titlebar_fg_normal = "#D3C6AA"    -- fg

theme.titlebar_bg_focus = "#425047"     -- bg_green
theme.titlebar_fg_focus = "#D3C6AA"     -- fg

theme.menu_height = 16
theme.menu_width = 140

theme.notification_font = "Meslo LGS Regular 12"
theme.notification_bg = theme.bg_normal
theme.notification_fg = theme.fg_normal
theme.notification_border_width = 0
theme.notification_border_color = theme.bg_normal
theme.notification_shape = gears.shape.rounded_rect
theme.notification_opacity = 1
theme.notification_margin = 30

theme.menu_submenu_icon = theme.dir .. "/icons/submenu.png"

-- Layout icons
theme.layout_tile = theme.dir .. "/icons/layouts/tile.png"
theme.layout_tileleft = theme.dir .. "/icons/layouts/tileleft.png"
theme.layout_tilebottom = theme.dir .. "/icons/layouts/tilebottom.png"
theme.layout_tiletop = theme.dir .. "/icons/layouts/tiletop.png"
theme.layout_fairv = theme.dir .. "/icons/layouts/fairv.png"
theme.layout_fairh = theme.dir .. "/icons/layouts/fairh.png"
theme.layout_spiral = theme.dir .. "/icons/layouts/spiral.png"
theme.layout_centerwork = theme.dir .. "/icons/layouts/centerwork.png"
theme.layout_dwindle = theme.dir .. "/icons/layouts/dwindle.png"
theme.layout_max = theme.dir .. "/icons/layouts/max.png"
theme.layout_fullscreen = theme.dir .. "/icons/layouts/fullscreen.png"
theme.layout_magnifier = theme.dir .. "/icons/layouts/magnifier.png"
theme.layout_floating = theme.dir .. "/icons/layouts/floating.png"

-- Widget icons
theme.widget_music = theme.dir .. "/icons/widgets/note.png"
theme.widget_music_on = theme.dir .. "/icons/widgets/note_on.png"
theme.widget_music_pause = theme.dir .. "/icons/widgets/pause.png"
theme.widget_music_stop = theme.dir .. "/icons/widgets/stop.png"

theme.tasklist_plain_task_name = true
theme.tasklist_disable_icon = true
theme.useless_gap = 6

theme.titlebar_close_button_focus = theme.dir .. "/icons/titlebar/close_focus.png"
theme.titlebar_ontop_button_focus_active = theme.dir .. "/icons/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_focus_inactive = theme.dir .. "/icons/titlebar/ontop_focus_inactive.png"
theme.titlebar_sticky_button_focus_active = theme.dir .. "/icons/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_focus_inactive = theme.dir .. "/icons/titlebar/sticky_focus_inactive.png"
theme.titlebar_floating_button_focus_active = theme.dir .. "/icons/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_focus_inactive = theme.dir .. "/icons/titlebar/floating_focus_inactive.png"
theme.titlebar_maximized_button_focus_active = theme.dir .. "/icons/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_focus_inactive = theme.dir .. "/icons/titlebar/maximized_focus_inactive.png"

-- Everforest colors
theme.green = "#A7C080"         -- green
theme.red = "#E67E80"           -- red
theme.yellow = "#DBBC7F"        -- yellow
theme.blue = "#7FBBB3"          -- blue
theme.orange = "#E69875"        -- orange
theme.purple = "#D699B6"        -- purple
theme.aqua = "#83C092"          -- aqua
theme.grey0 = "#7A8478"         -- grey0
theme.grey1 = "#859289"         -- grey1
theme.grey2 = "#9DA9A0"         -- grey2
theme.bg_dim = "#232A2E"        -- bg_dim
theme.bg_visual = "#543A48"     -- bg_visual
theme.black = theme.bg_normal

-- Panel
local markup = lain.util.markup

-- Widgets --
local clock_widget = require("themes.everforest.widgets_config.clock_widget")
local battery_widget = require("themes.everforest.widgets_config.battery_widget")
local mem_widget = require("themes.everforest.widgets_config.mem_widget")
local cpu_widget = require("themes.everforest.widgets_config.cpu_widget")
local temp_widget = require("themes.everforest.widgets_config.temp_widget")
local disk_widget = require("themes.everforest.widgets_config.disk_widget")
local volume_widget = require("themes.everforest.widgets_config.volume_widget")
local kbd_widget = require("widgets.kbd_widget.kbd_widget")
local brightness_widget = require("themes.everforest.widgets_config.brightness_widget")
local music_widget = require("themes.everforest.widgets_config.music_widget")
local crypto_widget = require("themes.everforest.widgets_config.crypto_widget")
local notif_widget  = require("themes.everforest.widgets_config.notif_widget")
local pkg_widget      = require("themes.everforest.widgets_config.pkg_widget")
local pomodoro_widget = require("themes.everforest.widgets_config.pomodoro_widget")
local todo_widget     = require("themes.everforest.widgets_config.todo_widget")
local rss_widget      = require("themes.everforest.widgets_config.rss_widget")

function theme.connect(s)
    -- Quake application
    s.quake = lain.util.quake({ app = awful.util.terminal })

    -- Set solid color wallpaper
    gears.wallpaper.set(theme.wallpaper)

    -- Tags
    layout = {
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[1],
        awful.layout.layouts[3],
        awful.layout.layouts[3],
        awful.layout.layouts[5],
    }
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, layout)

    -- Promptbox
    s.mypromptbox = awful.widget.prompt()

    -- Layoutbox
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end),
        awful.button({}, 4, function() awful.layout.inc(1) end),
        awful.button({}, 5, function() awful.layout.inc(-1) end)
    ))

    -- Taglist
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, awful.util.taglist_buttons)

    -- Wibar
    s.mywibox = awful.wibar({ position = "top", screen = s, height = 16, bg = "#00000000", fg = theme.fg_focus })
    local net_speed_widget = require("widgets.net_speed_widget.net_speed")

    -- Setup
    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        { -- Left
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
            s.mypromptbox,
        },
        { -- Middle (empty for now)
            layout = wibox.layout.fixed.horizontal,
        },
        { -- Right
            layout = wibox.layout.fixed.horizontal,
            music_widget,
            wibox.widget.textbox(" "),
            wibox.container.background(
                wibox.container.margin(net_speed_widget(), 2, 2),
                "#425047",
                gears.shape.rounded_rect
            ),
            wibox.widget.textbox(" "),
            brightness_widget,
            wibox.widget.textbox(" "),
            volume_widget,
            wibox.widget.textbox(" "),
            disk_widget,
            wibox.widget.textbox(" "),
            temp_widget,
            wibox.widget.textbox(" "),
            cpu_widget,
            wibox.widget.textbox(" "),
            mem_widget,
            wibox.widget.textbox(" "),
            battery_widget,
            wibox.widget.textbox(" "),
            crypto_widget,
            wibox.widget.textbox(" "),
            todo_widget,
            wibox.widget.textbox(" "),
            pomodoro_widget,
            wibox.widget.textbox(" "),
            pkg_widget,
            wibox.widget.textbox(" "),
            rss_widget,
            wibox.widget.textbox(" "),
            notif_widget,
            wibox.widget.textbox(" "),
            clock_widget,
            wibox.widget.textbox(" "),
            kbd_widget,
            wibox.widget.textbox(" "),
            s.mylayoutbox,
        },
    })
end

return theme

