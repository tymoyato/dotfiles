local conform = {}

conform = {
  formatters_by_ft = {
    lua = { "stylua" },
    eruby = { "erb_format" },
    sql = { "sql_formatter" },
    javascript = { "prettierd", "prettier", stop_after_first = true },
    css = { "prettier" },
    html = { "prettier" },
    yaml = { "yamlfmt" },
  },

  -- format_on_save = {
  --   -- These options will be passed to conform.format()
  --   timeout_ms = 500,
  --   lsp_fallback = true,
  -- },
}

return conform
