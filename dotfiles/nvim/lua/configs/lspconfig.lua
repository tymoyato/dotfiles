-- Using vim.lsp.config (Neovim 0.11+)
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

local servers = { "html", "cssls", "clangd", "sqls", "ts_ls", "eslint", "solargraph", "tailwindcss", "gopls" }

-- lsps with default config
for _, lsp in ipairs(servers) do
  vim.lsp.config[lsp] = {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
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

-- solargraph
vim.lsp.config.solargraph = {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
  filetypes = { "ruby", "eruby", "gemfile", "rakefile" },
  settings = {
    solargraph = {
      diagnostics = true,
      completion = true,
      autoformat = true,
      formatting = true,
      folding = true,
      references = true,
      rename = true,
      symbols = true,
    },
  },
}

-- Enable the servers
vim.lsp.enable(servers)
