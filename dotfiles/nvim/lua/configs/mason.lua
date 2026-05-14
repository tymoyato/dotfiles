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
    -- svelte
    "svelte-language-server",
    -- bash
    "bash-language-server",
    "shfmt",
    -- json/yaml/docker
    "json-lsp",
    "yaml-language-server",
    "dockerfile-language-server",
    -- sql
    "sqls",
  },
}

return mason
