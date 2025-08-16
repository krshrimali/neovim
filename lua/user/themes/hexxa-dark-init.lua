-- Hexxa Dark Theme Main Loader
-- This file orchestrates all theme components

local M = {}

-- Expose colors for external use (lazy loaded)
function M.get_colors() return require("user.themes.hexxa-dark").colors end

-- Backward compatibility
M.colors = setmetatable({}, {
  __index = function(_, key) return M.get_colors()[key] end,
})

-- Setup function to initialize the complete theme
function M.setup(opts)
  opts = opts or {}

  -- Load the base theme
  local base_theme = require "user.themes.hexxa-dark"
  base_theme.setup()

  -- Load treesitter highlighting
  local treesitter_theme = require "user.themes.hexxa-dark-treesitter"
  treesitter_theme.setup()

  -- Load plugin support
  local plugins_theme = require "user.themes.hexxa-dark-plugins"
  plugins_theme.setup()

  -- Load LSP/CoC support
  local lsp_theme = require "user.themes.hexxa-dark-lsp"
  lsp_theme.setup()

  -- Set up autocommands to maintain theme consistency
  vim.api.nvim_create_augroup("HexxaDarkTheme", { clear = true })

  -- Reapply theme when colorscheme is changed
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "HexxaDarkTheme",
    pattern = "hexxa-dark",
    callback = function()
      -- Small delay to ensure the colorscheme is fully loaded
      vim.defer_fn(function()
        treesitter_theme.setup()
        plugins_theme.setup()
        lsp_theme.setup()
      end, 10)
    end,
  })

  -- Reapply plugin highlights when plugins are loaded
  vim.api.nvim_create_autocmd("User", {
    group = "HexxaDarkTheme",
    pattern = "LazyDone",
    callback = function()
      plugins_theme.setup()
      lsp_theme.setup()
    end,
  })

  -- Reapply treesitter highlights when treesitter is loaded
  vim.api.nvim_create_autocmd("FileType", {
    group = "HexxaDarkTheme",
    callback = function()
      vim.defer_fn(function()
        treesitter_theme.setup()
        lsp_theme.setup()
      end, 50)
    end,
  })

  -- Reapply all highlights when entering a buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    group = "HexxaDarkTheme",
    callback = function()
      vim.defer_fn(function()
        treesitter_theme.setup()
        plugins_theme.setup()
        lsp_theme.setup()
      end, 10)
    end,
  })

  -- Create a command to reload the theme
  vim.api.nvim_create_user_command("HexxaReload", function() M.reload() end, { desc = "Reload Hexxa Dark theme" })

  -- Create a command to toggle between Hexxa and Cursor themes
  vim.api.nvim_create_user_command("HexxaToggle", function()
    if vim.g.colors_name == "hexxa-dark" then
      vim.cmd "colorscheme cursor-dark"
    else
      vim.cmd "colorscheme hexxa-dark"
    end
  end, { desc = "Toggle between Hexxa and Cursor themes" })
end

-- Function to reload the theme
function M.reload()
  -- Clear module cache
  package.loaded["user.themes.hexxa-dark"] = nil
  package.loaded["user.themes.hexxa-dark-treesitter"] = nil
  package.loaded["user.themes.hexxa-dark-plugins"] = nil
  package.loaded["user.themes.hexxa-dark-lsp"] = nil

  -- Reload the theme
  M.setup()

  vim.notify("Hexxa Dark theme reloaded!", vim.log.levels.INFO)
end

-- Function to apply custom highlights
function M.highlight(group, opts) vim.api.nvim_set_hl(0, group, opts) end

return M
