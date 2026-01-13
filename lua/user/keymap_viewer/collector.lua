local M = {}
local utils = require "user.keymap_viewer.utils"

-- Collect keymaps from Neovim API
function M.collect_from_api()
  local keymaps = {}
  local modes = { "n", "i", "v", "x", "t", "c", "s", "o" }

  for _, mode in ipairs(modes) do
    local maps = vim.api.nvim_get_keymap(mode)
    for _, map in ipairs(maps) do
      table.insert(keymaps, {
        key = map.lhs,
        mode = mode,
        rhs = map.rhs,
        desc = map.desc,
        buffer = map.buffer ~= 0 and map.buffer or nil,
        source = "api",
        silent = map.silent == 1,
        noremap = map.noremap == 1,
        expr = map.expr == 1,
        nowait = map.nowait == 1,
      })
    end
  end

  return keymaps
end

-- Parse Lua files to extract keymap definitions and comments
function M.parse_lua_files()
  local keymaps = {}
  local config_dir = vim.fn.stdpath "config"
  local lua_dir = config_dir .. "/lua"

  -- Get all lua files recursively
  local function get_lua_files(dir)
    local files = {}
    local handle = vim.loop.fs_scandir(dir)
    if not handle then return files end

    while true do
      local name, type = vim.loop.fs_scandir_next(handle)
      if not name then break end

      local path = dir .. "/" .. name
      if type == "file" and name:match "%.lua$" then
        table.insert(files, path)
      elseif type == "directory" and name ~= "keymap_viewer" then
        local sub_files = get_lua_files(path)
        for _, f in ipairs(sub_files) do
          table.insert(files, f)
        end
      end
    end

    return files
  end

  local files = get_lua_files(lua_dir)

  for _, file_path in ipairs(files) do
    local ok, content = pcall(vim.fn.readfile, file_path)
    if ok and content then
      local lines = content
      for i, line in ipairs(lines) do
        -- Look for comment above line
        local desc = nil
        if i > 1 then
          local prev_line = lines[i - 1]
          if prev_line:match "^%s*%-%-" and not prev_line:match "^%s*%-%-%s*%[" then
            desc = prev_line:match "^%s*%-%-%s*(.+)"
            -- Clean up comment
            if desc then desc = desc:gsub("^%s+", ""):gsub("%s+$", "") end
          end
        end

        -- Match vim.keymap.set calls with desc in table (more flexible)
        -- Pattern: vim.keymap.set("mode", "key", func, { desc = "description" })
        local keymap_set_with_desc =
          line:match "vim%.keymap%.set%s*%(%s*[\"']([^\"']+)[\"']%s*,%s*[\"']([^\"']+)[\"']%s*,%s*[^,]+desc%s*=%s*[\"']([^\"']+)[\"']"
        if keymap_set_with_desc then
          local mode, key, desc_from_line = keymap_set_with_desc:match "([^,]+),%s*([^,]+),%s*(.+)"
          if mode and key then
            table.insert(keymaps, {
              key = key:gsub("[\"']", ""):gsub("^%s+", ""):gsub("%s+$", ""),
              mode = mode:gsub("[\"']", ""):gsub("%s+", ""),
              rhs = nil,
              desc = desc_from_line or desc,
              source_file = file_path,
              source_line = i,
              source = "lua_file",
            })
            goto continue
          end
        end

        -- Match vim.keymap.set calls (simple form: mode, key, rhs)
        -- Pattern: vim.keymap.set("mode", "key", "rhs")
        local keymap_simple = line:match "vim%.keymap%.set%s*%(%s*[\"']([^\"']+)[\"']%s*,%s*[\"']([^\"']+)[\"']"
        if keymap_simple then
          -- Extract mode and key more carefully
          local mode_match = line:match "vim%.keymap%.set%s*%(%s*[\"']([^\"']+)[\"']"
          local key_match = line:match "vim%.keymap%.set%s*%(%s*[\"']([^\"']+)[\"']%s*,%s*[\"']([^\"']+)[\"']"
          if mode_match and key_match then
            local mode = mode_match
            local key = key_match:match "[\"']([^\"']+)[\"']"
            if not key then
              -- Try alternative pattern
              key = line:match "vim%.keymap%.set%s*%(%s*[\"'][^\"']+[\"']%s*,%s*[\"']([^\"']+)[\"']"
            end
            if mode and key then
              table.insert(keymaps, {
                key = key:gsub("^%s+", ""):gsub("%s+$", ""),
                mode = mode:gsub("^%s+", ""):gsub("%s+$", ""),
                rhs = nil,
                desc = desc,
                source_file = file_path,
                source_line = i,
                source = "lua_file",
              })
              goto continue
            end
          end
        end

        -- Match keymap() wrapper calls
        local wrapper_match = line:match "keymap%s*%(%s*[\"']([^\"']+)[\"']%s*,%s*[\"']([^\"']+)[\"']"
        if wrapper_match then
          local mode, key = wrapper_match:match "([^,]+),%s*(.+)"
          if mode and key then
            table.insert(keymaps, {
              key = key:gsub("[\"']", ""):gsub("^%s+", ""):gsub("%s+$", ""),
              mode = mode:gsub("[\"']", ""):gsub("%s+", ""),
              rhs = nil,
              desc = desc,
              source_file = file_path,
              source_line = i,
              source = "lua_file",
            })
            goto continue
          end
        end

        -- Match vim.api.nvim_set_keymap calls
        local api_match = line:match "vim%.api%.nvim_set_keymap%s*%(%s*[\"']([^\"']+)[\"']%s*,%s*[\"']([^\"']+)[\"']"
        if api_match then
          local mode, key = api_match:match "([^,]+),%s*(.+)"
          if mode and key then
            table.insert(keymaps, {
              key = key:gsub("[\"']", ""):gsub("^%s+", ""):gsub("%s+$", ""),
              mode = mode:gsub("[\"']", ""):gsub("%s+", ""),
              rhs = nil,
              desc = desc,
              source_file = file_path,
              source_line = i,
              source = "lua_file",
            })
            goto continue
          end
        end

        ::continue::
      end
    end
  end

  return keymaps
end

-- Merge and deduplicate keymaps
function M.collect_all()
  local api_keymaps = M.collect_from_api()
  local file_keymaps = M.parse_lua_files()

  -- Create a map to deduplicate
  local keymap_map = {}

  -- Add API keymaps first (they have more info)
  for _, km in ipairs(api_keymaps) do
    local key = km.mode .. ":" .. km.key
    if not keymap_map[key] or not keymap_map[key].desc then keymap_map[key] = vim.deepcopy(km) end
  end

  -- Add file keymaps, merge descriptions if missing
  for _, km in ipairs(file_keymaps) do
    local key = km.mode .. ":" .. km.key
    if keymap_map[key] then
      -- Merge description if API version doesn't have one
      if not keymap_map[key].desc and km.desc then keymap_map[key].desc = km.desc end
      -- Add source file info
      if not keymap_map[key].source_file then
        keymap_map[key].source_file = km.source_file
        keymap_map[key].source_line = km.source_line
      end
    else
      keymap_map[key] = vim.deepcopy(km)
    end
  end

  -- Convert back to list
  local all_keymaps = {}
  for _, km in pairs(keymap_map) do
    table.insert(all_keymaps, km)
  end

  return all_keymaps
end

return M
