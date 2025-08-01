-- Theme Reload Helper
-- Use this to reload the Cursor Dark theme if needed
-- Run with: :lua require("user.themes.reload").reload()

local M = {}

function M.reload()
  print("Reloading Cursor Dark theme...")
  
  -- Clear any existing highlights
  vim.cmd("hi clear")
  
  -- Clear module cache
  local modules_to_clear = {
    "user.themes.cursor-dark",
    "user.themes.cursor-dark-treesitter", 
    "user.themes.cursor-dark-plugins",
    "user.themes.cursor-dark-lsp",
    "user.themes.init"
  }
  
  for _, module in ipairs(modules_to_clear) do
    package.loaded[module] = nil
  end
  
  -- Reload the theme
  local success, err = pcall(function()
    local cursor_theme = require("user.themes.init")
    cursor_theme.setup()
  end)
  
  if success then
    print("✅ Cursor Dark theme reloaded successfully!")
  else
    print("❌ Error reloading theme: " .. tostring(err))
    -- Fallback to a working theme
    vim.cmd("colorscheme default")
    print("Fallback: Loaded default colorscheme")
  end
end

function M.test()
  print("Testing Cursor Dark theme...")
  
  local success, err = pcall(function()
    local cursor_theme = require("user.themes.init")
    local colors = cursor_theme.get_colors()
    
    print("Theme colors loaded successfully:")
    print("  Background: " .. colors.bg)
    print("  Foreground: " .. colors.fg)
    print("  Blue: " .. colors.blue)
    print("  Green: " .. colors.green)
  end)
  
  if success then
    print("✅ Theme test passed!")
  else
    print("❌ Theme test failed: " .. tostring(err))
  end
end

function M.fix_colors()
  print("Checking for invalid colors...")
  
  local cursor_theme = require("user.themes.cursor-dark")
  local colors = cursor_theme.colors
  
  local invalid_colors = {}
  
  for name, color in pairs(colors) do
    if type(color) == "string" and color:match("^#") then
      -- Check if it's an 8-digit hex (invalid for nvim_set_hl)
      if #color == 9 then
        table.insert(invalid_colors, {name = name, color = color})
      end
    end
  end
  
  if #invalid_colors > 0 then
    print("❌ Found invalid 8-digit hex colors:")
    for _, item in ipairs(invalid_colors) do
      print("  " .. item.name .. ": " .. item.color)
    end
    print("Please fix these colors to 6-digit hex format (remove alpha channel)")
  else
    print("✅ All colors are valid!")
  end
end

return M