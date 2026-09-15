local gears = require("gears")
local music_widget = require("utils.music_widget")

return music_widget.new({
	bg    = "#000000",
	shape = gears.shape.octogon,
})
