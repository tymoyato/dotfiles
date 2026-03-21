local mason = {}

mason.ensure_installed = {
  ensure_installed = {
    "tailwindcss-language-server",
    "lua-language-server",
    "stylua",
    "html-lsp",
    "css-lsp",
    "prettier",
    "prettierd",
    "erb-formatter",
    "typescript-language-server",
    "eslint-lsp",
    "eslint_d",
    "deno",
    "solargraph",
    "rubocop",
    "sql-formatter",
    -- c/cpp stuff
    "clangd",
    "clang-format",
    -- go stuff
    "gopls",
    "goimports",
    "gofumpt",
    "golangci-lint",
  },
}

return mason
