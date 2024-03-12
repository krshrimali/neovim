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
  -- use "christianchiarulli/lua-dev.nvim"
  use "folke/neodev.nvim"
  use "j-hui/fidget.nvim"

  -- LSP
  use "neovim/nvim-lspconfig" -- enable LSP
  -- use "williamboman/nvim-lsp-installer" -- simple to use language server installer
  use "williamboman/mason.nvim"
  use "williamboman/mason-lspconfig.nvim"

  use "ray-x/lsp_signature.nvim"
  use "SmiteshP/nvim-navic"

  -- TODO: Remove this as it's archived by the author and not actively maintained anymore
  -- use "simrat39/symbols-outline.nvim"
  use {
    "stevearc/aerial.nvim",
    config = function()
      require("aerial").setup()
    end,
  }
  use "b0o/SchemaStore.nvim"
  -- bringing it back
  use "folke/trouble.nvim"
  use "github/copilot.vim"

  use "nvimtools/none-ls.nvim"

  use "RRethy/vim-illuminate"
  use "lvimuser/lsp-inlayhints.nvim"

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

  -- Snippet
  use "L3MON4D3/LuaSnip" --snippet engine
  use "rafamadriz/friendly-snippets" -- a bunch of snippets to use

  -- Syntax/Treesitter
  use { "nvim-treesitter/nvim-treesitter", run = ":TSUpdate" }
  use "JoosepAlviste/nvim-ts-context-commentstring"
  use "windwp/nvim-ts-autotag"
  use {
    "kylechui/nvim-surround",
    -- tag = "*", -- Use for stability; omit to use `main` branch for the latest features
  }

  use {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "nvim-telescope/telescope.nvim", -- optional
      "sindrets/diffview.nvim", -- optional
    },
    config = true,
  }
  use { "xiyaowong/transparent.nvim" }
  use {
    "rmagatti/goto-preview",
  }

  use { "chrisgrieser/nvim-spider" }

  use {
    "nvim-telescope/telescope.nvim",
    requires = {
      { "nvim-telescope/telescope-live-grep-args.nvim" },
    },
    config = function()
      require("telescope").load_extension "live_grep_args"
      require("telescope").load_extension("noice")
    end,
  }

  -- Colorschemes
  use { "decaycs/decay.nvim", as = "decay" }
  use "lunarvim/darkplus.nvim"
  use "folke/tokyonight.nvim"
  use {
    "uloco/bluloco.nvim",
    requires = { "rktjmp/lush.nvim" },
  }

  -- Utility
  use "rcarriga/nvim-notify"
  use "stevearc/dressing.nvim"
  use "ghillb/cybu.nvim"

  -- Registers
  use "tversteeg/registers.nvim"

  -- Icon
  use "kyazdani42/nvim-web-devicons"

  use "akinsho/bufferline.nvim"

  -- Statusline
  use "nvim-lualine/lualine.nvim"

  -- Startup
  use {
    "goolord/alpha-nvim",
  }

  -- Indent
  use { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} }

  use {
    "nvim-tree/nvim-tree.lua",
    requires = {
      "nvim-tree/nvim-web-devicons", -- optional
    },
  }
  -- use "tamago324/lir.nvim"

  -- Comment
  use "numToStr/Comment.nvim"
  use "folke/todo-comments.nvim"

  -- Terminal
  use "akinsho/toggleterm.nvim"

  -- My own plugins
  use "krshrimali/nvim-autorunner"

  use "nvim-pack/nvim-spectre"
  use "kevinhwang91/nvim-bqf"

  -- Git
  use "lewis6991/gitsigns.nvim"
  use "f-person/git-blame.nvim"

  -- Editing Support
  use "windwp/nvim-autopairs"
  use "karb94/neoscroll.nvim"

  use "folke/which-key.nvim"

  use "simrat39/rust-tools.nvim"
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
  }

  use { "kevinhwang91/nvim-ufo", requires = { "kevinhwang91/promise-async", "luukvbaal/statuscol.nvim" } }

  use {
    -- pass local path of the plugin instead of git path
    -- "/home/krshrimali/Documents/Projects-Live-Stream/context-pilot.nvim",
    "krshrimali/context-pilot.nvim",
    -- branch = "backend/upgrade",
    requires = {
      "nvim-telescope/telescope.nvim",
      "nvim-telescope/telescope-fzy-native.nvim",
    },
  }

  use {
    "linrongbin16/gitlinker.nvim",
    config = function()
      require("gitlinker").setup()
    end,
  }

  use "nacro90/numb.nvim"
  use "MunifTanjim/nui.nvim"
  use "stevearc/oil.nvim"

  -- use "junegunn/gv.vim"
  use "jonarrien/telescope-cmdline.nvim"

  use {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    }
  }

  use {
    "princejoogie/dir-telescope.nvim",
    -- telescope.nvim is a required dependency
    requires = {"nvim-telescope/telescope.nvim"},
    config = function()
      require("dir-telescope").setup({
        -- these are the default options set
        hidden = true,
        no_ignore = false,
        show_preview = true,
      })
    end,
  }

  -- Automatically set up your configuration after cloning packer.nvim
  -- Put this at the end after all plugins
  if PACKER_BOOTSTRAP then
    require("packer").sync()
  end
end)
