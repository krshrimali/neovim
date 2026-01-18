-- Floating Breadcrumbs Navigation
-- Shows breadcrumbs in a floating window for easy navigation

local M = {}

-- Create a floating window with breadcrumbs
function M.show()
  local navic = require "nvim-navic"

  if not navic.is_available() then
    vim.notify("No breadcrumbs available", vim.log.levels.WARN)
    return
  end

  -- Get breadcrumbs data
  local data = navic.get_data()
  if not data or #data == 0 then
    vim.notify("No breadcrumbs available", vim.log.levels.WARN)
    return
  end

  -- Create buffer for floating window
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "breadcrumbs")

  -- Build lines for display
  local lines = {}
  local highlights = {}

  for i, item in ipairs(data) do
    local indent = string.rep("  ", i - 1)
    local icon = item.icon or ""
    local name = item.name or ""
    local kind = item.type or ""

    -- Format: "  > Class MyClass"
    local line = indent .. "> " .. kind .. " " .. name
    table.insert(lines, line)

    -- Store position data for navigation
    if item.scope then
      table.insert(highlights, {
        line = i - 1,
        col = 0,
        lnum = item.scope.start.line,
        col_start = item.scope.start.character,
      })
    end
  end

  -- Set buffer content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Calculate window size
  local width = 60
  local height = #lines
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  -- Window options
  local opts = {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
    title = " Breadcrumbs Navigation ",
    title_pos = "center",
  }

  -- Create floating window
  local win = vim.api.nvim_open_win(buf, true, opts)

  -- Set window options
  vim.api.nvim_win_set_option(win, "winblend", 0)
  vim.api.nvim_win_set_option(win, "cursorline", true)

  -- Keymaps for navigation
  local function close_window()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end

  local function navigate_to_item()
    local current_line = vim.api.nvim_win_get_cursor(win)[1]
    close_window()

    -- Navigate to the corresponding location
    local item = data[current_line]
    if item and item.scope then
      vim.api.nvim_win_set_cursor(0, { item.scope.start.line + 1, item.scope.start.character })
    end
  end

  -- Set keymaps
  local keymap_opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "<CR>", navigate_to_item, keymap_opts)
  vim.keymap.set("n", "<ESC>", close_window, keymap_opts)
  vim.keymap.set("n", "q", close_window, keymap_opts)
  vim.keymap.set("n", "<C-c>", close_window, keymap_opts)
end

return M
