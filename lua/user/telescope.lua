local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require "telescope.actions"
local lga_actions = require "telescope-live-grep-args.actions"
-- telescope.load_extension "media_files"
local icons = require "user.icons"
local themes = require "user.telescope.user_themes"

telescope.setup {
    defaults = {
        wrap_results = true,
        results_limit = 100, -- Reduced further for faster startup
        dynamic_preview_title = false,
        file_sorter = require('telescope.sorters').get_fuzzy_file,
        generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
        
        -- Performance optimizations
        initial_mode = "insert",
        selection_strategy = "reset",
        sorting_strategy = "ascending",
        scroll_strategy = "cycle",
        
        -- Faster file processing
        file_previewer = require('telescope.previewers').vim_buffer_cat.new,
        grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
        qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
        
        layout_config = {
            width = 0.85, -- Reduced for faster rendering
            height = 0.75, -- Reduced for faster rendering
            
            horizontal = {
                preview_width = function(_, cols, _)
                    if cols > 200 then
                        return math.floor(cols * 0.3) -- Further reduced preview width
                    else
                        return math.floor(cols * 0.4)
                    end
                end,
            },

            vertical = {
                width = 0.80,
                height = 0.85,
                preview_height = 0.35, -- Further reduced preview height
            },

            flex = {
                horizontal = {
                    preview_width = 0.7,
                },
            },
        },
        
        cache_picker = {
            num_pickers = 3, -- Further reduced
            limit_entries = 100, -- Further reduced
            ignore_empty_prompt = true,
        },
        
        disable_coordinates = true,
        layout_strategy = "horizontal",
        use_less = false,
        get_status_text = function() return "" end,
        
        prompt_prefix = "> ",
        selection_caret = "> ",
        entry_prefix = " ",
        path_display = { "smart" },

        color_devicons = false, -- Disabled to avoid nerd fonts

        -- Optimized file ignore patterns (kept essential ones)
        file_ignore_patterns = {
            "%.git/",
            "node_modules/",
            "__pycache__/",
            "%.cache",
            "build/",
            "target/",
            "vendor/",
            "%.lock",
            "%.sqlite3",
            "%.dll",
            "%.exe",
            "%.so",
            "%.dylib",
            "%.jar",
            "%.class",
            "%.zip",
            "%.tar%.gz",
            "%.rar",
            "%.7z",
        },

        mappings = {
            i = {
                ["<C-n>"] = actions.cycle_history_next,
                ["<C-p>"] = actions.cycle_history_prev,

                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,

                ["<C-c>"] = actions.close,

                ["<Down>"] = actions.move_selection_next,
                ["<Up>"] = actions.move_selection_previous,

                ["<CR>"] = actions.select_default,
                ["<C-s>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-\\>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,

                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,

                ["<Tab>"] = actions.close,
                ["<S-Tab>"] = actions.close,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                ["<C-l>"] = actions.complete_tag,
                ["<C-h>"] = actions.which_key, -- keys from pressing <C-h>
            },

            n = {
                ["<esc>"] = actions.close,
                ["<CR>"] = actions.select_default,
                ["<C-x>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-\\>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,
                ["<C-b>"] = actions.results_scrolling_up,
                ["<C-f>"] = actions.results_scrolling_down,

                ["<Tab>"] = actions.close,
                ["<S-Tab>"] = actions.close,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                ["j"] = actions.move_selection_next,
                ["k"] = actions.move_selection_previous,
                ["H"] = actions.move_to_top,
                ["M"] = actions.move_to_middle,
                ["L"] = actions.move_to_bottom,
                ["q"] = actions.close,
                ["dd"] = require("telescope.actions").delete_buffer,
                ["s"] = actions.select_horizontal,
                ["v"] = actions.select_vertical,
                ["\\"] = actions.select_vertical,
                ["t"] = actions.select_tab,

                ["<Down>"] = actions.move_selection_next,
                ["<Up>"] = actions.move_selection_previous,
                ["gg"] = actions.move_to_top,
                ["G"] = actions.move_to_bottom,
                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,

                ["<PageUp>"] = actions.results_scrolling_up,
                ["<PageDown>"] = actions.results_scrolling_down,

                ["?"] = actions.which_key,
            },
        },
    },
    pickers = {
        live_grep = {
            find_command = { "rg", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
            path_display = { "smart" },
            previewer = false,
            debounce = 30, -- Reduced for faster response
            results_limit = 75, -- Reduced for faster results
        },
        
        grep_string = {
            previewer = false,
            results_limit = 75,
            debounce = 30,
        },
        
        quickfix = {
            theme = "ivy",
            initial_mode = "normal",
        },
        
        loclist = {
            theme = "ivy",
        },
        
        jumplist = {
            initial_mode = "normal",
            wrap_results = true,
        },
        
        find_files = {
            initial_mode = "insert",
            find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
            previewer = false,
            debounce = 30, -- Reduced for faster response
            results_limit = 100, -- Optimized for speed
            path_display = { "smart" },
            follow = false, -- Don't follow symlinks for better performance
            hidden = true,
            -- Faster file discovery
            file_sorter = require('telescope.sorters').get_fuzzy_file,
        },
        
        git_files = {
            initial_mode = "insert",
            previewer = false,
            show_untracked = true,
            results_limit = 150,
            debounce = 30,
        },
        
        projects = {
            enable_preview = false, -- Disabled for faster loading
        },
        
        keymaps = {
            theme = "ivy",
        },
        
        buffers = {
            theme = "ivy",
            initial_mode = "insert",
            preview = false, -- Disabled preview for instant switching
            sort_lastused = true,
            sort_mru = true,
            results_limit = 30, -- Further reduced for instant display
            ignore_current_buffer = false,
        },
        
        planets = {
            show_pluto = true,
            show_moon = true,
        },
        
        colorscheme = {
            enable_preview = false, -- Disabled for faster loading
        },
        
        lsp_references = {
            theme = "ivy",
            initial_mode = "normal",
            results_limit = 75,
        },
        
        lsp_definitions = {
            theme = "ivy",
            initial_mode = "normal",
        },
        
        lsp_incoming_calls = {
            theme = "ivy",
            initial_mode = "normal",
        },
        
        lsp_outgoing_calls = {
            theme = "ivy",
            initial_mode = "normal",
        },
        
        lsp_declarations = {
            theme = "ivy",
            initial_mode = "normal",
        },
        
        lsp_implementations = {
            theme = "ivy",
            initial_mode = "normal",
        },
        
        diagnostics = {
            theme = "ivy",
            initial_mode = "normal",
            preview = false, -- Disabled for faster loading
            results_limit = 75,
        },
    },
    extensions = {
        live_grep_args = {
            auto_quoting = false,
            find_command = "rg",
            theme = "ivy",
            path_display = { "smart" },
            debounce = 30,
            results_limit = 75,
        },
        fzf = {
            fuzzy = true,             -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true, -- override the file sorter
            case_mode = "smart_case", -- or "ignore_case" or "respect_case"
        }
    },
}

-- Load extensions after setup to avoid startup delays
vim.defer_fn(function()
    require('telescope').load_extension('fzf')
end, 100)
