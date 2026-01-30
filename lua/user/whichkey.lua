-- Which-Key Configuration
-- Shows keybindings in a popup when you press leader key

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then return end

-- Setup which-key with modern preset
which_key.setup {
  preset = "modern", -- "classic", "modern", or "helix"
  delay = 500, -- Delay before showing which-key popup (ms)

  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20,
    },
    presets = {
      operators = true, -- adds help for operators like d, y, ...
      motions = true, -- adds help for motions
      text_objects = true, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },

  win = {
    border = "rounded",
    padding = { 1, 2 },
  },

  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },

  layout = {
    height = { min = 4, max = 25 },
    width = { min = 20, max = 50 },
    spacing = 3,
    align = "left",
  },
}

-- Surround keymaps (nvim-surround)
which_key.add {
  { "ys", group = "Surround add" },
  { "ysiw", desc = "Surround word" },
  { "ysi", desc = "Surround inner..." },
  { "ysa", desc = "Surround around..." },
  { "ys$", desc = "Surround to EOL" },
  { "yss", desc = "Surround line" },

  { "ds", group = "Surround delete" },
  { "ds\"", desc = "Delete quotes" },
  { "ds'", desc = "Delete single quotes" },
  { "ds)", desc = "Delete parens" },
  { "ds]", desc = "Delete brackets" },
  { "ds}", desc = "Delete braces" },
  { "dst", desc = "Delete HTML tag" },

  { "cs", group = "Surround change" },
  { "cs\"", desc = "Change from quotes" },
  { "cs'", desc = "Change from single quotes" },
  { "cs)", desc = "Change from parens" },
  { "cs]", desc = "Change from brackets" },
  { "cs}", desc = "Change from braces" },
  { "cst", desc = "Change HTML tag" },
}

-- Visual mode surround
which_key.add {
  mode = { "v" },
  { "S", desc = "Surround selection" },
}

