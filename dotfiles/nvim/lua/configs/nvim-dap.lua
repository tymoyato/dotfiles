local dap = require "dap"
local dapui = require "dapui"

require("dapui").setup()
require("dap-go").setup()
require("dap-ruby").setup()
require("nvim-dap-virtual-text").setup()

dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

vim.keymap.set("n", "<Leader>dt", function()
  dap.toggle_breakpoint()
end, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<Leader>dc", function()
  dap.continue()
end, { desc = "Continue debugging session" })

-- dap.adapters.ruby = function(callback, config)
--   callback {
--     type = "server",
--     host = "127.0.0.1",
--     port = 3000,
--     executable = {
--       command = "bundle",
--       args = {
--         "exec",
--         "rdbg",
--         "-n",
--         "--open",
--         "--port",
--         "${port}",
--         "-c",
--         "--",
--         "bundle",
--         "exec",
--         config.command,
--         config.script,
--       },
--     },
--   }
-- end

dap.configurations.ruby = {
  {
    type = "ruby",
    name = "run rails",
    bundle = "bundle",
    request = "attach",
    command = "rails",
    script = "s",
    port = 3009,
    server = "127.0.0.1",
    options = {
      source_filetype = "ruby",
    },
    localfs = true,
    waiting = 1000,
  },
  {
    type = "ruby",
    name = "debug current file",
    bundle = "",
    request = "attach",
    command = "ruby",
    script = "${file}",
    port = 38698,
    server = "127.0.0.1",
    options = {
      source_filetype = "ruby",
    },
    localfs = true,
    waiting = 1000,
  },
  {
    type = "ruby",
    name = "run rspec current_file",
    bundle = "bundle",
    request = "attach",
    command = "rspec",
    script = "${file}",
    port = 38698,
    server = "127.0.0.1",
    options = {
      source_filetype = "ruby",
    },
    localfs = true,
    waiting = 1000,
  },
  {
    type = "ruby",
    name = "run rspec current_file:current_line",
    bundle = "bundle",
    request = "attach",
    command = "rspec",
    script = "${file}",
    port = 38698,
    server = "127.0.0.1",
    options = {
      source_filetype = "ruby",
    },
    localfs = true,
    waiting = 1000,
    current_line = true,
  },
  {
    type = "ruby",
    name = "run rspec",
    bundle = "bundle",
    request = "attach",
    command = "rspec",
    script = "./spec",
    port = 38698,
    server = "127.0.0.1",
    options = {
      source_filetype = "ruby",
    },
    localfs = true,
    waiting = 1000,
  },
}
