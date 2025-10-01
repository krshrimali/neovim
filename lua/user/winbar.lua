-- Disable winbar display completely
vim.g.loaded_winbar = 1  -- Prevent winbar from loading

-- Clear any existing winbar settings
vim.opt.winbar = ""
vim.wo.winbar = ""

-- Set autocommand to ensure winbar stays empty
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "WinEnter" }, {
  callback = function()
    vim.wo.winbar = ""
  end,
})