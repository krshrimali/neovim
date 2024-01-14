local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
  return
end

local setup = {
  plugins = {
    marks = true, -- shows a list of your marks on ' and `
    registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    spelling = {
      enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
      suggestions = 20, -- how many suggestions should be shown in the list?
    },
    -- the presets plugin, adds help for a bunch of default keybindings in Neovim
    -- No actual key bindings are created
    presets = {
      operators = false, -- adds help for operators like d, y, ... and registers them for motion / text object completion
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = true, -- default bindings on <c-w>
      nav = true, -- misc bindings to work with windows
      z = true, -- bindings for folds, spelling and others prefixed with z
      g = true, -- bindings for prefixed with g
    },
  },
  -- add operators that will trigger motion and text object completion
  -- to enable all native operators, set the preset / operators plugin above
  -- operators = { gc = "Comments" },
  key_labels = {
    -- override the label used to display some keys. It doesn't effect WK in any other way.
    -- For example:
    -- ["<space>"] = "SPC",
    ["<leader>"] = "SPC",
    -- ["<cr>"] = "RET",
    -- ["<tab>"] = "TAB",
  },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  popup_mappings = {
    scroll_down = "<c-d>", -- binding to scroll down inside the popup
    scroll_up = "<c-u>", -- binding to scroll up inside the popup
  },
  window = {
    border = "rounded", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
    winblend = 0,
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
    align = "center", -- align columns left, center or right
  },
  ignore_missing = true, -- enable this to hide mappings for which you didn't specify a label
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
  show_help = false, -- show help message on the command line when the popup is visible
  -- triggers = "auto", -- automatically setup triggers
  -- triggers = {"<leader>"} -- or specify a list manually
  triggers_blacklist = {
    -- list of mode / prefixes that should never be hooked by WhichKey
    -- this is mostly relevant for key maps that start with a native binding
    -- most people should not need to change this
    i = { "j", "k" },
    v = { "j", "k" },
  },
}

