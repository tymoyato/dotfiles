--[[

     Licensed under GNU General Public License v2
      * (c) 2013, Luca CPZ

--]]

local helpers = require("lain.helpers")
local wibox = require("wibox")
local open = io.open
local tonumber = tonumber

-- coretemp
-- lain.widget.temp

local function factory(args)
	local temp = { widget = wibox.widget.textbox() }
	local args = args or {}
	local timeout = args.timeout or 2
	local tempfiles = args.tempfiles or {
		"/sys/class/hwmon/hwmon9/temp1_input",
	}
	local settings = args.settings or function() end
	CORETEMP_NOW = nil

	function temp.update()
		for _, tempfile in ipairs(tempfiles) do
			local f = open(tempfile)
			if f then
				CORETEMP_NOW = tonumber(f:read("*all")) / 1000
				f:close()
				if CORETEMP_NOW then
					break
				else
					print("Error: Unable to read temperature data from " .. tempfile)
				end
			else
				print("Error: Unable to open temperature file at " .. tempfile)
			end
		end
		if CORETEMP_NOW == nil then
			CORETEMP_NOW = "N/A"
		end

		WIDGET = temp.widget
		settings()
	end

	helpers.newtimer("coretemp", timeout, temp.update)

	return temp
end

return factory
