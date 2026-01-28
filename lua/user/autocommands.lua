-- Simplified Autocommands
-- Close special buffers with q or ESC
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "qf", "help", "man", "lspinfo", "spectre_panel", "DressingSelect", "Outline" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
    vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = true, silent = true })
    vim.bo.buflisted = false
  end,
})

-- Disable formatoptions auto-comments
vim.api.nvim_create_autocmd({ "BufWinEnter" }, {
  callback = function() vim.opt_local.formatoptions:remove { "c", "r", "o" } end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd({ "TextYankPost" }, {
  callback = function() vim.highlight.on_yank { higroup = "Visual", timeout = 100 } end,
})

-- Close floating windows with ESC
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = true, silent = true })
      vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = true, silent = true })
    end
  end,
})

-- ============================================
-- Config Commands (like Helix :config-open)
-- ============================================
vim.api.nvim_create_user_command("ConfigOpen", function()
  vim.cmd("edit " .. vim.fn.stdpath("config") .. "/init.lua")
end, { desc = "Open Neovim config (init.lua)" })

vim.api.nvim_create_user_command("ConfigWorkspaceOpen", function()
  local config_path = vim.fn.stdpath("config")
  vim.cmd("cd " .. config_path)
  vim.cmd("edit " .. config_path)
end, { desc = "Open Neovim config directory" })

vim.api.nvim_create_user_command("ConfigRefresh", function()
  -- Clear user module cache
  for name, _ in pairs(package.loaded) do
    if name:match("^user") then
      package.loaded[name] = nil
    end
  end
  -- Reload init.lua
  dofile(vim.fn.stdpath("config") .. "/init.lua")
  vim.notify("Config reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Neovim configuration" })
