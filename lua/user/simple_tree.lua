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
    return (is_open and "v " or "> ")
  else
    return "  "
  end
end

local function get_file_type(path)
  local stat = vim.loop.fs_stat(path)
  if not stat then return nil end
  return stat.type
end

-- Detect absolute path (cross-platform)
local function is_absolute_path(path)
  if not path or path == '' then return false end
  -- Windows: "C:\" or "C:/" or UNC paths "\\server\share"
  if vim.fn.has('win32') == 1 or vim.fn.has('win64') == 1 then
    return path:match('^%a:[/\\]') ~= nil or path:match('^[/\\][/\\]') ~= nil
  end
  -- POSIX
  return path:sub(1, 1) == '/'
end

-- Run a git command in the context of the current tree root
local function git_in_root(args)
  local root = current_root or vim.fn.getcwd()
  local command = string.format("git -C %s %s 2>/dev/null", vim.fn.shellescape(root), args)
  local output = vim.fn.system(command)
  if vim.v.shell_error ~= 0 then return nil end
  if not output then return nil end
  output = output:gsub("%s+$", "")
  if output == '' then return nil end
  return output
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
  vim.api.nvim_buf_set_option(tree_buf, 'filetype', 'simpletree')
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

local function open_file(path, split_type, should_close_tree)
  split_type = split_type or 'default'
  should_close_tree = should_close_tree == nil and config.auto_close or should_close_tree
  
  -- Resolve relative paths against the current tree root
  if not is_absolute_path(path) then
    path = current_root .. '/' .. path
  end
  
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
  
  if should_close_tree then
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
  local result = git_in_root("remote get-url origin")
  if result and result ~= "" then
    return result
  end
  return nil
end

local function url_encode(str)
  if not str then return '' end
  -- Encode everything except unreserved and '/'
  return (str:gsub("([^%w%-%._~/])", function(c)
    return string.format("%%%02X", string.byte(c))
  end))
end

local function normalize_remote_to_https(remote)
  if not remote or remote == '' then return nil end
  -- git@host:owner/repo(.git)
  local host, path = remote:match('^git@([^:]+):(.+)$')
  if host and path then
    path = path:gsub('%.git$', '')
    return 'https://' .. host .. '/' .. path
  end
  -- ssh://git@host/owner/repo(.git)
  host, path = remote:match('^ssh://git@([^/]+)/(.+)$')
  if host and path then
    path = path:gsub('%.git$', '')
    return 'https://' .. host .. '/' .. path
  end
  -- https://host/owner/repo(.git)
  local scheme, rest = remote:match('^(https?)://(.+)$')
  if scheme and rest then
    rest = rest:gsub('%.git$', '')
    return 'https://' .. rest
  end
  -- git://host/owner/repo(.git)
  local git_host, git_path = remote:match('^git://([^/]+)/(.+)$')
  if git_host and git_path then
    git_path = git_path:gsub('%.git$', '')
    return 'https://' .. git_host .. '/' .. git_path
  end
  return nil
end

local function open_github_link(path)
  local git_url = get_git_remote_url()
  if not git_url then
    print("Not a git repository or no remote origin found")
    return
  end
  
  local https_url = normalize_remote_to_https(git_url)
  if not https_url then
    print("Unsupported git URL format: " .. git_url)
    return
  end
  
  -- Get current branch (fallbacks)
  local branch = git_in_root("branch --show-current")
  if not branch or branch == '' then
    local ref = git_in_root("symbolic-ref --quiet --short refs/remotes/origin/HEAD") or ''
    branch = ref:match('origin/(.+)$') or 'main'
  end
  
  -- Get relative path from git root
  local git_root = git_in_root("rev-parse --show-toplevel")
  if not git_root or git_root == '' then
    print("Error getting git root")
    return
  end
  
  local relative_path = path:gsub("^" .. vim.fn.escape(git_root, "^$()%.[]*+-?" ) .. "/", "")
  local encoded_path = url_encode(relative_path)
  
  local github_url = https_url .. "/blob/" .. url_encode(branch) .. "/" .. encoded_path
  
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

local function create_file()
  local input = vim.fn.input("Create file: ", "", "file")
  if input == "" then return end
  
  local file_path = current_root .. "/" .. input
  
  -- Create parent directories if they don't exist
  local parent_dir = vim.fn.fnamemodify(file_path, ':h')
  if vim.fn.isdirectory(parent_dir) == 0 then
    vim.fn.mkdir(parent_dir, 'p')
  end
  
  -- Create the file
  local file = io.open(file_path, 'w')
  if file then
    file:close()
    print("Created file: " .. file_path)
    
    -- Refresh the tree
    clear_cache()
    tree_data = scan_directory(current_root, 0)
    render_tree()
  else
    print("Error: Could not create file: " .. file_path)
  end