local opts = {
  mode = "n", -- NORMAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local m_opts = {
  mode = "n", -- NORMAL mode
  prefix = "m",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}

local m_mappings = {
  a = { "<cmd>silent BookmarkAnnotate<cr>", "Annotate" },
  c = { "<cmd>silent BookmarkClear<cr>", "Clear" },
  b = { "<cmd>silent BookmarkToggle<cr>", "Toggle" },
  m = { '<cmd>lua require("harpoon.mark").add_file()<cr>', "Harpoon" },
  ["."] = { '<cmd>lua require("harpoon.ui").nav_next()<cr>', "Harpoon Next" },
  [","] = { '<cmd>lua require("harpoon.ui").nav_prev()<cr>', "Harpoon Prev" },
  l = { "<cmd>lua require('user.bfs').open()<cr>", "Buffers" },
  j = { "<cmd>silent BookmarkNext<cr>", "Next" },
  s = { "<cmd>Telescope harpoon marks<cr>", "Search Files" },
  k = { "<cmd>silent BookmarkPrev<cr>", "Prev" },
  S = { "<cmd>silent BookmarkShowAll<cr>", "Prev" },
  -- s = {
  --   "<cmd>lua require('telescope').extensions.vim_bookmarks.all({ hide_filename=false, prompt_title=\"bookmarks\", shorten_path=false })<cr>",
  --   "Show",
  -- },
  x = { "<cmd>BookmarkClearAll<cr>", "Clear All" },
  [";"] = { '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>', "Harpoon UI" },
}

local mappings = {
  -- ["1"] = "which_key_ignore",
  -- a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Action" },
  A = {
    name = "AutoRunner",
    r = { "<cmd>AutoRunnerRun<cr>", "Run the command" },
    t = { "<cmd>AutoRunnerToggle<cr>", "Toggle output window" },
    e = { "<cmd>AutoRunnerEditFile<cr>", "Edit build file/command (if available)" },
    a = { "<cmd>AutoRunnerAddCommand<cr>", "Add/change command" },
    c = { "<cmd>AutoRunnerClearBuffer<cr>", "Clear buffer" },
    C = { "<cmd>AutoRunnerClearAll<cr>", "Clear all (command and buffers)" },
    p = { "<cmd>AutoRunnerPrintCommand<cr>", "Print command" },
  },
  a = {
    name = "Aerial",
    a = { "<cmd>AerialOpenAll<cr>", "Open all" },
    c = { "<cmd>AerialCloseAll<cr>", "Close all" },
    o = { "<cmd>AerialOpen<cr>", "Open" },
    n = { "<cmd>AerialNavToggle<cr>", "Nav Toggle"},
    t = { "<cmd>AerialToggle<cr>", "Toggle" },
  },
  -- a = {
  --   name = "AutoRunnerTerm",
  --   r = { "<cmd>AutoRunnerTermRun<cr>", "Run the command" },
  --   t = { "<cmd>AutoRunnerTermToggle<cr>", "Toggle output window" },
  --   e = { "<cmd>AutoRunnerEditFile<cr>", "Edit build file/command (if available)" },
  --   a = { "<cmd>AutoRunnerAddCommand<cr>", "Add/change command" },
  --   p = { "<cmd>AutoRunnerPrintCommand<cr>", "Print command" },
  -- },
  b = { "<cmd>Telescope buffers<cr>", "Buffers" },
  e = { "<cmd>NvimTreeToggle<cr>", "Explorer" },
  -- v = { "<cmd>vsplit<cr>", "vsplit" },
  -- s = { "<cmd>split<cr>", "split" },
  w = { "<cmd>w<CR>", "Write" },
  h = { "<cmd>nohlsearch<CR>", "No HL" },
  q = { '<cmd>lua require("user.functions").smart_quit()<CR>', "Quit" },
  ["/"] = { '<cmd>lua require("Comment.api").toggle.linewise.current()<CR>', "Comment" },
  -- ["c"] = { "<cmd>Bdelete!<CR>", "Close Buffer" },
  c = { "<cmd>bdelete!<CR>", "Close Buffer" },

  -- :lua require'lir.float'.toggle()
  -- ["f"] = {
  -- },
  -- ["F"] = { "<cmd>Telescope live_grep theme=ivy<cr>", "Find Text" },
  -- P = { "<cmd>lua require('telescope').extensions.projects.projects()<cr>", "Projects" },
  -- ["R"] = { '<cmd>lua require("renamer").rename()<cr>', "Rename" },
  -- ["z"] = { "<cmd>ZenMode<cr>", "Zen" },
  -- ["gy"] = "Link",

  B = {
    name = "Browse",
    i = { "<cmd>BrowseInputSearch<cr>", "Input Search" },
    b = { "<cmd>Browse<cr>", "Browse" },
    d = { "<cmd>BrowseDevdocsSearch<cr>", "Devdocs" },
    f = { "<cmd>BrowseDevdocsFiletypeSearch<cr>", "Devdocs Filetype" },
    m = { "<cmd>BrowseMdnSearch<cr>", "Mdn" },
  },
  E = {
    name = "Executor",
    r = { "<cmd>ExecutorRun<cr>", "Run" },
    a = { "<cmd>ExecutorSetCommand<cr>", "Set Command" },
    s = { "<cmd>ExecutorShowDetail<cr>", "Show Detail" },
    h = { "<cmd>ExecutorHideDetail<cr>", "Hide Detail" },
    t = { "<cmd>ExecutorToggleDetail<cr>", "Toggle Detail" },
    S = { "<cmd>ExecutorSwapToSplit<cr>", "Swap to Split" },
    P = { "<cmd>ExecutorSwapToPopup<cr>", "Swap to Popup" },
    c = { "<cmd>ExecutorShowPresets<cr>", "Show preset commands in config" },
    H = { "<cmd>ExecutorShowHistory<cr>", "Show History" },
    C = { "<cmd>ExecutorReset<cr>", "Clear output" },
  },
  p = {
    name = "Packer",
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    S = { "<cmd>PackerStatus<cr>", "Status" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
  },

  o = {
    name = "Options",
    c = { "<cmd>lua vim.g.cmp_active=false<cr>", "Completion off" },
    C = { "<cmd>lua vim.g.cmp_active=true<cr>", "Completion on" },
    w = { '<cmd>lua require("user.functions").toggle_option("wrap")<cr>', "Wrap" },
    r = { '<cmd>lua require("user.functions").toggle_option("relativenumber")<cr>', "Relative" },
    l = { '<cmd>lua require("user.functions").toggle_option("cursorline")<cr>', "Cursorline" },
    s = { '<cmd>lua require("user.functions").toggle_option("spell")<cr>', "Spell" },
    t = { '<cmd>lua require("user.functions").toggle_tabline()<cr>', "Tabline" },
  },

  k = {
    name = "Split",
    s = { "<cmd>split<cr>", "HSplit" },
    v = { "<cmd>vsplit<cr>", "VSplit" },
  },

  S = {
    name = "Session",
    s = { "<cmd>SessionSave<cr>", "Save" },
    r = { "<cmd>SessionRestore<cr>", "Restore" },
    x = { "<cmd>SessionDelete<cr>", "Delete" },
    f = { "<cmd>Autosession search<cr>", "Find" },
    d = { "<cmd>Autosession delete<cr>", "Find Delete" },
  },

  r = {
    name = "Replace",
    r = { "<cmd>lua require('spectre').open()<cr>", "Replace" },
    w = { "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", "Replace Word (Workspace)" },
    f = { "<cmd>lua require('spectre').open_file_search({select_word=true})<cr>", "Replace Word (Buffer)" },
    b = { "<cmd>lua require('spectre').open_file_search()<cr>", "Replace Buffer" },
  },

  R = {
    name = "Code Runner",
    b = { ":TermExec cmd=./.buildme.sh<CR>", "Build the project" },
    p = { ':TermExec cmd="python %<CR>"', "Run python file" },
  },

  D = {
    name = "Debug",
    b = { "<cmd>lua require'dap'.toggle_breakpoint()<cr>", "Breakpoint" },
    c = { "<cmd>lua require'dap'.continue()<cr>", "Continue" },
    i = { "<cmd>lua require'dap'.step_into()<cr>", "Into" },
    o = { "<cmd>lua require'dap'.step_over()<cr>", "Over" },
    O = { "<cmd>lua require'dap'.step_out()<cr>", "Out" },
    r = { "<cmd>lua require'dap'.repl.toggle()<cr>", "Repl" },
    l = { "<cmd>lua require'dap'.run_last()<cr>", "Last" },
    u = { "<cmd>lua require'dapui'.toggle()<cr>", "UI" },
    x = { "<cmd>lua require'dap'.terminate()<cr>", "Exit" },
  },

  d = {
    name = "Diagnostics",
    c = {
      "<cmd>lua require('telescope.builtin').diagnostics({ bufnr = 0 })<cr>",
      "Diagnostics of current buffer",
    },
    w = {
      "<cmd>lua require('telescope.builtin').diagnostics()<cr>",
      "Workspace Diagnostics",
    },
    u = {
      "<cmd>lua require('telescope.builtin').diagnostics({ no_unlisted = true })<cr>",
      "Diagnostics from listed buffers",
    },
  },

  -- nnoremap <silent> <leader>B :lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>
  -- nnoremap <silent> <leader>lp :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
  -- require("dapui").open()
  -- require("dapui").close()
  -- require("dapui").toggle()
  -- s = {
  --   -- vim.api.nvim_set_keymap("n", "s", "<cmd>lua require('flash').jump()<CR>", opts)
  --   -- vim.api.nvim_set_keymap("n", "S", "<cmd>lua require('flash').treesitter()<CR>", opts)
  --   -- vim.api.nvim_set_keymap("o", "r", "<cmd>lua require('flash').remote()<CR>", opts)
  --   -- vim.api.nvim_set_keymap("o", "R", "<cmd>lua require('flash').tresitter_search()<CR>", opts)
  --   -- vim.api.nvim_set_keymap("c", "<C-s>", "<cmd>lua require('flash').toggle()<CR>", opts)
  --   name = "Flash NeoVim",
  --   s = { "<cmd>lua require('flash').jump()<CR>", "Jump" },
  --   S = { "<cmd>lua require('flash').treesitter()<CR>", "Treesitter" },
  --   r = { "<cmd>lua require('flash').remote()<CR>", "Remote" },
  --   R = { "<cmd>lua require('flash').treesitter_search()<CR>", "Treesitter Search" },
  --   ["<C-s>"] = { "<cmd>lua require('flash').toggle()<CR>", "Toggle" },
  -- },

  f = {
    name = "Find using Telescope",
    B = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    b = { "<cmd>Telescope buffers<cr>", "Buffers" },
    c = { "<cmd>Telescope colorscheme<cr>", "Colorscheme" },
    -- f = {"<cmd>lua require('telescope.builtin').find_files(require('user.telescope.user_themes').get_ivy_vertical{})<cr>", "Find files"},
    f = { "<cmd>Telescope find_files<cr>", "Find files" },
    g = { "<cmd>Telescope git_files<cr>", "Git Files" },
    -- t = {"<cmd>lua require('telescope.builtin').live_grep(require('user.telescope.user_themes').get_ivy_vertical{})<cr>", "Find files"},
    -- T = { "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args()<cr>", "Find text (live grep args)" },
    t = {
      t = { "<cmd>Telescope live_grep<cr>", "Find Text" },
      a = { "<cmd>Telescope live_grep_args<cr>", "Find text (live grep args)" },
      s = { "<cmd>lua require('telescope').extensions.live_grep_args.live_grep_args(default_text=vim.fn.expand('<cword>'))", "Live Grep Args with the word under cursor" },
    },
    s = {
      s = {"<cmd>lua require('telescope.builtin').live_grep({default_text=vim.fn.expand('<cword>')})<cr>", "Find string in the workspace"},
      -- w = {"<cmd>lua require('telescope.builtin').grep_string({word_match = '-w'})<cr>", "Exact word match"},
      b = {"<cmd>lua require('telescope.builtin').live_grep({default_text=vim.fn.expand('<cword>'), grep_open_files=true})<cr>", "Grep only open files"},
    },
    h = { "<cmd>Telescope help_tags<cr>", "Help" },
    H = { "<cmd>Telescope highlights<cr>", "Highlights" },
    -- i = { "<cmd>lua require('telescope').extensions.media_files.media_files()<cr>", "Media" },
    i = { "<cmd>Telescope lsp_incoming_calls<cr>", "Incoming calls" },
    o = { "<cmd>Telescope lsp_outgoing_calls<cr>", "Outgoing calls" },
    I = { "<cmd>Telescope lsp_implementations<cr>", "Implementations" },
    l = { "<cmd>Telescope resume<cr>", "Last Search" },
    M = { "<cmd>Telescope man_pages<cr>", "Man Pages" },
    r = { "<cmd>Telescope oldfiles<cr>", "Recent File" },
    R = { "<cmd>Telescope registers<cr>", "Registers" },
    k = { "<cmd>Telescope keymaps<cr>", "Keymaps" },
    C = { "<cmd>Telescope commands<cr>", "Commands" },
  },

  g = {
    name = "Git",
    -- TODO: Not really a good idea to use lazygit within neovim: https://github.com/jesseduffield/lazygit/issues/996
    g = { "<cmd>lua require ('user.terminal').lazygit_toggle()<cr>", "Lazygit" },
    j = { "<cmd>lua require 'gitsigns'.next_hunk()<cr>", "Next Hunk" },
    k = { "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", "Prev Hunk" },
    l = { "<cmd>GitBlameToggle<cr>", "Blame" },
    p = { "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", "Preview Hunk" },
    r = { "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", "Reset Hunk" },
    R = { "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", "Reset Buffer" },
    s = { "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", "Stage Hunk" },
    u = {
      "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
      "Undo Stage Hunk",
    },
    o = { "<cmd>Telescope git_status<cr>", "Open changed file" },
    b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    c = { "<cmd>Telescope git_commits<cr>", "Checkout commit" },
    d = {
      "<cmd>Gitsigns diffthis HEAD<cr>",
      "Diff",
    },
    G = {
      name = "Gist",
      a = { "<cmd>Gist -b -a<cr>", "Create Anon" },
      d = { "<cmd>Gist -d<cr>", "Delete" },
      f = { "<cmd>Gist -f<cr>", "Fork" },
      g = { "<cmd>Gist -b<cr>", "Create" },
      l = { "<cmd>Gist -l<cr>", "List" },
      p = { "<cmd>Gist -b -p<cr>", "Create Private" },
    },
    L = {
      name = "Gitlinker",
      Y = {
        "<cmd>lua require('gitlinker').get_buf_range_url('n', {action_callback = require'gitlinker.actions'.open_in_browser})<cr>",
        "Open in browser",
      },
      H = {
        "<cmd>lua require('gitlinker').get_repo_url({action_callback = require('gitlinker.actions').open_in_browser})<cr>",
        "Open Home Repo URL",
      },
    },
  },

  -- GitBlame
  G = {
    l = { "<cmd>GitBlameToggle<cr>", "Blame Toggle" },
    c = { "<cmd>GitBlameCopySHA<cr>", "Copy SHA URL of the commit" },
    o = { "<cmd>GitBlameOpenCommitURL<cr>", "Open commit URL" },
  },

  l = {
    name = "LSP",
    A = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    c = { "<cmd>lua require('user.lsp').server_capabilities()<cr>", "Get Capabilities" },
    -- d = { "<cmd>TroubleToggle<cr>", "Diagnostics" },
    d = {
      "<cmd>lua require('telescope.builtin').diagnostics({ bufnr = 0 })<cr>",
      "Document diagnostics",
    },
    w = {
      "<cmd>lua require('telescope.builtin').diagnostics()<cr>",
      "Workspace Diagnostics",
    },
    f = { "<cmd>lua vim.lsp.buf.format({ async = true })<cr>", "Format" },
    F = { "<cmd>LspToggleAutoFormat<cr>", "Toggle Autoformat" },
    i = { "<cmd>MasonLog<cr>", "Info" },
    h = { "<cmd>lua require('lsp-inlayhints').toggle()<cr>", "Toggle Hints" },
    H = { "<cmd>IlluminateToggle<cr>", "Toggle Doc HL" },
    I = { "<cmd>Mason<cr>", "Installer Info" },
    j = {
      "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>",
      "Next Diagnostic",
    },
    k = {
      "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>",
      "Prev Diagnostic",
    },
    e = {
      v = { "<cmd>lua require('lsp_lines').toggle()<cr>", "Virtual Lines" },
      V = {
        function()
          vim.diagnostic.config { virtual_text = not vim.diagnostic.config().virtual_text }
        end,
        "Virtual Text",
      },
    },
    o = { "<cmd>SymbolsOutline<cr>", "Outline" },
    q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix (Diagnostics)" },
    Q = { "<cmd>lua require('telescope.builtin').quickfix()<cr>", "Quickfix (Telescope)" },
    R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    r = { "<cmd>Trouble lsp_references<cr>", "References" },
    s = { "<cmd>Telescope lsp_document_symbols<cr>", "Document Symbols" },
    S = {
      "<cmd>Telescope lsp_dynamic_workspace_symbols<cr>",
      "Workspace Symbols",
    },
    g = {
      name = "Goto Preview",
      g = {
        "<cmd>lua require('goto-preview').goto_preview_definition()<cr>",
        "Definition",
      },
      t = {
        "<cmd>lua require('goto-preview').goto_preview_type_definition()<cr>",
        "Type Definition",
      },
      i = {
        "<cmd>lua require('goto-preview').goto_preview_implementation()<cr>",
        "Implementation",
      },
      -- Requires telescope
      r = {
        "<cmd>lua require('goto-preview').goto_preview_references()<cr>",
        "References",
      },
      c = {
        "<cmd>lua require('goto-preview').close_all_win()<cr>",
        "Close all windows",
      },
    },
    t = { '<cmd>lua require("user.functions").toggle_diagnostics()<cr>', "Toggle Diagnostics" },
    u = { "<cmd>LuaSnipUnlinkCurrent<cr>", "Unlink Snippet" },
  },

  n = {
    -- name = "Session",
    -- s = { "<cmd>SaveSession<cr>", "Save" },
    -- l = { "<cmd>LoadLastSession!<cr>", "Load Last" },
    -- d = { "<cmd>LoadCurrentDirSession!<cr>", "Load Last Dir" },
    -- f = { "<cmd>Telescope sessions save_current=false<cr>", "Find Session" },
    name = "SnipRun",
    c = { "<cmd>SnipClose<cr>", "Close" },
    f = { "<cmd>%SnipRun<cr>", "Run File" },
    i = { "<cmd>SnipInfo<cr>", "Info" },
    m = { "<cmd>SnipReplMemoryClean<cr>", "Mem Clean" },
    r = { "<cmd>SnipReset<cr>", "Reset" },
    t = { "<cmd>SnipRunToggle<cr>", "Toggle" },
    x = { "<cmd>SnipTerminate<cr>", "Terminate" },
  },

  T = {
    name = "Terminal",
    ["1"] = { ":1ToggleTerm<cr>", "1" },
    ["2"] = { ":2ToggleTerm<cr>", "2" },
    ["3"] = { ":3ToggleTerm<cr>", "3" },
    ["4"] = { ":4ToggleTerm<cr>", "4" },
    n = { "<cmd>lua _NODE_TOGGLE()<cr>", "Node" },
    u = { "<cmd>lua _NCDU_TOGGLE()<cr>", "NCDU" },
    t = { "<cmd>lua _HTOP_TOGGLE()<cr>", "Htop" },
    m = { "<cmd>lua _MAKE_TOGGLE()<cr>", "Make" },
    f = { "<cmd>ToggleTerm direction=float<cr>", "Float" },
    h = { "<cmd>ToggleTerm size=10 direction=horizontal<cr>", "Horizontal" },
    v = { "<cmd>ToggleTerm size=80 direction=vertical<cr>", "Vertical" },
  },

  t = {
    name = "Telescope",
    c = { "<cmd>Telescope commands<cr>", "Commands" },
    p = { "<cmd>Telescope projects<cr>", "Projects" },
    d = { "<cmd>Telescope diagnostics<cr>", "Diagnostics" },
    m = { "<cmd>Telescope media_files<cr>", "Media Files" },
    g = {
      name = "Git",
      c = { "<cmd>Telescope git_commits<cr>", "Git Commits" },
      b = { "<cmd>Telescope git_branches<cr>", "Git Branches" },
      s = { "<cmd>Telescope git_status<cr>", "Git Status" },
      S = { "<cmd>Telescope git_stash<cr>", "Git Stash" },
    },
    f = {
      "<cmd>Telescope find_files<cr>",
      "Find Files",
    },
    C = { "<cmd>Telescope command_history<cr>", "Command History" },
    j = { "<cmd>Telescope jumplist<cr>", "Jumplist" },
    r = { "<cmd>Telescope resume<cr>", "Resume" },
    s = { "<cmd>Telescope symbols<cr>", "Symbols" },
    h = { "<cmd>Telescope search_history<cr>", "Search History" },
    b = { "<cmd>Telescope builtin<cr>", "Builtin" },
    B = { "<cmd>Telescope Buffers<cr>", "buffers" },
    S = { "<cmd>Telescope current_buffer_fuzzy_find<cr>", "Search Buffer" },
  },

  -- z = {
  --   name = "Zen",
  --   z = { "<cmd>TZAtaraxis<cr>", "Zen" },
  --   m = { "<cmd>TZMinimalist<cr>", "Minimal" },
  --   n = { "<cmd>TZNarrow<cr>", "Narrow" },
  --   f = { "<cmd>TZFocus<cr>", "Focus" },
  -- },
  x = {
    name = "Transparent",
    t = { "<cmd>TransparentToggle<cr>", "Toggle transparency" },
  },
}

local vopts = {
  mode = "v", -- VISUAL mode
  prefix = "<leader>",
  buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
  silent = true, -- use `silent` when creating keymaps
  noremap = true, -- use `noremap` when creating keymaps
  nowait = true, -- use `nowait` when creating keymaps
}
local vmappings = {
  ["/"] = { '<ESC><CMD>lua require("Comment.api").toggle.linewise(vim.fn.visualmode())<CR>', "Comment" },
  s = { "<esc><cmd>'<,'>SnipRun<cr>", "Run range" },
  -- z = { "<cmd>TZNarrow<cr>", "Narrow" },
}

which_key.setup(setup)
which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
which_key.register(m_mappings, m_opts)
