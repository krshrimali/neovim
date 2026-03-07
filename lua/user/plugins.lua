local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
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
      { "saghen/blink.cmp", version = "1.*", dependencies = { "rafamadriz/friendly-snippets" } },
      { "folke/neodev.nvim", config = true },
      { "b0o/schemastore.nvim", lazy = true },
    },
    config = function() require("user.lsp").setup() end,
  },

  -- LSP progress (minimal UI)
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },

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
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Git diff (split)" },
      { "<leader>gu", "<cmd>DiffviewOpen --view=diff1_plain<cr>", desc = "Git diff (unified)" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
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

  { "tpope/vim-sleuth", event = "VeryLazy" },

  -- ============================================
  -- UI: Minimal UI enhancements
  -- ============================================
  -- Theme - flexoki
  {
    "kepano/flexoki-neovim",
    name = "flexoki",
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = "light"
      vim.cmd.colorscheme "flexoki-light"
    end,
  },

  -- Transparent background (load on demand with :TransparentEnable)
  {
    "xiyaowong/transparent.nvim",
    cmd = { "TransparentEnable", "TransparentDisable", "TransparentToggle" },
    keys = { { "<leader>ut", "<cmd>TransparentToggle<cr>", desc = "Toggle Transparent" } },
    opts = {
      extra_groups = {
        "NormalFloat",
        "NvimTreeNormal",
      },
    },
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function() require "user.lualine" end,
  },

  -- Snacks for picker and gitbrowse
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 900,
    keys = {
      -- Picker keymaps
      { "<C-p>", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
      { "<leader>/", function() Snacks.picker.grep() end, desc = "Live Grep" },
      { "<leader>b", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Tags" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fs", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fc", function() Snacks.picker.commands() end, desc = "Commands" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep Word", mode = { "n", "x" } },
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

  -- ============================================
  -- TOOLS: Optional tools (lazy loaded)
  -- ============================================
  -- Diagnostics viewer
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
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
  { "kevinhwang91/nvim-bqf", ft = "qf", config = function() require "user.bqf" end },

  -- Claude Code integration
  {
    "coder/claudecode.nvim",
    dependencies = { "folke/snacks.nvim" },
    keys = {
      { "<leader><cr>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude", mode = { "n", "t" } },
      { "<leader><cr>", "<cmd>ClaudeCodeSend<cr>", mode = { "v", "x" }, desc = "Send to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
    opts = {
      port_range = { min = 10000, max = 65535 },
      auto_start = true,
      log_level = "info",
      terminal_cmd = "claude",
      track_selection = true,
      terminal = {
        provider = "snacks",
        snacks_win_opts = { position = "float", width = 0.6, height = 0.6, border = "rounded" },
      },
      diff_opts = { auto_close_on_accept = true, vertical_split = true },
    },
  },

  -- Copilot (lazy)
  -- { "github/copilot.vim", cmd = "Copilot", event = "InsertEnter" },

  -- Sidekick.nvim - AI CLI integration & Copilot NES
  {
    "krshrimali/sidekick.nvim",
    event = "VeryLazy",
    opts = {
      nes = { enabled = false },
      cli = {
        win = {
          keys = {
            interrupt = { "<C-c>", function(terminal)
              if terminal.job and terminal:is_running() then
                vim.api.nvim_chan_send(terminal.job, "\x03")
              end
            end, mode = "t", desc = "interrupt (SIGINT)" },
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
        function()
          -- Send parent function to sidekick using built-in treesitter
          local ok, parser = pcall(vim.treesitter.get_parser, 0)
          if not ok or not parser then
            vim.notify("Treesitter parser not available for this filetype", vim.log.levels.ERROR)
            return
          end
          parser:parse()
          local node = vim.treesitter.get_node()
          if not node then
            vim.notify("No treesitter node at cursor", vim.log.levels.WARN)
            return
          end
          while node do
            local t = node:type()
            if
              t == "function_definition"
              or t == "function_declaration"
              or t == "method_definition"
              or t == "method_declaration"
              or t == "function_item"
              or t == "fn_item"
              or t == "function"
              or t == "local_function"
            then
              break
            end
            node = node:parent()
          end
          if not node then
            vim.notify("No parent function found", vim.log.levels.WARN)
            return
          end
          local sr, _, er, _ = node:range()
          local lines = vim.api.nvim_buf_get_lines(0, sr, er + 1, false)
          local text = table.concat(lines, "\n")
          local path = vim.fn.fnamemodify(vim.fn.expand "%", ":.")
          require("sidekick.cli").send { msg = path .. ":" .. (sr + 1) .. ":" .. (er + 1) .. "\n" .. text }
        end,
        desc = "Sidekick Send Function",
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
      { "<leader>gh", "<cmd>Github<cr>", desc = "GitHub" },
      { "<leader>ghi", "<cmd>GithubIssues<cr>", desc = "GitHub Issues" },
      { "<leader>ghp", "<cmd>GithubPRs<cr>", desc = "GitHub PRs" },
    },
    config = function() require("github").setup {} end,
  },

  { "nvim-mini/mini.map", version = false },

  -- Goto Preview (LSP definition/reference previews)
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    keys = {
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview definition" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Preview implementation" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "Preview references" },
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
      { "<leader>op", "<cmd>Octo pr list<cr>", desc = "Octo: PRs" },
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
