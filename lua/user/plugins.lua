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

    -- COC.nvim for LSP and completion - LAZY LOAD
    { 
        'neoclide/coc.nvim', 
        branch = 'release',
        event = { "BufReadPre", "BufNewFile" }, -- Only load when opening files
        config = function()
            -- Defer CoC extension installation to avoid startup delay
            vim.defer_fn(function()
                require("user.coc")
            end, 1000)
        end
    },

    -- Highlight words under cursor - LAZY LOAD
    {
        "RRethy/vim-illuminate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("user.illuminate")
        end
    },

    -- Treesitter - LAZY LOAD
    { 
        "nvim-treesitter/nvim-treesitter", 
        build = ":TSUpdate",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("user.treesitter")
        end
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
            "nvim-lua/plenary.nvim",         -- required
            "nvim-telescope/telescope.nvim", -- optional
            "sindrets/diffview.nvim",        -- optional
        },
        cmd = "Neogit",
        keys = { "<leader>gg" },
        config = true,
    },
    
    -- Transparency - LOAD IMMEDIATELY (UI)
    "xiyaowong/transparent.nvim",
    
    -- Goto preview - LAZY LOAD
    {
        "rmagatti/goto-preview",
        dependencies = { "rmagatti/logger.nvim" },
        keys = {
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
        }
    },

    -- Telescope and extensions - LAZY LOAD
    { "nvim-telescope/telescope-fzf-native.nvim", build = 'make', lazy = true },
    {
        "nvim-telescope/telescope.nvim",
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
            { "<leader>fb", "<cmd>Telescope buffers<cr>" },
            { "<leader>fh", "<cmd>Telescope help_tags<cr>" },
        },
        dependencies = {
            { "nvim-telescope/telescope-live-grep-args.nvim" },
            { "nvim-telescope/telescope-fzf-native.nvim" },
        },
        config = function()
            require("user.telescope")
            require("telescope").load_extension "live_grep_args"
            require('telescope').load_extension('fzf')
        end,
    },

    -- THEMES - Keep minimal set, load immediately for UI consistency
    { "decaycs/decay.nvim", as = "decay" },
    "lunarvim/darkplus.nvim",
    "folke/tokyonight.nvim",
    {
        "uloco/bluloco.nvim",
        dependencies = { "rktjmp/lush.nvim" },
    },

    -- Notifications - LOAD IMMEDIATELY (UI)
    {
        "rcarriga/nvim-notify",
        config = function()
            require("user.notify")
        end
    },
    
    -- Dressing - LOAD IMMEDIATELY (UI)
    {
        "stevearc/dressing.nvim",
        config = function()
            require("user.dressing")
        end
    },

    -- Buffer navigation - LAZY LOAD
    {
        "ghillb/cybu.nvim",
        branch = "main", -- timely updates
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("user.cybu")
        end
    },

    -- Registers - LAZY LOAD
    {
        "tversteeg/registers.nvim",
        keys = { "\"", "<C-r>" },
        config = function()
            require("user.registers")
        end
    },



    -- Bufferline - LAZY LOAD
    {
        "akinsho/bufferline.nvim",
        event = "VeryLazy",
        -- config handled in separate file
    },
    
    -- Lualine - LOAD IMMEDIATELY (UI)
    {
        "nvim-lualine/lualine.nvim",
        config = function()
            require("user.lualine")
        end
    },

    -- File explorer - LAZY LOAD
    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        cmd = { "NvimTreeToggle", "NvimTreeOpen", "NvimTreeFocus" },
        keys = { "<leader>e" },
        config = function()
            require("user.nvim-tree")
        end
    },

    -- Comment - LAZY LOAD
    {
        "numToStr/Comment.nvim",
        config = function()
            require("Comment").setup()
        end
        -- keys = {
        --     { "gc", mode = { "n", "v" } },
        --     { "gb", mode = { "n", "v" } },
        -- },
        -- lazy = false,
        -- config = function()
        --     require("user.comment")
        -- end
    },
    
    -- Todo comments - LAZY LOAD
    {
        "folke/todo-comments.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("user.todo-comments")
        end
    },

    -- Terminal - LAZY LOAD
    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        keys = { "<C-\\>" },
        config = function()
            require("user.toggleterm")
        end
    },

    -- Search and replace - LAZY LOAD
    {
        "nvim-pack/nvim-spectre",
        cmd = "Spectre",
        keys = { "<leader>S" },
        config = function()
            require("user.spectre")
        end
    },

    -- Better quickfix - LAZY LOAD
    {
        "kevinhwang91/nvim-bqf",
        ft = "qf",
        config = function()
            require("user.bqf")
        end
    },

    -- Git signs - LAZY LOAD
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("user.gitsigns")
        end
    },

    -- Which key - LAZY LOAD
    {
        "folke/which-key.nvim",
        event = "VeryLazy",
        config = function()
            require("user.whichkey")
        end
    },

    -- THEMES - Move less used themes to lazy load
    {
        "krshrimali/vim-moonfly-colors",
        lazy = true
    },
    {
        "navarasu/onedark.nvim",
        lazy = true
    },
    {
        "ellisonleao/gruvbox.nvim",
        lazy = true
    },
    {
        "sainnhe/gruvbox-material",
        lazy = true
    },
    {
        "Shadorain/shadotheme",
        lazy = true
    },
    {
        "nyoom-engineering/oxocarbon.nvim",
        lazy = true
    },
    {
        "projekt0n/github-nvim-theme",
        lazy = true
    },

    -- Peek numbers - LAZY LOAD
    {
        "nacro90/numb.nvim",
        event = { "BufReadPost", "BufNewFile" },
        config = function()
            require("user.numb")
        end
    },

    -- Telescope cmdline - LAZY LOAD
    {
        "jonarrien/telescope-cmdline.nvim",
        keys = { ":" },
        config = function()
            require("telescope").load_extension "cmdline"
        end
    },

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
                    File = { icon = 'F', hl = 'Identifier' },
                    Module = { icon = 'M', hl = 'Include' },
                    Namespace = { icon = 'N', hl = 'Include' },
                    Package = { icon = 'P', hl = 'Include' },
                    Class = { icon = 'C', hl = 'Type' },
                    Method = { icon = 'm', hl = 'Function' },
                    Property = { icon = 'p', hl = 'Identifier' },
                    Field = { icon = 'f', hl = 'Identifier' },
                    Constructor = { icon = 'c', hl = 'Special' },
                    Enum = { icon = 'E', hl = 'Type' },
                    Interface = { icon = 'I', hl = 'Type' },
                    Function = { icon = 'F', hl = 'Function' },
                    Variable = { icon = 'v', hl = 'Constant' },
                    Constant = { icon = 'C', hl = 'Constant' },
                    String = { icon = 's', hl = 'String' },
                    Number = { icon = '#', hl = 'Number' },
                    Boolean = { icon = 'b', hl = 'Boolean' },
                    Array = { icon = 'A', hl = 'Constant' },
                    Object = { icon = 'O', hl = 'Type' },
                    Key = { icon = 'k', hl = 'Type' },
                    Null = { icon = 'n', hl = 'Type' },
                    EnumMember = { icon = 'e', hl = 'Identifier' },
                    Struct = { icon = 'S', hl = 'Structure' },
                    Event = { icon = 'E', hl = 'Type' },
                    Operator = { icon = 'o', hl = 'Identifier' },
                    TypeParameter = { icon = 't', hl = 'Identifier' },
                    Component = { icon = 'C', hl = 'Function' },
                    Fragment = { icon = 'f', hl = 'Constant' },
                    TypeAlias = { icon = 'T', hl = 'Type' },
                    Parameter = { icon = 'p', hl = 'Identifier' },
                    StaticMethod = { icon = 'S', hl = 'Function' },
                    Macro = { icon = 'M', hl = 'Function' },
                }
            }
        },
    },

    -- Python type stubs - DISABLED
    {
        "microsoft/python-type-stubs",
        cond = false,
    },

    -- Telescope file browser - LAZY LOAD
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
        cmd = "Telescope file_browser",
        keys = { "<leader>fb" },
    },

    -- Winbar functionality is now handled by lualine winbar
    -- Removed fgheng/winbar.nvim to prevent conflicts and improve performance

    -- Telescope frecency - LAZY LOAD
    {
        "nvim-telescope/telescope-frecency.nvim",
        dependencies = { "nvim-telescope/telescope.nvim" },
        cmd = "Telescope frecency",
        config = function() 
            require("telescope").load_extension "frecency" 
        end,
    },

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
    { 
        "github/copilot.vim",
        event = "InsertEnter"
    },

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
            require("telescope").load_extension "projects"
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
            "nvim-telescope/telescope.nvim",
            "nvim-telescope/telescope-fzy-native.nvim"
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
            picker = { enabled = false }, -- Disable picker since we're using nvim-tree
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
            "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
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
}
