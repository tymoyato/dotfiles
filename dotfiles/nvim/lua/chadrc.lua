-- This file  needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "cyberdream",
	transparancy = true,
	theme_toggle = { "cyberdream", "cyberdream" },
  integration = { "neogit", "lazygit", "diffview" },
}

M.ui = {
	cmp = {
		style = "default", -- default/flat_light/flat_dark/atom/atom_colored
	},
	statusline = {
		theme = "default",
		separator_style = "default",
		order = nil,
		modules = nil,
	},
	nvdash = {
		load_on_startup = false,
	},
	prompt_cache = {
		enabled = false, -- Disable the caching gem popup
	},
}

return M
