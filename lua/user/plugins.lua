local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath "data" .. "/site/pack/packer/start/packer.nvim"
---@diagnostic disable-next-line: missing-parameter
if fn.empty(fn.glob(install_path)) > 0 then
  PACKER_BOOTSTRAP = fn.system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    install_path,
  }
  print "Installing packer close and reopen Neovim..."
  vim.cmd [[packadd packer.nvim]]
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd [[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]]

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
  return
end

-- Have packer use a popup window
packer.init {
  -- snapshot = "july-24",
  snapshot_path = fn.stdpath "config" .. "/snapshots",
  max_jobs = 50,
  display = {
    open_fn = function()
      return require("packer.util").float { border = "rounded" }
    end,
    prompt_border = "rounded", -- Border style of prompt popups.
  },
}

-- Install your plugins here
return packer.startup(function(use)
  -- Plugin Mangager
  use "wbthomason/packer.nvim" -- Have packer manage itself

  -- Lua Development
  use "nvim-lua/plenary.nvim" -- Useful lua functions used ny lots of plugins
  use "nvim-lua/popup.nvim"
  use "christianchiarulli/lua-dev.nvim"
  -- use "folke/lua-dev.nvim"
  use "j-hui/fidget.nvim"

  use {
    "Wansmer/treesj",
    requires = { "nvim-treesitter" },
    config = function()
      require("treesj").setup {--[[ your config ]]
      }
    end,
  }

  -- LSP
  use "neovim/nvim-lspconfig" -- enable LSP
  -- use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"
  use "jose-elias-alvarez/null-ls.nvim" -- for formatters and linters
  use "ray-x/lsp_signature.nvim"
  use "SmiteshP/nvim-navic"
  use "simrat39/symbols-outline.nvim"
  use "b0o/SchemaStore.nvim"
  -- bringing it back
  use "folke/trouble.nvim"

  use {
    "zbirenbaum/copilot-cmp",
    after = { "copilot.lua" },
    config = function()
      require("copilot_cmp").setup()
    end,
  }
  use {
    "zbirenbaum/copilot.lua",
    event = { "VimEnter" },
    config = function()
      vim.defer_fn(function()
        require "user.copilot"
      end, 100)
    end,
  }

  use "RRethy/vim-illuminate"
  use "lvimuser/lsp-inlayhints.nvim"
  -- use "simrat39/inlay-hints.nvim"
  use "https://git.sr.ht/~whynothugo/lsp_lines.nvim"

  -- Completion
  use "hrsh7th/nvim-cmp"
  use "hrsh7th/cmp-buffer" -- buffer completions
  use "hrsh7th/cmp-path" -- path completions
  use "hrsh7th/cmp-cmdline" -- cmdline completions
  use "saadparwaiz1/cmp_luasnip" -- snippet completions
  use "hrsh7th/cmp-nvim-lsp"
  use "hrsh7th/cmp-emoji"
  use "hrsh7th/cmp-nvim-lua"
  -- use "zbirenbaum/copilot-cmp"
  -- use { "tzachar/cmp-tabnine", commit = "1a8fd2795e4317fd564da269cc64a2fa17ee854e", run = "./install.sh" }

  -- Snippet
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- Syntax/Treesitter
  use "nvim-treesitter/nvim-treesitter"
  use "JoosepAlviste/nvim-ts-context-commentstring"
  use "p00f/nvim-ts-rainbow"
  use "nvim-treesitter/playground"
  use "windwp/nvim-ts-autotag"
  use "nvim-treesitter/nvim-treesitter-textobjects"
  -- use "wellle/targets.vim"
  -- use "RRethy/nvim-treesitter-textsubjects"
  use {
    "kylechui/nvim-surround",
    -- tag = "*", -- Use for stability; omit to use `main` branch for the latest features
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  }
  -- use {
  --   "abecodes/tabout.nvim",
  --   wants = { "nvim-treesitter" }, -- or require if not used so far
  -- }

  -- Marks
  use "krshrimali/harpoon"
  -- use "ThePrimeagen/harpoon"
  -- use "MattesGroeger/vim-bookmarks"
  use {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim", -- optional
    },
    config = true,
  }
  -- use { "krshrimali/nvim-transparent", branch = "fix/highlight-search" }
  use { "xiyaowong/transparent.nvim" }
  -- use "petertriho/nvim-scrollbar"
  -- use "rmagatti/goto-preview"
  use {
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup {}
    end,
  }
  use {
    "mawkler/modicator.nvim",
    after = "bluloco.nvim", -- Add your colorscheme plugin here
    setup = function()
      -- These are required for Modicator to work
      vim.o.cursorline = true
      vim.o.number = true
      vim.o.termguicolors = true
    end,
    config = function()
      require("modicator").setup {}
    end,
  }
  use { "chrisgrieser/nvim-spider" }
  use {
    "mrjones2014/legendary.nvim",
    -- sqlite is only needed if you want to use frecency sorting
    requires = "kkharji/sqlite.lua",
  }

  use "mbbill/undotree"

  -- Fuzzy Finder/Telescope
  -- use "nvim-telescope/telescope.nvim"
  use "nvim-telescope/telescope-media-files.nvim"
  -- use "tom-anders/telescope-vim-bookmarks.nvim"
  use {
    "nvim-telescope/telescope.nvim",
    requires = {
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      require("telescope").load_extension "live_grep_args"
    end,
  }
  use {
    "aaronhallaert/advanced-git-search.nvim",
    config = function()
      require("telescope").load_extension "advanced_git_search"
    end,
    requires = {
      "nvim-telescope/telescope.nvim",
      -- to show diff splits and open commits in browser
      "tpope/vim-fugitive",
    },
  }

  -- Color
  use "NvChad/nvim-colorizer.lua"
  -- use "ziontee113/color-picker.nvim"
  use "nvim-colortils/colortils.nvim"

  -- Colorschemes
  -- use "lunarvim/onedarker.nvim"
  use { "decaycs/decay.nvim", as = "decay" }
  use "lunarvim/darkplus.nvim"
  use "folke/tokyonight.nvim"
  use {
    "uloco/bluloco.nvim",
    requires = { "rktjmp/lush.nvim" },
  }
  -- use "lunarvim/colorschemes"

  -- Utility
  use "rcarriga/nvim-notify"
  use "stevearc/dressing.nvim"
  use "ghillb/cybu.nvim"
  -- use "lalitmee/browse.nvim"

  -- Registers
  use "tversteeg/registers.nvim"

  -- Icon
  use "kyazdani42/nvim-web-devicons"

  -- Debugging
  use "mfussenegger/nvim-dap"
  use "rcarriga/nvim-dap-ui"

  use "mfussenegger/nvim-dap-python"
  -- use "theHamsta/nvim-dap-virtual-text"
  -- use "Pocco81/DAPInstall.nvim"

  use "akinsho/bufferline.nvim"
  -- use "tiagovla/scope.nvim"

  -- Statusline
  use "nvim-lualine/lualine.nvim"
  --[[ use "freddiehaddad/feline.nvim" ]]

  -- Startup
  use {
    "goolord/alpha-nvim",
    config = function()
      require("alpha").setup(require("alpha.themes.dashboard").config)
    end,
  }

  -- Indent
  use "lukas-reineke/indent-blankline.nvim"

  -- File Explorer
  -- use "kyazdani42/nvim-tree.lua"

  use {
    "nvim-tree/nvim-tree.lua",
    requires = {
      "nvim-tree/nvim-web-devicons", -- optional
    },
    -- config = function()
    --   require("nvim-tree").setup({})
    -- end,
  }
  use "tamago324/lir.nvim"

  -- Comment
  use "numToStr/Comment.nvim"
  use "folke/todo-comments.nvim"

  -- Terminal
  use "akinsho/toggleterm.nvim"

  -- My own plugins
  use "krshrimali/nvim-autorunner"

  -- use 'echasnovski/mini.nvim'
  use "echasnovski/mini.bracketed"

  -- Project
  -- Note: https://github.com/ahmedkhalf/project.nvim - Look at the options here if the auto change of cwd irritates me
  use {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup {
        -- manual_mode = true,
        -- respect_buf_cwd = true,
        -- update_cwd = true,
        -- update_focused_file = {
        --   enable = true,
        --   update_cwd = true
        -- },
      }
    end,
  }
  use "nvim-pack/nvim-spectre"

  -- Session
  use "rmagatti/auto-session"
  use "rmagatti/session-lens"

  -- Quickfix
  use "kevinhwang91/nvim-bqf"

  -- use {
  --   "0x100101/lab.nvim",
  --   run = "cd js && npm ci",
  -- }

  -- Git
  use "lewis6991/gitsigns.nvim"
  use "f-person/git-blame.nvim"
  -- use "ruifm/gitlinker.nvim"
  use "mattn/vim-gist"
  use "mattn/webapi-vim"

  -- Github
  use "pwntester/octo.nvim"

  -- Editing Support
  use "windwp/nvim-autopairs"
  use "monaqa/dial.nvim"
  use "andymass/vim-matchup"
  use "folke/zen-mode.nvim"
  -- use "Pocco81/true-zen.nvim"
  use "karb94/neoscroll.nvim"
  use "junegunn/vim-slash"

  -- Motion
  use "phaazon/hop.nvim"
  -- use "jinh0/eyeliner.nvim"

  -- Keybinding
  use "folke/which-key.nvim"

  -- Java
  use "mfussenegger/nvim-jdtls"

  -- Rust
  -- use { "christianchiarulli/rust-tools.nvim", branch = "modularize_and_inlay_rewrite" }
  use "simrat39/rust-tools.nvim"
  use "Saecki/crates.nvim"

  -- Typescript TODO: set this up, also add keybinds to ftplugin
  use "jose-elias-alvarez/typescript.nvim"

  -- Markdown
  use {
    "iamcco/markdown-preview.nvim",
    run = "cd app && npm install",
    setup = function()
      vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = "markdown",
  }

  -- Theme
  -- use { "bluz71/vim-moonfly-colors" }
  use { "krshrimali/vim-moonfly-colors" } -- personalized, this one is very dark :D
  use { "navarasu/onedark.nvim" }
  use { "ellisonleao/gruvbox.nvim" }
  use { "sainnhe/gruvbox-material" }
  use { "Shadorain/shadotheme" }
  use { "catppuccin/nvim", as = "catppuccin" }
  use { "nyoom-engineering/oxocarbon.nvim" }
  use { "projekt0n/github-nvim-theme" }

  -- clip
  use {
    "AckslD/nvim-neoclip.lua",
    requires = {
      { "kkharji/sqlite.lua", module = "sqlite" },
      { "nvim-telescope/telescope.nvim" },
    },
    config = function()
      require("neoclip").setup()
    end,
  }

  -- Graveyard
  -- use "romgrk/nvim-treesitter-context"
  -- use "mizlan/iswap.nvim"
  -- use {'christianchiarulli/nvim-ts-rainbow'}
  -- use "nvim-telescope/telescope-ui-select.nvim"
  -- use "nvim-telescope/telescope-file-browser.nvim"
  -- use 'David-Kunz/cmp-npm' -- doesn't seem to work
  -- use { "christianchiarulli/JABS.nvim" }
  -- use "lunarvim/vim-solidity"
  -- use "tpope/vim-repeat"
  -- use "Shatur/neovim-session-manager"
  -- use "metakirby5/codi.vim"
  -- use { "nyngwang/NeoZoom.lua", branch = "neo-zoom-original" }
  -- use "rcarriga/cmp-dap"
  -- use "filipdutescu/renamer.nvim"
  -- use "https://github.com/rhysd/conflict-marker.vim"
  -- use "rebelot/kanagawa.nvim"
  -- use "unblevable/quick-scope"
  -- use "tamago324/nlsp-settings.nvim" -- language server settings defined in json for
  -- use "gbprod/cutlass.nvim"
  -- use "christianchiarulli/lsp-inlay-hints"
  -- use "rmagatti/goto-preview"
  -- use "stevearc/aerial.nvim"
  -- use "nvim-lua/lsp_extensions.nvim"
  -- use { "christianchiarulli/nvim-gps", branch = "text_hl" }
  -- use "stevearc/stickybuf.nvim"
  -- use "drybalka/tree-climber.nvim"
  -- use "phaazon/hop.nvim"
  use { "michaelb/sniprun", run = "bash ./install.sh" }
  use { "numToStr/Navigator.nvim" }
  use {
    "cbochs/portal.nvim",
    -- Optional dependencies
    requires = {
      "cbochs/grapple.nvim",
      "ThePrimeagen/harpoon",
    },
  }

  -- folding
  -- use {
  --   "anuvyklack/pretty-fold.nvim",
  --   config = function()
  --     require("pretty-fold").setup {}
  --   end,
  -- }

  use { "kevinhwang91/nvim-ufo", requires = "kevinhwang91/promise-async" }

  use {
    "anuvyklack/fold-preview.nvim",
    requires = "anuvyklack/keymap-amend.nvim",
    config = function()
      require("fold-preview").setup {
        -- Your configuration goes here.
      }
    end,
  }

  use {
    "krshrimali/context-pilot.nvim",
    requires = {
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
    },
  }

  -- nvim v0.7.2
  -- use({
  --     "kdheepak/lazygit.nvim",
  --     -- optional for floating window border decoration
  --     requires = {
  --         "nvim-lua/plenary.nvim",
  --     },
  -- })

  -- nvim v0.7.2
  use {
    "kdheepak/lazygit.nvim",
    requires = {
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    config = function()
      require("telescope").load_extension "lazygit"
    end,
  }

  use {
    "ruifm/gitlinker.nvim",
    requires = "nvim-lua/plenary.nvim",
    config = function()
      require("gitlinker").setup()
    end,
  }

  -- use {
  --   "folke/flash.nvim",
  --   config = function()
  --     require("flash").setup({})
  --   end,
  -- }
  use {
    "nvim-treesitter/nvim-treesitter-context",
  }

  use "nacro90/numb.nvim"

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
