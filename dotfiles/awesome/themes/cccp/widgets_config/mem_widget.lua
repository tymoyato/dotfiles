-- MEM
local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local gears = require("gears")

theme.widget_mem = theme.dir .. "/icons/widgets/mem.png"
local mem_icon = wibox.widget.imagebox(theme.widget_mem)
local mem = lain.widget.mem({
	settings = function()
		widget:set_markup(
			markup.font(
				theme.font,
				markup.fg.color(theme.fg_widget, " " .. mem_now.used .. "MB [" .. mem_now.perc .. "%]")
			)
		)
	end,
})
local mem_widget = wibox.container.background(
	wibox.container.margin(wibox.widget({ mem_icon, mem.widget, layout = wibox.layout.align.horizontal }), 2, 4),
	"#DC143C",
	gears.shape.rounded_rect
)

return mem_widget
