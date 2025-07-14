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
    { "decaycs/decay.nvim",              as = "decay" },
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
    -- {
    --     "goolord/alpha-nvim",
    -- },

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
    -- {
    --     "nvimdev/lspsaga.nvim",
    --     config = function() require("lspsaga").setup {
    --     } end,
    --     dependencies = {
    --         "nvim-treesitter/nvim-treesitter", -- optional
    --         "nvim-tree/nvim-web-devicons",     -- optional
    --     },
    -- },
    {
        "nvim-telescope/telescope-frecency.nvim",
        config = function() require("telescope").load_extension "frecency" end,
    },
    -- {
    --     "CopilotC-Nvim/CopilotChat.nvim",
    --     dependencies = {
    --         { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
    --         { "nvim-lua/plenary.nvim" },  -- for curl, log wrapper
    --     },
    --     build = "make tiktoken",          -- Only on MacOS or Linux
    --     opts = {
    --         debug = true,                 -- Enable debugging
    --         -- See Configuration section for rest
    --     },
    --     -- See Commands section for default commands if you want to lazy load on them
    -- },
    -- -- {
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
    },
    {
        "Saghen/blink.cmp",
        -- optional: provides snippets for the snippet source
        dependencies = { 'rafamadriz/friendly-snippets' },

        -- use a release tag to download pre-built binaries
        version = '1.*',
        -- AND/OR build from source, requires nightly: https://rust-lang.github.io/rustup/concepts/channels.html#working-with-nightly-rust
        -- build = 'cargo build --release',
        -- If you use nix, you can build from source using latest nightly rust with:
        -- build = 'nix run .#build-plugin',

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = { preset = 'enter',
                -- ["<Tab>"] = {
                --     function(cmp)
                --         if vim.b[vim.api.nvim_get_current_buf()].nes_state then
                --             cmp.hide()
                --             return (
                --                 require("copilot-lsp.nes").apply_pending_nes()
                --                 and require("copilot-lsp.nes").walk_cursor_start_edit()
                --             )
                --         end
                --         if cmp.snippet_active() then
                --             return cmp.accept()
                --         else
                --             return cmp.select_and_accept()
                --         end
                --     end,
                --     "snippet_forward",
                --     "fallback",
                -- },
            },
            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono'
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = { documentation = { auto_show = true } },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"` or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = "prefer_rust_with_warning" }
        },
        opts_extend = { "sources.default" }
    },
    { "SmiteshP/nvim-navic" },
    -- {
    --     "copilotlsp-nvim/copilot-lsp",
    --     init = function()
    --         vim.g.copilot_nes_debounce = 500
    --         vim.lsp.enable("copilot_ls")
    --         vim.keymap.set("n", "<C-p>", function()
    --             -- Try to jump to the start of the suggestion edit.
    --             -- If already at the start, then apply the pending suggestion and jump to the end of the edit.
    --             local _ = require("copilot-lsp.nes").walk_cursor_start_edit()
    --                 or (
    --                     require("copilot-lsp.nes").apply_pending_nes() and require("copilot-lsp.nes").walk_cursor_end_edit()
    --                 )
    --         end)
    --     end
    -- },
    {
        "mason-org/mason.nvim",
    },
    {
        "coffebar/neovim-project",
        opts = {
            projects = { -- define project roots
                "~/Documents/*",
                "~/.config/*",
                "~/RustroverProjects/*",
                "~/CLionProjects/*",
            },
            picker = {
                type = "telescope", -- one of "telescope", "fzf-lua", or "snacks"
            }
        },
        init = function()
            -- enable saving the state of plugins in the session
            vim.opt.sessionoptions:append("globals") -- save global variables that start with an uppercase letter and contain at least one lowercase letter.
        end,
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            -- optional picker
            { "nvim-telescope/telescope.nvim" },
            -- optional picker
            { "ibhagwan/fzf-lua" },
            -- optional picker
            { "folke/snacks.nvim" },
            { "Shatur/neovim-session-manager" },
        },
        lazy = false,
        priority = 100,
    },
    {
        "mason-org/mason-lspconfig.nvim",
        opts = {},
        dependencies = {
            { "mason-org/mason.nvim", opts = {} },
            "neovim/nvim-lspconfig",
        },
    },
    {
        "https://github.deshaw.com/genai/vim-ai",
        tag = 'v0.0.1',
    },
    {
        "krshrimali/nvim-utils",
        config = function()
            require("tgkrsutil").setup({
                enable_test_runner = true,
                test_runner = function(file, func)
                    return string.format("despytest %s -k %s", file, func)
                end,
            })
        end,
        event = "VeryLazy",
    },
    {
        "krshrimali/context-pilot.nvim",
        dependencies = {
            "nvim-telescope/telescope.nvim",
            "nvim-telescope/telescope-fzy-native.nvim"
        },
        config = function()
            require("contextpilot")
        end
    },
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        event = "BufEnter",
        config = true, -- necessary
    },
    {
        "TabbyML/vim-tabby",
        lazy = false,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        init = function()
            vim.g.tabby_agent_start_command = { "npx", "tabby-agent", "--stdio" }
            vim.g.tabby_inline_completion_trigger = "auto"
        end,
    },
    {
        "f-person/git-blame.nvim",
        event = "VeryLazy",
        opts = {
            enabled = true,
            virtual_text_column = 1
        },
    },
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            explorer = { enabled = false },
            indent = { enabled = false },
            input = { enabled = false },
            picker = { enabled = false },
            notifier = { enabled = true },
            quickfile = { enabled = false },
            scope = { enabled = false },
            scroll = { enabled = false },
            statuscolumn = { enabled = true },
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
            }
        },
        keys = {
            { "<leader>gY", function() Snacks.gitbrowse() end, desc = "Git Browse", mode = { "n", "v" } },
        }
    },


    -- TEST later
    -- "kylechui/nvim-surround",
    -- "windwp/nvim-autopairs",
}
