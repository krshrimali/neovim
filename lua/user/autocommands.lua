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

-- Close floating windows with ESC/q using window-local keymaps
vim.api.nvim_create_autocmd("WinEnter", {
  callback = function()
    local win = vim.api.nvim_get_current_win()
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= "" then
      -- Use vim.wo to track state on the window, not the buffer
      vim.wo[win].winbar = vim.wo[win].winbar -- no-op, just ensure win is valid
      local buf = vim.api.nvim_get_current_buf()
      -- Only close if the current window is still a float
      local function close_float()
        local w = vim.api.nvim_get_current_win()
        local c = vim.api.nvim_win_get_config(w)
        if c.relative ~= "" then
          vim.api.nvim_win_close(w, true)
        end
      end
      vim.keymap.set("n", "<Esc>", close_float, { buffer = buf, silent = true, desc = "Close float" })
      vim.keymap.set("n", "q", close_float, { buffer = buf, silent = true, desc = "Close float" })
    end
  end,
})

-- ============================================
-- Config Commands (like Helix :config-open)
-- ============================================
vim.api.nvim_create_user_command(
  "ConfigOpen",
  function() vim.cmd("edit " .. vim.fn.stdpath "config" .. "/init.lua") end,
  { desc = "Open Neovim config (init.lua)" }
)

vim.api.nvim_create_user_command("ConfigWorkspaceOpen", function()
  local config_path = vim.fn.stdpath "config"
  vim.cmd("cd " .. config_path)
  vim.cmd("edit " .. config_path)
end, { desc = "Open Neovim config directory" })

vim.api.nvim_create_user_command("ConfigRefresh", function()
  -- Clear user module cache
  for name, _ in pairs(package.loaded) do
    if name:match "^user" then package.loaded[name] = nil end
  end
  -- Reload init.lua
  dofile(vim.fn.stdpath "config" .. "/init.lua")
  vim.notify("Config reloaded!", vim.log.levels.INFO)
end, { desc = "Reload Neovim configuration" })
