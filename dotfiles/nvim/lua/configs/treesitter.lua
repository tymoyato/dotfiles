local treesitter = {}

treesitter.ensure_installed = {
  ensure_installed = {
    "yaml",
    "vim",
    "lua",
    "vimdoc",
    "html",
    "css",
    "embedded_template",
    "ruby",
    "sql",
    "javascript",
    "typescript",
    "tsx",
    "c",
    "markdown",
    "markdown_inline",
  },
  indent = {
    enable = true,
  },
  endwise = {
    enable = true,
  },
  embedded_template = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
}

return treesitter
