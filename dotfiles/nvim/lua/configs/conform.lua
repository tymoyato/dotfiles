local conform = {}

conform = {
  formatters_by_ft = {
    lua = { "stylua" },
    ruby = { "rubocop" },
    eruby = { "erb_format" },
    sql = { "sql_formatter" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact = { "prettierd", "prettier", stop_after_first = true },
    typescript = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "yamlfmt" },
    go = { "goimports", "gofumpt" },
    svelte = { "prettierd", "prettier", stop_after_first = true },
    sh = { "shfmt" },
    bash = { "shfmt" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return conform
