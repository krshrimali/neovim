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
    folder_closed = "",
    folder_open = "",
  },
  signs = {
    fold_closed = "",
    fold_open = "",
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
    disable_defaults = false, -- Disable the default keymaps
    view = {
      -- The `view` bindings are active in the diff buffers, only when the current
      -- tabpage is a Diffview.
      { "n", "<tab>", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel." } },
      { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle through available layouts" } },
      { "n", "[x", actions.prev_conflict, { desc = "In the merge-tool: jump to the previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "In the merge-tool: jump to the next conflict" } },
      {
        "n",
        "<leader>co",
        actions.conflict_choose "ours",
        { desc = "Choose the OURS version of a conflict" },
      },
      {
        "n",
        "<leader>ct",
        actions.conflict_choose "theirs",
        { desc = "Choose the THEIRS version of a conflict" },
      },
      {
        "n",
        "<leader>cb",
        actions.conflict_choose "base",
        { desc = "Choose the BASE version of a conflict" },
      },
      {
        "n",
        "<leader>ca",
        actions.conflict_choose "all",
        { desc = "Choose all the versions of a conflict" },
      },
      { "n", "dx", actions.conflict_choose "none", { desc = "Delete the conflict region" } },

      -- Partial staging (':h diffview-partial-staging'). Works on the hunk
      -- under the cursor in normal mode, and on the selected lines in visual
      -- mode. Upstream puts these on '<leader>h*', which is nohlsearch here,
      -- so they're mirrored onto the gitsigns bindings instead: the same keys
      -- now stage a hunk in a regular buffer and in a diff.
      { { "n", "x" }, "<leader>hs", false },
      { { "n", "x" }, "<leader>hu", false },
      { { "n", "x" }, "<leader>hr", false },
      { { "n", "x" }, "<leader>gs", actions.stage_hunk, { desc = "Stage the hunk / selection" } },
      { { "n", "x" }, "<leader>gu", actions.unstage_hunk, { desc = "Unstage the hunk / selection" } },
      { { "n", "x" }, "<leader>gr", actions.restore_hunk, { desc = "Discard the hunk / selection" } },

      -- Jump between the changes of the whole view: unlike the built-in
      -- motions these roll over into the next / previous file.
      { "n", "]c", actions.next_change, { desc = "Next change in the view" } },
      { "n", "[c", actions.prev_change, { desc = "Previous change in the view" } },

      -- Display toggles. Upstream puts these on '<leader>d*', which is the
      -- black-hole delete here.
      { "n", "<leader>dw", false },
      { "n", "<leader>du", false },
      { "n", "<leader>di", false },
      { "n", "<leader>gw", actions.toggle_ignore_whitespace, { desc = "Toggle ignoring whitespace changes" } },
      { "n", "<leader>gz", actions.toggle_unchanged_regions, { desc = "Toggle hiding unchanged regions" } },
      { "n", "<leader>gi", actions.toggle_inline_diff, { desc = "Toggle the inline (unified) diff" } },

      -- Keep 'gy' as LSP type-definition in the diff buffers.
      { "n", "gy", false },
      -- PR/review actions are explicit here so their availability does not
      -- depend on default-keymap merge order.
      { "n", "<leader>rC", actions.request_claude_review, { desc = "PR: request Claude review" } },
      { "n", "gpc", actions.pr_tab_conversation, { desc = "PR: Conversation view" } },
      { "n", "gpm", actions.pr_tab_commits, { desc = "PR: Commits view" } },
      { "n", "gpt", actions.pr_toggle_threads, { desc = "PR: toggle comments panel" } },
      { "n", "gpi", actions.pr_import_comments, { desc = "PR: refresh GitHub comments" } },
    },
    diff1 = { -- Mappings in single window diff layouts
      { "n", "g?", actions.help { "view", "diff1" }, { desc = "Open the help panel" } },
    },
    diff2 = { -- Mappings in 2-way diff layouts
      { "n", "g?", actions.help { "view", "diff2" }, { desc = "Open the help panel" } },
    },
    diff3 = { -- Mappings in 3-way diff layouts
      {
        { "n", "x" },
        "2do",
        actions.conflict_choose "ours",
        { desc = "Choose the OURS version of a conflict" },
      },
      {
        { "n", "x" },
        "3do",
        actions.conflict_choose "theirs",
        { desc = "Choose the THEIRS version of a conflict" },
      },
      { "n", "g?", actions.help { "view", "diff3" }, { desc = "Open the help panel" } },
    },
    diff4 = { -- Mappings in 4-way diff layouts
      { "n", "g?", actions.help { "view", "diff4" }, { desc = "Open the help panel" } },
    },
    file_panel = {
      { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
      { "n", "<up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
      { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage the selected entry" } },
      { "n", "S", actions.stage_all, { desc = "Stage all entries" } },
      { "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
      { "n", "X", actions.restore_entry, { desc = "Restore entry to the state on the left side" } },
      { "n", "L", actions.open_commit_log, { desc = "Open the commit log panel" } },
      { "n", "zo", actions.open_fold, { desc = "Expand fold" } },
      { "n", "zc", actions.close_fold, { desc = "Collapse fold" } },
      { "n", "zr", actions.open_all_folds, { desc = "Expand all folds" } },
      { "n", "zm", actions.close_all_folds, { desc = "Collapse all folds" } },
      { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "tab", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "i", actions.listing_style, { desc = "Toggle between 'list' and 'tree' views" } },
      {
        "n",
        "f",
        actions.toggle_flatten_dirs,
        { desc = "Flatten empty subdirectories in tree listing style" },
      },
      { "n", "<C-r>", actions.refresh_files, { desc = "Update stats of the files" } },
      { "n", "R", actions.reply_review_comment, { desc = "Reply to selected local review comment" } },
      { "n", "r", actions.toggle_review_resolved, { desc = "Resolve selected local review comment" } },
      { "n", "e", actions.edit_review_comment, { desc = "Edit selected local review comment" } },
      { "n", "dd", actions.delete_review_comment, { desc = "Delete selected local review comment" } },
      { "n", "<space>", actions.toggle_comment_replies, { desc = "Fold/unfold selected review thread" } },
      { "n", "Q", actions.review_comments_quickfix, { desc = "Review comments to quickfix" } },
      { "n", "<leader>rC", actions.request_claude_review, { desc = "PR: request Claude review" } },
      { "n", "gpt", actions.pr_toggle_threads, { desc = "PR: toggle comments panel" } },
      { "n", "gpi", actions.pr_import_comments, { desc = "PR: refresh GitHub comments" } },
      { "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
      { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
      { "n", "[x", actions.prev_conflict, { desc = "Go to the previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "Go to the next conflict" } },
      { "n", "g?", actions.help "file_panel", { desc = "Open the help panel" } },

      -- Commit what's staged without leaving the view. Opens a gitcommit
      -- buffer: '<C-c><C-c>' or ':w' commits, 'q' aborts.
      { "n", "cc", actions.commit, { desc = "Commit the staged changes" } },
      { "n", "ca", actions.amend_commit, { desc = "Amend the last commit" } },

      -- Only list the files whose path matches a string. An empty pattern
      -- clears the filter. Use ':/' to search the panel buffer itself.
      { "n", "/", actions.filter_files, { desc = "Filter the file list" } },

      -- Same as nvim-tree: 'gy' copies the path of the entry.
      { "n", "gy", actions.copy_file_path, { desc = "Copy the path of the entry" } },

      { "n", "]c", actions.next_change, { desc = "Next change in the view" } },
      { "n", "[c", actions.prev_change, { desc = "Previous change in the view" } },

      -- Same remaps as the view group.
      { "n", "<leader>dw", false },
      { "n", "<leader>du", false },
      { "n", "<leader>di", false },
      { "n", "<leader>gw", actions.toggle_ignore_whitespace, { desc = "Toggle ignoring whitespace changes" } },
      { "n", "<leader>gz", actions.toggle_unchanged_regions, { desc = "Toggle hiding unchanged regions" } },
      { "n", "<leader>gi", actions.toggle_inline_diff, { desc = "Toggle the inline (unified) diff" } },
    },
    file_history_panel = {
      { "n", "g!", actions.options, { desc = "Open the options panel" } },
      { "n", "<C-A-d>", actions.open_in_diffview, { desc = "Open the entry under the cursor in a diffview" } },
      { "n", "y", actions.copy_hash, { desc = "Copy the commit hash" } },
      { "n", "L", actions.open_commit_log, { desc = "Show commit details" } },
      { "n", "zR", actions.open_all_folds, { desc = "Expand all folds" } },
      { "n", "zM", actions.close_all_folds, { desc = "Collapse all folds" } },
      { "n", "j", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "<down>", actions.next_entry, { desc = "Bring the cursor to the next file entry" } },
      { "n", "k", actions.prev_entry, { desc = "Bring the cursor to the previous file entry." } },
      { "n", "<up>", actions.prev_entry, { desc = "Bring the cursor to the previous file entry" } },
      { "n", "<cr>", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "o", actions.select_entry, { desc = "Open the diff for the selected entry." } },
      { "n", "<2-LeftMouse>", actions.select_entry, { desc = "Open the diff diff for the selected entry." } },
      { "n", "<c-b>", actions.scroll_view(-0.25), { desc = "Scroll the view up" } },
      { "n", "<c-f>", actions.scroll_view(0.25), { desc = "Scroll the view down" } },
      { "n", "tab", actions.select_next_entry, { desc = "Open the diff for the next file" } },
      { "n", "<s-tab>", actions.select_prev_entry, { desc = "Open the diff for the previous file" } },
      { "n", "gf", actions.goto_file_edit, { desc = "Open the file in the previous tabpage" } },
      { "n", "<C-w><C-f>", actions.goto_file_split, { desc = "Open the file in a new split" } },
      { "n", "<C-w>gf", actions.goto_file_tab, { desc = "Open the file in a new tabpage" } },
      { "n", "<leader>e", actions.focus_files, { desc = "Bring focus to the file panel" } },
      { "n", "<leader>b", actions.toggle_files, { desc = "Toggle the file panel" } },
      { "n", "g<C-x>", actions.cycle_layout, { desc = "Cycle available layouts" } },
      { "n", "g?", actions.help "file_history_panel", { desc = "Open the help panel" } },

      -- 'y' copies the commit hash (above), 'gy' the path of the entry.
      { "n", "gy", actions.copy_file_path, { desc = "Copy the path of the entry" } },

      { "n", "]c", actions.next_change, { desc = "Next change in the view" } },
      { "n", "[c", actions.prev_change, { desc = "Previous change in the view" } },

      -- Same remaps as the view group.
      { "n", "<leader>dw", false },
      { "n", "<leader>du", false },
      { "n", "<leader>di", false },
      { "n", "<leader>gw", actions.toggle_ignore_whitespace, { desc = "Toggle ignoring whitespace changes" } },
      { "n", "<leader>gz", actions.toggle_unchanged_regions, { desc = "Toggle hiding unchanged regions" } },
      { "n", "<leader>gi", actions.toggle_inline_diff, { desc = "Toggle the inline (unified) diff" } },
    },
    option_panel = {
      { "n", "<tab>", actions.select_entry, { desc = "Open the diff for the selected entry" } },
      { "n", "q", actions.close, { desc = "Close the panel" } },
      { "n", "g?", actions.help "option_panel", { desc = "Open the help panel" } },
    },
  },
}
