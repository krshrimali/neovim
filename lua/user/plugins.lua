local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

-- Using space as leader for now [20251003]
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Install your plugins here
require("lazy").setup {

  -- CoC for LSP functionality (fast and reliable)
  {
    "neoclide/coc.nvim",
    branch = "release",
    lazy = false, -- Never lazy load CoC to ensure LSP always works
    priority = 1000, -- High priority to load first
    config = function() require "user.coc" end,
  },

  -- Keep nvim-lspconfig for plugin compatibility but disable its LSP servers
  {
    "neovim/nvim-lspconfig",
    lazy = true, -- Don't load automatically
    config = function()
      -- Minimal config for plugin compatibility only
      -- No servers are started here since coc.nvim handles LSP
    end,
  },

  -- Mason for managing LSP servers
  -- {
  --     "williamboman/mason.nvim",
  --     cmd = "Mason",
  --     build = ":MasonUpdate",
  --     config = function()
  --         require("mason").setup({
  --             ui = {
  --                 border = "rounded",
  --             },
  --         })
  --     end
  -- },

  -- Fast completion with blink.cmp
  -- {
  --   "saghen/blink.cmp",
  --   lazy = false, -- lazy loading handled internally
  --   dependencies = "rafamadriz/friendly-snippets",
  --   version = "v0.*",
  --   config = function() require "user.blink-cmp" end,
  -- },

  -- Highlight words under cursor - LAZY LOAD
  {
    "RRethy/vim-illuminate",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require "user.illuminate" end,
  },

  -- Treesitter - LAZY LOAD
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require "user.treesitter" end,
  },

  -- For commenting (uses Treesitter to comment properly) - LAZY LOAD
  -- {
  --     "JoosepAlviste/nvim-ts-context-commentstring",
  --     dependencies = "nvim-treesitter/nvim-treesitter",
  --     lazy = false,
  --     event = { "BufReadPost", "BufNewFile" }
  -- },

  -- Git integration - LAZY LOAD
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "ibhagwan/fzf-lua", -- optional
      "sindrets/diffview.nvim", -- optional
    },
    cmd = "Neogit",
    keys = { "<leader>gg" },
    config = true,
  },

  -- Transparency - LAZY LOAD
  {
    "xiyaowong/transparent.nvim",
    event = "VeryLazy",
  },

  -- Goto preview - LAZY LOAD
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    keys = {
      { "<leader>lgg ", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>" },
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>" },
      { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>" },
    },
    config = true,
  },

  -- Spider movement - LAZY LOAD
  {
    "chrisgrieser/nvim-spider",
    keys = {
      { "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" } },
      { "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" } },
      { "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" } },
    },
  },

  -- Telescope and extensions - LAZY LOAD
  {
    "ibhagwan/fzf-lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = "FzfLua",
    keys = {
      { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
      { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fg", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>FzfLua buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help Tags" },
    },
    config = function()
      -- Use minimal config for testing slow file opening
      -- require("user.fzf-lua-fast")
      -- Use full config (default)
      require "user.fzf-lua"
    end,
  },

  -- THEMES - Keep minimal set, load immediately for UI consistency
  { "decaycs/decay.nvim", name = "decay" },
  "lunarvim/darkplus.nvim",
  "folke/tokyonight.nvim",
  {
    "uloco/bluloco.nvim",
    dependencies = { "rktjmp/lush.nvim" },
  },

  -- Notifications - LAZY LOAD
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = function() require "user.notify" end,
  },

  -- Dressing - LAZY LOAD
  {
    "stevearc/dressing.nvim",
    event = "VeryLazy",
    config = function() require "user.dressing" end,
  },

  -- Buffer navigation - LAZY LOAD
  {
    "ghillb/cybu.nvim",
    branch = "main", -- timely updates
    event = { "BufReadPost", "BufNewFile" },
    config = function() require "user.cybu" end,
  },

  -- Registers - LAZY LOAD
  {
    "tversteeg/registers.nvim",
    keys = { '"', "<C-r>" },
    config = function() require "user.registers" end,
  },

  -- Bufferline - LAZY LOAD
  {
    "akinsho/bufferline.nvim",
    event = "VeryLazy",
    -- config handled in separate file
  },

  -- Lualine - LAZY LOAD with priority
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    priority = 900,
    config = function() require "user.lualine" end,
  },

  -- File explorer - LAZY LOAD
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
    keys = { "<leader>e" },
    config = function() require "user.nvim-tree" end,
  },

  -- Comment - LAZY LOAD
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" } },
      { "gb", mode = { "n", "v" } },
    },
    config = function() require("Comment").setup() end,
  },

  -- Todo comments - LAZY LOAD
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require "user.todo-comments" end,
  },

  -- Terminal functionality is now handled by native Neovim terminal
  -- Configuration in lua/user/terminal.lua

  -- Search and replace - LAZY LOAD
  {
    "nvim-pack/nvim-spectre",
    cmd = "Spectre",
    keys = { "<leader>S" },
    config = function() require "user.spectre" end,
  },

  -- Better quickfix - LAZY LOAD
  {
    "kevinhwang91/nvim-bqf",
    ft = "qf",
    config = function() require "user.bqf" end,
  },

  -- Git signs - LAZY LOAD
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function() require "user.gitsigns" end,
  },

  -- THEMES - Move less used themes to lazy load
  {
    "krshrimali/vim-moonfly-colors",
    lazy = true,
  },
  {
    "navarasu/onedark.nvim",
    lazy = true,
  },
  {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
  },
  {
    "sainnhe/gruvbox-material",
    lazy = true,
  },
  {
    "Shadorain/shadotheme",
    lazy = true,
  },
  {
    "nyoom-engineering/oxocarbon.nvim",
    lazy = true,
  },
  {
    "projekt0n/github-nvim-theme",
    lazy = true,
  },

  -- Peek numbers - LAZY LOAD
  {
    "nacro90/numb.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = function() require "user.numb" end,
  },

  -- Command line replaced with native fzf-lua functionality

  -- Outline - LAZY LOAD (already configured correctly)
  {
    "hedyhli/outline.nvim",
    lazy = true,
    cmd = { "Outline", "OutlineToggle", "OutlineOpen" },
    keys = {
      {
        "<leader>lo",
        "<cmd>Outline<CR>",
        desc = "Toggle Outline",
      },
    },
    opts = {
      outline_window = {
        wrap = true,
      },
      symbol_folding = {
        markers = { "> ", "v " },
      },
      symbols = {
        icons = {
          File = { icon = "F", hl = "Identifier" },
          Module = { icon = "M", hl = "Include" },
          Namespace = { icon = "N", hl = "Include" },
          Package = { icon = "P", hl = "Include" },
          Class = { icon = "C", hl = "Type" },
          Method = { icon = "m", hl = "Function" },
          Property = { icon = "p", hl = "Identifier" },
          Field = { icon = "f", hl = "Identifier" },
          Constructor = { icon = "c", hl = "Special" },
          Enum = { icon = "E", hl = "Type" },
          Interface = { icon = "I", hl = "Type" },
          Function = { icon = "F", hl = "Function" },
          Variable = { icon = "v", hl = "Constant" },
          Constant = { icon = "C", hl = "Constant" },
          String = { icon = "s", hl = "String" },
          Number = { icon = "#", hl = "Number" },
          Boolean = { icon = "b", hl = "Boolean" },
          Array = { icon = "A", hl = "Constant" },
          Object = { icon = "O", hl = "Type" },
          Key = { icon = "k", hl = "Type" },
          Null = { icon = "n", hl = "Type" },
          EnumMember = { icon = "e", hl = "Identifier" },
          Struct = { icon = "S", hl = "Structure" },
          Event = { icon = "E", hl = "Type" },
          Operator = { icon = "o", hl = "Identifier" },
          TypeParameter = { icon = "t", hl = "Identifier" },
          Component = { icon = "C", hl = "Function" },
          Fragment = { icon = "f", hl = "Constant" },
          TypeAlias = { icon = "T", hl = "Type" },
          Parameter = { icon = "p", hl = "Identifier" },
          StaticMethod = { icon = "S", hl = "Function" },
          Macro = { icon = "M", hl = "Function" },
        },
      },
    },
  },

  -- Python type stubs - DISABLED
  {
    "microsoft/python-type-stubs",
    cond = false,
  },

  -- File browser functionality available through fzf-lua files command

  -- Winbar - DISABLED (no filename/filepath display)
  {
    "fgheng/winbar.nvim",
    event = "BufReadPost",
    config = function() require "user.winbar" end,
  },

  -- Frecency functionality replaced with fzf-lua oldfiles

  -- Trouble - LAZY LOAD (already configured correctly)
  {
    "folke/trouble.nvim",
    opts = {

      icons = {
        indent = {
          top = "| ",
          middle = "|-",
          last = "+-",
          fold_open = "v",
          fold_closed = ">",
          ws = "  ",
        },
        folder_closed = "d",
        folder_open = "D",
        kinds = {
          Array = "A",
          Boolean = "B",
          Class = "C",
          Constant = "c",
          Constructor = "C",
          Enum = "E",
          EnumMember = "e",
          Event = "E",
          Field = "f",
          File = "F",
          Function = "f",
          Interface = "I",
          Key = "k",
          Method = "m",
          Module = "M",
          Namespace = "N",
          Null = "n",
          Number = "#",
          Object = "O",
          Operator = "o",
          Package = "P",
          Property = "p",
          String = "s",
          Struct = "S",
          TypeParameter = "t",
          Variable = "v",
        },
      },
    }, -- for default options, refer to the configuration section for custom setup.
    cmd = "Trouble",
    keys = {
      {
        "<leader>xx",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
      {
        "<leader>cs",
        "<cmd>Trouble symbols toggle focus=false<cr>",
        desc = "Symbols (Trouble)",
      },
      {
        "<leader>cl",
        "<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
        desc = "LSP Definitions / references / ... (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>Trouble loclist toggle<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>Trouble qflist toggle<cr>",
        desc = "Quickfix List (Trouble)",
      },
    },
  },
  {
    "github/copilot.vim",
    cmd = "Copilot",
    event = "InsertEnter",
  },

  -- Project management - LAZY LOAD
  {
    "ahmedkhalf/project.nvim",
    event = "VeryLazy",
    config = function()
      require("project_nvim").setup {
        detection_methods = { "lsp", "pattern" },
        patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml" },
        ignore_lsp = {},
        exclude_dirs = {},
        show_hidden = false,
        silent_chdir = true,
        scope_chdir = "global",
        datapath = vim.fn.stdpath "data",
      }
      -- projects extension removed - using fzf-lua for file navigation
    end,
  },

  -- Custom utilities - LAZY LOAD
  {
    "krshrimali/nvim-utils",
    event = "VeryLazy",
    config = function()
      require("tgkrsutil").setup {
        enable_test_runner = true,
        test_runner = function(file, func) return string.format("despytest %s -k %s", file, func) end,
      }
    end,
  },

  -- Context pilot - LAZY LOAD
  {
    -- "krshrimali/context-pilot.nvim",
    "krshrimali/context-pilot.nvim",
    dependencies = {
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
    },
    config = function() require "contextpilot" end,
  },

  -- Git blame - LAZY LOAD
  {
    "f-person/git-blame.nvim",
    cmd = { "GitBlameToggle", "GitBlameEnable" },
    keys = { "<leader>gb" },
    opts = {
      enabled = false,
      virtual_text_column = 1,
    },
  },

  -- Snacks - LOAD IMMEDIATELY (UI and core functionality)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      -- your configuration comes here
      -- or leave it empty to use the default settings
      -- refer to the configuration section below
      bigfile = {
        enabled = false, -- Disabled to ensure LSP always works
      },
      gitbrowse = {
        what = "permalink",
        url_patterns = {
          ["github%.deshaw%.com"] = {
            branch = "/tree/{branch}",
            file = "/blob/{branch}/{file}#L{line_start}-L{line_end}",
            permalink = "/blob/{commit}/{file}#L{line_start}-L{line_end}",
            commit = "/commit/{commit}",
          },
        },
      },
      dashboard = { enabled = false }, -- Completely disable dashboard
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      picker = { enabled = false }, -- Disable picker since we're using nvim-tree
      notifier = { enabled = false }, -- Disable for faster startup
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false }, -- Disable for faster startup
      words = { enabled = false },
    },
  },

  -- Avante - LAZY LOAD

  -- Markdown Preview - LAZY LOAD
  {
    "ellisonleao/glow.nvim",
    ft = "markdown",
    cmd = "Glow",
    config = function()
      local markdown_preview = require "user.markdown_preview"
      markdown_preview.setup()
      markdown_preview.setup_keymaps()
    end,
  },

  -- LSP Saga - LAZY LOAD
  -- {
  --     'nvimdev/lspsaga.nvim',
  --     event = { "BufReadPost", "BufNewFile" },
  --     config = function()
  --         require('lspsaga').setup({
  --             ui = {
  --                 devicon = false,
  --                 foldericon = false,
  --                 expand = '>',
  --                 collapse = '<',
  --                 use_nerd = false
  --             }
  --         })
  --     end,
  --     dependencies = {
  --         'nvim-treesitter/nvim-treesitter',
  --     }
  -- },
  -- LSP Configuration for goto-preview
  {
    "rmagatti/goto-preview",
    dependencies = {
      "rmagatti/logger.nvim",
      "neovim/nvim-lspconfig",
    },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("goto-preview").setup {
        width = 120,
        height = 25,
        border = { "↖", "─", "┐", "│", "┘", "─", "└", "│" },
        default_mappings = false,
        debug = false,
        opacity = nil,
        resizing_mappings = false,
        post_open_hook = nil,
        focus_on_open = true,
        dismiss_on_move = false,
        force_close = true,
        bufhidden = "wipe",
        stack_floating_preview_windows = true,
        preview_window_title = { enable = true, position = "left" },
      }
    end,
  },
  -- {
  --   "linux-cultist/venv-selector.nvim",
  --   dependencies = {
  --     "neovim/nvim-lspconfig",
  --     "mfussenegger/nvim-dap",
  --     "mfussenegger/nvim-dap-python", --optional
  --     { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" } },
  --   },
  --   lazy = false,
  --   branch = "regexp", -- This is the regexp branch, use this for the new version
  --   keys = {
  --     { ",v", "<cmd>VenvSelect<cr>" },
  --   },
  --   opts = {
  --     -- Your settings go here
  --     search = {
  --       my_vens = {
  --         command = "fd python$ ~/.virtualenv/",
  --       },
  --     },
  --   },
  -- },
  -- Minimap - VSCode-like minimap functionality - LAZY LOAD
  {
    "wfxr/minimap.vim",
    cmd = { "Minimap", "MinimapClose", "MinimapToggle", "MinimapRefresh", "MinimapUpdateHighlight" },
    keys = {
      { "<leader>mm", "<cmd>MinimapToggle<cr>", desc = "Toggle Minimap" },
      { "<leader>mr", "<cmd>MinimapRefresh<cr>", desc = "Refresh Minimap" },
    },
    build = function()
      -- Ensure cargo environment is sourced and install code-minimap
      local install_cmd = "source /usr/local/cargo/env 2>/dev/null || true; cargo install --locked code-minimap"
      vim.fn.system(install_cmd)
    end,
    init = function()
      -- Set the path to code-minimap binary early
      vim.g.minimap_exec_path = "/usr/local/cargo/bin/code-minimap"
      -- Also add to PATH if not already there
      local current_path = vim.env.PATH or ""
      if not current_path:find "/usr/local/cargo/bin" then vim.env.PATH = "/usr/local/cargo/bin:" .. current_path end
    end,
    config = function() require "user.minimap" end,
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
    -- use opts = {} for passing setup options
    -- this is equivalent to setup({}) function
  },
  -- Surround text objects - LAZY LOAD
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        keymaps = {
          insert = "<C-g>s",
          insert_line = "<C-g>S",
          normal = "ys",
          normal_cur = "yss",
          normal_line = "yS",
          normal_cur_line = "ySS",
          visual = "S",
          visual_line = "gS",
          delete = "ds",
          change = "cs",
        },
      })
    end,
  },
  -- Auto-detect indentation (tabs vs spaces, indent width)
  {
    "tpope/vim-sleuth",
    event = { "BufReadPre", "BufNewFile" },
  },
  {
    "SmiteshP/nvim-navic",
  },
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader><cr>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude", mode = { "n", "t", "x" } },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader><cr>", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      -- Diff management
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
    opts = {
      -- Server Configuration
      port_range = { min = 10000, max = 65535 },
      auto_start = true,
      log_level = "info", -- "trace", "debug", "info", "warn", "error"
      terminal_cmd = "claude", -- Custom terminal command (default: "claude")
      -- For local installations: "~/.claude/local/claude"
      -- For native binary: use output from 'which claude'

      -- Selection Tracking
      track_selection = true,
      visual_demotion_delay_ms = 50,

      -- Terminal Configuration
      terminal = {
        provider = "snacks",
        snacks_win_opts = {
          position = "float",
          width = 0.6,
          height = 0.6,
          border = "rounded",
          keys = {
            claude_hide = {
              "<leader><cr>",
              function(self) self:hide() end,
              mode = "t",
              desc = "Hide",
            },
          },
        },
        split_side = "left",
        split_width_percentage = 0.25,
      },

      -- Diff Integration
      diff_opts = {
        auto_close_on_accept = true,
        vertical_split = true,
        open_in_current_tab = true,
        keep_terminal_focus = false, -- If true, moves focus back to terminal after diff opens
      },
    },
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    -- config = function() vim.cmd "colorscheme rose-pine" end,
  },

  -- {
  --     "karb94/neoscroll.nvim",
  --     opts = {},
  -- }
}
