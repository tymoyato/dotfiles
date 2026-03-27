return {
  --
  --@Autocompletion and Code Intelligence
  --
  --# nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    opts = require("configs.cmp").sources,
  },
  --
  --# codeium.nvim
  {
    "Exafunction/codeium.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup {}
    end,
    lazy = false,
  },
  --
  --# conform.nvim
  {
    "stevearc/conform.nvim",
    lazy = true,
    opts = require "configs.conform",
  },
  --
  --@LSP and Language Servers
  --
  --# nvim-lspconfig
  {
    "neovim/nvim-lspconfig",
    lazy = false,
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },
  --
  --# mason.nvim
  {
    "williamboman/mason.nvim",
    opts = require("configs.mason").ensure_installed,
  },
  --
  --@Treesitter and Syntax Highlighting
  --
  --# nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = require("configs.treesitter").ensure_installed,
  },
  --
  --# nvim-treesitter-endwise
  { "RRethy/nvim-treesitter-endwise", ft = "ruby", lazy = false },

  --# tree-sitter-embedded-template
  { "tree-sitter/tree-sitter-embedded-template", ft = "embedded_template", lazy = false },

  --# nvim-treesitter-textobjects
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  --
  --@Markdown and Documentation
  --
  --# render-markdown.nvim
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
    ft = { "markdown" },
    opts = {},
  },
  --# markdown-preview.nvim
  {
    "iamcco/markdown-preview.nvim",
    lazy = true,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
  },
  --
  --@Ruby Development
  --
  --# vim-rails
  { "tpope/vim-rails", ft = "ruby", lazy = false },

  --# vim-ruby
  { "vim-ruby/vim-ruby", ft = "ruby", lazy = false },

  --# rainbow-delimiters.nvim
  { "HiPhish/rainbow-delimiters.nvim", ft = "ruby", lazy = false },
  --
  --@Git and Version Control
  --
  --# vim-fugitive
  { "tpope/vim-fugitive", lazy = false },

  --# diffview
  { "sindrets/diffview.nvim", lazy = true },

  --# lazygit.nvim
  {
    "kdheepak/lazygit.nvim",
    lazy = true,
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    keys = {
      { "<leader>gl", "<cmd>LazyGit<cr>", desc = "LazyGit" },
    },
  },

  --# neogit
  {
    "NeogitOrg/neogit",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
      "nvim-telescope/telescope.nvim",
    },
    config = true,
    keys = {
      { "<leader>gn", "<cmd>Neogit<cr>", desc = "NeoGit" },
    },
  },
  --
  --@Editing and Navigation
  --
  --# vim-visual-multi
  { "mg979/vim-visual-multi", lazy = false },

  --# vim-surround
  { "tpope/vim-surround", lazy = false },

  --# nvim-colorizer.lua
  {
    "NvChad/nvim-colorizer.lua",
    enabled = true,
  },

  --# flash.nvim
  {
    "folke/flash.nvim",
    lazy = true,
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>ss",
        mode = { "n", "x", "o" },
        function()
          require("flash").jump()
        end,
        desc = "Flash",
      },
      {
        "<leader>sS",
        mode = { "n", "x", "o" },
        function()
          require("flash").treesitter()
        end,
        desc = "Flash Treesitter",
      },
      {
        "<leader>sd",
        mode = "o",
        function()
          require("flash").remote()
        end,
        desc = "Remote Flash",
      },
      {
        "<leader>sD",
        mode = { "o", "x" },
        function()
          require("flash").treesitter_search()
        end,
        desc = "Treesitter Search",
      },
      {
        "<leader>s<leader>",
        mode = { "c" },
        function()
          require("flash").toggle()
        end,
        desc = "Toggle Flash Search",
      },
    },
  },

  --# auto-session
  {
    "rmagatti/auto-session",
    lazy = false,
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/" },
    },
  },

  --# goto-preview
  {
    "rmagatti/goto-preview",
    event = "BufEnter",
    config = true,
    keys = {
      {
        "<leader>gpd",
        function()
          require("goto-preview").goto_preview_definition()
        end,
        desc = "goto_preview_definition",
      },
      {
        "<leader>gpt",
        function()
          require("goto-preview").goto_preview_type_definition()
        end,
        desc = "goto_preview_type_definition",
      },
      {
        "<leader>gpi",
        function()
          require("goto-preview").goto_preview_implementation()
        end,
        desc = "goto_preview_implementation",
      },
      {
        "<leader>gpD",
        function()
          require("goto-preview").goto_preview_declaration()
        end,
        desc = "goto_preview_declaration",
      },
      {
        "<leader>gpp",
        function()
          require("goto-preview").close_all_win()
        end,
        desc = "close_all_win",
      },
      {
        "<leader>gpr",
        function()
          require("goto-preview").goto_preview_references()
        end,
        desc = "goto_preview_references",
      },
    },
  },
  --
  --@Debugging
  --
  --# nvim-dap
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      "suketa/nvim-dap-ruby",
      "theHamsta/nvim-dap-virtual-text",
    },
    config = function()
      require "configs.nvim-dap"
    end,
  },
  --
  --@Testing
  --
  --# neotest
  {
    "nvim-neotest/neotest",
    lazy = false,
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
      "olimorris/neotest-rspec",
      "haydenmeade/neotest-jest",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require "neotest-go",
          require "neotest-rspec",
          require "neotest-jest",
        },
      }
    end,
  },
  --
  --@Database
  --
  --# vim-dadbod
  {
    "tpope/vim-dadbod",
    lazy = true,
    ft = "sql",
    dependencies = {
      "kristijanhusak/vim-dadbod-ui",
      "kristijanhusak/vim-dadbod-completion",
    },
  },
  --
  --@Utility and Productivity
  --
  --# Harpoon
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  --# rest.nvim
  -- {
  --   "rest-nvim/rest.nvim",
  -- },
  {
    "rachartier/tiny-glimmer.nvim",
    lazy = false,
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    lazy = false,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "sphamba/smear-cursor.nvim",
    lazy = false,
    opts = {},
  },
  --
  --@Enhanced UI and Diagnostics
  --
  --# trouble.nvim
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {},
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
    },
  },
  --# nvim-ufo
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    event = "BufRead",
    config = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true
      require("ufo").setup()
    end,
  },
  --# glance.nvim
  {
    "dnlhc/glance.nvim",
    event = "LspAttach",
    config = function()
      require("glance").setup()
    end,
    keys = {
      { "gD", "<cmd>Glance definitions<CR>", desc = "Glance definitions" },
      { "gR", "<cmd>Glance references<CR>", desc = "Glance references" },
      { "gY", "<cmd>Glance type_definitions<CR>", desc = "Glance type definitions" },
      { "gM", "<cmd>Glance implementations<CR>", desc = "Glance implementations" },
    },
  },
  --
  --@Search and Replace
  --
  --# nvim-spectre
  {
    "nvim-pack/nvim-spectre",
    dependencies = { "nvim-lua/plenary.nvim" },
    cmd = "Spectre",
    keys = {
      { "<leader>S", "<cmd>lua require('spectre').toggle()<CR>", desc = "Toggle Spectre" },
      { "<leader>sw", "<cmd>lua require('spectre').open_visual({select_word=true})<CR>", desc = "Search current word" },
      { "<leader>sp", "<cmd>lua require('spectre').open_file_search({select_word=true})<CR>", desc = "Search on current file" },
    },
  },
  --
  --@Code Intelligence
  --
  --# Comment.nvim
  {
    "numToStr/Comment.nvim",
    lazy = false,
    config = function()
      require("Comment").setup()
    end,
  },
  --# nvim-ts-autotag
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "javascriptreact", "typescriptreact", "vue", "xml", "eruby" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  --# inc-rename.nvim
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      { "<leader>rn", ":IncRename ", desc = "Incremental rename" },
    },
    config = function()
      require("inc_rename").setup()
    end,
  },
  --# mini.ai
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    config = function()
      require("mini.ai").setup()
    end,
  },
  --# nvim-lint
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require "lint"
      lint.linters_by_ft = {
        ruby = { "rubocop" },
        go = { "golangcilint" },
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        javascriptreact = { "eslint_d" },
        typescriptreact = { "eslint_d" },
      }
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
        callback = function()
          require("lint").try_lint()
        end,
      })
    end,
  },
}
