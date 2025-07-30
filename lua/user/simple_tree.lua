local M = {}

-- Configuration
local config = {
  width = 30,
  side = 'left',
  auto_close = true,
  show_hidden = false,
}

-- State
local tree_buf = nil
local tree_win = nil
local current_root = nil
local tree_data = {}
local search_mode = false
local search_buf = nil
local search_win = nil
local filtered_items = {}

-- Utility functions
local function get_icon(is_dir, is_open)
  if is_dir then
    return is_open and "▼ " or "▶ "
  else
    return "  "
  end
end

local function get_file_type(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then return nil end
  return stat.type
end

local function scan_directory(path, level)
  level = level or 0
  local items = {}
  
  local handle = vim.loop.fs_scandir(path)
  if not handle then return items end
  
  local entries = {}
  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then break end
    
    -- Skip hidden files unless configured to show them
    if not config.show_hidden and name:match("^%.") then
      goto continue
    end
    
    local full_path = path .. "/" .. name
    table.insert(entries, {
      name = name,
      path = full_path,
      type = type,
      level = level
    })
    
    ::continue::
  end
  
  -- Sort entries: directories first, then files, alphabetically
  table.sort(entries, function(a, b)
    if a.type ~= b.type then
      return a.type == "directory"
    end
    return a.name:lower() < b.name:lower()
  end)
  
  for _, entry in ipairs(entries) do
    local item = {
      name = entry.name,
      path = entry.path,
      type = entry.type,
      level = entry.level,
      expanded = false,
      children = {}
    }
    
    table.insert(items, item)
  end
  
  return items
end

local function expand_directory(item)
  if item.type ~= "directory" or item.expanded then return end
  
  item.children = scan_directory(item.path, item.level + 1)
  item.expanded = true
end

local function collapse_directory(item)
  if item.type ~= "directory" or not item.expanded then return end
  
  item.children = {}
  item.expanded = false
end

local function flatten_tree(items, result)
  result = result or {}
  
  for _, item in ipairs(items) do
    table.insert(result, item)
    if item.expanded and #item.children > 0 then
      flatten_tree(item.children, result)
    end
  end
  
  return result
end

local function render_tree()
  if not tree_buf or not vim.api.nvim_buf_is_valid(tree_buf) then return end
  
  local flat_items = flatten_tree(tree_data)
  local lines = {}
  
  for _, item in ipairs(flat_items) do
    local indent = string.rep("  ", item.level)
    local icon = get_icon(item.type == "directory", item.expanded)
    local line = indent .. icon .. item.name
    table.insert(lines, line)
  end
  
  vim.api.nvim_buf_set_option(tree_buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(tree_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(tree_buf, 'modifiable', false)
end

local function get_item_at_cursor()
  if not tree_win or not vim.api.nvim_win_is_valid(tree_win) then return nil end
  
  local cursor = vim.api.nvim_win_get_cursor(tree_win)
  local line_num = cursor[1]
  
  local flat_items = flatten_tree(tree_data)
  return flat_items[line_num]
end

local function open_file(path)
  -- Find a suitable window to open the file
  local wins = vim.api.nvim_list_wins()
  local target_win = nil
  
  for _, win in ipairs(wins) do
    if win ~= tree_win and win ~= search_win then
      local buf = vim.api.nvim_win_get_buf(win)
      local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')
      if buf_type == '' then
        target_win = win
        break
      end
    end
  end
  
  if not target_win then
    -- Create a new window
    vim.cmd('vsplit')
    target_win = vim.api.nvim_get_current_win()
  end
  
  vim.api.nvim_set_current_win(target_win)
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  
  if config.auto_close then
    M.close()
  end
end

local function toggle_directory()
  local item = get_item_at_cursor()
  if not item or item.type ~= "directory" then return end
  
  if item.expanded then
    collapse_directory(item)
  else
    expand_directory(item)
  end
  
  render_tree()
end

local function handle_enter()
  local item = get_item_at_cursor()
  if not item then return end
  
  if item.type == "directory" then
    toggle_directory()
  else
    open_file(item.path)
  end
end

-- Search functionality
local function fuzzy_match(str, pattern)
  if pattern == "" then return true end
  
  local str_lower = str:lower()
  local pattern_lower = pattern:lower()
  
  -- Simple fuzzy matching
  local str_idx = 1
  for i = 1, #pattern_lower do
    local char = pattern_lower:sub(i, i)
    local found = str_lower:find(char, str_idx, true)
    if not found then return false end
    str_idx = found + 1
  end
  
  return true
end

local function filter_tree(pattern)
  filtered_items = {}
  local flat_items = flatten_tree(tree_data)
  
  for _, item in ipairs(flat_items) do
    if fuzzy_match(item.name, pattern) then
      table.insert(filtered_items, item)
    end
  end
end

local function render_search_results(pattern)
  if not search_buf or not vim.api.nvim_buf_is_valid(search_buf) then return end
  
  filter_tree(pattern)
  local lines = {}
  
  for _, item in ipairs(filtered_items) do
    local icon = get_icon(item.type == "directory", false)
    local relative_path = item.path:gsub("^" .. vim.fn.escape(current_root, "^$()%.[]*+-?") .. "/", "")
    local line = icon .. relative_path
    table.insert(lines, line)
  end
  
  vim.api.nvim_buf_set_option(search_buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(search_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(search_buf, 'modifiable', false)
end

local function setup_search_window()
  if search_win and vim.api.nvim_win_is_valid(search_win) then
    vim.api.nvim_set_current_win(search_win)
    return
  end
  
  -- Create search buffer
  search_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(search_buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(search_buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(search_buf, 'bufhidden', 'wipe')
  
  -- Create floating window for search
  local width = math.floor(vim.o.columns * 0.6)
  local height = math.floor(vim.o.lines * 0.6)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  search_win = vim.api.nvim_open_win(search_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Search Files ',
    title_pos = 'center'
  })
  
  -- Set up search input
  vim.fn.prompt_start(search_buf, '> ', function(text)
    local pattern = text:gsub('^> ', '')
    if #filtered_items > 0 then
      local selected = filtered_items[1]
      if selected.type == "directory" then
        -- For directories, just close search
        M.close_search()
      else
        open_file(selected.path)
        M.close_search()
      end
    end
  end)
  
  -- Set up real-time filtering
  vim.api.nvim_create_autocmd('TextChangedI', {
    buffer = search_buf,
    callback = function()
      local line = vim.api.nvim_get_current_line()
      local pattern = line:gsub('^> ', '')
      render_search_results(pattern)
    end
  })
  
  -- Key mappings for search window
  local search_opts = { buffer = search_buf, silent = true }
  vim.keymap.set('i', '<Esc>', function() M.close_search() end, search_opts)
  vim.keymap.set('i', '<C-c>', function() M.close_search() end, search_opts)
  vim.keymap.set('i', '<Down>', function()
    -- TODO: Implement navigation in search results
  end, search_opts)
  vim.keymap.set('i', '<Up>', function()
    -- TODO: Implement navigation in search results
  end, search_opts)
  
  -- Start in insert mode
  vim.cmd('startinsert')
  
  -- Initial render
  render_search_results('')
end

-- Main functions
function M.open(root_path)
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_set_current_win(tree_win)
    return
  end
  
  current_root = root_path or vim.fn.getcwd()
  
  -- Create buffer
  tree_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(tree_buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(tree_buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(tree_buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(tree_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_name(tree_buf, 'SimpleTree')
  
  -- Create window
  vim.cmd('topleft ' .. config.width .. 'vsplit')
  tree_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(tree_win, tree_buf)
  
  -- Window options
  vim.api.nvim_win_set_option(tree_win, 'number', false)
  vim.api.nvim_win_set_option(tree_win, 'relativenumber', false)
  vim.api.nvim_win_set_option(tree_win, 'signcolumn', 'no')
  vim.api.nvim_win_set_option(tree_win, 'foldcolumn', '0')
  vim.api.nvim_win_set_option(tree_win, 'wrap', false)
  vim.api.nvim_win_set_option(tree_win, 'cursorline', true)
  
  -- Load tree data
  tree_data = scan_directory(current_root, 0)
  render_tree()
  
  -- Set up key mappings
  local opts = { buffer = tree_buf, silent = true }
  vim.keymap.set('n', '<CR>', handle_enter, opts)
  vim.keymap.set('n', 'o', handle_enter, opts)
  vim.keymap.set('n', '<Space>', toggle_directory, opts)
  vim.keymap.set('n', 'q', function() M.close() end, opts)
  vim.keymap.set('n', '/', function() setup_search_window() end, opts)
  vim.keymap.set('n', 'R', function() M.refresh() end, opts)
  vim.keymap.set('n', 'H', function() config.show_hidden = not config.show_hidden; M.refresh() end, opts)
  
  -- Set cursor to first item
  if #tree_data > 0 then
    vim.api.nvim_win_set_cursor(tree_win, {1, 0})
  end
end

function M.close()
  if search_win and vim.api.nvim_win_is_valid(search_win) then
    vim.api.nvim_win_close(search_win, true)
    search_win = nil
    search_buf = nil
  end
  
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_win_close(tree_win, true)
    tree_win = nil
    tree_buf = nil
  end
end

function M.close_search()
  if search_win and vim.api.nvim_win_is_valid(search_win) then
    vim.api.nvim_win_close(search_win, true)
    search_win = nil
    search_buf = nil
  end
  
  -- Return focus to tree window
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_set_current_win(tree_win)
  end
end

function M.toggle(root_path)
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    M.close()
  else
    M.open(root_path)
  end
end

function M.refresh()
  if not current_root then return end
  
  tree_data = scan_directory(current_root, 0)
  render_tree()
end

function M.open_current_dir()
  local current_file = vim.fn.expand('%:p')
  if current_file == '' then
    M.toggle(vim.fn.getcwd())
  else
    local dir = vim.fn.fnamemodify(current_file, ':h')
    M.toggle(dir)
  end
end

function M.open_workspace()
  M.toggle(vim.fn.getcwd())
end

return M