end

local function create_directory()
  local input = vim.fn.input("Create directory: ", "", "dir")
  if input == "" then return end
  
  local dir_path = current_root .. "/" .. input
  
  -- Create directory recursively
  if vim.fn.mkdir(dir_path, 'p') == 1 then
    print("Created directory: " .. dir_path)
    
    -- Refresh the tree
    clear_cache()
    tree_data = scan_directory(current_root, 0)
    render_tree()
  else
    print("Error: Could not create directory: " .. dir_path)
  end
end

local function delete_item()
  local item = get_item_at_cursor()
  if not item or item.is_parent then
    print("Cannot delete parent directory entry")
    return
  end
  
  local item_type = item.type == "directory" and "directory" or "file"
  local confirm = vim.fn.input("Delete " .. item_type .. " '" .. item.name .. "'? (y/N): ")
  
  if confirm:lower() ~= 'y' and confirm:lower() ~= 'yes' then
    print("Deletion cancelled")
    return
  end
  
  local success = false
  if item.type == "directory" then
    -- Use Neovim API to remove directory recursively (fallback to system if needed)
    if vim.fn.delete(item.path, 'rf') == 0 then
      success = true
    else
      local result = os.execute("rm -rf '" .. item.path .. "'")
      success = result == 0
    end
  else
    -- Remove file using Neovim API
    success = (vim.fn.delete(item.path) == 0)
  end
  
  if success then
    print("Deleted " .. item_type .. ": " .. item.path)
    
    -- Refresh the tree
    clear_cache()
    tree_data = scan_directory(current_root, 0)
    render_tree()
  else
    print("Error: Could not delete " .. item_type .. ": " .. item.path)
  end
end

local function rename_item()
  local item = get_item_at_cursor()
  if not item or item.is_parent then
    print("Cannot rename parent directory entry")
    return
  end
  
  local item_type = item.type == "directory" and "directory" or "file"
  local current_name = item.name
  local new_name = vim.fn.input("Rename " .. item_type .. " '" .. current_name .. "' to: ", current_name)
  
  if new_name == "" or new_name == current_name then
    print("Rename cancelled")
    return
  end
  
  -- Construct new path
  local parent_dir = vim.fn.fnamemodify(item.path, ':h')
  local new_path = parent_dir .. "/" .. new_name
  
  -- Check if target already exists
  if vim.fn.filereadable(new_path) == 1 or vim.fn.isdirectory(new_path) == 1 then
    print("Error: Target '" .. new_name .. "' already exists")
    return
  end
  
  -- Create parent directories if the new name contains path separators
  local new_parent_dir = vim.fn.fnamemodify(new_path, ':h')
  if new_parent_dir ~= parent_dir and vim.fn.isdirectory(new_parent_dir) == 0 then
    if vim.fn.mkdir(new_parent_dir, 'p') ~= 1 then
      print("Error: Could not create parent directories for: " .. new_path)
      return
    end
  end
  
  -- Perform the rename using Neovim API first, fallback to os.rename
  local success = (vim.fn.rename(item.path, new_path) == 0)
  if not success then
    success = os.rename(item.path, new_path)
  end
  
  if success then
    print("Renamed " .. item_type .. " '" .. current_name .. "' to '" .. new_name .. "'")
    
    -- Refresh the tree
    clear_cache()
    tree_data = scan_directory(current_root, 0)
    render_tree()
  else
    print("Error: Could not rename " .. item_type .. " '" .. current_name .. "' to '" .. new_name .. "'")
  end
end

