local M = {}

-- Terminal configuration
local config = {
  shell = "fish", -- Default shell
  size = {
    float = { width = 0.8, height = 0.8 },
    vertical = { width = 0.5, height = 0.9 },
    horizontal = { width = 0.9, height = 0.3 },
  },
  border = "rounded",
}

-- Terminal instances storage
local terminals = {}
local terminal_count = 0

-- Helper function to create floating window
local function create_float_window(width_ratio, height_ratio, title)
  local width = math.floor(vim.o.columns * width_ratio)
  local height = math.floor(vim.o.lines * height_ratio)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)

  local buf = vim.api.nvim_create_buf(false, true)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    border = config.border,
    title = title or "Terminal",
    title_pos = "center",
    style = "minimal",
  })

  return buf, win
end

-- Helper function to create split window terminal
local function create_split_terminal(direction, size_ratio, cmd)
  if direction == "vertical" then
    vim.cmd("vsplit")
    local width = math.floor(vim.o.columns * size_ratio)
    vim.cmd("vertical resize " .. width)
  elseif direction == "horizontal" then
    vim.cmd("split")
    local height = math.floor(vim.o.lines * size_ratio)
    vim.cmd("resize " .. height)
  end
  
  local buf = vim.api.nvim_get_current_buf()
  local job_id = vim.fn.termopen(cmd or config.shell)
  
  return buf, job_id
end

-- Set terminal keymaps
local function set_terminal_keymaps(buf)
  local opts = { buffer = buf, noremap = true, silent = true }
  
  -- Exit terminal mode
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
  
  -- Window navigation from terminal
  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
  
  -- Close terminal
  vim.keymap.set("n", "q", ":q<CR>", opts)
end

-- Auto-enter insert mode for terminals
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    set_terminal_keymaps(buf)
    vim.cmd("startinsert")
  end,
})

-- Float terminal
function M.float_terminal(cmd)
  local buf, win = create_float_window(config.size.float.width, config.size.float.height, "Float Terminal")
  
  vim.api.nvim_set_current_buf(buf)
  local job_id = vim.fn.termopen(cmd or config.shell)
  
  terminals.float = { buf = buf, win = win, job_id = job_id }
  
  -- Auto-close window when terminal exits
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      terminals.float = nil
    end,
    once = true,
  })
  
  return buf, win, job_id
end

-- Vertical terminal
function M.vertical_terminal(cmd)
  local buf, job_id = create_split_terminal("vertical", config.size.vertical.width, cmd)
  terminals.vertical = { buf = buf, job_id = job_id }
  return buf, job_id
end

-- Horizontal terminal
function M.horizontal_terminal(cmd)
  local buf, job_id = create_split_terminal("horizontal", config.size.horizontal.height, cmd)
  terminals.horizontal = { buf = buf, job_id = job_id }
  return buf, job_id
end

-- Toggle float terminal
function M.toggle_float_terminal()
  if terminals.float and vim.api.nvim_win_is_valid(terminals.float.win) then
    vim.api.nvim_win_close(terminals.float.win, true)
    terminals.float = nil
  else
    M.float_terminal()
  end
end

-- Specialized terminals
function M.node_terminal()
  M.float_terminal("node")
end

function M.ncdu_terminal()
  M.float_terminal("ncdu")
end

function M.htop_terminal()
  M.float_terminal("htop")
end

function M.make_terminal()
  M.float_terminal("./.buildme.sh")
end

function M.cargo_run()
  M.float_terminal("cargo run")
end

function M.cargo_test()
  M.float_terminal("cargo test")
end

-- Lazygit integration
function M.lazygit_float()
  local buf, win = create_float_window(0.95, 0.95, "Lazygit")
  
  vim.api.nvim_set_current_buf(buf)
  local job_id = vim.fn.termopen("lazygit")
  
  -- Lazygit-specific keymaps
  local opts = { buffer = buf, noremap = true, silent = true }
  vim.keymap.set("t", "<C-\\><C-n>", [[<C-\><C-n>]], opts)
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, opts)
  
  -- Auto-close window when lazygit exits
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
    end,
    once = true,
  })
  
  return buf, win, job_id
end

function M.lazygit_tab()
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  local job_id = vim.fn.termopen("lazygit")
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, "lazygit")
  
  return buf, job_id
end

-- Legacy function for backward compatibility
M.lazygit_toggle = function()
  M.lazygit_float()
end

-- Global functions for keybindings
_G._FLOAT_TERM = M.toggle_float_terminal
_G._VERTICAL_TERM = function() M.vertical_terminal() end
_G._HORIZONTAL_TERM = function() M.horizontal_terminal() end
_G._NODE_TOGGLE = M.node_terminal
_G._NCDU_TOGGLE = M.ncdu_terminal
_G._HTOP_TOGGLE = M.htop_terminal
_G._MAKE_TOGGLE = M.make_terminal
_G._CARGO_RUN = M.cargo_run
_G._CARGO_TEST = M.cargo_test
_G.LAZYGIT_TOGGLE_FLOAT = M.lazygit_float
_G.LAZYGIT_TOGGLE_TAB = M.lazygit_tab

-- Set up keymaps
local function setup_keymaps()
  local opts = { noremap = true, silent = true }
  
  -- Main terminal toggles
  vim.keymap.set("n", "<A-1>", M.toggle_float_terminal, opts)
  vim.keymap.set("i", "<A-1>", M.toggle_float_terminal, opts)
  vim.keymap.set("t", "<A-1>", M.toggle_float_terminal, opts)
  
  vim.keymap.set("n", "<A-2>", function() M.vertical_terminal() end, opts)
  vim.keymap.set("i", "<A-2>", function() M.vertical_terminal() end, opts)
  vim.keymap.set("t", "<A-2>", function() M.vertical_terminal() end, opts)
  
  vim.keymap.set("n", "<A-3>", function() M.horizontal_terminal() end, opts)
  vim.keymap.set("i", "<A-3>", function() M.horizontal_terminal() end, opts)
  vim.keymap.set("t", "<A-3>", function() M.horizontal_terminal() end, opts)
  
  -- Lazygit
  vim.keymap.set("n", "<leader>gg", M.lazygit_float, { desc = "Lazygit Float", noremap = true, silent = true })
  vim.keymap.set("n", "<leader>gG", M.lazygit_tab, { desc = "Lazygit Tab", noremap = true, silent = true })
end

-- Initialize
setup_keymaps()

return M