-- Register keymaps with descriptions
-- Normal mode mappings
which_key.add {
  -- Basic operations
  { "<leader>w", "<cmd>w<CR>", desc = "Save" },
  { "<leader>h", "<cmd>nohlsearch<CR>", desc = "No Highlight" },
  { "<leader>q", "<cmd>lua require('user.functions').smart_quit()<CR>", desc = "Quit" },
  { "<leader>Q", "<cmd>lua require('user.functions').force_quit()<CR>", desc = "Force Quit" },
  { "<leader>fq", "<cmd>q!<CR>", desc = "Force Quit Without Prompt" },

  -- Buffer operations
  { "<leader>b", group = "Buffers" },
  { "<leader>b", "<cmd>FzfLua buffers<cr>", desc = "List Buffers" },

  -- Diagnostics
  { "<leader>d", group = "Diagnostics" },
  {
    "<leader>dl",
    "<cmd>lua require('user.diagnostics_display').show_line_diagnostics()<cr>",
    desc = "Line Diagnostics",
  },
  {
    "<leader>df",
    "<cmd>lua require('user.diagnostics_display').show_file_diagnostics()<cr>",
    desc = "File Diagnostics",
  },
  {
    "<leader>dw",
    "<cmd>lua require('user.diagnostics_display').show_workspace_diagnostics()<cr>",
    desc = "Workspace Diagnostics",
  },
  { "<leader>dd", "<cmd>lua require('user.diagnostics_display').debug()<cr>", desc = "Debug Diagnostics" },

  -- File Explorer
  { "<leader><leader>", group = "Extra" },
  { "<leader><leader>e", "<cmd>:NvimTreeToggle<cr>", desc = "File Explorer" },
  { "<leader><leader>f", ":lua find_files()<CR>", desc = "Find Files (Current Dir)" },
  { "<leader><leader>g", ":lua live_grep()<CR>", desc = "Live Grep (Current Dir)" },
  { "<leader><leader>s", ":FzfLua command_history<CR>", desc = "Command History" },

  -- Find (FzfLua)
  { "<leader>f", group = "Find" },
  { "<leader>ff", "<cmd>FzfLua files<cr>", desc = "Find Files" },
  { "<leader>fg", "<cmd>FzfLua git_files<cr>", desc = "Git Files" },
  { "<leader>fr", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files" },
  { "<leader>fp", "<cmd>FzfLua oldfiles<cr>", desc = "Recent Files (Projects)" },
  { "<leader>fh", "<cmd>FzfLua helptags<cr>", desc = "Help Tags" },
  { "<leader>fH", "<cmd>FzfLua highlights<cr>", desc = "Highlights" },
  { "<leader>fc", "<cmd>FzfLua colorschemes<cr>", desc = "Colorschemes" },
  { "<leader>fk", "<cmd>FzfLua keymaps<cr>", desc = "Keymaps" },
  { "<leader>fC", "<cmd>FzfLua commands<cr>", desc = "Commands" },
  { "<leader>fR", "<cmd>FzfLua registers<cr>", desc = "Registers" },
  { "<leader>fM", "<cmd>FzfLua manpages<cr>", desc = "Man Pages" },
  { "<leader>fl", "<cmd>FzfLua resume<cr>", desc = "Resume Last Search" },
  { "<leader>fB", "<cmd>FzfLua git_branches<cr>", desc = "Git Branches" },
  { "<leader>fb", desc = "Find in Base" },
  { "<leader>fi", "<cmd>FzfLua lsp_incoming_calls<cr>", desc = "LSP Incoming Calls" },
  { "<leader>fo", "<cmd>FzfLua lsp_outgoing_calls<cr>", desc = "LSP Outgoing Calls" },
  { "<leader>fI", "<cmd>FzfLua lsp_implementations<cr>", desc = "LSP Implementations" },
  { "<leader>/", "<cmd>FzfLua live_grep<cr>", desc = "Live Grep" },

  -- Find/Search in buffer
  { "<leader>fs", group = "Search" },
  { "<leader>fss", "<cmd>FzfLua grep_cword<cr>", desc = "Grep Word Under Cursor" },
  { "<leader>fsb", "<cmd>FzfLua grep_curbuf<cr>", desc = "Grep Current Buffer" },

  -- Git
  { "<leader>g", group = "Git" },
  { "<leader>gg", "<cmd>lua require('user.terminal').lazygit_float()<cr>", desc = "Lazygit (Float)" },
  { "<leader>gt", "<cmd>lua require('user.terminal').lazygit_tab()<cr>", desc = "Lazygit (Tab)" },
  { "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", desc = "Next Hunk" },
  { "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", desc = "Prev Hunk" },
  { "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", desc = "Preview Hunk" },
  { "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", desc = "Reset Hunk" },
  { "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", desc = "Reset Buffer" },
  { "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", desc = "Stage Hunk" },
  { "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", desc = "Undo Stage Hunk" },
  { "<leader>go", "<cmd>FzfLua git_status<cr>", desc = "Git Status" },
  { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
  { "<leader>gD", "<cmd>Gitsigns diffthis HEAD<cr>", desc = "Diff This (Inline)" },
  { "<leader>gb", desc = "Grep in Base" },

  -- Git Diffview
  { "<leader>gd", group = "Diffview" },
  { "<leader>gdo", "<cmd>DiffviewOpen<cr>", desc = "Open Diffview" },
  { "<leader>gdc", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
  { "<leader>gdh", "<cmd>DiffviewFileHistory<cr>", desc = "File History" },
  { "<leader>gdf", "<cmd>DiffviewFileHistory %<cr>", desc = "Current File History" },
  { "<leader>gdt", "<cmd>DiffviewToggleFiles<cr>", desc = "Toggle File Panel" },

  -- Git Blame
  { "<leader>gl", group = "Git Blame" },
  { "<leader>gll", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
  { "<leader>glf", "<cmd>Git blame<cr>", desc = "Git Blame (Fugitive)" },
  { "<leader>glg", "<cmd>Gitsigns blame_line<cr>", desc = "Blame Line" },
  { "<leader>glb", "<cmd>Gitsigns blame_line<cr>", desc = "Blame Line" },

  -- GitHub
  { "<leader>gh", group = "GitHub" },
  { "<leader>gh", "<cmd>Github<cr>", desc = "GitHub Menu" },
  { "<leader>ghi", "<cmd>GithubIssues<cr>", desc = "GitHub Issues" },
  { "<leader>ghp", "<cmd>GithubPRs<cr>", desc = "GitHub PRs" },
  { "<leader>gha", "<cmd>GithubAssigned<cr>", desc = "GitHub Assigned" },

  -- Git (Snacks)
  { "<leader>gy", desc = "Git Browse (copy)" },

  -- GitBlame (capital G)
  { "<leader>G", group = "GitBlame" },
  { "<leader>Gl", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
  { "<leader>Gc", "<cmd>GitBlameCopySHA<cr>", desc = "Copy SHA" },
  { "<leader>Go", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open Commit URL" },

  -- LSP
  { "<leader>l", group = "LSP" },
  { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
  { "<leader>lf", "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", desc = "Format" },
  { "<leader>li", "<cmd>LspInfo<cr>", desc = "LSP Info" },
  { "<leader>lI", "<cmd>Mason<cr>", desc = "Mason Installer" },
  { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", desc = "Next Diagnostic" },
  { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", desc = "Prev Diagnostic" },
  {
    "<leader>ll",
    "<cmd>lua require('user.lsp.virtual_diagnostics').toggle_virtual_lines()<cr>",
    desc = "Toggle Virtual Lines",
  },
  {
    "<leader>lv",
    "<cmd>lua require('user.lsp.virtual_diagnostics').toggle_virtual_text()<cr>",
    desc = "Toggle Virtual Text",
  },
  {
    "<leader>ld",
    "<cmd>lua require('user.lsp.virtual_diagnostics').show_line_diagnostics()<cr>",
    desc = "Line Diagnostics",
  },
  { "<leader>lb", "<cmd>lua require('user.breadcrumbs_float').toggle()<cr>", desc = "Breadcrumbs (Float)" },
  { "<leader>lo", "<cmd>Outline<cr>", desc = "Outline" },
  { "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix" },
  { "<leader>lQ", "<cmd>FzfLua quickfix<cr>", desc = "Quickfix (FzfLua)" },
  { "<leader>lr", "<cmd>Trouble lsp_references<cr>", desc = "References" },
  { "<leader>ls", "<cmd>lua require('user.symbol_browser').toggle()<cr>", desc = "Symbol Browser" },
  { "<leader>lS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", desc = "Workspace Symbols" },
  { "<leader>lt", '<cmd>lua require("user.functions").toggle_diagnostics()<cr>', desc = "Toggle Diagnostics" },
  { "<leader>lu", "<cmd>LuaSnipUnlinkCurrent<cr>", desc = "Unlink Snippet" },
  { "<leader>lH", "<cmd>IlluminateToggle<cr>", desc = "Toggle Illuminate" },
  { "<leader>cl", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },

  -- LSP Goto Preview
  { "<leader>lg", group = "Goto Preview" },
  { "<leader>lgg", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Preview Definition" },
  {
    "<leader>lgt",
    "<cmd>lua require('goto-preview').goto_preview_type_definition()<cr>",
    desc = "Preview Type Definition",
  },
  {
    "<leader>lgi",
    "<cmd>lua require('goto-preview').goto_preview_implementation()<cr>",
    desc = "Preview Implementation",
  },
  { "<leader>lgr", "<cmd>lua require('goto-preview').goto_preview_references()<cr>", desc = "Preview References" },
  { "<leader>lgc", "<cmd>lua require('goto-preview').close_all_win()<cr>", desc = "Close All Previews" },
  { "<leader>lgw", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close All Windows" },

  -- Window management
  { "<leader>k", group = "Window" },
  { "<leader>ks", "<cmd>split<cr>", desc = "Horizontal Split" },
  { "<leader>kv", "<cmd>vsplit<cr>", desc = "Vertical Split" },


  -- Octo (GitHub) - comprehensive keymaps
  { "<leader>o", group = "Octo (GitHub)" },

  -- Issues
  { "<leader>oi", group = "Issues" },
  { "<leader>oi", "<CMD>Octo issue list<CR>", desc = "List Issues" },
  { "<leader>oic", "<CMD>Octo issue create<CR>", desc = "Create Issue" },
  { "<leader>oio", "<CMD>Octo issue browser<CR>", desc = "Open Issue in Browser" },
  { "<leader>oix", "<CMD>Octo issue close<CR>", desc = "Close Issue" },
  { "<leader>oir", "<CMD>Octo issue reopen<CR>", desc = "Reopen Issue" },
  { "<leader>ois", "<CMD>Octo issue search<CR>", desc = "Search Issues" },

  -- Pull Requests
  { "<leader>op", group = "Pull Requests" },
  { "<leader>op", "<CMD>Octo pr list<CR>", desc = "List PRs" },
  { "<leader>opc", "<CMD>Octo pr create<CR>", desc = "Create PR" },
  { "<leader>opo", "<CMD>Octo pr browser<CR>", desc = "Open PR in Browser" },
  { "<leader>opx", "<CMD>Octo pr close<CR>", desc = "Close PR" },
  { "<leader>opr", "<CMD>Octo pr reopen<CR>", desc = "Reopen PR" },
  { "<leader>opm", "<CMD>Octo pr merge<CR>", desc = "Merge PR" },
  { "<leader>opd", "<CMD>Octo pr diff<CR>", desc = "Show PR Diff" },
  { "<leader>ops", "<CMD>Octo pr search<CR>", desc = "Search PRs" },
  { "<leader>opp", "<CMD>Octo pr commits<CR>", desc = "PR Commits" },
  { "<leader>opf", "<CMD>Octo pr changes<CR>", desc = "PR Changed Files" },
  { "<leader>opk", "<CMD>Octo pr checkout<CR>", desc = "Checkout PR" },
  { "<leader>ope", "<CMD>Octo pr ready<CR>", desc = "Mark PR Ready" },

  -- Reviews
  { "<leader>or", group = "Reviews" },
  { "<leader>ors", "<CMD>Octo review start<CR>", desc = "Start Review" },
  { "<leader>orr", "<CMD>Octo review resume<CR>", desc = "Resume Review" },
  { "<leader>orc", "<CMD>Octo review comments<CR>", desc = "Review Comments" },
  { "<leader>ord", "<CMD>Octo review discard<CR>", desc = "Discard Review" },
  { "<leader>ora", "<CMD>Octo review submit<CR>", desc = "Submit Review (Approve)" },
  { "<leader>orx", "<CMD>Octo review close<CR>", desc = "Close Review" },

  -- Comments
  { "<leader>oc", group = "Comments" },
  { "<leader>oca", "<CMD>Octo comment add<CR>", desc = "Add Comment" },
  { "<leader>ocd", "<CMD>Octo comment delete<CR>", desc = "Delete Comment" },

  -- Threads
  { "<leader>ot", group = "Threads" },
  { "<leader>otr", "<CMD>Octo thread resolve<CR>", desc = "Resolve Thread" },
  { "<leader>otu", "<CMD>Octo thread unresolve<CR>", desc = "Unresolve Thread" },

  -- Reactions
  { "<leader>oe", group = "Reactions" },
  { "<leader>oe+", "<CMD>Octo reaction thumbs_up<CR>", desc = "👍" },
  { "<leader>oe-", "<CMD>Octo reaction thumbs_down<CR>", desc = "👎" },
  { "<leader>oeh", "<CMD>Octo reaction heart<CR>", desc = "❤️" },
  { "<leader>oer", "<CMD>Octo reaction rocket<CR>", desc = "🚀" },
  { "<leader>oee", "<CMD>Octo reaction eyes<CR>", desc = "👀" },
  { "<leader>oel", "<CMD>Octo reaction laugh<CR>", desc = "😄" },
  { "<leader>oec", "<CMD>Octo reaction confused<CR>", desc = "😕" },
  { "<leader>oep", "<CMD>Octo reaction party<CR>", desc = "🎉" },

  -- Labels
  { "<leader>ol", group = "Labels" },
  { "<leader>ola", "<CMD>Octo label add<CR>", desc = "Add Label" },
  { "<leader>olr", "<CMD>Octo label remove<CR>", desc = "Remove Label" },
  { "<leader>olc", "<CMD>Octo label create<CR>", desc = "Create Label" },

  -- Assignees
  { "<leader>oa", group = "Assignees" },
  { "<leader>oaa", "<CMD>Octo assignee add<CR>", desc = "Add Assignee" },
  { "<leader>oar", "<CMD>Octo assignee remove<CR>", desc = "Remove Assignee" },

  -- Discussions
  { "<leader>od", group = "Discussions" },
  { "<leader>od", "<CMD>Octo discussion list<CR>", desc = "List Discussions" },
  { "<leader>odc", "<CMD>Octo discussion create<CR>", desc = "Create Discussion" },
  { "<leader>odo", "<CMD>Octo discussion browser<CR>", desc = "Open Discussion in Browser" },
  { "<leader>odx", "<CMD>Octo discussion close<CR>", desc = "Close Discussion" },
  { "<leader>odr", "<CMD>Octo discussion reopen<CR>", desc = "Reopen Discussion" },

  -- Notifications
  { "<leader>on", group = "Notifications" },
  { "<leader>on", "<CMD>Octo notification list<CR>", desc = "List Notifications" },

  -- Search
  { "<leader>os", group = "Search" },
  { "<leader>os", desc = "Search GitHub" },

  -- Repo Operations
  { "<leader>oR", group = "Repo" },
  { "<leader>oRf", "<CMD>Octo repo fork<CR>", desc = "Fork Repo" },
  { "<leader>oRb", "<CMD>Octo repo browser<CR>", desc = "Open Repo in Browser" },
  { "<leader>oRl", "<CMD>Octo repo list<CR>", desc = "List User Repos" },

  -- Gists
  { "<leader>og", group = "Gists" },
  { "<leader>ogl", "<CMD>Octo gist list<CR>", desc = "List Gists" },

  -- Rename (LSP)
  { "<leader>rn", vim.lsp.buf.rename, desc = "Rename (LSP)" },

  -- Terminal (using user.terminal)
  { "<leader>T", group = "Terminal" },
  { "<leader>Tf", "<cmd>lua _FLOAT_TERM()<cr>", desc = "Float" },
  { "<leader>Tv", "<cmd>lua _VERTICAL_TERM()<cr>", desc = "Vertical" },
  { "<leader>Th", "<cmd>lua _HORIZONTAL_TERM()<cr>", desc = "Horizontal" },

  -- Telescope/FzfLua
  { "<leader>t", group = "Telescope" },
  { "<leader>tc", "<cmd>lua require('user.lsp.blink').toggle()<cr>", desc = "Toggle Completion" },
  { "<leader>tgS", "<cmd>FzfLua git_stash<cr>", desc = "Git Stash" },
  { "<leader>tC", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
  { "<leader>tj", "<cmd>FzfLua jumps<cr>", desc = "Jumps" },
  { "<leader>th", "<cmd>FzfLua search_history<cr>", desc = "Search History" },
  { "<leader>tb", "<cmd>FzfLua builtin<cr>", desc = "Builtin" },
  { "<leader>tS", "<cmd>FzfLua blines<cr>", desc = "Buffer Lines" },
  { "<leader>tp", "<cmd>FzfLua files<cr>", desc = "Project Files" },

  -- Trouble
  { "<leader>x", group = "Trouble" },
  { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
  { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
  { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
  { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },

  -- Copy utilities
  { "<leader>y", group = "Yank" },
  { "<leader>yi", "<cmd>lua require('user.copy_utils').copy_python_import()<cr>", desc = "Copy Python Import" },
  { "<leader>yp", "<cmd>lua require('user.copy_utils').copy_absolute_path()<cr>", desc = "Copy Absolute Path" },
  { "<leader>yr", "<cmd>lua require('user.copy_utils').copy_relative_path()<cr>", desc = "Copy Relative Path" },

  -- Claude Code
  { "<leader>a", group = "AI/Claude" },
  { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Model" },
  { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add Buffer" },
  { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Diff" },
  { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny Diff" },

  -- Space prefix (CocList replacements)
  { "<space>a", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics" },
  { "<space>s", "<cmd>FzfLua lsp_workspace_symbols<cr>", desc = "Symbols" },
  { "<space>e", "<cmd>Mason<cr>", desc = "Extensions" },
  { "<space>c", "<cmd>FzfLua commands<cr>", desc = "Commands" },
  { "<space>p", "<cmd>FzfLua resume<cr>", desc = "Resume" },
  { "<space>ls", "<cmd>lua require('user.symbol_browser').toggle()<cr>", desc = "Symbol Browser" },
}

-- Visual mode mappings
which_key.add {
  mode = { "v" },
  { "<leader>a", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
  { "<leader>f", desc = "Format Selection" },
  { "<leader><cr>", "<cmd>ClaudeCodeSend<cr>", desc = "Send to Claude" },
}
