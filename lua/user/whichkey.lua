local status_ok, which_key = pcall(require, "which-key")
if not status_ok then return end

which_key.add {
  {
    "<leader>b",
    function() Snacks.picker.buffers() end,
    desc = "Buffers",
  },
  {
    "<leader>bb",
    "<cmd>lua require('user.buffer_browser').open_buffer_browser()<cr>",
    desc = "Buffer Browser",
  },
  {
    "<leader>bs",
    "<cmd>lua require('user.buffer_browser').toggle_sidebar()<cr>",
    desc = "Buffer Sidebar",
  },
  {
    "<leader>e",
    "<cmd>lua require('user.simple_tree').open_current_dir()<cr>",
    desc = "Explorer (Current Dir)",
  },
  {
    "<leader>E",
    "<cmd>lua require('user.simple_tree').open_workspace()<cr>",
    desc = "Explorer (Workspace)",
  },
  {
    "<leader>w",
    "<cmd>w<CR>",
    desc = "Write",
  },
  {
    "<leader>h",
    "<cmd>nohlsearch<CR>",
    desc = "No HL",
  },
  {
    "<leader>q",
    "<cmd>lua require('user.functions').smart_quit()<CR>",
    desc = "Quit",
  },

  -- Options
  {
    "<leader>oc",
    "<cmd>lua vim.g.cmp_active=false<cr>",
    desc = "Completion off",
  },
  {
    "<leader>oC",
    "<cmd>lua vim.g.cmp_active=true<cr>",
    desc = "Completion on",
  },
  {
    "<leader>ow",
    '<cmd>lua require("user.functions").toggle_option("wrap")<cr>',
    desc = "Wrap",
  },
  {
    "<leader>or",
    '<cmd>lua require("user.functions").toggle_option("relativenumber")<cr>',
    desc = "Relative",
  },
  {
    "<leader>ol",
    '<cmd>lua require("user.functions").toggle_option("cursorline")<cr>',
    desc = "Cursorline",
  },
  {
    "<leader>os",
    '<cmd>lua require("user.functions").toggle_option("spell")<cr>',
    desc = "Spell",
  },
  {
    "<leader>ot",
    '<cmd>lua require("user.functions").toggle_tabline()<cr>',
    desc = "Tabline",
  },

  -- Split
  {
    "<leader>ks",
    "<cmd>split<cr>",
    desc = "HSplit",
  },
  {
    "<leader>kv",
    "<cmd>vsplit<cr>",
    desc = "VSplit",
  },

  -- Session
  {
    "<leader>Ss",
    "<cmd>SessionSave<cr>",
    desc = "Save",
  },
  {
    "<leader>Sr",
    "<cmd>SessionRestore<cr>",
    desc = "Restore",
  },
  {
    "<leader>Sx",
    "<cmd>SessionDelete<cr>",
    desc = "Delete",
  },
  -- {
  --   "<leader>Sf",
  --   "<cmd>Autosession search<cr>",
  --   desc = "Find",
  -- },
  -- {
  --   "<leader>Sd",
  --   "<cmd>Autosession delete<cr>",
  --   desc = "Find Delete",
  -- },

  -- Replace
  {
    "<leader>rr",
    "<cmd>lua require('spectre').open()<cr>",
    desc = "Replace",
  },
  {
    "<leader>rw",
    "<cmd>lua require('spectre').open_visual({select_word=true})<cr>",
    desc = "Replace Word (Workspace)",
  },
  {
    "<leader>rf",
    "<cmd>lua require('spectre').open_file_search({select_word=true})<cr>",
    desc = "Replace Word (Buffer)",
  },
  {
    "<leader>rb",
    "<cmd>lua require('spectre').open_file_search()<cr>",
    desc = "Replace Buffer",
  },

  -- Code Runner
  {
    "<leader>Rb",
    ":TermExec cmd=./.buildme.sh<CR>",
    desc = "Build the project",
  },
  {
    "<leader>Rp",
    ':TermExec cmd="python %<CR>"',
    desc = "Run python file",
  },

  -- Debug (DAP not installed)
  -- {
  --   "<leader>Db",
  --   "<cmd>lua require'dap'.toggle_breakpoint()<cr>",
  --   desc = "Breakpoint",
  -- },
  -- {
  --   "<leader>Dc",
  --   "<cmd>lua require'dap'.continue()<cr>",
  --   desc = "Continue",
  -- },
  -- {
  --   "<leader>Di",
  --   "<cmd>lua require'dap'.step_into()<cr>",
  --   desc = "Into",
  -- },
  -- {
  --   "<leader>Do",
  --   "<cmd>lua require'dap'.step_over()<cr>",
  --   desc = "Over",
  -- },
  -- {
  --   "<leader>DO",
  --   "<cmd>lua require'dap'.step_out()<cr>",
  --   desc = "Out",
  -- },
  -- {
  --   "<leader>Dr",
  --   "<cmd>lua require'dap'.repl.toggle()<cr>",
  --   desc = "Repl",
  -- },
  -- {
  --   "<leader>Dl",
  --   "<cmd>lua require'dap'.run_last()<cr>",
  --   desc = "Last",
  -- },
  -- {
  --   "<leader>Du",
  --   "<cmd>lua require'dapui'.toggle()<cr>",
  --   desc = "UI",
  -- },
  -- {
  --   "<leader>Dx",
  --   "<cmd>lua require'dap'.terminate()<cr>",
  --   desc = "Exit",
  -- },

  -- Diagnostics
  -- Duplicate of <leader>ld - removed
  -- {
  --   "<leader>ldc",
  --   "<cmd>lua require('telescope.builtin').diagnostics({ bufnr = 0 })<cr>",
  --   desc = "Diagnostics of current buffer",
  -- },
  -- Duplicate of <leader>lw - removed
  -- {
  --   "<leader>ldw",
  --   "<cmd>lua require('telescope.builtin').diagnostics()<cr>",
  --   desc = "Workspace Diagnostics",
  -- },
  -- Specific diagnostics filter - keeping this one

  -- Find using Telescope
  {
    "<leader>fB",
    function() Snacks.picker.git_branches() end,
    desc = "Checkout branch",
  },
  -- Duplicate of <leader>b - removed
  -- {
  --   "<leader>fb",
  --   "<cmd>Telescope buffers<cr>",
  --   desc = "Buffers",
  -- },
  {
    "<leader>fc",
    function() Snacks.picker.colorschemes() end,
    desc = "Colorscheme",
  },
  {
    "<leader>ff",
    function() Snacks.picker.files() end,
    desc = "Find files",
  },
  {
    "<leader>fg",
    function() Snacks.picker.git_files() end,
    desc = "Git Files",
  },
  {
    "<leader>ftt",
    function() Snacks.picker.grep() end,
    desc = "Find Text",
  },
  {
    "<leader>fta",
    function() Snacks.picker.grep() end,
    desc = "Find text (live grep args)",
  },
  {
    "<leader>fts",
    function() 
      local word = vim.fn.expand("<cword>")
      if word and word ~= "" then
        Snacks.picker.grep({ search = word })
      end
    end,
    desc = "Live Grep Args with the word under cursor",
  },
  {
    "<leader>fss",
    function() 
      local word = vim.fn.expand("<cword>")
      if word and word ~= "" then
        Snacks.picker.grep({ search = word })
      end
    end,
    desc = "Find string in the workspace",
  },
  {
    "<leader>fsb",
    function() Snacks.picker.lines() end,
    desc = "Grep only open files",
  },
  {
    "<leader>fTT",
    function() Snacks.picker.grep() end,
    desc = "Live Grep (with preview)",
  },
  {
    "<leader>fSS",
    function() 
      local word = vim.fn.expand("<cword>")
      if word and word ~= "" then
        Snacks.picker.grep({ search = word })
      end
    end,
    desc = "Grep String under cursor (with preview)",
  },
  {
    "<leader>fh",
    function() Snacks.picker.help() end,
    desc = "Help",
  },
  {
    "<leader>fH",
    function() Snacks.picker.highlights() end,
    desc = "Highlights",
  },
  {
    "<leader>fi",
    function() Snacks.picker.lsp_incoming_calls() end,
    desc = "Incoming calls",
  },
  {
    "<leader>fo",
    function() Snacks.picker.lsp_outgoing_calls() end,
    desc = "Outgoing calls",
  },
  {
    "<leader>fI",
    function() Snacks.picker.lsp_implementations() end,
    desc = "Implementations",
  },
  {
    "<leader>fl",
    function() Snacks.picker.resume() end,
    desc = "Last Search",
  },
  {
    "<leader>fM",
    function() Snacks.picker.man() end,
    desc = "Man Pages",
  },
  {
    "<leader>fr",
    function() Snacks.picker.recent() end,
    desc = "Recent Files",
  },
  {
    "<leader>fp",
    function() Snacks.picker.recent() end,
    desc = "Frecency recent file",
  },
  {
    "<leader>fR",
    function() Snacks.picker.registers() end,
    desc = "Registers",
  },
  {
    "<leader>fk",
    function() Snacks.picker.keymaps() end,
    desc = "Keymaps",
  },
  {
    "<leader>fC",
    function() Snacks.picker.commands() end,
    desc = "Commands",
  },
  {
    "<leader>fF",
    function() Snacks.picker.files() end,
    desc = "Find Files (with preview)",
  },

  -- Diagnostics
  {
    "<leader>dl",
    "<cmd>lua require('user.diagnostics_display').show_current_line_diagnostics()<cr>",
    desc = "Line Diagnostics",
  },
  {
    "<leader>df",
    "<cmd>lua require('user.diagnostics_display').show_current_file_diagnostics()<cr>",
    desc = "File Diagnostics",
  },
  {
    "<leader>dd",
    "<cmd>lua require('user.diagnostics_display').debug()<cr>",
    desc = "Debug Diagnostics",
  },

  -- Git
  {
    "<leader>gg",
    "<cmd>lua require('user.terminal').lazygit_float()<cr>",
    desc = "Lazygit (Float)",
  },
  {
    "<leader>gt",
    "<cmd>lua require('user.terminal').lazygit_tab()<cr>",
    desc = "Lazygit (Tab)",
  },
  {
    "<leader>gj",
    "<cmd>lua require 'gitsigns'.next_hunk()<cr>",
    desc = "Next Hunk",
  },
  {
    "<leader>gk",
    "<cmd>lua require 'gitsigns'.prev_hunk()<cr>",
    desc = "Prev Hunk",
  },
  {
    "<leader>gll",
    "<cmd>GitBlameToggle<cr>",
    desc = "Blame Virtual Text",
  },
  {
    "<leader>glf",
    "<cmd>Git blame<cr>",
    desc = "Blame column",
  },
  {
    "<leader>glg",
    "<cmd>Gitsigns blame_line<cr>",
    desc = "Blame line preview",
  },
  {
    "<leader>gp",
    "<cmd>lua require 'gitsigns'.preview_hunk()<cr>",
    desc = "Preview Hunk",
  },
  {
    "<leader>gr",
    "<cmd>lua require 'gitsigns'.reset_hunk()<cr>",
    desc = "Reset Hunk",
  },
  {
    "<leader>gR",
    "<cmd>lua require 'gitsigns'.reset_buffer()<cr>",
    desc = "Reset Buffer",
  },
  {
    "<leader>gs",
    "<cmd>lua require 'gitsigns'.stage_hunk()<cr>",
    desc = "Stage Hunk",
  },
  {
    "<leader>gu",
    "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>",
    desc = "Undo Stage Hunk",
  },
  {
    "<leader>go",
    function() Snacks.picker.git_status() end,
    desc = "Open changed file",
  },
  -- Commented out duplicates - functionality available via other keymaps
  -- { "<leader>gb", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
  -- { "<leader>gc", "<cmd>Telescope git_commits<cr>", desc = "Checkout commit" },
  {
    "<leader>gd",
    "<cmd>Gitsigns diffthis HEAD<cr>",
    desc = "Diff",
  },

  -- GitBlame
  {
    "<leader>Gl",
    "<cmd>GitBlameToggle<cr>",
    desc = "Blame Toggle",
  },
  {
    "<leader>Gc",
    "<cmd>GitBlameCopySHA<cr>",
    desc = "Copy SHA URL of the commit",
  },
  {
    "<leader>Go",
    "<cmd>GitBlameOpenCommitURL<cr>",
    desc = "Open commit URL",
  },

  -- LSP
  -- {
  --   "<leader>lA",
  --   "<cmd>lua vim.lsp.codelens.run()<cr>",
  --   desc = "CodeLens Action",
  -- },
  -- {
  --   "<leader>la",
  --   "<cmd>lua vim.lsp.buf.code_action()<cr>",
  --   desc = "Code Action",
  -- },
  -- {
  --   "<leader>ld",
  --   "<cmd>call CocActionAsync('diagnosticInfo')<cr>",
  --   desc = "Line Diagnostics",
  -- },
  -- {
  --   "<leader>lf",
  --   "<cmd>lua vim.lsp.buf.format({ async = true })<cr>",
  --   desc = "Format",
  -- },
  -- {
  --   "<leader>lF",
  --   "<cmd>LspToggleAutoFormat<cr>",
  --   desc = "Toggle Autoformat",
  -- },
  -- {
  --   "<leader>li",
  --   "<cmd>MasonLog<cr>",
  --   desc = "Info",
  -- },
  -- {
  --   "<leader>lh",
  --   "<cmd>lua require('lsp-inlayhints').toggle()<cr>",
  --   desc = "Toggle Hints",
  -- },
  {
    "<leader>lH",
    "<cmd>IlluminateToggle<cr>",
    desc = "Toggle Doc HL",
  },
  {
    "<leader>lI",
    "<cmd>Mason<cr>",
    desc = "Installer Info",
  },
  {
    "<leader>lj",
    "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>",
    desc = "Next Diagnostic",
  },
  {
    "<leader>lk",
    "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>",
    desc = "Prev Diagnostic",
  },
  {
    "<leader>lev",
    function()
      -- Toggle coc.nvim virtual text
      local current = vim.fn.CocAction('getConfig', 'diagnostic.virtualText')
      local new_value = not current
      vim.fn['coc#config']('diagnostic.virtualText', new_value)
      vim.notify('COC Virtual Text: ' .. (new_value and 'enabled' or 'disabled'))
    end,
    desc = "Toggle COC Virtual Text",
  },
  {
    "<leader>leV",
    function()
      -- Toggle coc.nvim virtual text current line only
      local current = vim.fn.CocAction('getConfig', 'diagnostic.virtualTextCurrentLineOnly')
      local new_value = not current
      vim.fn['coc#config']('diagnostic.virtualText', true)
      vim.fn['coc#config']('diagnostic.virtualTextCurrentLineOnly', new_value)
      vim.notify('COC Virtual Text Current Line Only: ' .. (new_value and 'enabled' or 'disabled'))
    end,
    desc = "Toggle COC Virtual Text (Current Line Only)",
  },
  {
    "<leader>lel",
    function()
      -- Toggle between 'after' and 'below' alignment for virtual text
      local current = vim.fn.CocAction('getConfig', 'diagnostic.virtualTextAlign') or 'after'
      local new_align = current == 'below' and 'after' or 'below'
      vim.fn['coc#config']('diagnostic.virtualText', true)
      vim.fn['coc#config']('diagnostic.virtualTextAlign', new_align)
      local mode_text = new_align == 'below' and 'lines' or 'inline'
      vim.notify('COC Virtual Text Mode: ' .. mode_text)
    end,
    desc = "Toggle COC Virtual Text Mode (Inline/Lines)",
  },
  {
    "<leader>levv",
    function()
      -- Use custom virtual lines implementation
      require("user.coc_virtual_lines").toggle()
    end,
    desc = "Toggle Custom COC Virtual Lines",
  },
  {
    "<leader>lec",
    function()
      -- Toggle COC Code Lens
      local current = vim.fn.CocAction('getConfig', 'codeLens.enable')
      local new_value = not current
      vim.fn['coc#config']('codeLens.enable', new_value)
      vim.notify('COC Code Lens: ' .. (new_value and 'enabled' or 'disabled'))
    end,
    desc = "Toggle COC Code Lens",
  },
  {
    "<leader>lo",
    "<cmd>Outline<cr>",
    desc = "Outline (toggles)",
  },
  {
    "<leader>lq",
    "<cmd>lua vim.diagnostic.setloclist()<cr>",
    desc = "Quickfix (Diagnostics)",
  },
  {
    "<leader>lQ",
    function() Snacks.picker.qflist() end,
    desc = "Quickfix",
  },
  -- Commented out to avoid conflict with COC.nvim
  -- {
  --   "<leader>lR",
  --   "<cmd>lua vim.lsp.buf.rename()<cr>",
  --   desc = "Rename",
  -- },
  {
    "<leader>lr",
    "<cmd>Trouble lsp_references<cr>",
    desc = "References",
  },
  {
    "<leader>ls",
    function() Snacks.picker.lsp_symbols() end,
    desc = "Document Symbols",
  },
  {
    "<leader>lS",
    function() Snacks.picker.lsp_workspace_symbols() end,
    desc = "Workspace Symbols",
  },
  {
    "<leader>lgg",
    "<cmd>lua require('goto-preview').goto_preview_definition()<cr>",
    desc = "Goto Preview Definition",
  },
  {
    "<leader>lgt",
    "<cmd>lua require('goto-preview').goto_preview_type_definition()<cr>",
    desc = "Goto Preview Type Definition",
  },
  {
    "<leader>lgi",
    "<cmd>lua require('goto-preview').goto_preview_implementation()<cr>",
    desc = "Goto Preview Implementation",
  },
  {
    "<leader>lgr",
    "<cmd>lua require('goto-preview').goto_preview_references()<cr>",
    desc = "Goto Preview References",
  },
  {
    "<leader>lgc",
    "<cmd>lua require('goto-preview').close_all_win()<cr>",
    desc = "Close all windows",
  },
  {
    "<leader>lt",
    '<cmd>lua require("user.functions").toggle_diagnostics()<cr>',
    desc = "Toggle Diagnostics",
  },
  {
    "<leader>lu",
    "<cmd>LuaSnipUnlinkCurrent<cr>",
    desc = "Unlink Snippet",
  },
  -- Lspsaga (not installed)
  -- {
  --   "<leader>llt",
  --   "<cmd>Lspsaga term_toggle<cr>",
  --   desc = "Terminal toggle",
  -- },
  -- {
  --   "<leader>llo",
  --   "<cmd>Lspsaga outline<cr>",
  --   desc = "LSP outline",
  -- },
  -- {
  --   "<leader>lld",
  --   "<cmd>Lspsaga show_line_diagnostics<cr>",
  --   desc = "Cursor diagnostics",
  -- },
  -- {
  --   "<leader>llc",
  --   "<cmd>Lspsaga show_cursor_diagnostics<cr>",
  --   desc = "Cursor diagnostics",
  -- },

  -- Terminal
  {
    "<leader>T1",
    "<cmd>lua _FLOAT_TERM()<cr>",
    desc = "Float Terminal",
  },
  {
    "<leader>T2",
    "<cmd>lua _VERTICAL_TERM()<cr>",
    desc = "Vertical Terminal",
  },
  {
    "<leader>T3",
    "<cmd>lua _HORIZONTAL_TERM()<cr>",
    desc = "Horizontal Terminal",
  },
  {
    "<leader>T4",
    "<cmd>lua _FLOAT_TERM()<cr>",
    desc = "Float Terminal",
  },
  {
    "<leader>Tn",
    "<cmd>lua _NODE_TOGGLE()<cr>",
    desc = "Node",
  },
  {
    "<leader>Tu",
    "<cmd>lua _NCDU_TOGGLE()<cr>",
    desc = "NCDU",
  },
  {
    "<leader>Tt",
    "<cmd>lua _HTOP_TOGGLE()<cr>",
    desc = "Htop",
  },
  {
    "<leader>Tm",
    "<cmd>lua _MAKE_TOGGLE()<cr>",
    desc = "Make",
  },
  {
    "<leader>Tf",
    "<cmd>lua _FLOAT_TERM()<cr>",
    desc = "Float",
  },
  {
    "<leader>Th",
    "<cmd>lua _HORIZONTAL_TERM()<cr>",
    desc = "Horizontal",
  },
  {
    "<leader>Tv",
    "<cmd>lua _VERTICAL_TERM()<cr>",
    desc = "Vertical",
  },

  -- Telescope
  -- Duplicate of <leader>fC - removed
  -- {
  --   "<leader>tc",
  --   "<cmd>Telescope commands<cr>",
  --   desc = "Commands",
  -- },
  -- Duplicate of <leader>lw - removed
  -- {
  --   "<leader>td",
  --   "<cmd>Telescope diagnostics<cr>",
  --   desc = "Diagnostics",
  -- },
  -- {
  --   "<leader>tm",
  --   "<cmd>Telescope media_files<cr>",
  --   desc = "Media Files",
  -- },
  -- Git commits available via other keymaps
  -- {
  --   "<leader>tgc",
  --   "<cmd>Telescope git_commits<cr>",
  --   desc = "Git Commits",
  -- },
  -- Duplicate of <leader>fB - removed
  -- {
  --   "<leader>tgb",
  --   "<cmd>Telescope git_branches<cr>",
  --   desc = "Git Branches",
  -- },
  -- Duplicate of <leader>go - removed
  -- {
  --   "<leader>tgs",
  --   "<cmd>Telescope git_status<cr>",
  --   desc = "Git Status",
  -- },
  {
    "<leader>tgS",
    function() Snacks.picker.git_stash() end,
    desc = "Git Stash",
  },
  -- Duplicate of <leader>ff - removed
  -- {
  --   "<leader>tf",
  --   "<cmd>Telescope find_files<cr>",
  --   desc = "Find Files",
  -- },
  {
    "<leader>tC",
    function() Snacks.picker.command_history() end,
    desc = "Command History",
  },
  {
    "<leader>tj",
    function() Snacks.picker.jumps() end,
    desc = "Jumplist",
  },
  -- Duplicate of <leader>fl - removed
  -- {
  --   "<leader>tr",
  --   "<cmd>Telescope resume<cr>",
  --   desc = "Resume",
  -- },
  -- {
  --   "<leader>ts",
  --   "<cmd>Telescope symbols<cr>",
  --   desc = "Symbols",
  -- },
  {
    "<leader>th",
    function() Snacks.picker.search_history() end,
    desc = "Search History",
  },
  {
    "<leader>tb",
    function() Snacks.picker.pick() end,
    desc = "Builtin",
  },
  -- Duplicate of <leader>b - removed
  -- {
  --   "<leader>tB",
  --   "<cmd>Telescope Buffers<cr>",
  --   desc = "buffers",
  -- },
  {
    "<leader>tS",
    function() Snacks.picker.lines() end,
    desc = "Search Buffer",
  },

  -- NavBar (not installed)
  -- {
  --   "<leader>nb",
  --   "<cmd>Navbuddy<cr>",
  --   desc = "NavBar",
  -- },

  -- Folding
  -- { "<leader>zo", "<cmd>lua require('ufo').openAllFolds()<CR>", desc = "Open All Folds" },
  -- { "<leader>zc", "<cmd>lua require('ufo').closeAllFolds()<CR>", desc = "Close" },
  -- { "<leader>zm", "<cmd>lua require('ufo').closeFoldsWith()<CR>", desc = "Close Folds With" },
  -- { "<leader>zr", "<cmd>lua require('ufo').openFoldsExceptKinds()<CR>", desc = "Open Folds except Kinds" },

  -- Project
  {
    "<leader>tp",
    function() Snacks.picker.files() end,
    desc = "Switch project",
  },

  -- Transparent
  {
    "<leader>xt",
    "<cmd>TransparentToggle<cr>",
    desc = "Toggle transparency",
  },

  -- Guard (not installed)
  -- {
  --   "<leader>gf",
  --   "<cmd>GuardFmt<cr>",
  --   desc = "Guard Fmt",
  -- },
}
