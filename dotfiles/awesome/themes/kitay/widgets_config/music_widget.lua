local gears = require("gears")
local music_widget = require("utils.music_widget")

return music_widget.new({
	bg    = "#425047",
	shape = gears.shape.rounded_rect,
})
