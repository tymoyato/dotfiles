-- Using vim.lsp.config (Neovim 0.11+)
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- tailwindcss and ts_ls are excluded here — configured explicitly below
local servers = {
  "html", "cssls", "clangd", "sqls", "eslint", "solargraph",
  "gopls", "svelte", "bashls", "jsonls", "dockerls",
}

local defaults = { on_attach = on_attach, on_init = on_init, capabilities = capabilities }

for _, lsp in ipairs(servers) do
  vim.lsp.config[lsp] = defaults
end

-- tailwindcss
vim.lsp.config.tailwindcss = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = {
    "erb",
    "eruby",
    "html",
    "css",
    "sass",
    "scss",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  settings = {
    tailwindCSS = {
      experimental = {
        classRegex = {},
      },
    },
  },
  init_options = {
    userLanguages = {
      eruby = "erb",
      templ = "html",
    },
  },
}

-- typescript
vim.lsp.config.ts_ls = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}

-- solargraph — diagnostics/autoformat off; rubocop via nvim-lint handles those
vim.lsp.config.solargraph = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "ruby", "eruby", "gemfile", "rakefile" },
  settings = {
    solargraph = {
      diagnostics = false,
      completion = true,
      autoformat = false,
      formatting = false,
      folding = true,
      references = true,
      rename = true,
      symbols = true,
    },
  },
}

-- lua_ls (mason installs it but needs explicit config for vim globals)
vim.lsp.config.lua_ls = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    Lua = { diagnostics = { globals = { "vim" } } },
  },
}

-- yamlls
vim.lsp.config.yamlls = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  settings = {
    yaml = {
      schemas = {
        ["https://raw.githubusercontent.com/evilmartians/lefthook/master/schema.json"] = "lefthook.yml",
      },
    },
  },
}

-- Enable all servers (avoid mutating the servers table with list_extend)
local all_servers = vim.list_extend(vim.deepcopy(servers), {
  "lua_ls", "yamlls", "tailwindcss", "ts_ls",
})
vim.lsp.enable(all_servers)
