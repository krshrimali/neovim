local M = {}

-- Runtime state and configuration
M.state = {
  enable_top = true,
  enable_bottom = true,
}

M.config = {
  separator = " → ",
  max_name_length = 50, -- truncate long names to reduce redraw cost
  include_leaf = false, -- whether to include current leaf node type; off reduces churn
  min_width = 80, -- do not render breadcrumbs on very narrow windows
  excluded_filetypes = {
    help = true,
    alpha = true,
    TelescopePrompt = true,
    [""] = true,
  },
}

-- Per-buffer simple cache keyed by current ancestor scopes
local breadcrumbs_cache_by_bufnr = {}

local function in_excluded_filetype()
  local ft = vim.bo.filetype
  return M.config.excluded_filetypes[ft] == true
end

local function window_is_narrow()
  return vim.o.columns < M.config.min_width
end

local function truncate(text, max_len)
  if #text <= max_len then return text end
  return string.sub(text, 1, max_len - 1) .. "…"
end

local function get_current_node()
  local ok_ts, ts_utils = pcall(require, 'nvim-treesitter.ts_utils')
  if not ok_ts then return nil end
  return ts_utils.get_node_at_cursor()
end

local CLASS_TYPES = {
  ['class_declaration'] = true, ['class_definition'] = true, ['impl_item'] = true,
  ['struct_item'] = true, ['interface_declaration'] = true, ['trait_item'] = true,
  ['enum_item'] = true, ['type_item'] = true,
}

local FUNCTION_TYPES = {
  ['function_item'] = true, ['function_definition'] = true, ['function_declaration'] = true,
  ['method_definition'] = true, ['method_declaration'] = true, ['arrow_function'] = true,
}

local function get_scopes(node)
  if not node then return nil, nil end
  local class_node, func_node = nil, nil
  local current = node
  while current do
    local t = current:type()
    if not func_node and FUNCTION_TYPES[t] then
      func_node = current
    end
    if not class_node and CLASS_TYPES[t] then
      class_node = current
    end
    if func_node and class_node then break end
    current = current:parent()
  end
  return class_node, func_node
end

local function build_cache_key(class_node, func_node)
  local parts = {}
  if class_node then
    local sr, sc, er, ec = class_node:range()
    table.insert(parts, table.concat({ 'C', sr, sc, er, ec, class_node:type() }, ':'))
  end
  if func_node then
    local sr, sc, er, ec = func_node:range()
    table.insert(parts, table.concat({ 'F', sr, sc, er, ec, func_node:type() }, ':'))
  end
  if #parts == 0 then return 'none' end
  return table.concat(parts, '|')
end

local function text_for_scopes(class_node, func_node, bufnr)
  local class_name, function_name = nil, nil

  if class_node then
    local name_node = class_node:field('name')[1] or class_node:field('type')[1] or class_node:field('identifier')[1]
    if name_node then
      local ok_txt, name_text = pcall(vim.treesitter.get_node_text, name_node, bufnr)
      if ok_txt and name_text and #name_text > 0 then
        class_name = truncate(name_text, M.config.max_name_length)
      end
    end
  end

  if func_node then
    local name_node = func_node:field('name')[1] or func_node:field('identifier')[1]
    if name_node then
      local ok_txt, name_text = pcall(vim.treesitter.get_node_text, name_node, bufnr)
      if ok_txt and name_text and #name_text > 0 then
        function_name = truncate(name_text, M.config.max_name_length)
      end
    end
  end

  local parts = {}
  if class_name then table.insert(parts, class_name) end
  if function_name then table.insert(parts, function_name) end

  if #parts == 0 then return '' end
  return ' ' .. M.config.separator .. table.concat(parts, M.config.separator)
end

local function compute_breadcrumbs()
  if in_excluded_filetype() or window_is_narrow() then return '' end
  local bufnr = vim.api.nvim_get_current_buf()
  local node = get_current_node()
  if not node then return '' end

  local class_node, func_node = get_scopes(node)
  local key = build_cache_key(class_node, func_node)

  local cache = breadcrumbs_cache_by_bufnr[bufnr]
  if cache and cache.key == key and cache.text then
    return cache.text
  end

  local text = text_for_scopes(class_node, func_node, bufnr)
  breadcrumbs_cache_by_bufnr[bufnr] = { key = key, text = text }
  return text
end

-- Public provider function for lualine sections
function M.provider()
  if vim.g.breadcrumbs_enable_top ~= nil then M.state.enable_top = vim.g.breadcrumbs_enable_top end
  if vim.g.breadcrumbs_enable_bottom ~= nil then M.state.enable_bottom = vim.g.breadcrumbs_enable_bottom end
  return compute_breadcrumbs()
end

function M.cond_top()
  return M.state.enable_top and not in_excluded_filetype() and not window_is_narrow()
end

function M.cond_bottom()
  return M.state.enable_bottom and not in_excluded_filetype() and not window_is_narrow()
end

-- Toggle commands
local function refresh(place)
  local ok, ll = pcall(require, 'lualine')
  if ok then
    ll.refresh({ place = place or { 'statusline', 'winbar' }, trigger = 'auto' })
  end
end

function M.toggle_top()
  M.state.enable_top = not M.state.enable_top
  vim.g.breadcrumbs_enable_top = M.state.enable_top
  refresh({ 'winbar' })
end

function M.toggle_bottom()
  M.state.enable_bottom = not M.state.enable_bottom
  vim.g.breadcrumbs_enable_bottom = M.state.enable_bottom
  refresh({ 'statusline' })
end

-- Define user commands
vim.api.nvim_create_user_command('BreadcrumbsToggleTop', function()
  M.toggle_top()
end, {})

vim.api.nvim_create_user_command('BreadcrumbsToggleBottom', function()
  M.toggle_bottom()
end, {})

vim.api.nvim_create_user_command('BreadcrumbsToggle', function()
  M.toggle_top(); M.toggle_bottom()
end, {})

return M