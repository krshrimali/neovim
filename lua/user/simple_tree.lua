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
local search_pattern = ""
local search_selected_idx = 1

-- Utility functions
local function get_icon(is_dir, is_open)
  if is_dir then
    return "> "
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

local function open_file(path, split_type)
  split_type = split_type or 'default'
  
  local target_win = nil
  
  if split_type == 'default' then
    -- Find a suitable window to open the file
    local wins = vim.api.nvim_list_wins()
    
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
  elseif split_type == 'vertical' then
    vim.cmd('vsplit')
    target_win = vim.api.nvim_get_current_win()
  elseif split_type == 'horizontal' then
    vim.cmd('split')
    target_win = vim.api.nvim_get_current_win()
  end
  
  vim.api.nvim_set_current_win(target_win)
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
  
  if config.auto_close then
    M.close()
  end
end

local function copy_to_clipboard(text)
  vim.fn.setreg('+', text)
  vim.fn.setreg('"', text)
  print("Copied: " .. text)
end

local function get_relative_path(path)
  local cwd = vim.fn.getcwd()
  local relative = path:gsub("^" .. vim.fn.escape(cwd, "^$()%.[]*+-?") .. "/", "")
  return relative
end

local function get_git_remote_url()
  local handle = io.popen("git remote get-url origin 2>/dev/null")
  if not handle then return nil end
  
  local result = handle:read("*a")
  handle:close()
  
  if result and result ~= "" then
    return result:gsub("%s+", "") -- trim whitespace
  end
  return nil
end

local function open_github_link(path)
  local git_url = get_git_remote_url()
  if not git_url then
    print("Not a git repository or no remote origin found")
    return
  end
  
  -- Convert SSH to HTTPS if needed
  if git_url:match("^git@") then
    git_url = git_url:gsub("^git@([^:]+):", "https://%1/")
    git_url = git_url:gsub("%.git$", "")
  elseif git_url:match("^https://") then
    git_url = git_url:gsub("%.git$", "")
  else
    print("Unsupported git URL format")
    return
  end
  
  -- Get current branch
  local branch_handle = io.popen("git branch --show-current 2>/dev/null")
  local branch = "main"
  if branch_handle then
    local branch_result = branch_handle:read("*a")
    branch_handle:close()
    if branch_result and branch_result ~= "" then
      branch = branch_result:gsub("%s+", "")
    end
  end
  
  -- Get relative path from git root
  local git_root_handle = io.popen("git rev-parse --show-toplevel 2>/dev/null")
  if not git_root_handle then
    print("Error getting git root")
    return
  end
  
  local git_root = git_root_handle:read("*a")
  git_root_handle:close()
  
  if not git_root or git_root == "" then
    print("Error getting git root")
    return
  end
  
  git_root = git_root:gsub("%s+", "")
  local relative_path = path:gsub("^" .. vim.fn.escape(git_root, "^$()%.[]*+-?") .. "/", "")
  
  local github_url = git_url .. "/blob/" .. branch .. "/" .. relative_path
  
  -- Open in browser
  local open_cmd = "xdg-open"
  if vim.fn.has("mac") == 1 then
    open_cmd = "open"
  elseif vim.fn.has("win32") == 1 then
    open_cmd = "start"
  end
  
  os.execute(open_cmd .. " '" .. github_url .. "'")
  print("Opening: " .. github_url)
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

local function handle_l_key()
  local item = get_item_at_cursor()
  if not item then return end
  
  if item.type == "directory" then
    if not item.expanded then
      expand_directory(item)
      render_tree()
    end
  else
    open_file(item.path)
  end
end

local function handle_copy_relative()
  local item = get_item_at_cursor()
  if not item then return end
  
  local relative_path = get_relative_path(item.path)
  copy_to_clipboard(relative_path)
end

local function handle_copy_absolute()
  local item = get_item_at_cursor()
  if not item then return end
  
  copy_to_clipboard(item.path)
end

local function handle_github_open()
  local item = get_item_at_cursor()
  if not item then return end
  
  if item.type == "directory" then
    print("GitHub links are only available for files")
    return
  end
  
  open_github_link(item.path)
end

local function handle_vertical_split()
  local item = get_item_at_cursor()
  if not item then return end
  
  if item.type == "directory" then
    return -- Do nothing for directories
  else
    open_file(item.path, 'vertical')
  end
end

