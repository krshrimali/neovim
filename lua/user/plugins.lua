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

vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Install your plugins here
require("lazy").setup {
    -- Lua Development
    -- "nvim-lua/plenary.nvim", -- Useful lua functions used ny lots of plugins
    -- "nvim-lua/popup.nvim",
    -- "folke/neodev.nvim",
    -- "j-hui/fidget.nvim",
    -- {
    --     "mrcjkb/rustaceanvim",
    --     version = "^4", -- Recommended
    --     ft = { "rust" },
    -- },
    -- { "rust-lang/rust.vim" },

    -- LSP
    {
        "neovim/nvim-lspconfig",
    },

    "ray-x/lsp_signature.nvim",
    "github/copilot.vim",

    -- Highlight words under cursor
    "RRethy/vim-illuminate",

    -- Check if vim.lsp provides this now...
    "https://git.sr.ht/~whynothugo/lsp_lines.nvim",

    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    -- For commenting (uses Treesitter to comment properly)
    "JoosepAlviste/nvim-ts-context-commentstring",

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
        dependencies = {
            { "nvim-telescope/telescope-live-grep-args.nvim" },
        },
        config = function()
            require("telescope").load_extension "live_grep_args"
            -- require("telescope").load_extension("noice")
        end,
    },
    { "decaycs/decay.nvim",                  as = "decay" },
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
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {
            "nvim-tree/nvim-web-devicons", -- optional
        },
    },
    -- "tamago324/lir.nvim"

    -- Comment
    "numToStr/Comment.nvim",
    "folke/todo-comments.nvim",

    -- Terminal
    "akinsho/toggleterm.nvim",

    "nvim-pack/nvim-spectre",
    "kevinhwang91/nvim-bqf",

    "lewis6991/gitsigns.nvim",
    "folke/which-key.nvim",

    -- THEMES
    "krshrimali/vim-moonfly-colors", -- personalized, this one is very dark :D
    "navarasu/onedark.nvim",
    "ellisonleao/gruvbox.nvim",
    "sainnhe/gruvbox-material",
    "Shadorain/shadotheme",
    "nyoom-engineering/oxocarbon.nvim",
    "projekt0n/github-nvim-theme",

    -- Peek numbers
    "nacro90/numb.nvim",
    -- File Explorer
    "stevearc/oil.nvim",

    "jonarrien/telescope-cmdline.nvim",
    {
        "hedyhli/outline.nvim",
        config = function()
            -- Example mapping to toggle outline
            vim.keymap.set("n", "<leader>lo", "<cmd>Outline<CR>", { desc = "Toggle Outline" })

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
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    },
    {
        "fgheng/winbar.nvim",
    },
    {
        "nvimdev/lspsaga.nvim",
        config = function() require("lspsaga").setup {} end,
        dependencies = {
            "nvim-treesitter/nvim-treesitter", -- optional
            "nvim-tree/nvim-web-devicons",     -- optional
        },
    },
    {
        "nvim-telescope/telescope-frecency.nvim",
        config = function() require("telescope").load_extension "frecency" end,
    },
    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "canary",
        dependencies = {
            { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
            { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
        },
        build = "make tiktoken",          -- Only on MacOS or Linux
        opts = {
            debug = true,                 -- Enable debugging
            -- See Configuration section for rest
        },
        -- See Commands section for default commands if you want to lazy load on them
    },
    -- {
    --     'neoclide/coc.nvim',
    --     branch = 'release',
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
    }

    -- TEST later
    -- "kylechui/nvim-surround",
    -- "windwp/nvim-autopairs",
}
