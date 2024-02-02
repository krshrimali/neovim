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
    -- layout_config = {
    --   prompt_position = "bottom",
    --   height = 80,
    -- },
    layout_config = {
      width = 0.95,
      height = 0.85,
      -- preview_cutoff = 120,
      -- prompt_position = "bottom",

      horizontal = {
        preview_width = function(_, cols, _)
          if cols > 200 then
            return math.floor(cols * 0.4)
          else
            return math.floor(cols * 0.6)
          end
        end,
      },

      vertical = {
        width = 0.9,
        height = 0.95,
        preview_height = 0.5,
      },

      flex = {
        horizontal = {
          preview_width = 0.9,
        },
      },
    },
    cache_picker = {
      ignore_empty_prompt = true,
    },
    disable_coordinates = false,
    layout_strategy = "horizontal",
    prompt_prefix = icons.ui.Telescope .. " ",
    selection_caret = " ",
    path_display = { "shorten" }, -- do :help telescope.defaults.path_display (options: hidden, tail, smart, shorten, truncate)

    selection_strategy = "reset",
    sorting_strategy = "descending",
    scroll_strategy = "cycle",
    color_devicons = true,

    -- file_ignore_patterns = { },
    file_ignore_patterns = {
      ".git/",
      "target/",
      -- "docs/",
      "vendor/*",
      "%.lock",
      "__pycache__/*",
      "%.sqlite3",
      "%.ipynb",
      "node_modules/*",
      -- "%.jpg",
      -- "%.jpeg",
      -- "%.png",
      "%.svg",
      "%.otf",
      "%.ttf",
      "%.webp",
      ".dart_tool/",
      -- ".github/",
      ".gradle/",
      ".idea/",
      ".settings/",
      ".vscode/",
      "__pycache__/",
      "build/",
      "env/",
      "gradle/",
      "node_modules/",
      "%.pdb",
      "%.dll",
      "%.class",
      "%.exe",
      "%.cache",
      "%.ico",
      "%.pdf",
      "%.dylib",
      "%.jar",
      "%.docx",
      "%.met",
      "smalljre_*/*",
      ".vale/",
      "%.burp",
      "%.mp4",
      "%.mkv",
      "%.rar",
      "%.zip",
      "%.7z",
      "%.tar",
      "%.bz2",
      "%.epub",
      "%.flac",
      "%.tar.gz",
    },

    mappings = {
      i = {
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,

        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,

        -- ["<C-b>"] = actions.results_scrolling_up,

        ["<C-c>"] = actions.close,

        ["<Down>"] = actions.move_selection_next,
        ["<Up>"] = actions.move_selection_previous,

        ["<CR>"] = actions.select_default,
        ["<C-s>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,

        -- ["<c-d>"] = require("telescope.actions").delete_buffer,

        ["<C-u>"] = actions.preview_scrolling_up,
        ["<C-d>"] = actions.preview_scrolling_down,

        -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        ["<Tab>"] = actions.close,
        ["<S-Tab>"] = actions.close,
        -- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
        ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
        ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
        ["<C-l>"] = actions.complete_tag,
        ["<C-h>"] = actions.which_key, -- keys from pressing <C-h>
        -- ["<esc>"] = actions.close,
      },

      n = {
        ["<esc>"] = actions.close,
        ["<CR>"] = actions.select_default,
        ["<C-x>"] = actions.select_horizontal,
        ["<C-v>"] = actions.select_vertical,
        ["<C-t>"] = actions.select_tab,
        ["<C-b>"] = actions.results_scrolling_up,
        ["<C-f>"] = actions.results_scrolling_down,

        ["<Tab>"] = actions.close,
        ["<S-Tab>"] = actions.close,
        -- ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
        -- ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
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
      -- theme = "ivy",
      -- theme = "ivy",
      find_command = { "rg", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case" },
      path_display = { "absolute" },
      -- theme = "ivy_vertical"
      -- theme = themes.get_ivy_vertical({}),
    },
    grep_string = {
      -- theme = "ivy",
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
      -- theme = "ivy", -- dropdown
      initial_mode = "insert",
      find_command = { "rg", "--files", "--iglob", "!.git", "--hidden" },
    },
    projects = {
      enable_preview = true,
    },
    keymaps = {
      theme = "ivy",
    },
    buffers = {
      theme = "ivy",
      initial_mode = "insert",
      preview = true,
      sort_lastused = true,
      sort_mru = true,
    },
    planets = {
      show_pluto = true,
      show_moon = true,
    },
    colorscheme = {
      enable_preview = true,
    },
    lsp_references = {
      theme = "ivy",
      initial_mode = "normal",
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
      preview = true,
    },

    -- Default configuration for builtin pickers goes here:
    -- picker_name = {
    --   picker_config_key = value,
    --   ...
    -- }
    -- Now the picker_config_key will be applied every time you call this
    -- builtin picker
  },
  extensions = {
    live_grep_args = {
      auto_quoting = false,
      find_command = "rg",
      theme = "ivy",
      path_display = { "absolute" },
      -- mappings = {
      --   i = {
      --     ["<C-k>"] = lga_actions.quote_prompt(),
      --     ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob "})
      --   },
      -- },
    },
  },
}
