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

-- ⚡ ULTRA-OPTIMIZED PLUGIN LOADING
-- Smart conditions for even better performance
local function is_large_file(buf)
    buf = buf or 0
    local max_filesize = 50 * 1024 -- 50KB
    local filename = vim.api.nvim_buf_get_name(buf)
    if filename == "" then return false end
    
    local ok, stats = pcall(vim.loop.fs_stat, filename)
    return ok and stats and stats.size > max_filesize
end

local function should_load_lsp()
    -- Only load LSP for programming files
    local ft = vim.bo.filetype
    local programming_fts = {
        "lua", "python", "javascript", "typescript", "rust", "go", 
        "c", "cpp", "java", "php", "ruby", "vim", "sh", "zsh", "bash"
    }
    return vim.tbl_contains(programming_fts, ft)
end

-- Install your plugins here
-- Ensure at least one plugin is always loaded to prevent lazy.nvim warnings
require("lazy").setup {
    -- Essential plugin that's always loaded
    {
        "nvim-lua/plenary.nvim",
        lazy = false,
        priority = 1000,
    },

    -- COC.nvim for LSP and completion - ULTRA LAZY LOAD
    {
        'neoclide/coc.nvim',
        branch = 'release',
        event = { "BufReadPost", "BufNewFile" }, -- Changed from BufReadPre for faster startup
        cond = function()
            return not is_large_file() and should_load_lsp()
        end,
        config = function()
            -- Load COC configuration with proper error handling
            vim.defer_fn(function()
                local ok, err = pcall(require, "user.coc")
                if not ok then
                    vim.notify("Failed to load COC config: " .. tostring(err), vim.log.levels.WARN)
                end
            end, 2000) -- Increased delay
        end
    },

    -- Highlight words under cursor - SMART LAZY LOAD
    {
        "RRethy/vim-illuminate",
        event = { "CursorMoved", "CursorMovedI" }, -- Only load when cursor moves
        cond = function()
            return not is_large_file()
        end,
        config = function()
            require("user.illuminate")
        end
    },

    -- Treesitter - CONDITIONAL LAZY LOAD
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        cond = function()
            return not is_large_file() and should_load_lsp()
        end,
        config = function()
            require("user.treesitter")
        end
    },

    -- Git integration - ULTRA LAZY LOAD
    {
        "NeogitOrg/neogit",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "ibhagwan/fzf-lua",
            "sindrets/diffview.nvim",
        },
        cmd = "Neogit",
        keys = { "<leader>gg" },
        cond = function()
            -- Only load in git repositories
            return vim.fn.isdirectory(".git") == 1
        end,
        config = true,
    },

    -- Transparency - IMMEDIATE LOAD (Essential UI)
    {
        "xiyaowong/transparent.nvim",
        priority = 900, -- High priority for UI consistency
    },

    -- Goto preview - ULTRA SMART LAZY LOAD
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        keys = {
            { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>" },
            { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>" },
            { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>" },
            { "gP",  "<cmd>lua require('goto-preview').close_all_win()<CR>" },
        },
        cond = should_load_lsp,
        config = true,
    },

    -- Spider movement - IMMEDIATE KEYS LOAD
    {
        "chrisgrieser/nvim-spider",
        keys = {
            { "w", function()
                local ok, spider = pcall(require, 'spider')
                if ok then
                    spider.motion('w')
                else
                    vim.cmd('normal! w')
                end
            end, mode = { "n", "o", "x" } },
            { "e", function()
                local ok, spider = pcall(require, 'spider')
                if ok then
                    spider.motion('e')
                else
                    vim.cmd('normal! e')
                end
            end, mode = { "n", "o", "x" } },
            { "b", function()
                local ok, spider = pcall(require, 'spider')
                if ok then
                    spider.motion('b')
                else
                    vim.cmd('normal! b')
                end
            end, mode = { "n", "o", "x" } },
        }
    },

    -- FZF-Lua - OPTIMIZED LAZY LOAD
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
            -- Use fast config for better performance
            require("user.fzf-lua-fast")
        end,
    },

    -- THEMES - Ultra minimal set, smart loading
    { 
        "decaycs/decay.nvim", 
        name = "decay",
        lazy = false, -- Keep one theme always available
        priority = 1000,
    },
    { "lunarvim/darkplus.nvim", lazy = true },
    { "folke/tokyonight.nvim", lazy = true },
    {
        "uloco/bluloco.nvim",
        dependencies = { "rktjmp/lush.nvim" },
        lazy = true,
    },

    -- UI Components - SMART IMMEDIATE LOADING
    {
        "rcarriga/nvim-notify",
        priority = 800,
        config = function()
            require("user.notify")
        end
    },

    {
        "stevearc/dressing.nvim",
        priority = 800,
        config = function()
            require("user.dressing")
        end
    },

    -- Buffer navigation - VERY LAZY LOAD
    {
        "ghillb/cybu.nvim",
        branch = "main",
        event = "VeryLazy", -- Even more lazy
        config = function()
            require("user.cybu")
        end
    },

    -- Registers - KEYS ONLY LOAD
    {
        "tversteeg/registers.nvim",
        keys = { "\"", "<C-r>" },
        config = function()
            require("user.registers")
        end
    },

    -- Bufferline - VERY LAZY LOAD
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
    },

    -- Lualine - IMMEDIATE LOAD (Critical UI)
    {
        "nvim-lualine/lualine.nvim",
        priority = 850,
        config = function()
            require("user.lualine")
        end
    },

    -- Comment - SMART LAZY LOAD
    {
        "numToStr/Comment.nvim",
        keys = {
            { "gc", mode = { "n", "v" } },
            { "gb", mode = { "n", "v" } },
        },
        config = function()
            require("Comment").setup()
        end
    },

    -- Todo comments - CONDITIONAL LOAD
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        cond = function()
            return not is_large_file() and should_load_lsp()
        end,
        config = function()
            require("user.todo-comments")
        end
    },

    -- Terminal - COMMAND ONLY LOAD
    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        keys = { "<C-\\>" },
        config = function()
            require("user.toggleterm")
        end
    },

    -- Search and replace - COMMAND ONLY LOAD
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        keys = { "<leader>S" },
        config = function()
            require("user.spectre")
        end
    },

    -- Better quickfix - FILETYPE ONLY LOAD
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        config = function()
            require("user.bqf")
        end
    },

    -- Git signs - CONDITIONAL GIT LOAD
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPost", "BufNewFile" },
        cond = function()
            return vim.fn.isdirectory(".git") == 1 and not is_large_file()
        end,
        config = function()
            require("user.gitsigns")
        end
    },

    -- Which key - VERY LAZY LOAD
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("user.whichkey")
        end
    },

    -- THEMES - All other themes ultra lazy
    { "krshrimali/vim-moonfly-colors", lazy = true },
    { "navarasu/onedark.nvim", lazy = true },
    { "ellisonleao/gruvbox.nvim", lazy = true },
    { "sainnhe/gruvbox-material", lazy = true },
    { "Shadorain/shadotheme", lazy = true },
    { "nyoom-engineering/oxocarbon.nvim", lazy = true },
    { "projekt0n/github-nvim-theme", lazy = true },

    -- Peek numbers - SMART LAZY LOAD
    {
        "nacro90/numb.nvim",
        keys = { ":" }, -- Only load when entering command mode
        config = function()
            require("user.numb")
        end
    },

    -- Outline - COMMAND ONLY LOAD
    {
        "hedyhli/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineToggle", "OutlineOpen" },
        keys = { "<leader>o" },
        cond = should_load_lsp,
        config = function()
            require("outline").setup {}
        end,
    },

    -- Python type stubs - DISABLED
    {
        "microsoft/python-type-stubs",
        cond = false,
    },

    -- File browser functionality available through fzf-lua files command

    -- Winbar - LAZY LOAD
    {
        "fgheng/winbar.nvim",
        event = "BufReadPost",
    },

    -- Frecency functionality replaced with fzf-lua oldfiles

    -- Trouble - LAZY LOAD (already configured correctly)
    {
        "folke/trouble.nvim",
        opts = {

            icons = {
                indent        = {
                    top         = "| ",
                    middle      = "|-",
                    last        = "+-",
                    fold_open   = "v",
                    fold_closed = ">",
                    ws          = "  ",
                },
                folder_closed = "d",
                folder_open   = "D",
                kinds         = {
                    Array         = "A",
                    Boolean       = "B",
                    Class         = "C",
                    Constant      = "c",
                    Constructor   = "C",
                    Enum          = "E",
                    EnumMember    = "e",
                    Event         = "E",
                    Field         = "f",
                    File          = "F",
                    Function      = "f",
                    Interface     = "I",
                    Key           = "k",
                    Method        = "m",
                    Module        = "M",
                    Namespace     = "N",
                    Null          = "n",
                    Number        = "#",
                    Object        = "O",
                    Operator      = "o",
                    Package       = "P",
                    Property      = "p",
                    String        = "s",
                    Struct        = "S",
                    TypeParameter = "t",
                    Variable      = "v",
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

    -- Copilot - LAZY LOAD
    -- {
    --     "github/copilot.vim",
    --     event = "InsertEnter"
    -- },

    -- Project management - LAZY LOAD
    {
        "ahmedkhalf/project.nvim",
        event = "VeryLazy",
        config = function()
            require("project_nvim").setup({
                detection_methods = { "lsp", "pattern" },
                patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json", "Cargo.toml" },
                ignore_lsp = {},
                exclude_dirs = {},
                show_hidden = false,
                silent_chdir = true,
                scope_chdir = 'global',
                datapath = vim.fn.stdpath("data"),
            })
            -- projects extension removed - using fzf-lua for file navigation
        end,
    },

    -- Custom utilities - LAZY LOAD
    {
        "krshrimali/nvim-utils",
        event = "VeryLazy",
        config = function()
            require("tgkrsutil").setup({
                enable_test_runner = true,
                test_runner = function(file, func)
                    return string.format("despytest %s -k %s", file, func)
                end,
            })
        end,
    },

    -- Context pilot - LAZY LOAD
    {
        "krshrimali/context-pilot.nvim",
        dependencies = {
            "ibhagwan/fzf-lua"
        },
        cmd = "ContextPilot",
        config = function()
            require("contextpilot")
        end
    },

    -- Git blame - LAZY LOAD
    {
        "f-person/git-blame.nvim",
        cmd = { "GitBlameToggle", "GitBlameEnable" },
        keys = { "<leader>gb" },
        opts = {
            enabled = false,
            virtual_text_column = 1
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
            bigfile = { enabled = true },
            dashboard = { enabled = false }, -- Completely disable dashboard
            explorer = { enabled = false },
            indent = { enabled = false },
            input = { enabled = false },
            picker = { enabled = false },   -- Disable picker since we're using nvim-tree
            notifier = { enabled = false }, -- Disable for faster startup
            quickfile = { enabled = true },
            scope = { enabled = false },
            scroll = { enabled = false },
            statuscolumn = { enabled = false }, -- Disable for faster startup
            words = { enabled = false },
        },
    },

    -- Avante - LAZY LOAD
    {
        "yetone/avante.nvim",
        build = function()
            if vim.fn.has("win32") == 1 then
                return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
            else
                return "make"
            end
        end,
        cmd = { "AvanteAsk", "AvanteChat", "AvanteToggle" },
        keys = { "<leader>aa", "<leader>ac", "<leader>at" },
        version = false,
        ---@module 'avante'
        ---@type avante.Config
        opts = {
            -- add any opts here
            -- for example
            provider = "copilot",
            providers = {
                claude = {
                    endpoint = "https://api.anthropic.com",
                    model = "claude-sonnet-4-20250514",
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 20480,
                    },
                },
                moonshot = {
                    endpoint = "https://api.moonshot.ai/v1",
                    model = "kimi-k2-0711-preview",
                    timeout = 30000, -- Timeout in milliseconds
                    extra_request_body = {
                        temperature = 0.75,
                        max_tokens = 32768,
                    },
                },
            },
        },
        dependencies = {
            "nvim-lua/plenary.nvim",
            "MunifTanjim/nui.nvim",
            --- The below dependencies are optional,
            "echasnovski/mini.pick",         -- for file_selector provider mini.pick
            -- "nvim-telescope/telescope.nvim", -- replaced with fzf-lua
            "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
            "ibhagwan/fzf-lua",              -- for file_selector provider fzf
            "stevearc/dressing.nvim",        -- for input provider dressing
            "folke/snacks.nvim",             -- for input provider snacks
            -- "nvim-tree/nvim-web-devicons",   -- or echasnovski/mini.icons
            "github/copilot.vim",
            -- "zbirenbaum/copilot.lua",        -- for providers='copilot'
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
    },

    -- LSP Saga - LAZY LOAD
    {
        'nvimdev/lspsaga.nvim',
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require('lspsaga').setup({
                ui = {
                    devicon = false,
                    foldericon = false,
                    expand = '>',
                    collapse = '<',
                    use_nerd = false
                }
            })
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        }
    },
    {
        "TabbyML/vim-tabby",
        lazy = false,
        dependencies = {
            "neovim/nvim-lspconfig",
        },
        config = function()
            -- Keybinding to accept Tabby suggestion
            vim.g.tabby_keybinding_accept = "<C-y>"
            -- Set specific Node.js binary path
            vim.g.tabby_node_binary = "/prod/tools/infra/nodejs/node20/node/bin/node"
            vim.g.tabby_agent_start_command = { "npx", "tabby-agent", "--stdio" }
            vim.g.tabby_inline_completion_trigger = "auto"
        end,
    },
    {
        "https://github.deshaw.com/genai/vim-ai",
        tag = "v0.0.1"
    }
}
