local status_ok, diffview = pcall(require, "diffview")
if not status_ok then return end

diffview.setup {
  diff_binaries = false, -- Show diffs for binaries
  enhanced_diff_hl = true, -- Enhanced diff highlighting for better visibility
  git_cmd = { "git" }, -- The git executable to use
  use_icons = true, -- Requires nvim-web-devicons
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
    folder_closed = "",
    folder_open = "",
  },
  signs = {
    fold_closed = "",
    fold_open = "",
    done = "✓",
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
  hooks = {}, -- See ':h diffview-config-hooks'
  keymaps = {
    disable_defaults = false, -- Disable the default keymaps
    view = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      { "n", "<tab>", diffview.actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", diffview.actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", diffview.actions.goto_file, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", diffview.actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", diffview.actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "<leader>e", diffview.actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<leader>b", diffview.actions.toggle_files, { desc = "Toggle the file panel." } },
      { "n", "g<C-x>", diffview.actions.cycle_layout, { desc = "Cycle through available layouts" } },
      { "n", "[x", diffview.actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
      { "n", "]x", diffview.actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
      { "n", "<leader>co", diffview.actions.conflict_choose("ours"), { desc = "Choose the OURS version of a conflict" } },
      { "n", "<leader>ct", diffview.actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
      { "n", "<leader>cb", diffview.actions.conflict_choose("base"), { desc = "Choose the BASE version of a conflict" } },
      { "n", "<leader>ca", diffview.actions.conflict_choose("all"), { desc = "Choose all the versions of a conflict" } },
      { "n", "dx", diffview.actions.conflict_choose("none"), { desc = "Delete the conflict region" } },
    },
    diff1 = { -- Mappings in single window diff layouts
      { "n", "g?", diffview.actions.help({ "view", "diff1" }), { desc = "Open the help panel" } },
    },
    diff2 = { -- Mappings in 2-way diff layouts
      { "n", "g?", diffview.actions.help({ "view", "diff2" }), { desc = "Open the help panel" } },
    },
    diff3 = { -- Mappings in 3-way diff layouts
      { { "n", "x" }, "2do", diffview.actions.conflict_choose("ours"), { desc = "Choose the OURS version of a conflict" } },
      { { "n", "x" }, "3do", diffview.actions.conflict_choose("theirs"), { desc = "Choose the THEIRS version of a conflict" } },
      { "n", "g?", diffview.actions.help({ "view", "diff3" }), { desc = "Open the help panel" } },
    },
    diff4 = { -- Mappings in 4-way diff layouts
      { "n", "g?", diffview.actions.help({ "view", "diff4" }), { desc = "Open the help panel" } },
    },
    file_panel = {
      { "n", "j", diffview.actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "<down>", diffview.actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "k", diffview.actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
      { "n", "<up>", diffview.actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
      { "n", "<cr>", diffview.actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "o", diffview.actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "<2-LeftMouse>", diffview.actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "-", diffview.actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
      { "n", "S", diffview.actions.stage_all, { desc = "Stage all entries" } },
      { "n", "U", diffview.actions.unstage_all, { desc = "Unstage all entries" } },
      { "n", "X", diffview.actions.restore_entry, { desc = "Restore entry to the state on the left side" } },
      { "n", "L", diffview.actions.open_commit_log, { desc = "Open the commit log panel" } },
      { "n", "zo", diffview.actions.open_fold, { desc = "Expand fold" } },
      { "n", "zc", diffview.actions.close_fold, { desc = "Collapse fold" } },
      { "n", "zr", diffview.actions.open_all_folds, { desc = "Expand all folds" } },
      { "n", "zm", diffview.actions.close_all_folds, { desc = "Collapse all folds" } },
      { "n", "<c-b>", diffview.actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-f>", diffview.actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "tab", diffview.actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", diffview.actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", diffview.actions.goto_file, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", diffview.actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", diffview.actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "i", diffview.actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
      { "n", "f", diffview.actions.toggle_flatten_dirs, { desc = "Flatten empty subdirectories in tree listing style" } },
      { "n", "R", diffview.actions.refresh_files, { desc = "Update stats of the files" } },
      { "n", "<leader>e", diffview.actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<leader>b", diffview.actions.toggle_files, { desc = "Toggle the file panel" } },
      { "n", "g<C-x>", diffview.actions.cycle_layout, { desc = "Cycle available layouts" } },
      { "n", "[x", diffview.actions.prev_conflict, { desc = "Go to the previous conflict" } },
      { "n", "]x", diffview.actions.next_conflict, { desc = "Go to the next conflict" } },
      { "n", "g?", diffview.actions.help("file_panel"), { desc = "Open the help panel" } },
    },
    file_history_panel = {
      { "n", "g!", diffview.actions.options, { desc = "Open the options panel" } },
      { "n", "<C-A-d>", diffview.actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
      { "n", "y", diffview.actions.copy_hash, { desc = "Copy the commit hash" } },
      { "n", "L", diffview.actions.open_commit_log, { desc = "Show commit details" } },
      { "n", "zR", diffview.actions.open_all_folds, { desc = "Expand all folds" } },
      { "n", "zM", diffview.actions.close_all_folds, { desc = "Collapse all folds" } },
      { "n", "j", diffview.actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "<down>", diffview.actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "k", diffview.actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<up>", diffview.actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
      { "n", "<cr>", diffview.actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "o", diffview.actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<2-LeftMouse>", diffview.actions.select_entry, { desc = "Open the diff diff for the selected entry." } },
      { "n", "<c-b>", diffview.actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-f>", diffview.actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "tab", diffview.actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", diffview.actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", diffview.actions.goto_file, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", diffview.actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", diffview.actions.goto_file_split, { desc = "Open the file in a new tabpage" } },
      { "n", "<leader>e", diffview.actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<leader>b", diffview.actions.toggle_files, { desc = "Toggle the file panel" } },
      { "n", "g<C-x>", diffview.actions.cycle_layout, { desc = "Cycle available layouts" } },
      { "n", "g?", diffview.actions.help("file_history_panel"), { desc = "Open the help panel" } },
    },
    option_panel = {
      { "n", "<tab>", diffview.actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "q", diffview.actions.close, { desc = "Close the panel" } },
      { "n", "g?", diffview.actions.help("option_panel"), { desc = "Open the help panel" } },
    },
  },
}
