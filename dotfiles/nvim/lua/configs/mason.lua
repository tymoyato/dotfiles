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
    "deno",
    "solargraph",
    "sql-formatter",
    -- c/cpp stuff
    "clangd",
    "clang-format",
  },
}

return mason
