-- Simplified Keymaps - Inspired by Helix
-- Leader: Space

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

-- Window navigation with Alt+hjkl
keymap("n", "<A-h>", "<C-w>h", opts)
keymap("n", "<A-j>", "<C-w>j", opts)
keymap("n", "<A-k>", "<C-w>k", opts)
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

-- ============================================
-- SEARCH & NAVIGATION
-- ============================================
-- Center screen after jumps
keymap("n", "<C-d>", "<C-d>zz", opts)
keymap("n", "<C-u>", "<C-u>zz", opts)
keymap("n", "n", "nzzzv", opts)
keymap("n", "N", "Nzzzv", opts)

-- ============================================
-- LSP KEYMAPS (set in lsp/servers.lua on_attach)
-- These are convenience aliases
-- ============================================
keymap("n", "gd", vim.lsp.buf.definition, opts)
keymap("n", "gr", vim.lsp.buf.references, opts)
keymap("n", "K", vim.lsp.buf.hover, opts)
keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
keymap("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)

-- Diagnostics
keymap("n", "[d", vim.diagnostic.goto_prev, opts)
keymap("n", "]d", vim.diagnostic.goto_next, opts)
keymap("n", "<leader>ld", vim.diagnostic.open_float, opts)

-- ============================================
-- GIT (like Helix <space>g)
-- ============================================
keymap("n", "<leader>gg", "<cmd>lua require('user.terminal').lazygit_float()<cr>", opts)
keymap("n", "glb", "<cmd>Gitsigns blame_line<cr>", opts)
keymap({ "n", "x" }, "<leader>gy", function()
  Snacks.gitbrowse { open = function(url) vim.fn.setreg("+", url) end }
end, { desc = "Copy GitHub permalink" })

-- ============================================
-- FILE OPERATIONS (FzfLua)
-- ============================================
keymap("n", "<C-p>", "<cmd>FzfLua files<cr>", opts)
keymap("n", "<leader>ff", "<cmd>FzfLua files<cr>", opts)
keymap("n", "<leader>fr", "<cmd>FzfLua oldfiles<cr>", opts)
keymap("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", opts)
keymap("n", "<leader>b", "<cmd>FzfLua buffers<cr>", opts)
keymap("n", "<leader>fh", "<cmd>FzfLua helptags<cr>", opts)
keymap("n", "<leader>fk", "<cmd>FzfLua keymaps<cr>", opts)
keymap("n", "<leader>fs", "<cmd>FzfLua lsp_document_symbols<cr>", opts)

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
-- QUICKFIX
-- ============================================
keymap("n", "<leader>xq", "<cmd>copen<cr>", opts)
keymap("n", "]q", "<cmd>cnext<cr>", opts)
keymap("n", "[q", "<cmd>cprev<cr>", opts)
