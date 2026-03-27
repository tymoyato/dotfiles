-- Disk usage widget
-- Shows used/total for root partition
local wibox  = require("wibox")
local awful  = require("awful")
local gears  = require("gears")
local markup = require("lain.util.markup")

local fg_color  = "#D3C6AA"
local fg_red    = "#E67E80"
local fg_yellow = "#DBBC7F"
local fg_green  = "#A7C080"

local disk_label = wibox.widget.textbox()

local function update_disk()
    awful.spawn.easy_async_with_shell(
        "df -h / | awk 'NR==2 {print $3\"|\"$2\"|\"$5}'",
        function(stdout)
            stdout = stdout:gsub("\n", "")
            local used, total, pct_str = stdout:match("^(.+)|(.+)|(.+)$")
            local pct = tonumber((pct_str or "0"):match("%d+")) or 0
            disk_label:set_markup(markup.font(theme.font,
                markup.fg.color(fg_color, " 💾 " .. (used or "?") .. "/" .. (total or "?") .. " ")
            ))
        end
    )
end

update_disk()
gears.timer {
    timeout   = 60,
    autostart = true,
    callback  = update_disk,
}

local disk_widget = wibox.container.background(
    wibox.container.margin(disk_label, 2, 2),
    "#425047",
    gears.shape.rounded_rect
)

return disk_widget
