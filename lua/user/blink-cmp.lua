-- Blink.cmp configuration for fast LSP completion
-- https://github.com/Saghen/blink.cmp

require("blink.cmp").setup {
    -- 'default' for mappings similar to built-in completion
    -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
    -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
    -- See the "default configuration" section below for full documentation on how to define
    -- your own keymap.
    keymap = { preset = "enter" },

    -- appearance = {
    --   -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    --   -- Useful for when your theme doesn't support blink.cmp
    --   -- will be removed in a future release
    --   -- use_nvim_cmp_as_default = true,
    --   -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    --   -- Adjusts spacing to ensure icons are aligned
    --   -- nerd_font_variant = "mono",
    -- },

    -- default list of enabled providers defined so that you can extend it
    -- elsewhere in your config, without redefining it, due to `opts_extend`
    sources = {
        default = { "lsp", "path", "buffer" },
        -- optionally disable cmdline completions
        -- cmdline = {},
        providers = {
            buffer = {
                max_items = 4,
                min_keyword_length = 2,
            },
            lsp = {
                max_items = 5,
                min_keyword_length = 2,
            }
        }
    },

    -- experimental signature help support
    -- signature = { enabled = true },

    completion = {
        -- 'prefix' will fuzzy match on the text before the cursor
        -- 'full' will fuzzy match on the text before and after the cursor
        -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
        -- keyword = { range = "full" },

        -- Trigger completion after typing 2 characters
        trigger = {
            prefetch_on_insert = false,
            show_on_trigger_character = true,
            show_on_keyword = true,
            -- keyword_length = 2
        },

        -- Limit completion items to 10
        list = { max_items = 10 },

        -- Disable icons in completion menu
        menu = {
            draw = {
                columns = {
                    { "label",      "label_description", gap = 1 },
                    { "source_name" },
                },
            },
        },

        -- Disable auto brackets
        -- NOTE: some LSPs may add auto brackets themselves anyway
        accept = { auto_brackets = { enabled = true } },

        -- Insert completion item on selection, don't select by default
        -- list = { selection = 'preselect' },

        -- menu = {
        --   -- Don't automatically show the completion menu
        --   auto_show = true,
        --
        --   -- nvim-cmp style menu
        --   draw = {
        --     treesitter = { "lsp" },
        --     columns = {
        --       { "kind_icon" },
        --       { "label", "label_description", gap = 1 },
        --       { "source_name" },
        --     },
        --   },
        -- },

        -- Show documentation when selecting a completion item
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 500,
            treesitter_highlighting = false,
            window = { border = "rounded" },
        },

        -- Display a preview of the selected item on the current line
        -- ghost_text = { enabled = true },
    },
}
