local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  }
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Simplified plugin list - inspired by Helix minimalism
require("lazy").setup({
  -- ============================================
  -- CORE: LSP & Completion (essential)
  -- ============================================
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy", -- Defer LSP startup for faster file opening
    dependencies = {
      {
        "williamboman/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        config = true,
      },
      { "williamboman/mason-lspconfig.nvim" },
      { "saghen/blink.cmp",                 version = "1.*", dependencies = { "rafamadriz/friendly-snippets" } },
      { "folke/neodev.nvim",                config = true },
      { "b0o/schemastore.nvim",             lazy = true },
    },
    config = function() require("user.lsp").setup() end,
  },

  -- LSP progress (minimal UI)
  { "j-hui/fidget.nvim",     event = "LspAttach",   opts = {} },

  -- ============================================
  -- SYNTAX: Treesitter (essential)
  -- ============================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = "VeryLazy", -- Defer for faster file opening
    config = function() require "user.treesitter" end,
  },

  -- ============================================
  -- NAVIGATION: File picker & Search
  -- ============================================
  {
    "ibhagwan/fzf-lua",
    cmd = "FzfLua",
    config = function() require "user.fzf-lua" end,
  },

  -- File explorer (lazy)
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeOpen" },
    keys = { { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File Explorer" } },
    config = function() require "user.nvim-tree" end,
  },

  -- ============================================
  -- GIT: Essential git tools
  -- ============================================
  {
    "lewis6991/gitsigns.nvim",
    event = "VeryLazy", -- Defer to after UI is ready
    config = function() require "user.gitsigns" end,
  },

  -- Inline diff overlay (shows old text as virtual lines)
  {
    "echasnovski/mini.diff",
    event = "VeryLazy",
    keys = {
      { "<leader>gm", function() require("mini.diff").toggle_overlay() end, desc = "Toggle diff overlay" },
    },
    opts = {
      view = {
        style = "sign",
        signs = { add = "+", change = "~", delete = "-" },
      },
      -- Disable signs to avoid conflict with gitsigns signcolumn
      mappings = {
        apply = "",
        reset = "",
        textobject = "",
        goto_first = "",
        goto_prev = "[m",
        goto_next = "]m",
        goto_last = "",
      },
    },
  },

  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>",                    desc = "Git diff (split)" },
      { "<leader>gu", "<cmd>DiffviewOpen --view=diff1_plain<cr>", desc = "Git diff (unified)" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>",           desc = "File history" },
    },
    config = function() require "user.diffview" end,
  },

  {
    "NeogitOrg/neogit",
    cmd = "Neogit",
    dependencies = { "nvim-lua/plenary.nvim", "sindrets/diffview.nvim" },
    opts = {
      integrations = { diffview = true },
      signs = { section = { ">", "v" }, item = { ">", "v" } },
    },
  },

  -- ============================================
  -- EDITING: Essential editing enhancements
  -- ============================================
  {
    "numToStr/Comment.nvim",
    keys = { { "gc", mode = { "n", "v" } }, { "gb", mode = { "n", "v" } } },
    config = true,
  },

  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },

  {
    "kylechui/nvim-surround",
    keys = { "ys", "ds", "cs", { "S", mode = "v" } },
    config = true,
  },

  { "tpope/vim-sleuth",      event = "VeryLazy" },

  -- ============================================
  -- UI: Minimal UI enhancements
  -- ============================================
  -- Theme - flexoki
  {
    "kepano/flexoki-neovim",
    name = "flexoki",
    lazy = false,
    priority = 1000,
  },

  -- Transparent background (load on demand with :TransparentEnable)
  {
    "xiyaowong/transparent.nvim",
    lazy = false,
    keys = { { "<leader>ut", "<cmd>TransparentToggle<cr>", desc = "Toggle Transparent" } },
    opts = {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
      },
    },
    config = function(_, opts)
      require("transparent").setup(opts)
      require("transparent").clear_prefix "BufferLine"
      vim.cmd "TransparentEnable"
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    opts = function()
      local c = require "user.lualine"
      return {
        options = {
          globalstatus = true,
          icons_enabled = false,
          theme = "auto",
          component_separators = { left = "\u{2502}", right = "\u{2502}" },
          section_separators = { left = "\u{2590}", right = "\u{258c}" },
          disabled_filetypes = { "alpha", "dashboard", "NvimTree" },
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = {
            {
              "branch",
              fmt = function(str) return "%@v:lua.LualineGitLog@ " .. str .. " %X" end,
            },
            { "diff", symbols = { added = "+", modified = "~", removed = "-" } },
          },
          lualine_c = {
            c.nav_buttons,
            { "filename", path = 1, symbols = { modified = " [+]", readonly = " [-]", unnamed = "[No Name]" } },
            c.breadcrumbs,
          },
          lualine_x = {
            { c.macro_recording, color = { fg = "#ff9e64", gui = "bold" } },
            { c.search_count,    color = { fg = "#7aa2f7" } },
            "diagnostics",
            { c.lsp_status, color = { fg = "#9ece6a" } },
          },
          lualine_y = { "filetype" },
          lualine_z = { "location", "progress" },
        },
        inactive_sections = {
          lualine_a = {},
          lualine_b = {},
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "location" },
          lualine_y = {},
          lualine_z = {},
        },
      }
    end,
    config = function(_, opts)
      local lualine = require "lualine"
      require("user.lualine").setup(lualine)
      lualine.setup(opts)
    end,
  },

  -- Snacks for picker and gitbrowse
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    keys = {
      -- Picker keymaps
      { "<C-p>",      function() Snacks.picker.files() end,       desc = "Find Files" },
      { "<leader>ff", function() Snacks.picker.files() end,       desc = "Find Files" },
      { "<leader>fr", function() Snacks.picker.recent() end,      desc = "Recent Files" },
      { "<leader>/",  function() Snacks.picker.grep() end,        desc = "Live Grep" },
      { "<leader>b",  function() Snacks.picker.buffers() end,     desc = "Buffers" },
      { "<leader>fh", function() Snacks.picker.help() end,        desc = "Help Tags" },
      { "<leader>fk", function() Snacks.picker.keymaps() end,     desc = "Keymaps" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fc", function() Snacks.picker.commands() end,    desc = "Commands" },
      { "<leader>fw", function() Snacks.picker.grep_word() end,   desc = "Grep Word",   mode = { "n", "x" } },
      { "<leader>fp", function() Snacks.picker.projects() end,    desc = "Projects" },
      -- Git
      {
        "<leader>gy",
        function()
          Snacks.gitbrowse { open = function(url) vim.fn.setreg("+", url) end }
        end,
        desc = "Copy GitHub permalink",
        mode = { "n", "x" },
      },
    },
    opts = {
      animations = { enabled = false },
      bigfile = { enabled = false },
      dashboard = { enabled = false },
      explorer = { enabled = false },
      indent = { enabled = false },
      input = { enabled = false },
      notifier = { enabled = false },
      quickfile = { enabled = false },
      scope = { enabled = false },
      scroll = { enabled = false },
      statuscolumn = { enabled = false },
      terminal = { enabled = false },
      words = { enabled = false },
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
      picker = {
        enabled = true,
        prompt = ":",
        focus = "input",
        layout = {
          cycle = true,
          preset = "ivy",
          -- Override ivy with a taller centered float
          layout = {
            backdrop = false,
            width = 0.8,
            min_width = 80,
            height = 0.8,
            min_height = 30,
            box = "vertical",
            border = "rounded",
            title = "{title} {live} {flags}",
            title_pos = "center",
            { win = "input", height = 1, border = "bottom" },
            {
              box = "horizontal",
              { win = "list",    border = "none" },
              { win = "preview", title = "{preview}", border = "left", width = 0.5 },
            },
          },
        },
        matcher = {
          fuzzy = true,
          smartcase = true,
          ignorecase = true,
          sort_empty = false,
          filename_bonus = true,
          file_pos = true,
          -- Disable expensive bonuses for performance
          cwd_bonus = false,
          frecency = false,
          history_bonus = false,
        },
        sort = {
          fields = { "score:desc", "#text", "idx" },
        },
        ui_select = true,
        formatters = {
          file = {
            filename_first = false,
            truncate = 80,
            filename_only = false,
            icon_width = 2,
            git_status_hl = false,
          },
        },
        icons = {
          files = { enabled = false },
        },
        win = {
          input = {
            keys = {
              ["<c-x>"] = { "edit_split", mode = { "i", "n" } },
              ["<A-q>"] = { "qflist_all", mode = { "i", "n" } },
            },
          },
          preview = {
            wo = {
              number = false,
              relativenumber = false,
            },
          },
        },
      },
    },
  },

  -- Which-key for keymap hints
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    config = function() require "user.whichkey" end,
  },

  {
    'dmtrKovalenko/fff.nvim',
    build = function()
      -- this will download prebuild binary or try to use existing rustup toolchain to build from source
      -- (if you are using lazy you can use gb for rebuilding a plugin if needed)
      require("fff.download").download_or_build_binary()
    end,
    -- if you are using nixos
    -- build = "nix run .#release",
    opts = {              -- (optional)
      debug = {
        enabled = true,   -- we expect your collaboration at least during the beta
        show_scores = true, -- to help us optimize the scoring system, feel free to share your scores!
      },
    },
    -- No need to lazy-load with lazy.nvim.
    -- This plugin initializes itself lazily.
    lazy = false,
    keys = {
      {
        "ff", -- try it if you didn't it is a banger keybinding for a picker
        function() require('fff').find_files() end,
        desc = 'FFFind files',
      },
      {
        "fg",
        function() require('fff').live_grep() end,
        desc = 'LiFFFe grep',
      },
      {
        "fz",
        function()
          require('fff').live_grep({
            grep = {
              modes = { 'fuzzy', 'plain' }
            }
          })
        end,
        desc = 'Live fffuzy grep',
      },
      {
        "fc",
        function() require('fff').live_grep({ query = vim.fn.expand("<cword>") }) end,
        desc = 'Search current word',
      },
    }
  },

  -- ============================================
  -- AI: Copilot
  -- ============================================
  {
    "github/copilot.vim",
    event = "InsertEnter",
    init = function()
      vim.g.copilot_no_tab_map = true
    end,
    keys = {
      { "<C-g>",  'copilot#Accept("")',       mode = "i", expr = true, replace_keycodes = false, desc = "Accept Copilot suggestion" },
      { "<C-]>",  "<Plug>(copilot-next)",     mode = "i", desc = "Next Copilot suggestion" },
      { "<C-p>",  "<Plug>(copilot-prev)",     mode = "i", desc = "Prev Copilot suggestion" },
      { "<C-\\>", "<Plug>(copilot-dismiss)",  mode = "i", desc = "Dismiss Copilot suggestion" },
    },
  },

  -- ============================================
  -- TOOLS: Optional tools (lazy loaded)
  -- ============================================
  -- Diagnostics viewer
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics" },
      { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
    },
    opts = {
      icons = {
        indent = { top = "| ", middle = "|-", last = "+-", fold_open = "v", fold_closed = ">", ws = "  " },
        folder_closed = "d",
        folder_open = "D",
        kinds = {
          Array = "[]",
          Boolean = "b",
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
          Object = "{}",
          Operator = "o",
          Package = "P",
          Property = "p",
          String = "s",
          Struct = "S",
          TypeParameter = "t",
          Variable = "v",
        },
      },
    },
  },

  -- Outline/symbols
  {
    "hedyhli/outline.nvim",
    cmd = { "Outline", "OutlineOpen" },
    keys = { { "<leader>lo", "<cmd>Outline<CR>", desc = "Toggle Outline" } },
    opts = {
      symbols = {
        icons = {
          File = { icon = "F" },
          Module = { icon = "M" },
          Namespace = { icon = "N" },
          Package = { icon = "P" },
          Class = { icon = "C" },
          Method = { icon = "m" },
          Property = { icon = "p" },
          Field = { icon = "f" },
          Constructor = { icon = "c" },
          Enum = { icon = "E" },
          Interface = { icon = "I" },
          Function = { icon = "F" },
          Variable = { icon = "v" },
          Constant = { icon = "C" },
          String = { icon = "s" },
          Number = { icon = "#" },
          Boolean = { icon = "b" },
          Array = { icon = "[]" },
          Object = { icon = "{}" },
          Key = { icon = "k" },
          Null = { icon = "n" },
          EnumMember = { icon = "e" },
          Struct = { icon = "S" },
          Event = { icon = "E" },
          Operator = { icon = "o" },
          TypeParameter = { icon = "t" },
        },
      },
      symbol_folding = { markers = { "> ", "v " } },
    },
  },

  -- Better quickfix
  { "kevinhwang91/nvim-bqf", ft = "qf",         config = function() require "user.bqf" end },

  -- Sidekick.nvim - AI CLI integration & Copilot NES
  {
    "krshrimali/sidekick.nvim",
    event = "VeryLazy",
    opts = {
      nes = { enabled = false },
      cli = {
        win = {
          keys = {
            interrupt = {
              "<C-c>",
              function(terminal)
                if terminal.job and terminal:is_running() then vim.api.nvim_chan_send(terminal.job, "\x03") end
              end,
              mode = "t",
              desc = "interrupt (SIGINT)",
            },
            normal_mode = { "jk", "stopinsert", mode = "t", desc = "enter normal mode" },
          },
        },
      },
    },
    keys = {
      {
        "<tab>",
        function()
          if not require("sidekick").nes_jump_or_apply() then return "<Tab>" end
        end,
        expr = true,
        desc = "Goto/Apply Next Edit Suggestion",
      },
      {
        "<leader>sk",
        function() require("sidekick.cli").toggle() end,
        desc = "Sidekick Toggle CLI",
        mode = { "n", "t", "i", "x" },
      },
      {
        "<leader>ss",
        function() require("sidekick.cli").select() end,
        desc = "Sidekick Select CLI",
      },
      {
        "<leader>sd",
        function() require("sidekick.cli").close() end,
        desc = "Sidekick Detach CLI",
      },
      {
        "<leader>st",
        function() require("sidekick.cli").send { msg = "{this}" } end,
        mode = { "x", "n" },
        desc = "Sidekick Send This",
      },
      {
        "<leader>sf",
        function() require("user.ai_context").send_function_with_context() end,
        desc = "Sidekick Send Function (with type + diagnostics)",
      },
      {
        "<leader>sl",
        function() require("sidekick.cli").send { msg = "{file}" } end,
        desc = "Sidekick Send File",
      },
      {
        "<leader>sv",
        function() require("sidekick.cli").send { msg = "{selection}" } end,
        mode = { "x" },
        desc = "Sidekick Send Selection",
      },
      {
        "<leader>sy",
        function()
          local clip = vim.fn.getreg "+"
          if clip == "" then
            vim.notify("Clipboard is empty", vim.log.levels.WARN)
            return
          end
          require("sidekick.cli").send { msg = clip }
        end,
        desc = "Sidekick Send Clipboard",
      },
      {
        "<leader>sp",
        function() require("sidekick.cli").prompt() end,
        mode = { "n", "x" },
        desc = "Sidekick Select Prompt",
      },
      {
        "<leader>sc",
        function() require("sidekick.cli").toggle { name = "claude", focus = true } end,
        desc = "Sidekick Toggle Claude",
      },
    },
  },

  {
    "Isrothy/neominimap.nvim",
    version = "v3.x.x",
    lazy = false, -- NOTE: NO NEED to Lazy load
    -- Optional. You can also set your own keybindings
    keys = {
      -- Global Minimap Controls
      { "<leader>nm",  "<cmd>Neominimap Toggle<cr>",      desc = "Toggle global minimap" },
      { "<leader>no",  "<cmd>Neominimap Enable<cr>",      desc = "Enable global minimap" },
      { "<leader>nc",  "<cmd>Neominimap Disable<cr>",     desc = "Disable global minimap" },
      { "<leader>nr",  "<cmd>Neominimap Refresh<cr>",     desc = "Refresh global minimap" },

      -- Window-Specific Minimap Controls
      { "<leader>nwt", "<cmd>Neominimap WinToggle<cr>",   desc = "Toggle minimap for current window" },
      { "<leader>nwr", "<cmd>Neominimap WinRefresh<cr>",  desc = "Refresh minimap for current window" },
      { "<leader>nwo", "<cmd>Neominimap WinEnable<cr>",   desc = "Enable minimap for current window" },
      { "<leader>nwc", "<cmd>Neominimap WinDisable<cr>",  desc = "Disable minimap for current window" },

      -- Tab-Specific Minimap Controls
      { "<leader>ntt", "<cmd>Neominimap TabToggle<cr>",   desc = "Toggle minimap for current tab" },
      { "<leader>ntr", "<cmd>Neominimap TabRefresh<cr>",  desc = "Refresh minimap for current tab" },
      { "<leader>nto", "<cmd>Neominimap TabEnable<cr>",   desc = "Enable minimap for current tab" },
      { "<leader>ntc", "<cmd>Neominimap TabDisable<cr>",  desc = "Disable minimap for current tab" },

      -- Buffer-Specific Minimap Controls
      { "<leader>nbt", "<cmd>Neominimap BufToggle<cr>",   desc = "Toggle minimap for current buffer" },
      { "<leader>nbr", "<cmd>Neominimap BufRefresh<cr>",  desc = "Refresh minimap for current buffer" },
      { "<leader>nbo", "<cmd>Neominimap BufEnable<cr>",   desc = "Enable minimap for current buffer" },
      { "<leader>nbc", "<cmd>Neominimap BufDisable<cr>",  desc = "Disable minimap for current buffer" },

      ---Focus Controls
      { "<leader>nf",  "<cmd>Neominimap Focus<cr>",       desc = "Focus on minimap" },
      { "<leader>nu",  "<cmd>Neominimap Unfocus<cr>",     desc = "Unfocus minimap" },
      { "<leader>ns",  "<cmd>Neominimap ToggleFocus<cr>", desc = "Switch focus on minimap" },
    },
    init = function()
      -- The following options are recommended when layout == "float"
      vim.opt.sidescrolloff = 36 -- Set a large value

      --- Put your configuration here
      ---@type Neominimap.UserConfig
      vim.g.neominimap = {
        auto_enable = false,
        click = {
          enabled = true,
        },
        diagnostic = {
          enabled = false,
        },
        mini_diff = {
          enabled = true,
        },
      }
    end,
  },

  -- Todo comments
  {
    "folke/todo-comments.nvim",
    event = "VeryLazy", -- Defer for faster file opening
    config = function() require "user.todo-comments" end,
  },

  -- Highlight words under cursor
  {
    "RRethy/vim-illuminate",
    event = "VeryLazy", -- Defer for faster file opening
    config = function() require "user.illuminate" end,
  },

  -- GitHub Integration
  {
    "krshrimali/gh.nvim",
    cmd = { "Github", "GithubIssues", "GithubPRs", "GithubAssigned", "GithubRefresh" },
    keys = {
      { "<leader>gh",  "<cmd>Github<cr>",       desc = "GitHub" },
      { "<leader>ghi", "<cmd>GithubIssues<cr>", desc = "GitHub Issues" },
      { "<leader>ghp", "<cmd>GithubPRs<cr>",    desc = "GitHub PRs" },
    },
    config = function() require("github").setup {} end,
  },

  { "nvim-mini/mini.map", version = false },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-mini/mini.nvim" }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- Goto Preview (LSP definition/reference previews)
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    keys = {
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",     desc = "Preview definition" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Preview implementation" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>",     desc = "Preview references" },
      {
        "gpt",
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        desc = "Preview type definition",
      },
      { "gP", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close all previews" },
    },
    opts = {
      width = 120,
      height = 25,
      border = "rounded",
      default_mappings = false,
      focus_on_open = true,
      force_close = true,
      bufhidden = "wipe",
    },
  },

  -- Custom utilities
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

  -- Octo.nvim (GitHub Issues/PRs in Neovim)
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    keys = {
      { "<leader>oi", "<cmd>Octo issue list<cr>", desc = "Octo: Issues" },
      { "<leader>op", "<cmd>Octo pr list<cr>",    desc = "Octo: PRs" },
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "ibhagwan/fzf-lua",
    },
    opts = {
      picker = "fzf-lua",
      enable_builtin = true,
    },
  },
  {
    "justinmk/guh.nvim",
  },
  {
    "carlos-algms/agentic.nvim",

    opts = {
      -- Any ACP-compatible provider works. Built-in: "claude-agent-acp" | "gemini-acp" | "codex-acp" | "opencode-acp" | "cursor-acp" | "copilot-acp" | "auggie-acp" | "mistral-vibe-acp" | "cline-acp" | "goose-acp"
      provider = "claude-agent-acp", -- setting the name here is all you need to get started
    },

    -- these are just suggested keymaps; customize as desired
    keys = {
      {
        "<C-\\>",
        function() require("agentic").toggle() end,
        mode = { "n", "v", "i" },
        desc = "Toggle Agentic Chat"
      },
      {
        "<C-'>",
        function() require("agentic").add_selection_or_file_to_context() end,
        mode = { "n", "v" },
        desc = "Add file or selection to Agentic to Context"
      },
      {
        "<C-,>",
        function() require("agentic").new_session() end,
        mode = { "n", "v", "i" },
        desc = "New Agentic Session"
      },
      {
        "<A-i>r", -- ai Restore
        function()
          require("agentic").restore_session()
        end,
        desc = "Agentic Restore session",
        silent = true,
        mode = { "n", "v", "i" },
      },
      {
        "<leader>ad", -- ai Diagnostics
        function()
          require("agentic").add_current_line_diagnostics()
        end,
        desc = "Add current line diagnostic to Agentic",
        mode = { "n" },
      },
      {
        "<leader>aD", -- ai all Diagnostics
        function()
          require("agentic").add_buffer_diagnostics()
        end,
        desc = "Add all buffer diagnostics to Agentic",
        mode = { "n" },
      },
    },
  }
}, {
  -- Lazy.nvim performance options
  performance = {
    cache = { enabled = true },
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
