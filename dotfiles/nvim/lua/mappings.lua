require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
vim.api.nvim_del_keymap('n', '<leader>cm')
map("n", "<leader>gm", "<cmd>Telescope git_commits<CR>", { desc = "telescope git commits" })

-- vim.api.nvim_del_keymap('th', '<leader>cm')
-- vim.api.nvim_del_keymap('pt', '<leader>cm')
map("n", "<leader>tH", "<cmd>Telescope terms<CR>", { desc = "telescope pick hidden term" })
map("n", "<leader>zt", "<cmd>Telescope themes<CR>", { desc = "telescope nvchad themes" })
map("n", "<leader>zc", "<cmd>NvCheatsheet<CR>", { desc = "toggle nvcheatsheet" })
vim.api.nvim_del_keymap("n", '<leader>pt')
vim.api.nvim_del_keymap("n", '<leader>ch')

map("n", "<leader>r", "<cmd>set rnu!<CR>", { desc = "toggle relative number" })
vim.api.nvim_del_keymap("n", '<leader>rn')

vim.api.nvim_del_keymap("n", '<leader>ma')
map("n", "<leader>aa", "<cmd>Telescope marks<CR>", { desc = "telescope find marks" })


-- whichkey
vim.api.nvim_del_keymap("n", '<leader>wK')
map("n", "<leader>K", "<cmd>WhichKey <CR>", { desc = "whichkey all keymaps" })

vim.api.nvim_del_keymap("n", '<leader>wk')
map("n", "<leader>k", function()
  vim.cmd("WhichKey " .. vim.fn.input "WhichKey: ")
end, { desc = "whichkey query lookup" })


-- new terminals
vim.api.nvim_del_keymap("n", '<leader>h')
map("n", "<leader>th", function()
  require("nvchad.term").new { pos = "sp" }
end, { desc = "terminal new horizontal term" })

vim.api.nvim_del_keymap("n", '<leader>v')
map("n", "<leader>tv", function()
  require("nvchad.term").new { pos = "vsp" }
end, { desc = "terminal new vertical window" })

