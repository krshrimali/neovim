-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Shorten function name
M = {}
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

local keymap = vim.api.nvim_set_keymap

--Remap comma as leader key
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Normal --
-- Better window navigation
keymap("n", "<m-h>", "<C-w>h", opts)
keymap("n", "<m-j>", "<C-w>j", opts)
keymap("n", "<m-k>", "<C-w>k", opts)
keymap("n", "<m-l>", "<C-w>l", opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

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

keymap('v', "F", ":m '>+1<CR>gv=gv", opts)
keymap('v', "U", ":m '<-2<CR>gv=gv", opts)

keymap('n', '<leader>d', '"_d', opts)
keymap('x', '<leader>d', '"_d', opts)
keymap('x', '<leader>p', '"_dP', opts)

keymap("x", "<leader>p", "\"_dP", opts)
-- keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>/<C-r><C-w>/gI<Left><Left><Left>", opts)
keymap("n", "<leader>s", ":%s/\\<<C-r><C-w>\\>//gI<Left><Left><Left>", opts)

-- NOTE: the fact that tab and ctrl-i are the same is stupid
keymap("n", "Q", "<cmd>Bdelete!<CR>", opts)
keymap("n", "<F11>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
keymap("n", "<F12>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
keymap("n", "<C-p>", "<cmd>Telescope projects<cr>", opts)
keymap("n", "<C-s>", "<cmd>lua vim.lsp.buf.document_symbol()<cr>", opts)
keymap("n", "<C-z>", "<cmd>ZenMode<cr>", opts)

keymap("n", "-", ":lua require'lir.float'.toggle()<cr>", opts)

M.show_documentation = function()
  local filetype = vim.bo.filetype
  if vim.tbl_contains({ "vim", "help" }, filetype) then
    vim.cmd("h " .. vim.fn.expand "<cword>")
  elseif vim.tbl_contains({ "man" }, filetype) then
    vim.cmd("Man " .. vim.fn.expand "<cword>")
  elseif vim.fn.expand "%:t" == "Cargo.toml" then
    require("crates").show_popup()
  else
    vim.lsp.buf.hover()
  end
end
vim.api.nvim_set_keymap("n", "K", ":lua require('user.keymaps').show_documentation()<CR>", opts)

-- TODO: Rethink on this, currently not using it... (harpoon)
-- vim.api.nvim_set_keymap(
--   "n",
--   "<C-m>",
--   "<cmd>lua require('telescope').extensions.harpoon.marks(require('telescope.themes').get_dropdown{ layout_strategy = 'horizontal', layout_config = { width = function(_, max_columns, _) return math.min(max_columns, 120) end, height= function(_, _, max_lines) return math.min(max_lines, 30) end, }, initial_mode='normal', prompt_title='Harpoon'})<cr>",
--   opts
-- )

vim.api.nvim_set_keymap("n", "<s-t>", "<cmd>TodoQuickFix<cr>", opts)
vim.api.nvim_set_keymap("n", "<m-t>", "<cmd>TodoQuickFix<cr>", opts)

vim.cmd [[
  function! QuickFixToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
      copen
    else
      cclose
    endif
  endfunction
]]

keymap("n", "<m-q>", ":call QuickFixToggle()<cr>", opts)

return M
