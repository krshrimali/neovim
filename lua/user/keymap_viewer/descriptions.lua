local M = {}
local utils = require("user.keymap_viewer.utils")

-- Generate description from command/function name
function M.generate_from_command(keymap)
  if not keymap.rhs then return nil end
  
  local ok, result = pcall(function()
    local rhs = keymap.rhs
    local desc = nil
    
    -- Extract from lua require calls
  -- Pattern: lua require('module') or lua require("module")
  -- Try with double quotes first
  local module_path = rhs:match('lua%s+require%("([^"]+)"')
  if not module_path then
    -- Try with single quotes
    module_path = rhs:match("lua%s+require%('([^']+)'")
  end
  -- If still not found, try a more flexible pattern
  if not module_path then
    -- Match: require("module") or require('module')
    module_path = rhs:match('require%("([^"]+)"')
    if not module_path then
      module_path = rhs:match("require%('([^']+)'")
    end
  end
  
  if module_path then
    -- Extract function name
    local func_match = rhs:match("%.([%w_]+)%(")
    if func_match then
      -- Convert snake_case to Title Case
      desc = func_match:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
      end)
    else
      -- Use module name
      local module_name = module_path:match("([^%.]+)$")
      if module_name then
        desc = module_name:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
          return first:upper() .. rest:lower()
        end)
      end
    end
  end
  
  -- Extract from vim commands
  if not desc then
    local cmd_match = rhs:match("<cmd>([^<]+)<cr>")
    if cmd_match then
      -- Common command patterns
      if cmd_match:match("^FzfLua") then
        local fzf_cmd = cmd_match:match("FzfLua%s+(%w+)")
        if fzf_cmd then
          desc = "FzfLua: " .. fzf_cmd:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
          end)
        end
      elseif cmd_match:match("^lua") then
        local lua_cmd = cmd_match:match("lua%s+(.+)")
        if lua_cmd then
          -- Try to extract meaningful description
          local func_match = lua_cmd:match("%.([%w_]+)%(")
          if func_match then
            desc = func_match:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
              return first:upper() .. rest:lower()
            end)
          end
        end
      else
        -- Use command name
        local cmd_name = cmd_match:match("^(%w+)")
        if cmd_name then
          desc = cmd_name:gsub("_", " "):gsub("(%a)([%w_']*)", function(first, rest)
            return first:upper() .. rest:lower()
          end)
        end
      end
    end
  end
  
  -- Common command mappings
  if not desc and rhs then
    local common = {
      ["<cmd>w<CR>"] = "Save file",
      ["<cmd>q<CR>"] = "Quit",
      ["<cmd>wq<CR>"] = "Save and quit",
      ["<ESC>"] = "Exit insert mode",
      ["<C-w>h"] = "Move to left window",
      ["<C-w>j"] = "Move to bottom window",
      ["<C-w>k"] = "Move to top window",
      ["<C-w>l"] = "Move to right window",
      ["<C-w><"] = "Decrease window width",
      ["<C-w>>"] = "Increase window width",
      ["<C-w>+"] = "Increase window height",
      ["<C-w>-"] = "Decrease window height",
    }
    desc = common[rhs]
    end
    
    return desc
  end)
  
  if ok then
    return result
  else
    -- Return nil on error to prevent crashes
    return nil
  end
end

-- Generate description from key pattern
function M.generate_from_key(keymap)
  local key = keymap.key
  if not key then return nil end
  
  -- Common key patterns
  local patterns = {
    ["<leader>ff"] = "Find files",
    ["<leader>fg"] = "Live grep",
    ["<leader>fb"] = "Find buffers",
    ["<leader>fr"] = "Recent files",
    ["<leader>fh"] = "Help tags",
    ["<leader>fk"] = "Keymaps",
    ["<leader>fC"] = "Commands",
    ["<leader>gg"] = "Lazygit",
    ["<leader>gd"] = "Git diff",
    ["<leader>gs"] = "Git stage",
    ["<leader>gr"] = "Git reset",
    ["<leader>gp"] = "Git preview",
    ["<leader>gj"] = "Next hunk",
    ["<leader>gk"] = "Previous hunk",
    ["<leader>lb"] = "Outline",
    ["<leader>ll"] = "Toggle virtual lines",
    ["<leader>ld"] = "Line diagnostics",
    ["<leader>lf"] = "Format",
    ["<leader>lr"] = "References",
    ["<leader>ls"] = "Document symbols",
    ["<leader>bb"] = "Buffer browser",
    ["<leader>bs"] = "Toggle sidebar",
    ["<leader>w"] = "Save",
    ["<leader>q"] = "Quit",
    ["<leader>h"] = "Clear search",
    ["<C-p>"] = "Find files",
    ["<C-s>"] = "Document symbols",
    ["jk"] = "Exit insert mode",
    ["dw"] = "Delete word",
    ["+"] = "Increment number",
    ["-"] = "Decrement number",
  }
  
  return patterns[key]
end

-- Generate description from context
function M.generate_from_context(keymap)
  -- Try command first
  local desc = M.generate_from_command(keymap)
  if desc then return desc end
  
  -- Try key pattern
  desc = M.generate_from_key(keymap)
  if desc then return desc end
  
  -- Fallback: use command string
  if keymap.rhs then
    local cmd = utils.extract_command(keymap.rhs)
    if cmd and cmd ~= "" then
      return cmd
    end
  end
  
  return nil
end

-- Ensure all keymaps have descriptions
function M.enrich_descriptions(keymaps)
  for _, km in ipairs(keymaps) do
    if not km.desc or km.desc == "" then
      local ok, desc = pcall(function()
        return M.generate_from_context(km)
      end)
      if ok and desc then
        km.desc = desc
      end
    end
  end
  return keymaps
end

return M
