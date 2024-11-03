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
  "nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
  "nvim-lua/popup.nvim",
  "folke/neodev.nvim",
  "j-hui/fidget.nvim",
  -- {
  --   'mrcjkb/rustaceanvim',
  --   version = '^4', -- Recommended
  --   ft = { 'rust' },
  -- },
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

  "ray-x/lsp_signature.nvim",
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

  "nvimtools/none-ls.nvim",

  "RRethy/vim-illuminate",
  "lvimuser/lsp-inlayhints.nvim",

  "https://git.sr.ht/~whynothugo/lsp_lines.nvim",

  -- Completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-buffer",       -- buffer completions
  "hrsh7th/cmp-path",         -- path completions
  "hrsh7th/cmp-cmdline",      -- cmdline completions
  "saadparwaiz1/cmp_luasnip", -- snippet completions
  "hrsh7th/cmp-nvim-lsp",
  "hrsh7th/cmp-emoji",
  "hrsh7th/cmp-nvim-lua",

  "L3MON4D3/LuaSnip",             --snippet engine
  "rafamadriz/friendly-snippets", -- a bunch of snippets to use

  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
  "JoosepAlviste/nvim-ts-context-commentstring",
  "windwp/nvim-ts-autotag",
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
      -- require("telescope").load_extension("noice")
    end,
  },
  { "decaycs/decay.nvim",    as = "decay" },
  "lunarvim/darkplus.nvim",
  "folke/tokyonight.nvim",
  {
    "uloco/bluloco.nvim",
    dependencies = { "rktjmp/lush.nvim" },
  },
  "rcarriga/nvim-notify",
  "stevearc/dressing.nvim",
  "ghillb/cybu.nvim",

  -- Registers
  "tversteeg/registers.nvim",

  "kyazdani42/nvim-web-devicons",

  "akinsho/bufferline.nvim",
  "nvim-lualine/lualine.nvim",
  {
    "goolord/alpha-nvim",
  },

  -- Indent
  -- { "lukas-reineke/indent-blankline.nvim", main = "ibl",                                                               opts = {} },

  -- File Explorer
  -- "kyazdani42/nvim-tree.lua"

  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- optional
    },
    -- config = function()
    --   require("nvim-tree").setup({})
    -- end,
  },
  -- "tamago324/lir.nvim"

  -- Comment
  "numToStr/Comment.nvim",
  "folke/todo-comments.nvim",

  -- Terminal
  "akinsho/toggleterm.nvim",

  -- My own plugins
  -- "krshrimali/nvim-autorunner",

  "nvim-pack/nvim-spectre",
  "kevinhwang91/nvim-bqf",

  "lewis6991/gitsigns.nvim",
  "f-person/git-blame.nvim",
  "windwp/nvim-autopairs",
  -- "karb94/neoscroll.nvim",
  "folke/which-key.nvim",

  "krshrimali/vim-moonfly-colors", -- personalized, this one is very dark :D
  "navarasu/onedark.nvim",
  "ellisonleao/gruvbox.nvim",
  "sainnhe/gruvbox-material",
  "Shadorain/shadotheme",
  "nyoom-engineering/oxocarbon.nvim",
  "projekt0n/github-nvim-theme",

  -- clip
  {
    "AckslD/nvim-neoclip.lua",
    dependencies = {
      { "kkharji/sqlite.lua",           module = "sqlite" },
      { "nvim-telescope/telescope.nvim" },
    },
  },

  { "kevinhwang91/nvim-ufo", dependencies = { "kevinhwang91/promise-async", "luukvbaal/statuscol.nvim" } },


  {
    -- "linrongbin16/gitlinker.nvim",
    dir = "/u/shrimali/gitlinker.nvim",
    -- config = function()
    --   require("gitlinker").setup()
    -- end,
  },

  "nacro90/numb.nvim",
  "MunifTanjim/nui.nvim",
  "stevearc/oil.nvim",

  "jonarrien/telescope-cmdline.nvim",


  -- {
  --   "folke/noice.nvim",
  --   dependencies = {
  --     "MunifTanjim/nui.nvim",
  --     "rcarriga/nvim-notify",
  --   }
  -- },

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
  "LunarVim/bigfile.nvim",
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
  -- {
  --     "neovim/nvim-lspconfig", -- REQUIRED: for native Neovim LSP integration
  --     lazy = false,            -- REQUIRED: tell lazy.nvim to start this plugin at startup
  --     dependencies = {
  --         -- main one
  --         { "ms-jpq/coq_nvim",       branch = "coq" },

  --         -- 9000+ Snippets
  --         { "ms-jpq/coq.artifacts",  branch = "artifacts" },

  --         -- lua & third party sources -- See https://github.com/ms-jpq/coq.thirdparty
  --         -- Need to **configure separately**
  --         { 'ms-jpq/coq.thirdparty', branch = "3p" }
  --         -- - shell repl
  --         -- - nvim lua api
  --         -- - scientific calculator
  --         -- - comment banner
  --         -- - etc
  --     },
  --     init = function()
  --         vim.g.coq_settings = {
  --             auto_start = true, -- if you want to start COQ at startup
  --             display = {
  --                 icons = {
  --                     mode = "none"
  --                 }
  --             },
  --             -- Your COQ settings here
  --         }
  --     end,
  --     config = function()
  --         -- Your LSP settings here
  --     end,
  -- },
  {
    "microsoft/python-type-stubs",
    cond = false,
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
  },
  {
    "0xstepit/flow.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
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
    'nvimdev/lspsaga.nvim',
    config = function()
      require('lspsaga').setup({})
    end,
    dependencies = {
      'nvim-treesitter/nvim-treesitter', -- optional
      'nvim-tree/nvim-web-devicons',     -- optional
    }
  },
  -- {
  --   'neoclide/coc.nvim', branch = 'release'
  -- },
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
  }
  -- {
  --   "nvimdev/guard.nvim",
  --   -- Builtin configuration, optional
  --   dependencies = {
  --     "nvimdev/guard-collection",
  --   },
  -- }
})
