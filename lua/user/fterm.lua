local status_ok, fterm = pcall(require, "FTerm")
if not status_ok then
  return
end

-- Main FTerm setup with fish as default shell and beautiful styling
fterm.setup({
  border = "rounded",
  dimensions = {
    height = 0.8,
    width = 0.8,
  },
  cmd = "fish", -- Set fish as default shell
  auto_close = false, -- Keep terminal open after command exits
  hl = "Normal",
  blend = 0,
})

-- Terminal navigation keymaps for all terminal buffers
function _G.set_terminal_keymaps()
  local opts = { noremap = true, silent = true }
  -- Exit terminal mode with Esc or jk
  vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "jk", [[<C-\><C-n>]], opts)
  -- Window navigation from terminal
  vim.api.nvim_buf_set_keymap(0, "t", "<C-h>", [[<C-\><C-n><C-W>h]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-j>", [[<C-\><C-n><C-W>j]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-k>", [[<C-\><C-n><C-W>k]], opts)
  vim.api.nvim_buf_set_keymap(0, "t", "<C-l>", [[<C-\><C-n><C-W>l]], opts)
end

-- Set terminal keymaps for all terminal buffers
vim.cmd "autocmd! TermOpen term://* lua set_terminal_keymaps()"

-- Custom terminal instances
local node = fterm:new({
  cmd = "node",
  ft = "fterm_node",
  dimensions = {
    height = 0.6,
    width = 0.8,
  },
})

local ncdu = fterm:new({
  cmd = "ncdu",
  ft = "fterm_ncdu",
  dimensions = {
    height = 0.8,
    width = 0.8,
  },
})

local htop = fterm:new({
  cmd = "htop",
  ft = "fterm_htop",
  dimensions = {
    height = 0.8,
    width = 0.9,
  },
})

local make = fterm:new({
  cmd = "./.buildme.sh",
  ft = "fterm_make",
  auto_close = false,
  dimensions = {
    height = 0.7,
    width = 0.9,
  },
})

local cargo_run = fterm:new({
  cmd = "cargo run",
  ft = "fterm_cargo_run",
  auto_close = false,
  dimensions = {
    height = 0.7,
    width = 0.9,
  },
})

local cargo_test = fterm:new({
  cmd = "cargo test",
  ft = "fterm_cargo_test",
  auto_close = false,
  dimensions = {
    height = 0.7,
    width = 0.9,
  },
})

-- Float terminal (main terminal)
local float_term = fterm:new({
  cmd = "fish",
  ft = "fterm_float",
  dimensions = {
    height = 0.8,
    width = 0.8,
  },
})

-- Vertical terminal
local vertical_term = fterm:new({
  cmd = "fish",
  ft = "fterm_vertical",
  dimensions = {
    height = 0.9,
    width = 0.5,
    x = 0.75,
    y = 0.5,
  },
})

-- Horizontal terminal
local horizontal_term = fterm:new({
  cmd = "fish",
  ft = "fterm_horizontal",
  dimensions = {
    height = 0.3,
    width = 0.9,
    x = 0.5,
    y = 0.85,
  },
})

-- Global functions for terminal access
function _G._NODE_TOGGLE()
  node:toggle()
end

function _G._NCDU_TOGGLE()
  ncdu:toggle()
end

function _G._HTOP_TOGGLE()
  htop:toggle()
end

function _G._MAKE_TOGGLE()
  make:toggle()
end

function _G._CARGO_RUN()
  cargo_run:toggle()
end

function _G._CARGO_TEST()
  cargo_test:toggle()
end

function _G._FLOAT_TERM()
  float_term:toggle()
end

function _G._VERTICAL_TERM()
  vertical_term:toggle()
end

function _G._HORIZONTAL_TERM()
  horizontal_term:toggle()
end

-- Main terminal toggle (Alt+1)
vim.api.nvim_set_keymap("n", "<A-1>", "<cmd>lua _FLOAT_TERM()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-1>", "<cmd>lua _FLOAT_TERM()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-1>", "<cmd>lua _FLOAT_TERM()<CR>", { noremap = true, silent = true })

-- Vertical terminal (Alt+2)
vim.api.nvim_set_keymap("n", "<A-2>", "<cmd>lua _VERTICAL_TERM()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-2>", "<cmd>lua _VERTICAL_TERM()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-2>", "<cmd>lua _VERTICAL_TERM()<CR>", { noremap = true, silent = true })

-- Horizontal terminal (Alt+3)
vim.api.nvim_set_keymap("n", "<A-3>", "<cmd>lua _HORIZONTAL_TERM()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("i", "<A-3>", "<cmd>lua _HORIZONTAL_TERM()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("t", "<A-3>", "<cmd>lua _HORIZONTAL_TERM()<CR>", { noremap = true, silent = true })