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

    -- LSP
    {
        "neovim/nvim-lspconfig",
    },

    -- "ray-x/lsp_signature.nvim",

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

    -- "kyazdani42/nvim-web-devicons", -- Disabled to avoid nerd fonts

    "akinsho/bufferline.nvim",
    "nvim-lualine/lualine.nvim",

    -- Indent
    { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },

    {
        "nvim-tree/nvim-tree.lua",
        version = "*",
        lazy = false,
        -- dependencies = {
        --     "nvim-tree/nvim-web-devicons", -- Disabled to avoid nerd fonts
        -- },
    },

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

    "jonarrien/telescope-cmdline.nvim",
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
        "nvim-telescope/telescope-frecency.nvim",
        config = function() require("telescope").load_extension "frecency" end,
    },
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
            keymap = { preset = 'super-tab', ['<C-j>'] = { 'select_next', 'fallback' },
                ['<C-k>'] = { 'select_prev', 'fallback' }, },
            signature = { enabled = true },
            appearance = {
                -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono',
                kind_icons = {
                    Text = 'T',
                    Method = 'M',
                    Function = 'F',
                    Constructor = 'C',
                    Field = 'f',
                    Variable = 'v',
                    Property = 'p',
                    Class = 'C',
                    Interface = 'I',
                    Struct = 'S',
                    Module = 'm',
                    Unit = 'u',
                    Value = 'V',
                    Enum = 'E',
                    EnumMember = 'e',
                    Keyword = 'k',
                    Constant = 'c',
                    Snippet = 's',
                    Color = '#',
                    File = 'f',
                    Reference = 'r',
                    Folder = 'd',
                    Event = 'E',
                    Operator = 'o',
                    TypeParameter = 't',
                },
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = { documentation = { auto_show = false }, list = {
                max_items = 10,
            } },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'buffer' },
                min_keyword_length = 2,
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
    { "github/copilot.vim" },
    {
        "ahmedkhalf/project.nvim",
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
        end,
    },
    {
        "mason-org/mason.nvim",
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
            dashboard = {
                enabled = true,
                preset = {
                    header = [[
████████  ██████  ██   ██ ██████  ███████
   ██    ██       ██  ██  ██   ██ ██
   ██    ██   ███ █████   ██████  ███████
   ██    ██    ██ ██  ██  ██   ██      ██
   ██     ██████  ██   ██ ██   ██ ███████

   Welcome to Kushashwa's Home! <3
        Jai Hind!
]],
                    keys = {
                        { icon = "f", key = "f", desc = "Find File",       action = ":lua Snacks.dashboard.pick('files')" },
                        { icon = "n", key = "n", desc = "New File",        action = ":ene | startinsert" },
                        { icon = "g", key = "g", desc = "Find Text",       action = ":lua Snacks.dashboard.pick('live_grep')" },
                        { icon = "r", key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('oldfiles')" },
                        { icon = "c", key = "c", desc = "Config",          action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                        { icon = "s", key = "s", desc = "Restore Session", section = "session" },
                        { icon = "l", key = "l", desc = "Lazy",            action = ":Lazy" },
                        { icon = "q", key = "q", desc = "Quit",            action = ":qa" },
                    },
                }
            },
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
    {
        'windwp/nvim-autopairs',
        event = "InsertEnter",
        config = true
    },
}
