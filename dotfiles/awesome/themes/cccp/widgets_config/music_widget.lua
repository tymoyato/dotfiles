local gears = require("gears")
local music_widget = require("utils.music_widget")

return music_widget.new({
	bg            = "#DC143C",
	shape         = gears.shape.rounded_rect,
	accent        = "#FFD700",
	fg            = "#FFD700",
	idle_fg       = "#FFD700",
	icon_suffix   = "",
	poll_interval = 4,
})
