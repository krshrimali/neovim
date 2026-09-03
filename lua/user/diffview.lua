local status_ok, diffview = pcall(require, "diffview")
if not status_ok then return end

local actions = require "diffview.actions"

diffview.setup {
  diff_binaries = false, -- Show diffs for binaries
  enhanced_diff_hl = true, -- Enhanced diff highlighting for better visibility
  git_cmd = { "git" }, -- The git executable to use
  use_icons = false, -- Disabled to avoid nerd fonts
  show_help_hints = true, -- Show hints for how to open the help panel
  watch_index = true, -- Update views and index buffers when the git index changes
  -- Performance optimizations
  hooks = {
    diff_buf_read = function()
      -- Optimize for large files
      vim.opt_local.wrap = false
      vim.opt_local.number = true
      vim.opt_local.relativenumber = false
    end,
  },
  icons = { -- Only applies when use_icons = true
    folder_closed = "",
    folder_open = "",
  },
  signs = {
    -- Unicode arrows so folds render without nerd fonts (use_icons = false).
    fold_closed = "▸",
    fold_open = "▾",
    done = "✓",
  },
  -- Applied to 'diffopt' while a view is open, and restored when the last one
  -- is closed. This is what lines up changed lines with each other, so the
  -- within-line highlighting actually points at what changed.
  -- Set an entry to `false` to keep your own value: ':h diffview-config-diffopt'.
  diffopt = {
    algorithm = "histogram",
    linematch = 60,
  },
  view = {
    -- Configure the layout and behavior of different types of views.
    -- Available layouts:
    --  'diff1_plain'
    --    |'diff2_horizontal'
    --    |'diff2_vertical'
    --    |'diff3_horizontal'
    --    |'diff3_vertical'
    --    |'diff3_mixed'
    --    |'diff4_mixed'
    -- For more info, see ':h diffview-config-view.x.layout'.
    default = {
      -- Config for changed files, and staged files in diff views.
      layout = "diff2_horizontal",
      winbar_info = false, -- See ':h diffview-config-view.x.winbar_info'
    },
    merge_tool = {
      -- Config for conflicted files in diff views during a merge or rebase.
      layout = "diff3_horizontal",
      disable_diagnostics = true, -- Temporarily disable diagnostics for conflict buffers while in the view.
      winbar_info = true,
    },
    file_history = {
      -- Config for all file history views.
      layout = "diff2_horizontal",
      winbar_info = true,
    },
  },
  file_panel = {
    listing_style = "tree", -- One of 'list' or 'tree'
    tree_options = { -- Only applies when listing_style = 'tree'
      flatten_dirs = true, -- Flatten dirs that only contain one single dir
      folder_statuses = "only_folded", -- One of 'never', 'only_folded' or 'always'
    },
    win_config = { -- See ':h diffview-config-win_config'
      position = "left",
      width = 35,
      win_opts = {},
    },
  },
  file_history_panel = {
    log_options = { -- See ':h diffview-config-log_options'
      git = {
        single_file = {
          diff_merges = "combined",
        },
        multi_file = {
          diff_merges = "first-parent",
        },
      },
    },
    win_config = { -- See ':h diffview-config-win_config'
      position = "bottom",
      height = 16,
      win_opts = {},
    },
  },
  commit_log_panel = {
    win_config = { -- See ':h diffview-config-win_config'
      win_opts = {},
    },
  },
  default_args = { -- Default args prepended to the list of diffview commands. See ':h diffview-config-default_args'
    DiffviewOpen = {},
    DiffviewFileHistory = {},
  },
  keymaps = {
    -- We deliberately keep ALL upstream defaults (disable_defaults = false) and
    -- only override the few keys that collide with bindings elsewhere in this
    -- config. Everything not listed here comes straight from diffview's
    -- defaults, so new upstream keymaps (PR tabs gpF/gpo/gpa/gpR, review nav
    -- ]r/[r, review-prompt maps, etc.) are picked up automatically.
    disable_defaults = false,

    view = {
      -- '<leader>h*' is nohlsearch and '<leader>d*' is black-hole delete here,
      -- so disable upstream's hunk/diff-toggle keys and mirror them onto
      -- '<leader>g*' (the same keys stage a hunk in a normal buffer via gitsigns).
      { { "n", "x" }, "<leader>hs", false },
      { { "n", "x" }, "<leader>hu", false },
      { { "n", "x" }, "<leader>hr", false },
      { { "n", "x" }, "<leader>gs", actions.stage_hunk, { desc = "Stage the hunk / selection" } },
      { { "n", "x" }, "<leader>gu", actions.unstage_hunk, { desc = "Unstage the hunk / selection" } },
      { { "n", "x" }, "<leader>gr", actions.restore_hunk, { desc = "Discard the hunk / selection" } },
      { "n", "<leader>dw", false },
      { "n", "<leader>du", false },
      { "n", "<leader>di", false },
      { "n", "<leader>gw", actions.toggle_ignore_whitespace, { desc = "Toggle ignoring whitespace changes" } },
      { "n", "<leader>gz", actions.toggle_unchanged_regions, { desc = "Toggle hiding unchanged regions" } },
      { "n", "<leader>gi", actions.toggle_inline_diff, { desc = "Toggle the inline (unified) diff" } },
      -- Keep 'gy' as LSP type-definition in the diff buffers.
      { "n", "gy", false },
    },
    file_panel = {
      { "n", "<leader>dw", false },
      { "n", "<leader>du", false },
      { "n", "<leader>di", false },
      { "n", "<leader>gw", actions.toggle_ignore_whitespace, { desc = "Toggle ignoring whitespace changes" } },
      { "n", "<leader>gz", actions.toggle_unchanged_regions, { desc = "Toggle hiding unchanged regions" } },
      { "n", "<leader>gi", actions.toggle_inline_diff, { desc = "Toggle the inline (unified) diff" } },
    },
    file_history_panel = {
      { "n", "<leader>dw", false },
      { "n", "<leader>du", false },
      { "n", "<leader>di", false },
      { "n", "<leader>gw", actions.toggle_ignore_whitespace, { desc = "Toggle ignoring whitespace changes" } },
      { "n", "<leader>gz", actions.toggle_unchanged_regions, { desc = "Toggle hiding unchanged regions" } },
      { "n", "<leader>gi", actions.toggle_inline_diff, { desc = "Toggle the inline (unified) diff" } },
    },
  },
}
