local M = {}

local status_ok, fterm = pcall(require, "FTerm")
if not status_ok then
  return M
end

-- Lazygit floating window configuration using FTerm
local lazygit_float = fterm:new({
  cmd = "bash",
  ft = "fterm_lazygit",
  dimensions = {
    height = 0.95,
    width = 0.95,
  },
  border = "rounded",
  auto_close = false,
  on_exit = function()
    -- Clean up when lazygit exits
    vim.cmd("startinsert!")
  end,
})

-- Lazygit tab configuration using FTerm
local lazygit_tab = fterm:new({
  cmd = "bash",
  ft = "fterm_lazygit_tab",
  dimensions = {
    height = 0.98,
    width = 0.98,
  },
  border = "rounded",
  auto_close = false,
  on_exit = function()
    -- Clean up when lazygit exits
    vim.cmd("startinsert!")
  end,
})

-- Helper function to set up lazygit-specific keymaps
local function setup_lazygit_keymaps(bufnr)
  local opts = { buffer = bufnr, noremap = true, silent = true }
  
  -- Mark this buffer as lazygit to prevent global terminal keymaps
  vim.b[bufnr].is_lazygit = true
  
  -- Only map Ctrl+\ Ctrl+n to exit terminal mode (standard Neovim terminal escape)
  vim.keymap.set("t", "<C-\\><C-n>", [[<C-\><C-n>]], opts)
  
  -- In normal mode, provide ways to get back to terminal or close
  vim.keymap.set("n", "i", "i", opts) -- Back to insert/terminal mode
  vim.keymap.set("n", "<CR>", "i", opts) -- Enter also goes back to terminal mode
  vim.keymap.set("n", "q", function()
    lazygit_float:close()
    lazygit_tab:close()
  end, opts)
end

-- Function to send lazygit command to terminal
local function send_lazygit_command(term)
  -- Clear any existing command and send lazygit
  vim.fn.chansend(vim.b.terminal_job_id, "\003") -- Send Ctrl+C to clear
  vim.defer_fn(function()
    vim.fn.chansend(vim.b.terminal_job_id, "lazygit\n")
  end, 100)
end

-- Floating lazygit toggle function
function M.lazygit_toggle_float()
  if lazygit_float:__is_open() then
    lazygit_float:close()
  else
    lazygit_float:open()
    -- Set up terminal for lazygit
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      setup_lazygit_keymaps(bufnr)
      send_lazygit_command(lazygit_float)
    end, 50)
  end
end

-- Tab lazygit toggle function
function M.lazygit_toggle_tab()
  if lazygit_tab:__is_open() then
    lazygit_tab:close()
  else
    lazygit_tab:open()
    -- Set up terminal for lazygit
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()
      setup_lazygit_keymaps(bufnr)
      send_lazygit_command(lazygit_tab)
    end, 50)
  end
end

-- Global functions for easy access
_G.LAZYGIT_TOGGLE_FLOAT = M.lazygit_toggle_float
_G.LAZYGIT_TOGGLE_TAB = M.lazygit_toggle_tab

-- Set up keymaps
vim.keymap.set("n", "<leader>gg", M.lazygit_toggle_float, { desc = "Lazygit Float", noremap = true, silent = true })
vim.keymap.set("n", "<leader>gG", M.lazygit_toggle_tab, { desc = "Lazygit Tab", noremap = true, silent = true })

return M