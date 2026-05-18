return {
  --# neoscroll.nvim
  {
    "karb94/neoscroll.nvim",
    event = "BufReadPost",
    opts = {
      duration_multiplier = 0.6,
      easing = "sine",
    },
  },
  --# nvim-tree.lua
  {
    "nvim-tree/nvim-tree.lua",
    opts = {
      filters = {
        dotfiles = false,
        git_ignored = false,
      },
    },
  },
  --# telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
    opts = {
      extensions = {
        fzf = {
          fuzzy = true,
          override_generic_sorter = true,
          override_file_sorter = true,
          case_mode = "smart_case",
        },
      },
      pickers = {
        find_files = {
          hidden = true,
          find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
        },
      },
    },
    config = function(_, opts)
      local telescope = require "telescope"
      telescope.setup(opts)
      telescope.load_extension "fzf"
    end,
  },
  --# telescope-fzf-native
  {
    "nvim-telescope/telescope-fzf-native.nvim",
    build = "make",
    lazy = true,
  },
  --
  --@Autocompletion and Code Intelligence
  --
  --# nvim-cmp
  {
    "hrsh7th/nvim-cmp",
    opts = function()
      return require("configs.cmp").sources
    end,
  },
  --
  --
  --# conform.nvim
  {
    "stevearc/conform.nvim",
    lazy = true,
    opts = function()
      return require "configs.conform"
    end,
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
    opts = function()
      return require("configs.mason").ensure_installed
    end,
  },
  --
  --@Treesitter and Syntax Highlighting
  --
  --# nvim-treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function()
      return require("configs.treesitter").ensure_installed
    end,
  },
  --
  --# nvim-treesitter-endwise
  { "RRethy/nvim-treesitter-endwise", ft = "ruby" },

  --# tree-sitter-embedded-template
  { "tree-sitter/tree-sitter-embedded-template", ft = "embedded_template" },

  --# nvim-treesitter-textobjects (loaded as treesitter dependency)
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "BufReadPost",
  },
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
  { "tpope/vim-rails", ft = { "ruby", "eruby" } },

  --# rainbow-delimiters.nvim
  { "HiPhish/rainbow-delimiters.nvim", ft = "ruby" },
  --
  --@Git and Version Control
  --
  --# vim-fugitive
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gread", "Gwrite", "Gdiffsplit", "GMove", "GDelete", "GBrowse", "Gblame" },
  },

  --# diffview
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles", "DiffviewFileHistory" },
  },

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
  {
    "mg979/vim-visual-multi",
    keys = { "<C-n>", "<C-Up>", "<C-Down>", "<S-Left>", "<S-Right>" },
  },

  --# vim-surround
  { "tpope/vim-surround", event = "BufReadPost" },

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
    event = "LspAttach",
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
    dependencies = {
      "nvim-neotest/nvim-nio",
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      "suketa/nvim-dap-ruby",
      "theHamsta/nvim-dap-virtual-text",
    },
    keys = {
      { "<Leader>dt", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<Leader>dc", function() require("dap").continue() end, desc = "Continue debugging session" },
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
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-go",
      "olimorris/neotest-rspec",
      "haydenmeade/neotest-jest",
    },
    keys = {
      { "<leader>nt", function() require("neotest").run.run() end, desc = "Run nearest test" },
      { "<leader>nf", function() require("neotest").run.run(vim.fn.expand "%") end, desc = "Run file tests" },
      { "<leader>ns", function() require("neotest").summary.toggle() end, desc = "Test summary" },
      { "<leader>no", function() require("neotest").output.open() end, desc = "Test output" },
      { "<leader>nS", function() require("neotest").run.stop() end, desc = "Stop test" },
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
    keys = {
      { "<leader>ha", function() require("harpoon"):list():add() end, desc = "Harpoon add file" },
      { "<leader>hh", function() require("harpoon").ui:toggle_quick_menu(require("harpoon"):list()) end, desc = "Harpoon menu" },
      { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "Harpoon file 1" },
      { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "Harpoon file 2" },
      { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "Harpoon file 3" },
      { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "Harpoon file 4" },
    },
  },
  {
    "rachartier/tiny-glimmer.nvim",
    event = "VeryLazy",
    opts = {},
  },
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },
  {
    "sphamba/smear-cursor.nvim",
    event = "VeryLazy",
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
    event = "BufReadPost",
    config = function()
      require("Comment").setup()
    end,
  },
  --# nvim-ts-autotag
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "javascriptreact", "typescriptreact", "vue", "xml", "eruby", "svelte" },
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
  --# obsidian.nvim
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    ---@module 'obsidian'
    ---@type obsidian.config
    opts = {
      legacy_commands = false,
      workspaces = {
        {
          name = "personal",
          path = "/home/tymoyato/Obsidian-Vault",
        },
      },
      notes_subdir = "notes",
      daily_notes = {
        folder = "daily",
        date_format = "%Y-%m-%d",
        default_tags = { "daily" },
      },
      templates = {
        folder = "templates",
        substitutions = {
          date = function() return os.date "%Y-%m-%d" end,
        },
      },
      picker = { name = "telescope.nvim" },
      note_id_func = function(title) return title end,
      note_frontmatter_func = function(note)
        local out = { id = note.id, tags = note.tags, aliases = note.aliases }
        if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
          for k, v in pairs(note.metadata) do out[k] = v end
        end
        return out
      end,
      ui = { enable = false },
      follow_url_func = function(url)
        vim.fn.jobstart({ "xdg-open", url })
      end,
      completion = {
        nvim_cmp = true,
        min_chars = 2,
      },
      attachments = {
        img_folder = "assets/images",
      },
    },
    keys = {
      { "<leader>on", "<cmd>ObsidianNew<cr>",       desc = "New note" },
      { "<leader>os", "<cmd>ObsidianSearch<cr>",    desc = "Search notes" },
      { "<leader>od", "<cmd>ObsidianToday<cr>",     desc = "Daily note" },
      { "<leader>ot", "<cmd>ObsidianTags<cr>",      desc = "Browse tags" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<cr>", desc = "Backlinks" },
      { "<leader>ol", "<cmd>ObsidianLinks<cr>",     desc = "Links in note" },
      { "<leader>oT", "<cmd>ObsidianTemplate<cr>",  desc = "Insert template" },
      { "<leader>op", "<cmd>ObsidianPasteImg<cr>",  desc = "Paste image" },
      { "<leader>or", "<cmd>ObsidianRename<cr>",    desc = "Rename note" },
    },
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

      local timer = vim.uv.new_timer()
      vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost" }, {
        callback = function()
          timer:stop()
          timer:start(500, 0, vim.schedule_wrap(function()
            require("lint").try_lint()
          end))
        end,
      })
    end,
  },
}