local function handle_horizontal_split()
  local item = get_item_at_cursor()
  if not item then return end
  
  if item.type == "directory" then
    return -- Do nothing for directories
  else
    open_file(item.path, 'horizontal')
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
  
  -- Add header with search pattern
  local header = "Search: " .. pattern
  if pattern == "" then
    header = "Search: (type to filter)"
  end
  table.insert(lines, header)
  
  -- Add filtered results
  for i, item in ipairs(filtered_items) do
    local icon = get_icon(item.type == "directory", false)
    local relative_path = item.path:gsub("^" .. vim.fn.escape(current_root, "^$()%.[]*+-?") .. "/", "")
    local prefix = (i == search_selected_idx) and "→ " or "  "
    local line = prefix .. icon .. relative_path
    table.insert(lines, line)
  end
  
  if #filtered_items == 0 and pattern ~= "" then
    table.insert(lines, "  No matches found")
  end
  
  vim.api.nvim_buf_set_option(search_buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(search_buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_option(search_buf, 'modifiable', false)
  
  -- Set cursor to selected item
  if #filtered_items > 0 then
    vim.api.nvim_win_set_cursor(search_win, {search_selected_idx + 1, 0}) -- +1 for header
  end
end

local function setup_search_window()
  if search_win and vim.api.nvim_win_is_valid(search_win) then
    vim.api.nvim_set_current_win(search_win)
    return
  end
  
  search_pattern = ""
  search_selected_idx = 1
  
  -- Create search buffer
  search_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(search_buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(search_buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(search_buf, 'bufhidden', 'wipe')
  vim.api.nvim_buf_set_option(search_buf, 'modifiable', false)
  
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
    title = ' Search Files (ESC to close) ',
    title_pos = 'center'
  })
  
  -- Window options
  vim.api.nvim_win_set_option(search_win, 'cursorline', true)
  
  -- Key mappings for search window
  local search_opts = { buffer = search_buf, silent = true }
  
  -- Close search
  vim.keymap.set('n', '<Esc>', function() M.close_search() end, search_opts)
  vim.keymap.set('n', '<C-c>', function() M.close_search() end, search_opts)
  vim.keymap.set('n', 'q', function() M.close_search() end, search_opts)
  
  -- Navigation
  vim.keymap.set('n', 'j', function()
    if #filtered_items > 0 then
      search_selected_idx = math.min(search_selected_idx + 1, #filtered_items)
      vim.api.nvim_win_set_cursor(search_win, {search_selected_idx + 1, 0}) -- +1 for header line
    end
  end, search_opts)
  
  vim.keymap.set('n', 'k', function()
    if #filtered_items > 0 then
      search_selected_idx = math.max(search_selected_idx - 1, 1)
      vim.api.nvim_win_set_cursor(search_win, {search_selected_idx + 1, 0}) -- +1 for header line
    end
  end, search_opts)
  
  vim.keymap.set('n', '<Down>', function()
    if #filtered_items > 0 then
      search_selected_idx = math.min(search_selected_idx + 1, #filtered_items)
      vim.api.nvim_win_set_cursor(search_win, {search_selected_idx + 1, 0})
    end
  end, search_opts)
  
  vim.keymap.set('n', '<Up>', function()
    if #filtered_items > 0 then
      search_selected_idx = math.max(search_selected_idx - 1, 1)
      vim.api.nvim_win_set_cursor(search_win, {search_selected_idx + 1, 0})
    end
  end, search_opts)
  
  -- Open selected file
  vim.keymap.set('n', '<CR>', function()
    if #filtered_items > 0 and search_selected_idx <= #filtered_items then
      local selected = filtered_items[search_selected_idx]
      if selected.type == "directory" then
        M.close_search()
      else
        open_file(selected.path, 'default')
        M.close_search()
      end
    end
  end, search_opts)
  
  -- Character input for search
  for i = 32, 126 do -- printable ASCII characters
    local char = string.char(i)
    vim.keymap.set('n', char, function()
      search_pattern = search_pattern .. char
      search_selected_idx = 1
      render_search_results(search_pattern)
      if #filtered_items > 0 then
        vim.api.nvim_win_set_cursor(search_win, {2, 0}) -- First result line
      end
    end, search_opts)
  end
  
  -- Backspace to delete characters
  vim.keymap.set('n', '<BS>', function()
    if #search_pattern > 0 then
      search_pattern = search_pattern:sub(1, -2)
      search_selected_idx = 1
      render_search_results(search_pattern)
      if #filtered_items > 0 then
        vim.api.nvim_win_set_cursor(search_win, {2, 0})
      end
    end
  end, search_opts)
  
  -- Initial render
  render_search_results(search_pattern)
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
  vim.keymap.set('n', 'l', handle_l_key, opts)
  vim.keymap.set('n', '<Space>', toggle_directory, opts)
  vim.keymap.set('n', 'q', function() M.close() end, opts)
  vim.keymap.set('n', '/', function() setup_search_window() end, opts)
  vim.keymap.set('n', 'R', function() M.refresh() end, opts)
  vim.keymap.set('n', 'H', function() config.show_hidden = not config.show_hidden; M.refresh() end, opts)
  vim.keymap.set('n', '<C-v>', handle_vertical_split, opts)
  vim.keymap.set('n', '<C-x>', handle_horizontal_split, opts)
  vim.keymap.set('n', 'y', handle_copy_relative, opts)
  vim.keymap.set('n', 'Y', handle_copy_absolute, opts)
  vim.keymap.set('n', 'g', handle_github_open, opts)
  
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