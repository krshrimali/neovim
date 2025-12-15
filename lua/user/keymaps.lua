-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Shorten function name
local M = {}
local opts = { noremap = true, silent = true }

local keymap = vim.api.nvim_set_keymap

--Remap comma as leader key
vim.g.mkdp_browser = "microsoft-edge"

-- Normal --
keymap("n", "glb", "<cmd>Gitsigns blame_line<cr>", opts)

-- Better window navigation
-- keymap("n", "<m-h>", "<C-w>h", opts)
-- keymap("n", "<m-j>", "<C-w>j", opts)
-- keymap("n", "<m-k>", "<C-w>k", opts)
-- keymap("n", "<m-l>", "<C-w>l", opts)

-- Enhanced buffer navigation with Alt+H/J/K/L (works with all buffers including SimpleTree)
keymap("n", "<A-h>", "<cmd>lua require('user.buffer_navigation').navigate_left()<cr>", opts)
keymap("n", "<A-j>", "<cmd>lua require('user.buffer_navigation').navigate_down()<cr>", opts)
keymap("n", "<A-k>", "<cmd>lua require('user.buffer_navigation').navigate_up()<cr>", opts)
keymap("n", "<A-l>", "<cmd>lua require('user.buffer_navigation').navigate_right()<cr>", opts)

-- Alt navigation also works in insert and terminal modes
keymap("i", "<A-h>", "<Esc><cmd>lua require('user.buffer_navigation').navigate_left()<cr>", opts)
keymap("i", "<A-j>", "<Esc><cmd>lua require('user.buffer_navigation').navigate_down()<cr>", opts)
keymap("i", "<A-k>", "<Esc><cmd>lua require('user.buffer_navigation').navigate_up()<cr>", opts)
keymap("i", "<A-l>", "<Esc><cmd>lua require('user.buffer_navigation').navigate_right()<cr>", opts)

keymap("t", "<A-h>", "<C-\\><C-n><cmd>lua require('user.buffer_navigation').navigate_left()<cr>", opts)
keymap("t", "<A-j>", "<C-\\><C-n><cmd>lua require('user.buffer_navigation').navigate_down()<cr>", opts)
keymap("t", "<A-k>", "<C-\\><C-n><cmd>lua require('user.buffer_navigation').navigate_up()<cr>", opts)
keymap("t", "<A-l>", "<C-\\><C-n><cmd>lua require('user.buffer_navigation').navigate_right()<cr>", opts)

-- Alternative keybindings using Meta key (in case Alt doesn't work in some terminals)
-- Uncomment these if Alt keys don't work in your terminal:
-- keymap("n", "<M-h>", "<cmd>lua require('user.buffer_navigation').navigate_left()<cr>", opts)
-- keymap("n", "<M-j>", "<cmd>lua require('user.buffer_navigation').navigate_down()<cr>", opts)
-- keymap("n", "<M-k>", "<cmd>lua require('user.buffer_navigation').navigate_up()<cr>", opts)
-- keymap("n", "<M-l>", "<cmd>lua require('user.buffer_navigation').navigate_right()<cr>", opts)

-- Debug window layout (useful for troubleshooting navigation)
keymap("n", "<leader>wd", "<cmd>lua require('user.buffer_navigation').debug_windows()<cr>", opts)

keymap("n", "+", "<C-a>", opts)
keymap("n", "-", "<C-x>", opts)

-- Delete word backwards
keymap("n", "dw", 'vb"_d', opts)

-- Select all
keymap("n", "<C-a>", "gg<S-v>G", opts)

keymap("n", "<C-w><left>", "<C-w><", opts)
keymap("n", "<C-w><right>", "<C-w>>", opts)
keymap("n", "<C-w><up>", "<C-w>+", opts)
keymap("n", "<C-w><down>", "<C-w>-", opts)

-- -- Resize with arrows
-- Didnd't work well on Mac
-- keymap("n", "<m-S-k>", ":resize -2<CR>", opts)
-- keymap("n", "<m-S-j>", ":resize +2<CR>", opts)
-- keymap("n", "<m-S-l>", ":vertical resize -2<CR>", opts)
-- keymap("n", "<m-S-h>", ":vertical resize +2<CR>", opts)

-- Naviagate buffers
-- TODO: Maybe this is not required in favor of C-l, C-h
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)

