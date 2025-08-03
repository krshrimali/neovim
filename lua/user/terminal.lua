local M = {}

-- Function to safely disable treesitter for terminal buffers
local function disable_treesitter_for_terminal(buf)
  -- Disable syntax highlighting for terminal buffers
  vim.api.nvim_buf_set_option(buf, "syntax", "")
  
  -- Try to disable treesitter highlighting for this buffer
  local ok, ts_highlighter = pcall(require, "nvim-treesitter.highlighter")
  if ok and ts_highlighter then
    -- Force disable treesitter highlighting for this buffer
    pcall(function()
      ts_highlighter.detach(buf)
    end)
  end
end

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
  
  -- Set buffer options before opening terminal to prevent issues
  vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  
  -- Disable treesitter highlighting for terminal buffers
  disable_treesitter_for_terminal(buf)
  
  local job_id = vim.fn.termopen(cmd or config.shell)
  
  return buf, job_id
end

-- Set terminal keymaps (for regular terminals, not lazygit)
local function set_terminal_keymaps(buf)
  local opts = { buffer = buf, noremap = true, silent = true }
  
  -- Exit terminal mode with Escape (regular terminals only)
  vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
  
  -- Window navigation from terminal
  vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], opts)
  vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], opts)
  vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], opts)
  vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], opts)
  
  -- Close terminal
  vim.keymap.set("n", "q", ":q<CR>", opts)
end

-- Auto-enter insert mode for terminals (but not lazygit)
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    
    -- Ensure buffer is properly configured as terminal
    vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
    vim.api.nvim_buf_set_option(buf, "modifiable", true)
    vim.api.nvim_buf_set_option(buf, "swapfile", false)
    
    -- Disable treesitter highlighting for terminal buffers
    disable_treesitter_for_terminal(buf)
    
    -- Skip lazygit buffers - they have their own keymaps
    if filetype ~= "lazygit" then
      set_terminal_keymaps(buf)
      vim.cmd("startinsert")
    end
  end,
})

-- Float terminal
function M.float_terminal(cmd)
  local buf, win = create_float_window(config.size.float.width, config.size.float.height, "Float Terminal")
  
  vim.api.nvim_set_current_buf(buf)
  
  -- Set buffer options before opening terminal to prevent issues
  vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  
  -- Disable treesitter highlighting for terminal buffers
  disable_treesitter_for_terminal(buf)
  
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

-- Toggle vertical terminal
function M.toggle_vertical_terminal()
  if terminals.vertical and vim.api.nvim_buf_is_valid(terminals.vertical.buf) then
    -- Find and close the vertical terminal window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == terminals.vertical.buf then
        vim.api.nvim_win_close(win, true)
        break
      end
    end
    terminals.vertical.hidden = true
  elseif terminals.vertical and terminals.vertical.hidden then
    -- Restore the vertical terminal
    local buf = terminals.vertical.buf
    if vim.api.nvim_buf_is_valid(buf) then
      vim.cmd("vsplit")
      local width = math.floor(vim.o.columns * config.size.vertical.width)
      vim.cmd("vertical resize " .. width)
      vim.api.nvim_set_current_buf(buf)
      terminals.vertical.hidden = false
      vim.cmd("startinsert")
    else
      -- Buffer is invalid, create new terminal
      terminals.vertical = nil
      M.vertical_terminal()
    end
  else
    M.vertical_terminal()
  end
end

-- Toggle horizontal terminal
function M.toggle_horizontal_terminal()
  if terminals.horizontal and vim.api.nvim_buf_is_valid(terminals.horizontal.buf) then
    -- Find and close the horizontal terminal window
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      if vim.api.nvim_win_get_buf(win) == terminals.horizontal.buf then
        vim.api.nvim_win_close(win, true)
        break
      end
    end
    terminals.horizontal.hidden = true
  elseif terminals.horizontal and terminals.horizontal.hidden then
    -- Restore the horizontal terminal
    local buf = terminals.horizontal.buf
    if vim.api.nvim_buf_is_valid(buf) then
      vim.cmd("split")
      local height = math.floor(vim.o.lines * config.size.horizontal.height)
      vim.cmd("resize " .. height)
      vim.api.nvim_set_current_buf(buf)
      terminals.horizontal.hidden = false
      vim.cmd("startinsert")
    else
      -- Buffer is invalid, create new terminal
      terminals.horizontal = nil
      M.horizontal_terminal()
    end
  else
    M.horizontal_terminal()
  end
end

-- Toggle float terminal
function M.toggle_float_terminal()
  if terminals.float and vim.api.nvim_win_is_valid(terminals.float.win) then
    -- Hide the terminal instead of closing it
    vim.api.nvim_win_hide(terminals.float.win)
    terminals.float.hidden = true
  elseif terminals.float and terminals.float.hidden then
    -- Restore the hidden terminal
    local buf = terminals.float.buf
    if vim.api.nvim_buf_is_valid(buf) then
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * config.size.float.width),
        height = math.floor(vim.o.lines * config.size.float.height),
        col = math.floor((vim.o.columns - math.floor(vim.o.columns * config.size.float.width)) / 2),
        row = math.floor((vim.o.lines - math.floor(vim.o.lines * config.size.float.height)) / 2),
        border = config.border,
        title = "Float Terminal",
        title_pos = "center",
        style = "minimal",
      })
      terminals.float.win = win
      terminals.float.hidden = false
      vim.cmd("startinsert")
    else
      -- Buffer is invalid, create new terminal
      terminals.float = nil
      M.float_terminal()
    end
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
  -- Create buffer first and set its properties
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "filetype", "lazygit")
  
  -- Create floating window
  local width = math.floor(vim.o.columns * 0.95)
  local height = math.floor(vim.o.lines * 0.95)
  local col = math.floor((vim.o.columns - width) / 2)
  local row = math.floor((vim.o.lines - height) / 2)
  
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = col,
    row = row,
    border = config.border,
    title = "Lazygit",
    title_pos = "center",
    style = "minimal",
  })
  
  -- Open terminal
  local job_id = vim.fn.termopen("lazygit")
  
  -- Minimal keymaps - only close function
  vim.keymap.set("n", "q", function()
    if vim.api.nvim_win_is_valid(win) then
      vim.api.nvim_win_close(win, true)
    end
  end, { buffer = buf, noremap = true, silent = true })
  
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
  
  -- Start in insert mode for immediate lazygit interaction
  vim.cmd("startinsert")
  
  return buf, win, job_id
