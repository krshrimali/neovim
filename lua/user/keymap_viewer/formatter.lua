local M = {}
local utils = require("user.keymap_viewer.utils")

-- Format keymap for display in list
function M.format_for_list(keymap)
  local key = utils.format_key(keymap.key)
  local mode = utils.get_mode_name(keymap.mode)
  local desc = keymap.desc or "No description"
  local cmd = utils.extract_command(keymap.rhs or "")
  
  -- Format: Key | Mode | Description | Command
  local formatted = string.format("%-20s | %-8s | %s", key, mode, desc)
  if cmd and cmd ~= "" and cmd ~= desc then
    formatted = formatted .. " | " .. cmd
  end
  
  return formatted
end

-- Format keymap for preview
function M.format_for_preview(keymap)
  local lines = {}
  
  -- Header
  table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  table.insert(lines, "KEYMAP DETAILS")
  table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  table.insert(lines, "")
  
  -- Key
  local key = utils.format_key(keymap.key)
  table.insert(lines, string.format("Key:        %s", key))
  table.insert(lines, string.format("Raw Key:    %s", keymap.key))
  
  -- Mode
  local mode = utils.get_mode_name(keymap.mode)
  table.insert(lines, string.format("Mode:       %s (%s)", mode, keymap.mode))
  
  -- Description
  local desc = keymap.desc or "No description available"
  table.insert(lines, string.format("Description: %s", desc))
  table.insert(lines, "")
  
  -- Command
  if keymap.rhs then
    local cmd = utils.extract_command(keymap.rhs)
    table.insert(lines, "Command:")
    table.insert(lines, string.format("  %s", keymap.rhs))
    if cmd and cmd ~= "" then
      table.insert(lines, "")
      table.insert(lines, "Extracted:")
      table.insert(lines, string.format("  %s", cmd))
    end
    table.insert(lines, "")
  end
  
  -- Options
  local options = {}
  if keymap.silent then table.insert(options, "silent") end
  if keymap.noremap then table.insert(options, "noremap") end
  if keymap.expr then table.insert(options, "expr") end
  if keymap.nowait then table.insert(options, "nowait") end
  if keymap.buffer then table.insert(options, "buffer=" .. keymap.buffer) end
  
  if #options > 0 then
    table.insert(lines, "Options: " .. table.concat(options, ", "))
    table.insert(lines, "")
  end
  
  -- Source
  if keymap.source_file then
    table.insert(lines, "Source:")
    table.insert(lines, string.format("  File: %s", keymap.source_file))
    if keymap.source_line then
      table.insert(lines, string.format("  Line: %d", keymap.source_line))
    end
  else
    table.insert(lines, "Source: Neovim API")
  end
  
  table.insert(lines, "")
  table.insert(lines, "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
  
  return table.concat(lines, "\n")
end

-- Format for FzfLua display
function M.format_for_fzf(keymap)
  local key = utils.format_key(keymap.key)
  local mode_short = keymap.mode:upper()
  local desc = keymap.desc or "No description"
  
  -- Format: [Mode] Key → Description
  return string.format("[%s] %s → %s", mode_short, key, desc)
end

-- Get searchable text for a keymap
function M.get_searchable_text(keymap)
  local parts = {}
  
  -- Add key
  table.insert(parts, keymap.key)
  table.insert(parts, utils.format_key(keymap.key))
  
  -- Add mode
  table.insert(parts, keymap.mode)
  table.insert(parts, utils.get_mode_name(keymap.mode))
  
  -- Add description
  if keymap.desc then
    table.insert(parts, keymap.desc)
  end
  
  -- Add command
  if keymap.rhs then
    table.insert(parts, keymap.rhs)
    local cmd = utils.extract_command(keymap.rhs)
    if cmd then
      table.insert(parts, cmd)
    end
  end
  
  -- Add source file name
  if keymap.source_file then
    local filename = keymap.source_file:match("([^/]+)$")
    if filename then
      table.insert(parts, filename)
    end
  end
  
  return table.concat(parts, " ")
end

return M
