-- CPU
local wibox = require("wibox")
local lain = require("lain")
local markup = lain.util.markup
local gears = require("gears")

local cpu = lain.widget.cpu({
	timeout = 5,
	settings = function()
		widget:set_markup(markup.font(theme.font, markup.fg.color("#D3C6AA", " 🔲 " .. cpu_now.usage .. "% ")))
	end,
})
local cpu_widget = wibox.container.background(
	wibox.container.margin(cpu.widget, 2, 2),
	"#425047",
	gears.shape.rounded_rect
)

return cpu_widget