end

function M.lazygit_tab()
  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()
  
  -- Set buffer options before opening terminal to prevent autocmd interference
  vim.api.nvim_buf_set_option(buf, "filetype", "lazygit")
  
  local job_id = vim.fn.termopen("lazygit")
  
  -- Set buffer name
  vim.api.nvim_buf_set_name(buf, "lazygit")
  
  -- Start in insert mode
  vim.cmd("startinsert")
  
  return buf, job_id
end

-- Legacy function for backward compatibility
M.lazygit_toggle = function()
  M.lazygit_float()
end

-- Global functions for keybindings
_G._FLOAT_TERM = M.toggle_float_terminal
_G._VERTICAL_TERM = M.toggle_vertical_terminal
_G._HORIZONTAL_TERM = M.toggle_horizontal_terminal
_G._NODE_TOGGLE = M.node_terminal
_G._NCDU_TOGGLE = M.ncdu_terminal
_G._HTOP_TOGGLE = M.htop_terminal
_G._MAKE_TOGGLE = M.make_terminal
_G._CARGO_RUN = M.cargo_run
_G._CARGO_TEST = M.cargo_test
_G.LAZYGIT_TOGGLE_FLOAT = M.lazygit_float
_G.LAZYGIT_TOGGLE_TAB = M.lazygit_tab

-- Toggle centered float terminal (60% screen)
function M.toggle_centered_terminal()
  if terminals.centered and vim.api.nvim_win_is_valid(terminals.centered.win) then
    -- Hide the terminal instead of closing it
    vim.api.nvim_win_hide(terminals.centered.win)
    terminals.centered.hidden = true
  elseif terminals.centered and terminals.centered.hidden then
    -- Restore the hidden terminal
    local buf = terminals.centered.buf
    if vim.api.nvim_buf_is_valid(buf) then
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = math.floor(vim.o.columns * 0.6),
        height = math.floor(vim.o.lines * 0.6),
        col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.6)) / 2),
        row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
        border = config.border,
        title = "Terminal",
        title_pos = "center",
        style = "minimal",
      })
      terminals.centered.win = win
      terminals.centered.hidden = false
      vim.cmd("startinsert")
    else
      -- Buffer is invalid, create new terminal
      terminals.centered = nil
      M.centered_terminal()
    end
  else
    M.centered_terminal()
  end
end

-- Centered terminal (60% screen)
function M.centered_terminal(cmd)
  local buf, win = create_float_window(0.6, 0.6, "Terminal")
  
  vim.api.nvim_set_current_buf(buf)
  
  -- Set buffer options before opening terminal to prevent issues
  vim.api.nvim_buf_set_option(buf, "buftype", "terminal")
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  
  -- Disable treesitter highlighting for terminal buffers
  disable_treesitter_for_terminal(buf)
  
  local job_id = vim.fn.termopen(cmd or config.shell)
  
  terminals.centered = { buf = buf, win = win, job_id = job_id }
  
  -- Auto-close window when terminal exits
  vim.api.nvim_create_autocmd("TermClose", {
    buffer = buf,
    callback = function()
      if vim.api.nvim_win_is_valid(win) then
        vim.api.nvim_win_close(win, true)
      end
      terminals.centered = nil
    end,
    once = true,
  })
  
  return buf, win, job_id
end

-- Set up keymaps
local function setup_keymaps()
  local opts = { noremap = true, silent = true }
  
  -- Main terminal toggles
  vim.keymap.set("n", "<A-1>", M.toggle_float_terminal, opts)
  vim.keymap.set("i", "<A-1>", M.toggle_float_terminal, opts)
  vim.keymap.set("t", "<A-1>", M.toggle_float_terminal, opts)
  
  vim.keymap.set("n", "<A-2>", M.toggle_vertical_terminal, opts)
  vim.keymap.set("i", "<A-2>", M.toggle_vertical_terminal, opts)
  vim.keymap.set("t", "<A-2>", M.toggle_vertical_terminal, opts)
  
  vim.keymap.set("n", "<A-3>", M.toggle_horizontal_terminal, opts)
  vim.keymap.set("i", "<A-3>", M.toggle_horizontal_terminal, opts)
  vim.keymap.set("t", "<A-3>", M.toggle_horizontal_terminal, opts)
  
  -- Ctrl+\ for centered floating terminal (60% screen)
  vim.keymap.set("n", "<C-\\>", M.toggle_centered_terminal, opts)
  vim.keymap.set("i", "<C-\\>", M.toggle_centered_terminal, opts)
  vim.keymap.set("t", "<C-\\>", M.toggle_centered_terminal, opts)
  
  -- Lazygit
  vim.keymap.set("n", "<leader>gG", M.lazygit_tab, { desc = "Lazygit Tab", noremap = true, silent = true })
end

-- Additional safety: Disable treesitter for terminal buffers
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
    
    if buftype == "terminal" then
      -- Disable treesitter highlighting for terminal buffers
      disable_treesitter_for_terminal(buf)
    end
  end,
})

-- Initialize
setup_keymaps()

return M
