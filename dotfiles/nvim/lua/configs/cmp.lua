local cmp = {}

cmp.sources = {
  sources = {
    { name = "codeium",  group_index = 1 },
    { name = "nvim_lsp", group_index = 1 },
    { name = "luasnip",  group_index = 1 },
    { name = "nvim_lua", group_index = 2 },
    { name = "path",     group_index = 2 },
    {
      name = "buffer",
      group_index = 2,
      keyword_length = 3,
      option = {
        keyword_length = 3,
        max_indexed_line_length = 1024,
      },
    },
    -- dadbod last: only relevant in sql buffers, gets per-buffer override there
    { name = "vim-dadbod-completion", group_index = 3 },
  },
}

return cmp
