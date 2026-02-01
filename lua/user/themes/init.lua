-- Cursor Dark Theme Main Loader
-- This file orchestrates all theme components

local M = {}

function M.load()
  -- Load the base theme
  local base_theme = require "user.themes.cursor-dark"
  base_theme.setup()

  -- Load Treesitter highlights
  local treesitter_theme = require "user.themes.cursor-dark-treesitter"
  treesitter_theme.setup()

  -- Load plugin-specific highlights
  local plugins_theme = require "user.themes.cursor-dark-plugins"
  plugins_theme.setup()

  -- Load LSP and CoC highlights
  local lsp_theme = require "user.themes.cursor-dark-lsp"
  lsp_theme.setup()

  -- Set up autocommands to maintain theme consistency
  vim.api.nvim_create_augroup("CursorDarkTheme", { clear = true })

  -- Reapply theme when colorscheme is changed
  vim.api.nvim_create_autocmd("ColorScheme", {
    group = "CursorDarkTheme",
    pattern = "cursor-dark",
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
    group = "CursorDarkTheme",
    pattern = "LazyLoad",
    callback = function()
      -- Small delay to ensure plugins are fully loaded
      vim.defer_fn(function()
        plugins_theme.setup()
        lsp_theme.setup()
      end, 50)
    end,
  })

  -- Ensure highlights are applied when entering vim
  vim.api.nvim_create_autocmd("VimEnter", {
    group = "CursorDarkTheme",
    callback = function()
      vim.defer_fn(function()
        treesitter_theme.setup()
        plugins_theme.setup()
        lsp_theme.setup()
      end, 20)
    end,
  })
end

-- Export colors for other configurations to use
M.colors = require("user.themes.cursor-dark").colors

-- Function to get a specific color
function M.get_color(color_name) return M.colors[color_name] end

-- Function to get colors for a specific plugin
function M.get_colors() return M.colors end

-- Function to reload the theme
function M.reload()
  -- Clear highlight cache
  vim.cmd "hi clear"

  -- Reload all theme modules
  package.loaded["user.themes.cursor-dark"] = nil
  package.loaded["user.themes.cursor-dark-treesitter"] = nil
  package.loaded["user.themes.cursor-dark-plugins"] = nil
  package.loaded["user.themes.cursor-dark-lsp"] = nil

  -- Reload the theme
  M.load()
end

-- Setup function for easy integration
function M.setup(opts)
  opts = opts or {}

  -- Apply any custom options here if needed in the future
  if opts.transparent then
    -- Future: Add transparency support
  end

  if opts.italic_comments ~= nil then
    -- Future: Add option to disable italic comments
  end

  -- Load the theme
  M.load()
end

return M
