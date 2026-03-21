local null_ls = require "null-ls"

local b = null_ls.builtins

local sources = {
  b.formatting.stylua,
  b.formatting.rubocop,
  b.diagnostics.rubocop
}

null_ls.setup {
  debug = true,
  sources = sources,
}