-- keymap("n", "<RightMouse>", ":Alpha<CR>", opts)

-- Move text up and down
-- keymap("n", "<S-f>", "<Esc>:m .+1<CR>", opts)
keymap("n", "<S-d>", "<Esc>:m .+1<CR>", opts)
keymap("n", "<S-u>", "<Esc>:m .-2<CR>", opts)

-- Insert --
-- Press jk fast to enter
-- TODO: Experimenting with this for now, and let's see how this goes
-- TODO: Map caps to control and use ctrl-C instead (no need to remap)
keymap("i", "jk", "<ESC>", opts)

-- Stay in indent mode
-- Visual --
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

keymap("v", "p", '"_dP', opts)

keymap("v", "F", ":m '>+1<CR>gv=gv", opts)
keymap("v", "U", ":m '<-2<CR>gv=gv", opts)

keymap("n", "<leader>d", '"_d', opts)
keymap("x", "<leader>d", '"_d', opts)
keymap("x", "<leader>p", '"_dP', opts)
-- keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", opts)
-- keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>", opts)

-- NOTE: the fact that tab and ctrl-i are the same is stupid
keymap("n", "<leader>Q", "<cmd>bdelete!<CR>", opts)
-- LSP keymaps are now handled in lua/user/lsp.lua on_attach function
-- Additional convenience keymaps
keymap("n", "<F11>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
keymap("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "<C-p>", "<cmd>FzfLua files<cr>", opts)
keymap("n", "<C-s>", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", opts)
keymap("n", "<C-z>", "<cmd>ZenMode<cr>", opts)

-- keymap("n", "-", ":lua require'lir.float'.toggle()<cr>", opts)

-- vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- K mapping is now handled by coc.nvim in user.coc
-- Removed to avoid conflicts

-- TODO: Rethink on this, currently not using it... (harpoon)
-- vim.api.nvim_set_keymap(
--   "n",
--   "<C-m>",
--   "<cmd>lua require('telescope').extensions.harpoon.marks(require('telescope.themes').get_dropdown{ layout_strategy = 'horizontal', layout_config = { width = function(_, max_columns, _) return math.min(max_columns, 120) end, height= function(_, _, max_lines) return math.min(max_lines, 30) end, }, initial_mode='normal', prompt_title='Harpoon'})<cr>",
--   opts
-- )

vim.api.nvim_set_keymap("n", "<s-t>", "<cmd>TodoQuickFix<cr>", opts)
vim.api.nvim_set_keymap("n", "<m-t>", "<cmd>TodoQuickFix<cr>", opts)

-- vim.api.nvim_set_keymap("n", "<leader>o", "<cmd>Portal jumplist backward<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<leader>i", "<cmd>Portal jumplist forward<cr>", opts)

-- vim.api.nvim_set_keymap('v', '<leader>gLb', '<cmd>lua require"gitlinker".get_buf_range_url("v", {action_callback = require"gitlinker.actions".open_in_browser})<cr>', {})
vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

-- nvim-spider keymaps are now handled by the plugin's lazy loading configuration in plugins.lua

keymap("n", "<m-q>", ":call QuickFixToggle()<cr>", opts)

-- imap <silent><script><expr> <C-M> copilot#Accept("\<CR>")
-- vim.keymap.set({"i", "C", "M"}, )
-- vim.api.nvim_set_keymap("i", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- vim.api.nvim_set_keymap("i", "<C-N>", "<cmd>copilot#Next()<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-N>", "<cmd>copilot#Next()<cr>", opts)
-- vim.api.nvim_set_keymap("i", "<C-P>", "<cmd>copilot#Prev()<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-P>", "<cmd>copilot#Prev()<cr>", opts)
-- map copilot#Accept
-- vim.api.nvim_set_keymap("i", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- vim.api.nvim_set_keymap("n", "<C-M>", "<cmd>copilot#Accept('<CR>')<cr>", opts)
-- let g:copilot_no_tab_map = v:true

-- vim.cmd [[
--   imap <silent><script><expr> <C-y> copilot#Accept("\<CR>")
--   let g:copilot_no_tab_map = v:true
-- ]]

-- vim.api.nvim_set_keymap('n', ':', '<cmd>FineCmdline<CR>', {noremap = true})
-- vim.api.nvim_set_keymap("i", "<C-y>", 'copilot#Accept("<CR>")', { expr = true, silent = true })
-- vim.keymap.set('v', '<leader>lf', vim.lsp.buf.format, bufopts)

-- vim.api.nvim_set_keymap("n", ":", "<cmd>FineCmdline<CR>", { noremap = true })

-- Copilot keymaps
-- Alt+Y to accept, M-] for next, M-[ for prev, C-] to dismiss
vim.g.copilot_no_tab_map = true
vim.keymap.set("i", "<A-y>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false, silent = true })
vim.keymap.set("i", "<M-]>", "<Plug>(copilot-next)", { silent = true })
vim.keymap.set("i", "<M-[>", "<Plug>(copilot-previous)", { silent = true })
vim.keymap.set("i", "<C-]>", "<Plug>(copilot-dismiss)", { silent = true })

-- Helper functions to fetch the current scope and set `search_dirs`
_G.find_files = function()
  local current_path = vim.fn.expand "%:p:h"
  local relative_path = vim.fn.fnamemodify(current_path, ":~:.")

  require("fzf-lua").files {
    cwd = relative_path,
    winopts = {
      preview = { hidden = true },
    },
  }
end
_G.live_grep = function()
  local current_path = vim.fn.expand "%:p:h"
  local relative_path = vim.fn.fnamemodify(current_path, ":~:.")

  require("fzf-lua").live_grep {
    cwd = relative_path,
    winopts = {
      preview = { hidden = true },
    },
  }
end

vim.api.nvim_set_keymap("n", "<Leader><leader>f", ":lua find_files()<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "<Leader><leader>g", ":lua live_grep()<CR>", { noremap = true })

-- vim.api.nvim_set_keymap("n", "<Leader><leader>F", "<cmd>Telescope dir find_files<CR>", { noremap = true })
-- vim.api.nvim_set_keymap("n", "<Leader><leader>t", "<cmd>Telescope dir live_grep<CR>", { noremap = true })
--
-- vim.api.nvim_set_keymap("n", "<leader>zm", '[[:lua require("ufo").openAllFolds()<CR>]]', opts)
-- vim.api.nvim_set_keymap("n", "<leader>zr", '[[:lua require("ufo").closeAllFolds()<CR>]]', opts)

vim.api.nvim_set_keymap("n", "<leader><leader>s", ":FzfLua command_history<CR>", opts)
-- vim.keymap.set("n", "zR", require("ufo").openAllFolds)
-- vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
-- vim.keymap.set("n", "zr", require("ufo").openFoldsExceptKinds)
-- vim.keymap.set("n", "zm", require("ufo").closeFoldsWith) -- closeAllFolds == closeFoldsWith(0)
-- vim.keymap.set("n", "zK", function()
--   local winid = require("ufo").peekFoldedLinesUnderCursor()
--   if not winid then
--     vim.lsp.buf.hover()
--   end
-- end)
-- Keymaps for goto-preview
vim.keymap.set("n", "<leader>lgg", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", { noremap = true })
-- vim.keymap.set(
--   "n",
--   "<leader>lgi",
--   "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
--   { noremap = true }
-- )
-- vim.keymap.set(
--   "n",
--   "<leader>lgd",
--   "<cmd>lua require('goto-preview').goto_preview_declaration()<CR>",
--   { noremap = true }
-- )
vim.keymap.set("n", "<leader>lgw", "<cmd>lua require('goto-preview').close_all_win()<CR>", { noremap = true })
-- vim.keymap.set("n", "<leader>gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", { noremap = true })
vim.keymap.set({ "n", "x" }, "<leader>gy", function()
  Snacks.gitbrowse {
    open = function(url) vim.fn.setreg("+", url) end,
  }
end, { desc = "Git Browse (copy)" })

-- nnoremap <leader>fb <cmd>FzfLua files cwd=/prod/tools/base/<cr>
-- nnoremap <leader>gb <cmd>FzfLua live_grep cwd=/prod/tools/base/<cr>
vim.keymap.set(
  "n",
  "<leader>fb",
  function()
    require("fzf-lua").files {
      cwd = "/prod/tools/base/",
      winopts = {
        height = 0.6,
        width = 0.8,
      },
    }
  end,
  { desc = "Find files in base" }
)
vim.keymap.set(
  "n",
  "<leader>gb",
  function()
    require("fzf-lua").live_grep {
      cwd = "/prod/tools/base/",
      winopts = {
        height = 0.6,
        width = 0.8,
      },
    }
  end,
  { desc = "Live grep in base" }
)

-- Diagnostic Display Plugin Keymaps (Native LSP)
keymap("n", "<leader>dl", "<cmd>lua require('user.diagnostics_display').show_line_diagnostics()<cr>", opts)
keymap("n", "<leader>df", "<cmd>lua require('user.diagnostics_display').show_file_diagnostics()<cr>", opts)
keymap("n", "<leader>dw", "<cmd>lua require('user.diagnostics_display').show_workspace_diagnostics()<cr>", opts)

-- Lazygit keymaps
keymap("n", "<leader>gg", "<cmd>lua require('user.terminal').lazygit_float()<cr>", opts)
keymap("n", "<leader>gt", "<cmd>lua require('user.terminal').lazygit_tab()<cr>", opts)

-- Minimap keymaps (VSCode-like minimap)
keymap("n", "<leader>mm", "<cmd>lua require('user.minimap').smart_toggle()<cr>", opts)
keymap("n", "<leader>mr", "<cmd>MinimapRefresh<cr>", opts)
keymap("n", "<leader>mc", "<cmd>MinimapClose<cr>", opts)
-- Alternative keybinding similar to VSCode's Ctrl+Shift+M (using Ctrl+M since Shift is hard to detect)
-- keymap("n", "<C-m>", "<cmd>lua require('user.minimap').smart_toggle()<cr>", opts)
-- vim.keymap.set('n', '<C-f>', function()
--     vim.cmd('normal! ' .. math.floor(vim.o.lines / 2) .. 'j')
--     vim.cmd('normal! zz')
-- end, { desc = 'Scroll down half page and center' })
--
vim.keymap.set("n", "<C-f>", function()
  vim.cmd("normal! " .. vim.o.scroll .. "j")
  vim.cmd "normal! zz"
end, { desc = "Scroll down and center" })
vim.keymap.set("n", "<C-d>", function()
  vim.cmd("normal! " .. vim.o.scroll .. "j")
  vim.cmd "normal! zz"
end, { desc = "Scroll down and center", noremap = true, silent = true, remap = false })

-- Keymaps transferred from whichkey.lua
-- Buffer management
keymap("n", "<leader>b", "<cmd>FzfLua buffers<cr>", opts)
keymap("n", "<leader>bb", "<cmd>lua require('user.buffer_browser').open_buffer_browser()<cr>", opts)
keymap("n", "<leader>bs", "<cmd>lua require('user.buffer_browser').toggle_sidebar()<cr>", opts)

-- File Explorer
keymap("n", "<leader><leader>e", "<cmd>:NvimTreeToggle<cr>", opts)

-- Basic operations
keymap("n", "<leader>w", "<cmd>w<CR>", opts)
keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)
keymap("n", "<leader>q", "<cmd>lua require('user.functions').smart_quit()<CR>", opts)

-- Options toggles
keymap("n", "<leader>oc", "<cmd>lua vim.g.cmp_active=false<cr>", opts)
keymap("n", "<leader>oC", "<cmd>lua vim.g.cmp_active=true<cr>", opts)
keymap("n", "<leader>ow", '<cmd>lua require("user.functions").toggle_option("wrap")<cr>', opts)
keymap("n", "<leader>or", '<cmd>lua require("user.functions").toggle_option("relativenumber")<cr>', opts)
keymap("n", "<leader>ol", '<cmd>lua require("user.functions").toggle_option("cursorline")<cr>', opts)
keymap("n", "<leader>os", '<cmd>lua require("user.functions").toggle_option("spell")<cr>', opts)
keymap("n", "<leader>ot", '<cmd>lua require("user.functions").toggle_tabline()<cr>', opts)

-- Window splits
keymap("n", "<leader>ks", "<cmd>split<cr>", opts)
keymap("n", "<leader>kv", "<cmd>vsplit<cr>", opts)

-- Session management
keymap("n", "<leader>Ss", "<cmd>SessionSave<cr>", opts)
keymap("n", "<leader>Sr", "<cmd>SessionRestore<cr>", opts)
keymap("n", "<leader>Sx", "<cmd>SessionDelete<cr>", opts)

-- Find and Replace (Spectre)
keymap("n", "<leader>rr", "<cmd>lua require('spectre').open()<cr>", opts)
keymap("n", "<leader>rw", "<cmd>lua require('spectre').open_visual({select_word=true})<cr>", opts)
keymap("n", "<leader>rf", "<cmd>lua require('spectre').open_file_search({select_word=true})<cr>", opts)
keymap("n", "<leader>rb", "<cmd>lua require('spectre').open_file_search()<cr>", opts)

-- Code Runner
keymap("n", "<leader>Rb", ":TermExec cmd=./.buildme.sh<CR>", opts)
keymap("n", "<leader>Rp", ':TermExec cmd="python %<CR>"', opts)

-- Find using FzfLua
keymap("n", "<leader>fB", "<cmd>FzfLua git_branches<cr>", opts)
keymap("n", "<leader>fc", "<cmd>FzfLua colorschemes<cr>", opts)
keymap("n", "<leader>ff", "<cmd>FzfLua files<cr>", opts)
keymap("n", "<leader>fg", "<cmd>FzfLua git_files<cr>", opts)
keymap("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", opts)
keymap("n", "<leader>fss", "<cmd>FzfLua grep_cword<cr>", opts)
keymap("n", "<leader>fsb", "<cmd>FzfLua grep_curbuf<cr>", opts)
keymap("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", opts)
keymap("n", "<leader>fH", "<cmd>FzfLua highlights<cr>", opts)
keymap("n", "<leader>fi", "<cmd>FzfLua lsp_incoming_calls<cr>", opts)
keymap("n", "<leader>fo", "<cmd>FzfLua lsp_outgoing_calls<cr>", opts)
keymap("n", "<leader>fI", "<cmd>FzfLua lsp_implementations<cr>", opts)
keymap("n", "<leader>fl", "<cmd>FzfLua resume<cr>", opts)
keymap("n", "<leader>fM", "<cmd>FzfLua manpages<cr>", opts)
keymap("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", opts)
keymap("n", "<leader>fp", "<cmd>FzfLua oldfiles<cr>", opts)
keymap("n", "<leader>fR", "<cmd>FzfLua registers<cr>", opts)
keymap("n", "<leader>fk", "<cmd>FzfLua keymaps<cr>", opts)
keymap("n", "<leader>fC", "<cmd>FzfLua commands<cr>", opts)
keymap("n", "<leader>fF", "<cmd>FzfLua files<cr>", opts)

-- Diagnostics (additional - some already exist above)
keymap("n", "<leader>dd", "<cmd>lua require('user.diagnostics_display').debug()<cr>", opts)

-- Git operations
keymap("n", "<leader>gj", "<cmd>lua require 'gitsigns'.next_hunk()<cr>", opts)
keymap("n", "<leader>gk", "<cmd>lua require 'gitsigns'.prev_hunk()<cr>", opts)
keymap("n", "<leader>gll", "<cmd>GitBlameToggle<cr>", opts)
keymap("n", "<leader>glf", "<cmd>Git blame<cr>", opts)
keymap("n", "<leader>glg", "<cmd>Gitsigns blame_line<cr>", opts)
keymap("n", "<leader>gp", "<cmd>lua require 'gitsigns'.preview_hunk()<cr>", opts)
keymap("n", "<leader>gr", "<cmd>lua require 'gitsigns'.reset_hunk()<cr>", opts)
keymap("n", "<leader>gR", "<cmd>lua require 'gitsigns'.reset_buffer()<cr>", opts)
keymap("n", "<leader>gs", "<cmd>lua require 'gitsigns'.stage_hunk()<cr>", opts)
keymap("n", "<leader>gu", "<cmd>lua require 'gitsigns'.undo_stage_hunk()<cr>", opts)
keymap("n", "<leader>go", "<cmd>FzfLua git_status<cr>", opts)
keymap("n", "<leader>gd", "<cmd>Gitsigns diffthis HEAD<cr>", opts)

-- GitBlame
keymap("n", "<leader>Gl", "<cmd>GitBlameToggle<cr>", opts)
keymap("n", "<leader>Gc", "<cmd>GitBlameCopySHA<cr>", opts)
keymap("n", "<leader>Go", "<cmd>GitBlameOpenCommitURL<cr>", opts)

-- LSP operations
keymap("n", "<leader>lH", "<cmd>IlluminateToggle<cr>", opts)
keymap("n", "<leader>lI", "<cmd>Mason<cr>", opts)
keymap("n", "<leader>lj", "<cmd>lua vim.diagnostic.goto_next({buffer=0})<CR>", opts)
keymap("n", "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev({buffer=0})<cr>", opts)

-- Native LSP Virtual Diagnostics (custom plugin - ported from CoC)
keymap("n", "<leader>ll", "<cmd>lua require('user.lsp.virtual_diagnostics').toggle_virtual_lines()<cr>", opts)
keymap("n", "<leader>lv", "<cmd>lua require('user.lsp.virtual_diagnostics').toggle_virtual_text()<cr>", opts)
keymap("n", "<leader>ld", "<cmd>lua require('user.lsp.virtual_diagnostics').show_line_diagnostics()<cr>", opts)

-- Breadcrumbs/Outline (replaces CoC breadcrumbs)
keymap("n", "<leader>lb", "<cmd>Outline<cr>", opts)

-- Native LSP Format (handled by LSP servers, configured in lsp/servers.lua with <leader>f)
-- Note: <leader>f is the primary format keymap (set in lsp/servers.lua on_attach)
-- <leader>lf is kept as an alias for consistency with other <leader>l* LSP keymaps
vim.keymap.set(
  { "n", "v" },
  "<leader>lf",
  function() vim.lsp.buf.format { async = true } end,
  { noremap = true, silent = true, desc = "Format with LSP" }
)

keymap("n", "<leader>lo", "<cmd>Outline<cr>", opts)
keymap("n", "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", opts)
keymap("n", "<leader>lQ", "<cmd>FzfLua quickfix<cr>", opts)
keymap("n", "<leader>lr", "<cmd>Trouble lsp_references<cr>", opts)
keymap("n", "<leader>ls", "<cmd>FzfLua lsp_document_symbols<cr>", opts)
keymap("n", "<leader>lS", "<cmd>FzfLua lsp_live_workspace_symbols<cr>", opts)
keymap("n", "<leader>lgt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<cr>", opts)
keymap("n", "<leader>lgi", "<cmd>lua require('goto-preview').goto_preview_implementation()<cr>", opts)
keymap("n", "<leader>lgr", "<cmd>lua require('goto-preview').goto_preview_references()<cr>", opts)
keymap("n", "<leader>lgc", "<cmd>lua require('goto-preview').close_all_win()<cr>", opts)
keymap("n", "<leader>lt", '<cmd>lua require("user.functions").toggle_diagnostics()<cr>', opts)
keymap("n", "<leader>lu", "<cmd>LuaSnipUnlinkCurrent<cr>", opts)

-- Completion toggle (matching CoC's <leader>tc)
keymap("n", "<leader>tc", "<cmd>lua require('user.lsp.blink').toggle_autocomplete()<cr>", opts)

-- CocList replacements (native LSP equivalents using <space> prefix)
keymap("n", "<space>a", "<cmd>Trouble diagnostics toggle<cr>", opts) -- CocList diagnostics
keymap("n", "<space>o", "<cmd>Outline<cr>", opts) -- CocList outline
keymap("n", "<space>s", "<cmd>FzfLua lsp_workspace_symbols<cr>", opts) -- CocList symbols
keymap("n", "<space>e", "<cmd>Mason<cr>", opts) -- CocList extensions
keymap("n", "<space>c", "<cmd>FzfLua commands<cr>", opts) -- CocList commands
keymap("n", "<space>p", "<cmd>FzfLua resume<cr>", opts) -- CocListResume

-- Terminal keymaps
keymap("n", "<leader>T1", "<cmd>lua _FLOAT_TERM()<cr>", opts)
keymap("n", "<leader>T2", "<cmd>lua _VERTICAL_TERM()<cr>", opts)
keymap("n", "<leader>T3", "<cmd>lua _HORIZONTAL_TERM()<cr>", opts)
keymap("n", "<leader>T4", "<cmd>lua _FLOAT_TERM()<cr>", opts)
keymap("n", "<leader>Tn", "<cmd>lua _NODE_TOGGLE()<cr>", opts)
keymap("n", "<leader>Tu", "<cmd>lua _NCDU_TOGGLE()<cr>", opts)
keymap("n", "<leader>Tt", "<cmd>lua _HTOP_TOGGLE()<cr>", opts)
keymap("n", "<leader>Tm", "<cmd>lua _MAKE_TOGGLE()<cr>", opts)
keymap("n", "<leader>Tf", "<cmd>lua _FLOAT_TERM()<cr>", opts)
keymap("n", "<leader>Th", "<cmd>lua _HORIZONTAL_TERM()<cr>", opts)
keymap("n", "<leader>Tv", "<cmd>lua _VERTICAL_TERM()<cr>", opts)

-- Telescope/FzfLua operations
keymap("n", "<leader>tgS", "<cmd>FzfLua git_stash<cr>", opts)
keymap("n", "<leader>tC", "<cmd>FzfLua command_history<cr>", opts)
keymap("n", "<leader>tj", "<cmd>FzfLua jumps<cr>", opts)
keymap("n", "<leader>th", "<cmd>FzfLua search_history<cr>", opts)
keymap("n", "<leader>tb", "<cmd>FzfLua builtin<cr>", opts)
keymap("n", "<leader>tS", "<cmd>FzfLua blines<cr>", opts)

-- Project
keymap("n", "<leader>tp", "<cmd>FzfLua files<cr>", opts)

-- Transparent
keymap("n", "<leader>xt", "<cmd>TransparentToggle<cr>", opts)

return M
