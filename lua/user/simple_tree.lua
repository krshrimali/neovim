local M = {}

-- Configuration
local config = {
  width = 30,
  side = 'left',
  auto_close = true,
  show_hidden = false,
  preserve_window_proportions = true,
}

-- State
local tree_buf = nil
local tree_win = nil
local current_root = nil
local tree_data = {}


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

-- Cache for directory contents to speed up repeated access
local dir_cache = {}

local function clear_cache()
  dir_cache = {}
end

local function scan_directory(path, level)
  level = level or 0
  
  -- Check cache first
  local cache_key = path .. ":" .. tostring(config.show_hidden)
  if dir_cache[cache_key] then
    -- Update levels for cached items
    for _, item in ipairs(dir_cache[cache_key]) do
      item.level = level
    end
    return dir_cache[cache_key]
  end
  
  local items = {}
  local handle = vim.loop.fs_scandir(path)
  if not handle then 
    dir_cache[cache_key] = items
    return items 
  end
  
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
  
  -- Cache the results
  dir_cache[cache_key] = items
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
  
  -- Add ".." entry for parent directory if we're not at the filesystem root
  local parent_path = vim.fn.fnamemodify(current_root, ':h')
  if current_root ~= parent_path and current_root ~= '/' then
    table.insert(lines, ".. ")
  end
  
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
  
  -- Check if cursor is on the ".." entry
  local parent_path = vim.fn.fnamemodify(current_root, ':h')
  local has_parent_entry = current_root ~= parent_path and current_root ~= '/'
  
  if has_parent_entry and line_num == 1 then
    return {
      name = "..",
      path = parent_path,
      type = "directory",
      level = 0,
      expanded = false,
      children = {},
      is_parent = true
    }
  end
  
  local flat_items = flatten_tree(tree_data)
  local adjusted_line = has_parent_entry and line_num - 1 or line_num
  return flat_items[adjusted_line]
end

local function open_file(path, split_type)
  split_type = split_type or 'default'
  
  local target_win = nil
  
  if split_type == 'default' then
    -- Find a suitable window to open the file
    local wins = vim.api.nvim_list_wins()
    
    for _, win in ipairs(wins) do
      if win ~= tree_win then
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
  
  -- Handle ".." parent directory navigation
  if item.is_parent then
    navigate_to_parent()
    return
  end
  
  if item.expanded then
    collapse_directory(item)
  else
    expand_directory(item)
  end
  
  render_tree()
end

local function navigate_to_parent()
  local parent_path = vim.fn.fnamemodify(current_root, ':h')
  if current_root == parent_path or current_root == '/' then
    print("Already at filesystem root")
    return
  end
  
  current_root = parent_path
  clear_cache()
  tree_data = scan_directory(current_root, 0)
  render_tree()
  
  -- Set cursor to first item after parent entry
  local cursor_line = 1
  local parent_check_path = vim.fn.fnamemodify(current_root, ':h')
  if current_root ~= parent_check_path and current_root ~= '/' then
    cursor_line = 2  -- Skip the ".." entry
  end
  
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_win_set_cursor(tree_win, {cursor_line, 0})
  end
end

local function handle_enter()
  local item = get_item_at_cursor()
  if not item then return end
  
  -- Handle ".." parent directory navigation
  if item.is_parent then
    navigate_to_parent()
    return
  end
  
  if item.type == "directory" then
    toggle_directory()
  else
    open_file(item.path)
  end
end

local function handle_l_key()
  local item = get_item_at_cursor()
  if not item then return end
  
  -- Handle ".." parent directory navigation
  if item.is_parent then
    navigate_to_parent()
    return
  end
  
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

-- Telescope integration for search
local function open_telescope_in_directory()
  local telescope_ok, telescope = pcall(require, 'telescope.builtin')
  if not telescope_ok then
    print("Telescope not available")
    return
  end
  
  -- Use current_root as the search directory
  telescope.find_files({
    cwd = current_root,
    prompt_title = "Find Files in " .. vim.fn.fnamemodify(current_root, ":t"),
    hidden = config.show_hidden,
    layout_config = {
      height = 0.8,
      width = 0.8,
    },
    results_limit = 100,
  })
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
  
  -- Prevent auto-resizing
  vim.api.nvim_win_set_option(tree_win, 'winfixwidth', true)
  
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
  vim.keymap.set('n', '/', function() open_telescope_in_directory() end, opts)
  vim.keymap.set('n', 'R', function() M.refresh() end, opts)
  vim.keymap.set('n', 'H', function() 
    config.show_hidden = not config.show_hidden
    clear_cache() -- Clear cache since hidden file setting changed
    M.refresh() 
  end, opts)
  vim.keymap.set('n', '<C-v>', handle_vertical_split, opts)
  vim.keymap.set('n', '<C-x>', handle_horizontal_split, opts)
  vim.keymap.set('n', 'y', handle_copy_relative, opts)
  vim.keymap.set('n', 'Y', handle_copy_absolute, opts)
  vim.keymap.set('n', 'g', handle_github_open, opts)
  vim.keymap.set('n', 'u', function() navigate_to_parent() end, opts)  -- Go to parent directory
  
  -- Set cursor to first item
  if #tree_data > 0 then
    vim.api.nvim_win_set_cursor(tree_win, {1, 0})
  end
end

function M.close()
  if tree_win and vim.api.nvim_win_is_valid(tree_win) then
    vim.api.nvim_win_close(tree_win, true)
    tree_win = nil
    tree_buf = nil
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
  
  -- Clear cache to force refresh
  clear_cache()
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