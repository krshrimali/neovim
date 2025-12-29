local M = {}
local utils = require "user.keymap_viewer.utils"
local formatter = require "user.keymap_viewer.formatter"

-- Filter keymaps by query
function M.filter(keymaps, query, options)
  options = options or {}
  local filtered = {}

  query = query or ""
  local normalized_query = utils.normalize_text(query)

  for _, km in ipairs(keymaps) do
    -- Mode filter
    if options.mode and km.mode ~= options.mode then goto continue end

    -- Has description filter
    if options.has_description ~= nil then
      if options.has_description and (not km.desc or km.desc == "") then goto continue end
      if not options.has_description and km.desc and km.desc ~= "" then goto continue end
    end

    -- Buffer filter
    if options.buffer_only ~= nil then
      if options.buffer_only and not km.buffer then goto continue end
      if not options.buffer_only and km.buffer then goto continue end
    end

    -- Prefix filter
    if options.prefix then
      if not km.key:match("^" .. vim.pesc(options.prefix)) then goto continue end
    end

    -- Query search
    if normalized_query ~= "" then
      local searchable = formatter.get_searchable_text(km)
      if not utils.fuzzy_match(searchable, query) then goto continue end
    end

    table.insert(filtered, km)
    ::continue::
  end

  return filtered
end

-- Sort keymaps
function M.sort(keymaps, sort_by)
  sort_by = sort_by or "key"

  table.sort(keymaps, function(a, b)
    if sort_by == "key" then
      return a.key < b.key
    elseif sort_by == "mode" then
      if a.mode ~= b.mode then return a.mode < b.mode end
      return a.key < b.key
    elseif sort_by == "description" then
      local desc_a = a.desc or ""
      local desc_b = b.desc or ""
      if desc_a ~= desc_b then return desc_a < desc_b end
      return a.key < b.key
    end
    return a.key < b.key
  end)

  return keymaps
end

-- Group keymaps by prefix
function M.group_by_prefix(keymaps)
  local groups = {}

  for _, km in ipairs(keymaps) do
    local prefix = nil

    -- Extract prefix (e.g., <leader>f from <leader>ff)
    if km.key:match "^<leader>" then
      prefix = km.key:match "^(<leader>[^%s]+)"
      if prefix and #prefix > 2 then
        -- Use first two chars after leader (e.g., <leader>f)
        prefix = prefix:sub(1, #prefix - 1)
      end
    elseif km.key:match "^<C%-" then
      prefix = "<C-*"
    elseif km.key:match "^<M%-" or km.key:match "^<A%-" then
      prefix = "<Alt-*"
    else
      prefix = "_other"
    end

    if not groups[prefix] then groups[prefix] = {} end
    table.insert(groups[prefix], km)
  end

  return groups
end

return M
