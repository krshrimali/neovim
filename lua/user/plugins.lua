local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.g.mapleader = ","
vim.g.maplocalleader = ","


-- Install your plugins here
require("lazy").setup({
  -- Lua Development
  "nvim-lua/plenary.nvim", -- Useful lua functions used in lots of plugins
  "nvim-lua/popup.nvim",
  "folke/neodev.nvim",
  "j-hui/fidget.nvim",
  { 'rust-lang/rust.vim' },
  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim"
        },
        opts = { lsp = { auto_attach = true } }
      }
    },
  },
  -- "williamboman/nvim-lsp-installer" -- simple to language server installer
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",

  -- "ray-x/lsp_signature.nvim", -- TODO
  -- TODO: Remove this as it's archived by the author and not actively maintained anymore
  -- "simrat39/symbols-outline.nvim"
  -- bringing it back
  "folke/trouble.nvim",
  -- "github/copilot.vim",
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        suggestion = { enabled = true, auto_trigger = true },
        panel = { enabled = true },
      })
    end,
  },
  "nvimtools/none-ls.nvim", -- TODO

  "RRethy/vim-illuminate",
  -- "lvimuser/lsp-inlayhints.nvim",
  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",

  "L3MON4D3/LuaSnip",             --snippet engine
  "rafamadriz/friendly-snippets", -- a bunch of snippets to use

  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  "JoosepAlviste/nvim-ts-context-commentstring",
  "kylechui/nvim-surround",
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",         -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim",        -- optional
    },
    config = true,
  },
  "xiyaowong/transparent.nvim",
  "rmagatti/goto-preview",
  "chrisgrieser/nvim-spider",
  {
    "nvim-telescope/telescope.nvim",
    -- "/Users/krshrimali/Documents/Projects/Personal/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      require("telescope").load_extension "live_grep_args"
    end,
  },
  "rcarriga/nvim-notify",
  "ghillb/cybu.nvim",
  -- "stevearc/dressing.nvim",

  -- Colorthemes
  { "decaycs/decay.nvim",    as = "decay" },
  "lunarvim/darkplus.nvim",
  "folke/tokyonight.nvim",
  {
    "uloco/bluloco.nvim",
    dependencies = { "rktjmp/lush.nvim" },
  },

  -- Registers
  "tversteeg/registers.nvim",

  "kyazdani42/nvim-web-devicons",

  "akinsho/bufferline.nvim",
  "nvim-lualine/lualine.nvim",
  {
    "goolord/alpha-nvim",
  },

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional
    },
  },
  "krshrimali/vim-moonfly-colors", -- personalized, this one is very dark :D
  "navarasu/onedark.nvim",
  "ellisonleao/gruvbox.nvim",
  "sainnhe/gruvbox-material",
  "Shadorain/shadotheme",
  "nyoom-engineering/oxocarbon.nvim",
  "projekt0n/github-nvim-theme",

  -- Comment
  "numToStr/Comment.nvim",
  "folke/todo-comments.nvim",
  -- Terminal
  "akinsho/toggleterm.nvim",

  -- Not so used
  "nvim-pack/nvim-spectre",
  "kevinhwang91/nvim-bqf",

  "lewis6991/gitsigns.nvim",
	{
		"f-person/git-blame.nvim", opts = { enabled = false } },
  -- "windwp/nvim-autopairs",
  -- "karb94/neoscroll.nvim",
  "folke/which-key.nvim",

  -- clip -- TODO
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      { "kkharji/sqlite.lua",           module = "sqlite" },
      { "nvim-telescope/telescope.nvim" },
    },
  },
  -- TODO: use gitlinker
  -- "stevearc/oil.nvim", -- TODO
  "jonarrien/telescope-cmdline.nvim",
  {
    "princejoogie/dir-telescope.nvim",
    -- telescope.nvim is a required dependency
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("dir-telescope").setup({
        -- these are the default options set
        hidden = true,
        no_ignore = false,
        show_preview = true,
      })
    end,
  },
  {
    "hedyhli/outline.nvim",
    config = function()
      -- Example mapping to toggle outline
      vim.keymap.set("n", "<leader>lo", "<cmd>Outline<CR>",
        { desc = "Toggle Outline" })

      require("outline").setup {
        -- Your setup opts here (leave empty to use defaults)
      }
    end,
  },
  {
    "microsoft/python-type-stubs",
    cond = false,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  {
    "coffebar/neovim-project",
    opts = {
      projects = { -- define project roots
        "~/Documents/Projects/*",
        "~/.config/*",
        "~/Documents/Projects/Open-Source/*"
      },
    },
    init = function()
      -- enable saving the state of plugins in the session
      vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
      require("nvim-tree").setup {}
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim", tag = "0.1.4" },
      { "Shatur/neovim-session-manager" },
    },
    lazy = false,
    priority = 100,
  },
  {
    "ibhagwan/fzf-lua",
    -- optional for icon support
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      -- calling `setup` is optional for customization
      require("fzf-lua").setup({})
    end
  },
  {
    "folke/trouble.nvim",
    opts = {}, -- for default options, refer to the configuration section for custom setup.
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
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false, -- set this if you want to always pull the latest change
    opts = {
      provider = "copilot",
      -- add any opts here
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua",      -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
    {
      'saghen/blink.cmp',
      lazy = false, -- lazy loading handled internally
      -- optional: provides snippets for the snippet source
      dependencies = 'rafamadriz/friendly-snippets',

      -- use a release tag to download pre-built binaries
      version = 'v0.*',
      -- OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
      -- build = 'cargo build --release',
      -- If you use nix, you can build from source using latest nightly rust with:
      -- build = 'nix run .#build-plugin',

      ---@module 'blink.cmp'
      ---@type blink.cmp.Config
      opts = {
        -- 'default' for mappings similar to built-in completion
        -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
        -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
        -- see the "default configuration" section below for full documentation on how to define
        -- your own keymap.
        keymap = { preset = 'default' },

        highlight = {
          -- sets the fallback highlight groups to nvim-cmp's highlight groups
          -- useful for when your theme doesn't support blink.cmp
          -- will be removed in a future release, assuming themes add support
          use_nvim_cmp_as_default = false,
        },
        -- set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
        -- adjusts spacing to ensure icons are aligned
        nerd_font_variant = 'normal',

        -- default list of enabled providers defined so that you can extend it
        -- elsewhere in your config, without redefining it, via `opts_extend`
        sources = {
          completion = {
            enabled_providers = { 'lsp', 'path', 'snippets', 'buffer' },
          },
        },

        -- experimental auto-brackets support
        -- accept = { auto_brackets = { enabled = true } }

        -- experimental signature help support
        -- trigger = { signature_help = { enabled = true } }
      },
      -- allows extending the enabled_providers array elsewhere in your config
      -- without having to redefine it
      opts_extend = { "sources.completion.enabled_providers" }
    },

    -- LSP servers and clients communicate what features they support through "capabilities".
    --  By default, Neovim support a subset of the LSP specification.
    --  With blink.cmp, Neovim has *more* capabilities which are communicated to the LSP servers.
    --  Explanation from TJ: https://youtu.be/m8C0Cq9Uv9o?t=1275
    --
    -- This can vary by config, but in general for nvim-lspconfig:

    -- {
    --   'neovim/nvim-lspconfig',
    --   dependencies = { 'saghen/blink.cmp' },
    --   config = function(_, opts)
    --     local lspconfig = require('lspconfig')
    --     for server, config in pairs(opts.servers or {}) do
    --       config.capabilities = require('blink.cmp').get_lsp_capabilities(config.capabilities)
    --       lspconfig[server].setup(config)
    --     end
    --   end
    -- }
  },
})
