local M = {}

local Terminal = require("toggleterm.terminal").Terminal

-- Lazygit floating window configuration
local lazygit_float = Terminal:new {
  cmd = "lazygit",
  hidden = true,
  direction = "float",
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  persist_mode = false,
  close_on_exit = true,
  float_opts = {
    border = "rounded",
    width = function()
      return math.floor(vim.o.columns * 0.95)
    end,
    height = function()
      return math.floor(vim.o.lines * 0.95)
    end,
    winblend = 0,
    highlights = {
      border = "Normal",
      background = "Normal",
    },
  },
  on_open = function(term)
    -- Start in insert mode
    vim.cmd("startinsert!")
    
    -- Set up proper keymaps for the lazygit buffer
    local opts = { buffer = term.bufnr, noremap = true, silent = true }
    
    -- Escape should go to normal mode in the terminal
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
    
    -- Allow easy navigation back to insert mode
    vim.keymap.set("n", "i", "i", opts)
    vim.keymap.set("n", "a", "a", opts)
    
    -- Close lazygit with q in normal mode
    vim.keymap.set("n", "q", function()
      term:close()
    end, opts)
    
    -- Disable line numbers and other UI elements for clean experience
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.wo.foldcolumn = "0"
    vim.wo.statuscolumn = ""
  end,
  on_close = function(_)
    -- Reset any global settings if needed
  end,
  count = 98, -- Use a unique count to avoid conflicts
}

-- Lazygit tab configuration
local lazygit_tab = Terminal:new {
  cmd = "lazygit",
  hidden = true,
  direction = "tab",
  start_in_insert = true,
  insert_mappings = true,
  terminal_mappings = true,
  persist_mode = false,
  close_on_exit = true,
  on_open = function(term)
    -- Start in insert mode
    vim.cmd("startinsert!")
    
    -- Set up proper keymaps for the lazygit buffer
    local opts = { buffer = term.bufnr, noremap = true, silent = true }
    
    -- Escape should go to normal mode in the terminal
    vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], opts)
    
    -- Allow easy navigation back to insert mode
    vim.keymap.set("n", "i", "i", opts)
    vim.keymap.set("n", "a", "a", opts)
    
    -- Close lazygit with q in normal mode (will close the tab)
    vim.keymap.set("n", "q", function()
      term:close()
    end, opts)
    
    -- Disable line numbers and other UI elements for clean experience
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.wo.foldcolumn = "0"
    vim.wo.statuscolumn = ""
    
    -- Set tab title
    vim.cmd("file lazygit")
  end,
  on_close = function(_)
    -- Reset any global settings if needed
  end,
  count = 97, -- Use a unique count to avoid conflicts
}

-- Function to toggle lazygit in floating window
function M.lazygit_toggle_float()
  -- Change to the current working directory before opening lazygit
  local cwd = vim.fn.getcwd()
  lazygit_float.cmd = "lazygit -p " .. vim.fn.shellescape(cwd)
  lazygit_float:toggle()
end

-- Function to toggle lazygit in a new tab
function M.lazygit_toggle_tab()
  -- Change to the current working directory before opening lazygit
  local cwd = vim.fn.getcwd()
  lazygit_tab.cmd = "lazygit -p " .. vim.fn.shellescape(cwd)
  lazygit_tab:toggle()
end

-- Legacy function for backward compatibility (floating window)
function M.lazygit_toggle()
  M.lazygit_toggle_float()
end

-- Global functions for easy access
_G.LAZYGIT_TOGGLE_FLOAT = M.lazygit_toggle_float
_G.LAZYGIT_TOGGLE_TAB = M.lazygit_toggle_tab
_G.LAZYGIT_TOGGLE = M.lazygit_toggle

return M