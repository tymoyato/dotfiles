-- This file  needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/NvChad/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "everforest",
	transparancy = true,
	theme_toggle = { "monekai", "everforest" },
  integration = { "neogit", "lazygit", "diffview" },
}

return M
