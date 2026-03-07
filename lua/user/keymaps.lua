-- Simplified Keymaps - Inspired by Helix
-- Leader: Comma (,)

local opts = { noremap = true, silent = true }
local keymap = vim.keymap.set

-- ============================================
-- ESCAPE ALTERNATIVES
-- ============================================
keymap("i", "jk", "<ESC>", opts)

-- ============================================
-- BASIC OPERATIONS
-- ============================================
keymap("n", "<leader>w", "<cmd>w<CR>", opts)
keymap("n", "<leader>q", "<cmd>q<CR>", opts)
keymap("n", "<leader>Q", "<cmd>q!<CR>", opts)
keymap("n", "<leader>h", "<cmd>nohlsearch<CR>", opts)

-- ============================================
-- BUFFER NAVIGATION (like Helix H/L)
-- ============================================
keymap("n", "<S-h>", "<cmd>bprevious<CR>", opts)
keymap("n", "<S-l>", "<cmd>bnext<CR>", opts)
keymap("n", "<leader>bd", "<cmd>bdelete<CR>", opts)

-- Window navigation with Alt+hjkl (j/k reserved for move-line below)
keymap("n", "<A-h>", "<C-w>h", opts)
keymap("n", "<A-l>", "<C-w>l", opts)

-- ============================================
-- LINE NAVIGATION (Vim-like, matching Helix)
-- ============================================
keymap("n", "0", "^", opts) -- Go to first non-blank
keymap("n", "^", "0", opts) -- Go to column 0

-- ============================================
-- TEXT MANIPULATION
-- ============================================
-- Move lines up/down
keymap("n", "<A-j>", "<cmd>m .+1<CR>==", opts)
keymap("n", "<A-k>", "<cmd>m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Stay in visual mode when indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Delete without yanking
keymap("n", "<leader>d", '"_d', opts)
keymap("v", "<leader>d", '"_d', opts)

-- Paste without yanking in visual
keymap("v", "p", '"_dP', opts)

-- Increment/decrement (like Helix +/-)
keymap("n", "+", "<C-a>", opts)
keymap("n", "-", "<C-x>", opts)

-- Select all
keymap("n", "<C-a>", "ggVG", opts)

-- ============================================
-- SEARCH & NAVIGATION
-- ============================================
-- Center screen after jumps
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- ============================================
-- GIT (like Helix <space>g)
-- ============================================
keymap("n", "<leader>gg", "<cmd>lua require('user.terminal').lazygit_float()<cr>", opts)
keymap("n", "glb", "<cmd>Gitsigns blame_line<cr>", opts)
-- <leader>gy is mapped in plugins.lua via snacks.nvim lazy keys

-- ============================================
-- FILE OPERATIONS (Snacks.picker - defined in plugins.lua)
-- ============================================
-- <C-p>, <leader>ff, <leader>fr, <leader>/, <leader>b, <leader>fh, <leader>fk, <leader>fs
-- are all mapped in plugins.lua via Snacks.picker for better performance

-- ============================================
-- WINDOW SPLITS (like Helix <space>k)
-- ============================================
keymap("n", "<leader>ks", "<cmd>split<cr>", opts)
keymap("n", "<leader>kv", "<cmd>vsplit<cr>", opts)

-- ============================================
-- TOGGLES (like Helix <space>o)
-- ============================================
keymap("n", "<leader>ow", "<cmd>set wrap!<cr>", opts)
keymap("n", "<leader>or", "<cmd>set relativenumber!<cr>", opts)
keymap("n", "<leader>ol", "<cmd>set cursorline!<cr>", opts)

-- ============================================
-- COPILOT
-- ============================================
vim.g.copilot_no_tab_map = true
keymap("i", "<A-y>", 'copilot#Accept("\\<CR>")', { expr = true, replace_keycodes = false, silent = true })
keymap("i", "<M-]>", "<Plug>(copilot-next)", { silent = true })
keymap("i", "<M-[>", "<Plug>(copilot-previous)", { silent = true })

-- ============================================
-- MOUSE
-- ============================================
keymap("n", "<C-LeftMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.definition()<cr>", opts)
keymap("n", "<C-RightMouse>", "<RightMouse><cmd>lua vim.lsp.buf.references()<cr>", opts)
keymap("n", "<MiddleMouse>", "<LeftMouse><cmd>lua vim.lsp.buf.hover()<cr>", opts)
keymap("n", "<A-LeftMouse>", "<C-o>", opts)
keymap("n", "<A-RightMouse>", "<C-i>", opts)

-- ============================================
-- QUICKFIX
-- ============================================
keymap("n", "<leader>xq", "<cmd>copen<cr>", opts)
keymap("n", "]q", "<cmd>cnext<cr>", opts)
keymap("n", "[q", "<cmd>cprev<cr>", opts)

-- ============================================
-- RIGHT-CLICK POPUP MENU
-- ============================================
-- Navigation
vim.cmd [[
  amenu PopUp.Go\ to\ Definition      <cmd>lua vim.lsp.buf.definition()<cr>
  amenu PopUp.Go\ to\ References      <cmd>lua vim.lsp.buf.references()<cr>
  amenu PopUp.Go\ to\ Implementation  <cmd>lua vim.lsp.buf.implementation()<cr>
  amenu PopUp.Go\ to\ Type\ Definition <cmd>lua vim.lsp.buf.type_definition()<cr>
  amenu PopUp.-sep1-                   <Nop>

  " Actions
  amenu PopUp.Rename\ Symbol           <cmd>lua vim.lsp.buf.rename()<cr>
  amenu PopUp.Code\ Actions            <cmd>lua vim.lsp.buf.code_action()<cr>
  amenu PopUp.Hover\ Documentation     <cmd>lua vim.lsp.buf.hover()<cr>
  amenu PopUp.Signature\ Help          <cmd>lua vim.lsp.buf.signature_help()<cr>
  amenu PopUp.-sep2-                   <Nop>

  " Diagnostics
  amenu PopUp.Show\ Diagnostic         <cmd>lua vim.diagnostic.open_float()<cr>
  amenu PopUp.Next\ Diagnostic         <cmd>lua vim.diagnostic.goto_next()<cr>
  amenu PopUp.Prev\ Diagnostic         <cmd>lua vim.diagnostic.goto_prev()<cr>
  amenu PopUp.-sep3-                   <Nop>

  " Git
  amenu PopUp.Git\ Blame\ Line         <cmd>Gitsigns blame_line<cr>
  amenu PopUp.Git\ Preview\ Hunk       <cmd>Gitsigns preview_hunk<cr>
  amenu PopUp.Git\ Open\ Lazygit       <cmd>lua require('user.terminal').lazygit_float()<cr>
  amenu PopUp.-sep4-                   <Nop>

  " Edit
  amenu PopUp.Format\ File             <cmd>lua vim.lsp.buf.format({ async = true })<cr>
  amenu PopUp.Copy\ File\ Path         <cmd>let @+ = fnamemodify(expand('%'), ':.')<cr>
  amenu PopUp.Copy\ Path:Line          <cmd>let @+ = fnamemodify(expand('%'), ':.') . ':' . line('.')<cr>
  vmenu PopUp.Copy\ Path:Line\ Range   <Esc><cmd>let @+ = fnamemodify(expand('%'), ':.') . ':' . line("'<") . ':' . line("'>")<cr>
  amenu PopUp.-sep5-                   <Nop>

  " Splits
  amenu PopUp.Split\ Right             <cmd>vsplit<cr>
  amenu PopUp.Split\ Left              <cmd>set splitright!<bar>vsplit<bar>set splitright<cr>
]]