local function show_help()
  local help_lines = {
    "SimpleTree Keymaps:",
    "",
    "Navigation:",
    "  <CR>, o     - Open file/toggle directory",
    "  l           - Expand directory/open file", 
    "  <Space>     - Toggle directory",
    "  u           - Go to parent directory",
    "  ..          - Click to go to parent directory",
    "",
    "Mouse Support:",
    "  Left Click  - Open file/toggle directory",
    "  Right Click - Show context menu",
    "",
    "File Operations:",
    "  a           - Create new file",
    "  A           - Create new directory", 
    "  r           - Rename file/directory",
    "  d           - Delete file/directory",
    "",
    "Window Operations:",
    "  <C-v>       - Open file in vertical split",
    "  <C-x>       - Open file in horizontal split",
    "",
    "Copy Operations:",
    "  y           - Copy relative path",
    "  Y           - Copy absolute path",
    "",
    "Other:",
    "  /           - Search files with FzfLua",
    "  R           - Refresh tree",
    "  H           - Toggle hidden files",
    "  w           - Open file in GitHub",
    "  ?           - Show this help",
    "  q           - Close tree",
    "",
    "Press any key to close this help..."
  }
  
  -- Create help buffer
  local help_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(help_buf, 0, -1, false, help_lines)
  vim.api.nvim_buf_set_option(help_buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(help_buf, 'buftype', 'nofile')
  
  -- Calculate window size
  local width = 50
  local height = #help_lines + 2
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)
  
  -- Create floating window
  local help_win = vim.api.nvim_open_win(help_buf, true, {
    relative = 'editor',
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Help ',
    title_pos = 'center'
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(help_win, 'wrap', false)
  vim.api.nvim_win_set_option(help_win, 'cursorline', false)
  
  -- Close on any key press
  vim.keymap.set('n', '<buffer>', function()
    if vim.api.nvim_win_is_valid(help_win) then
      vim.api.nvim_win_close(help_win, true)
    end
  end, { buffer = help_buf, silent = true })
  
  -- Also handle common keys explicitly
  local close_keys = {'<Esc>', 'q', '<CR>', '<Space>'}
  for _, key in ipairs(close_keys) do
    vim.keymap.set('n', key, function()
      if vim.api.nvim_win_is_valid(help_win) then
        vim.api.nvim_win_close(help_win, true)
      end
    end, { buffer = help_buf, silent = true })
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
    open_file(item.path, 'default', false) -- Don't close tree when using Enter
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
    open_file(item.path, 'default', false) -- Don't close tree when using 'l'
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

-- FzfLua integration for search
local function open_telescope_in_directory()
  local fzf_ok, fzf = pcall(require, 'fzf-lua')
  if not fzf_ok then
    vim.notify("FzfLua not available", vim.log.levels.WARN)
    return
  end
  
  -- Use current_root as the search directory
  fzf.files({
    cwd = current_root,
    winopts = {
      title = "Find Files in " .. vim.fn.fnamemodify(current_root, ":t"),
      height = 0.8,
      width = 0.8,
    },
    actions = {
      ["enter"] = function(selected)
        if selected and #selected > 0 then
          local sel = selected[1]
          if not is_absolute_path(sel) then
            sel = current_root .. '/' .. sel
          end
          open_file(sel, 'default', false)
        end
      end,
    },
  })
end

local function show_context_menu()
  local item = get_item_at_cursor()
  if not item then return end
  
  local menu_items = {}
  local menu_actions = {}
  
  -- Basic operations
  if item.type == "directory" then
    if item.is_parent then
      table.insert(menu_items, "Go to parent directory")
      table.insert(menu_actions, function() navigate_to_parent() end)
    else
      if item.expanded then
        table.insert(menu_items, "Collapse directory")
        table.insert(menu_actions, function() toggle_directory() end)
      else
        table.insert(menu_items, "Expand directory")
        table.insert(menu_actions, function() toggle_directory() end)
      end
    end
  else
    table.insert(menu_items, "Open file")
    table.insert(menu_actions, function() open_file(item.path, 'default', false) end)
    
    table.insert(menu_items, "Open in vertical split")
    table.insert(menu_actions, function() handle_vertical_split() end)
    
    table.insert(menu_items, "Open in horizontal split")
    table.insert(menu_actions, function() handle_horizontal_split() end)
  end
  
  if not item.is_parent then
    table.insert(menu_items, "---") -- Separator
    table.insert(menu_actions, nil)
    
    -- Copy operations
    table.insert(menu_items, "Copy relative path")
    table.insert(menu_actions, function() handle_copy_relative() end)
    
    table.insert(menu_items, "Copy absolute path")
    table.insert(menu_actions, function() handle_copy_absolute() end)
    
    -- GitHub link for files only
    if item.type ~= "directory" then
      table.insert(menu_items, "Copy GitHub link")
      table.insert(menu_actions, function() 
        local git_url = get_git_remote_url()
        if not git_url then
          print("Not a git repository or no remote origin found")
          return
        end
        
        local https_url = normalize_remote_to_https(git_url)
        if not https_url then
          print("Unsupported git URL format: " .. git_url)
          return
        end
        
        -- Get current branch (fallbacks)
        local branch = git_in_root("branch --show-current")
        if not branch or branch == '' then
          local ref = git_in_root("symbolic-ref --quiet --short refs/remotes/origin/HEAD") or ''
          branch = ref:match('origin/(.+)$') or 'main'
        end
        
        -- Get relative path from git root
        local git_root = git_in_root("rev-parse --show-toplevel")
        if not git_root or git_root == '' then
          print("Error getting git root")
          return
        end
        
        local relative_path = item.path:gsub("^" .. vim.fn.escape(git_root, "^$()%.[]*+-?" ) .. "/", "")
        local encoded_path = url_encode(relative_path)
        
        local github_url = https_url .. "/blob/" .. url_encode(branch) .. "/" .. encoded_path
        copy_to_clipboard(github_url)
      end)
      
      table.insert(menu_items, "Open in GitHub")
      table.insert(menu_actions, function() handle_github_open() end)
    end
    
    table.insert(menu_items, "---") -- Separator
    table.insert(menu_actions, nil)
    
    -- File operations
    table.insert(menu_items, "Rename")
    table.insert(menu_actions, function() rename_item() end)
    
    table.insert(menu_items, "Delete")
    table.insert(menu_actions, function() delete_item() end)
  end
  
  table.insert(menu_items, "---") -- Separator
  table.insert(menu_actions, nil)
  
  -- General operations
  table.insert(menu_items, "Create file")
  table.insert(menu_actions, function() create_file() end)
  
  table.insert(menu_items, "Create directory")
  table.insert(menu_actions, function() create_directory() end)
  
  table.insert(menu_items, "---") -- Separator
  table.insert(menu_actions, nil)
  
  table.insert(menu_items, "Search files")
  table.insert(menu_actions, function() open_telescope_in_directory() end)
  
  table.insert(menu_items, "Refresh tree")
  table.insert(menu_actions, function() M.refresh() end)
  
  table.insert(menu_items, "Toggle hidden files")
  table.insert(menu_actions, function() 
    config.show_hidden = not config.show_hidden
    clear_cache() -- Clear cache since hidden file setting changed
    M.refresh() 
  end)
  
  table.insert(menu_items, "Show help")
  table.insert(menu_actions, function() show_help() end)
  
  -- Create context menu buffer
  local menu_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(menu_buf, 'modifiable', true)
  vim.api.nvim_buf_set_lines(menu_buf, 0, -1, false, menu_items)
  vim.api.nvim_buf_set_option(menu_buf, 'modifiable', false)
  vim.api.nvim_buf_set_option(menu_buf, 'buftype', 'nofile')
  
  -- Calculate menu position near cursor
  local cursor = vim.api.nvim_win_get_cursor(tree_win)
  local width = 25
  local height = #menu_items
  local win_width = vim.api.nvim_win_get_width(tree_win)
  local win_height = vim.api.nvim_win_get_height(tree_win)
  
  -- Position menu to the right of the cursor, but within window bounds
  local col = math.min(win_width - width - 1, 15)
  local row = math.min(cursor[1] - 1, win_height - height - 1)
  
  -- Create floating window for context menu
  local menu_win = vim.api.nvim_open_win(menu_buf, true, {
    relative = 'win',
    win = tree_win,
    width = width,
    height = height,
    row = row,
    col = col,
    style = 'minimal',
    border = 'rounded',
    title = ' Context Menu ',
    title_pos = 'center'
  })
  
  -- Set window options
  vim.api.nvim_win_set_option(menu_win, 'wrap', false)
  vim.api.nvim_win_set_option(menu_win, 'cursorline', true)
  
  -- Set cursor to first non-separator item
  local first_item = 1
  for i, item_text in ipairs(menu_items) do
    if item_text ~= "---" then
      first_item = i
      break
    end
  end
  vim.api.nvim_win_set_cursor(menu_win, {first_item, 0})
  
  -- Handle menu navigation and selection
  local function close_menu()
    if vim.api.nvim_win_is_valid(menu_win) then
      vim.api.nvim_win_close(menu_win, true)
    end
  end
  
  local function execute_action()
    local menu_cursor = vim.api.nvim_win_get_cursor(menu_win)
    local selected_idx = menu_cursor[1]
    local action = menu_actions[selected_idx]
    
    close_menu()
    
    if action then
      action()
    end
  end
  
  local function move_to_next_valid_item(direction)
    local menu_cursor = vim.api.nvim_win_get_cursor(menu_win)
    local current_idx = menu_cursor[1]
    local next_idx = current_idx
    
    repeat
      next_idx = next_idx + direction
      if next_idx < 1 then
        next_idx = #menu_items
      elseif next_idx > #menu_items then
        next_idx = 1
      end
      
      if next_idx == current_idx then
        break -- Prevent infinite loop
      end
    until menu_items[next_idx] ~= "---"
    
    vim.api.nvim_win_set_cursor(menu_win, {next_idx, 0})
  end
  
  -- Menu key mappings
  local menu_opts = { buffer = menu_buf, silent = true }
  vim.keymap.set('n', '<CR>', execute_action, menu_opts)
  vim.keymap.set('n', '<Esc>', close_menu, menu_opts)
  vim.keymap.set('n', 'q', close_menu, menu_opts)
  vim.keymap.set('n', '<LeftMouse>', execute_action, menu_opts)
  vim.keymap.set('n', 'j', function() move_to_next_valid_item(1) end, menu_opts)
  vim.keymap.set('n', 'k', function() move_to_next_valid_item(-1) end, menu_opts)
  vim.keymap.set('n', '<Down>', function() move_to_next_valid_item(1) end, menu_opts)
  vim.keymap.set('n', '<Up>', function() move_to_next_valid_item(-1) end, menu_opts)
  
  -- Close menu when clicking outside
  vim.api.nvim_create_autocmd({"BufLeave", "WinLeave"}, {
    buffer = menu_buf,
    once = true,
    callback = close_menu
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
  
  -- Ensure mouse support is enabled globally for click functionality
  -- Do not change global mouse setting here; rely on user's config
  -- if vim.o.mouse == '' then
  --   vim.o.mouse = 'a'
  -- end
  
  -- Load tree data
  tree_data = scan_directory(current_root, 0)
  render_tree()
  
  -- Set up buffer protection to prevent replacement
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    buffer = tree_buf,
    callback = function()
      -- Prevent any command from replacing the SimpleTree buffer
      vim.api.nvim_buf_set_option(tree_buf, 'buftype', 'nofile')
      vim.api.nvim_buf_set_option(tree_buf, 'modifiable', false)
    end
  })
  
  -- Intercept common file opening commands and redirect them to a proper window
  vim.api.nvim_create_autocmd("BufReadCmd", {
    buffer = tree_buf,
    callback = function(args)
      -- If someone tries to open a file in the SimpleTree buffer, redirect it
      local file_path = args.file
      if file_path and file_path ~= '' and file_path ~= 'SimpleTree' then
        -- Find or create a suitable window for the file
        local wins = vim.api.nvim_list_wins()
        local target_win = nil
        
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
          vim.cmd('vsplit')
          target_win = vim.api.nvim_get_current_win()
        end
        
        vim.api.nvim_set_current_win(target_win)
        vim.cmd('edit ' .. vim.fn.fnameescape(file_path))
        return
      end
    end
  })

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
  vim.keymap.set('n', 'w', handle_github_open, opts)
  vim.keymap.set('n', 'u', function() navigate_to_parent() end, opts)  -- Go to parent directory
  vim.keymap.set('n', 'a', create_file, opts)
  vim.keymap.set('n', 'A', create_directory, opts)
  vim.keymap.set('n', 'r', rename_item, opts)
  vim.keymap.set('n', 'd', delete_item, opts)
  vim.keymap.set('n', '?', show_help, opts)
  
  -- Mouse support
  -- Mouse mappings are enabled only if user has mouse enabled in their config
  if vim.o.mouse ~= '' then
    vim.keymap.set('n', '<LeftMouse>', handle_enter, opts)  -- Left click opens file/toggles directory
    vim.keymap.set('n', '<RightMouse>', show_context_menu, opts)  -- Right click shows context menu
  end
  
  -- Override common file opening commands to prevent buffer replacement
  vim.keymap.set('n', '<leader>ff', function()
    -- Redirect fzf-lua to open in a proper window, not replace SimpleTree
    local fzf_ok, fzf = pcall(require, 'fzf-lua')
    if fzf_ok then
      -- Switch to a non-tree window first
      local wins = vim.api.nvim_list_wins()
      local target_win = nil
      
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
        vim.cmd('vsplit')
        target_win = vim.api.nvim_get_current_win()
      else
        vim.api.nvim_set_current_win(target_win)
      end
      
      fzf.files()
    end
  end, opts)
  
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