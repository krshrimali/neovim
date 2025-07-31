local M = {}

local Terminal = require("toggleterm.terminal").Terminal

-- Lazygit floating window configuration
local lazygit_float = Terminal:new {
  cmd = "bash",
  hidden = true,
  direction = "float",
  start_in_insert = true,
  insert_mappings = false, -- Disable insert mappings to prevent interference
  terminal_mappings = false, -- Disable terminal mappings to prevent interference
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
    -- Start in insert mode for immediate interaction
    vim.cmd("startinsert!")
    
    -- Disable all UI elements for clean experience
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.wo.foldcolumn = "0"
    vim.wo.statuscolumn = ""
    
    -- Mark this buffer as lazygit to prevent global terminal keymaps
    vim.b[term.bufnr].is_lazygit = true
    
    -- Set up minimal keymaps that don't interfere with lazygit
    local opts = { buffer = term.bufnr, noremap = true, silent = true }
    
    -- Only map Ctrl+\ Ctrl+n to exit terminal mode (standard Neovim terminal escape)
    vim.keymap.set("t", "<C-\\><C-n>", [[<C-\><C-n>]], opts)
    
    -- In normal mode, provide ways to get back to terminal or close
    vim.keymap.set("n", "i", "i", opts) -- Back to insert/terminal mode
    vim.keymap.set("n", "<CR>", "i", opts) -- Enter also goes back to terminal mode
    vim.keymap.set("n", "q", function()
      term:close()
    end, opts)
    
    -- Use a timer to clear interfering keymaps after they're set by the global autocmd
    vim.defer_fn(function()
      -- Clear all interfering terminal keymaps
      pcall(vim.keymap.del, "t", "<Esc>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "jk", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-h>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-j>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-k>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-l>", { buffer = term.bufnr })
    end, 100) -- Small delay to ensure global keymaps are set first, then cleared
  end,
  on_close = function(_)
    -- Reset any global settings if needed
  end,
  count = 98, -- Use a unique count to avoid conflicts
}

-- Lazygit tab configuration
local lazygit_tab = Terminal:new {
  cmd = "bash",
  hidden = true,
  direction = "tab",
  start_in_insert = true,
  insert_mappings = false, -- Disable insert mappings to prevent interference
  terminal_mappings = false, -- Disable terminal mappings to prevent interference
  persist_mode = false,
  close_on_exit = true,
  on_open = function(term)
    -- Start in insert mode for immediate interaction
    vim.cmd("startinsert!")
    
    -- Disable all UI elements for clean experience
    vim.wo.number = false
    vim.wo.relativenumber = false
    vim.wo.signcolumn = "no"
    vim.wo.foldcolumn = "0"
    vim.wo.statuscolumn = ""
    
    -- Set tab title
    vim.cmd("file lazygit")
    
    -- Mark this buffer as lazygit to prevent global terminal keymaps
    vim.b[term.bufnr].is_lazygit = true
    
    -- Set up minimal keymaps that don't interfere with lazygit
    local opts = { buffer = term.bufnr, noremap = true, silent = true }
    
    -- Only map Ctrl+\ Ctrl+n to exit terminal mode (standard Neovim terminal escape)
    vim.keymap.set("t", "<C-\\><C-n>", [[<C-\><C-n>]], opts)
    
    -- In normal mode, provide ways to get back to terminal or close
    vim.keymap.set("n", "i", "i", opts) -- Back to insert/terminal mode
    vim.keymap.set("n", "<CR>", "i", opts) -- Enter also goes back to terminal mode
    vim.keymap.set("n", "q", function()
      term:close()
    end, opts)
    
    -- Use a timer to clear interfering keymaps after they're set by the global autocmd
    vim.defer_fn(function()
      -- Clear all interfering terminal keymaps
      pcall(vim.keymap.del, "t", "<Esc>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "jk", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-h>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-j>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-k>", { buffer = term.bufnr })
      pcall(vim.keymap.del, "t", "<C-l>", { buffer = term.bufnr })
    end, 100) -- Small delay to ensure global keymaps are set first, then cleared
  end,
  on_close = function(_)
    -- Reset any global settings if needed
  end,
  count = 97, -- Use a unique count to avoid conflicts
}

-- Function to toggle lazygit in floating window
function M.lazygit_toggle_float()
  local cwd = vim.fn.getcwd()
  -- Send lazygit command to the bash terminal
  lazygit_float:toggle()
  -- Wait a moment for terminal to be ready, then send the command
  vim.defer_fn(function()
    lazygit_float:send(string.format('cd %s && exec lazygit', vim.fn.shellescape(cwd)))
  end, 50)
end

-- Function to toggle lazygit in a new tab
function M.lazygit_toggle_tab()
  local cwd = vim.fn.getcwd()
  -- Send lazygit command to the bash terminal
  lazygit_tab:toggle()
  -- Wait a moment for terminal to be ready, then send the command
  vim.defer_fn(function()
    lazygit_tab:send(string.format('cd %s && exec lazygit', vim.fn.shellescape(cwd)))
  end, 50)
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