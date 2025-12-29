local M = {}

-- Format keymap string for display
function M.format_key(key)
  if not key then return "" end
  -- Replace <leader> with actual leader key
  local leader = vim.g.mapleader or "\\"
  if leader == " " then leader = "Space" end
  key = key:gsub("<leader>", leader)
  -- Replace other common keycodes
  key = key:gsub("<C%-", "Ctrl+")
  key = key:gsub("<M%-", "Alt+")
  key = key:gsub("<S%-", "Shift+")
  key = key:gsub("<A%-", "Alt+")
  key = key:gsub(">", "")
  return key
end

-- Get mode name from mode code
function M.get_mode_name(mode)
  local mode_names = {
    n = "Normal",
    i = "Insert",
    v = "Visual",
    x = "Visual Block",
    t = "Terminal",
    c = "Command",
  }
  return mode_names[mode] or mode
end

-- Extract command from rhs (right-hand side)
function M.extract_command(rhs)
  if not rhs then return "" end

  -- Remove <cmd> and <cr>
  local cmd = rhs:gsub("<cmd>", ""):gsub("<cr>", ""):gsub("<CR>", "")

  -- Extract lua require calls
  local lua_match = cmd:match "lua%s+(.+)"
  if lua_match then return "lua " .. lua_match:gsub("^%s+", ""):gsub("%s+$", "") end

  -- Extract vim commands
  local vim_cmd = cmd:match ":([^<]+)"
  if vim_cmd then return vim_cmd:gsub("^%s+", ""):gsub("%s+$", "") end

  -- Return cleaned command
  return cmd:gsub("^%s+", ""):gsub("%s+$", "")
end

-- Normalize search text
function M.normalize_text(text)
  if not text then return "" end
  return text:lower():gsub("%s+", " "):gsub("[<>%-]", "")
end

-- Check if text matches query (fuzzy)
function M.fuzzy_match(text, query)
  if not query or query == "" then return true end
  text = M.normalize_text(text)
  query = M.normalize_text(query)

  local query_chars = {}
  for char in query:gmatch "." do
    table.insert(query_chars, char)
  end

  local text_idx = 1
  for _, char in ipairs(query_chars) do
    local found = false
    while text_idx <= #text do
      if text:sub(text_idx, text_idx) == char then
        found = true
        text_idx = text_idx + 1
        break
      end
      text_idx = text_idx + 1
    end
    if not found then return false end
  end
  return true
end

-- Group keymaps by prefix
function M.group_by_prefix(keymaps)
  local groups = {}
  for _, km in ipairs(keymaps) do
    local prefix = km.key:match "^(<leader>[^%s]+)"
    if prefix then
      local group_key = prefix:match "(<leader>[^%w]+)"
      if not group_key then
        group_key = prefix:sub(1, #prefix - 1) -- Remove last char
      end
      if not groups[group_key] then groups[group_key] = {} end
      table.insert(groups[group_key], km)
    else
      if not groups["_other"] then groups["_other"] = {} end
      table.insert(groups["_other"], km)
    end
  end
  return groups
end

return M
