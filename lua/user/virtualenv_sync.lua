-- Virtual Environment Synchronization for CoC
-- Automatically syncs terminal virtualenv changes with CoC Python language server

local M = {}

-- Configuration
local config = {
  -- Common virtualenv directories to scan
  search_paths = {
    vim.fn.expand("~/.virtualenvs"),
    vim.fn.expand("~/.pyenv/versions"),
    vim.fn.expand("~/venv"),
    vim.fn.expand("~/virtualenvs"),
    "./venv",
    "./.venv",
    "./env",
    "./.env"
  },
  -- File to store current virtualenv state
  state_file = vim.fn.stdpath("cache") .. "/nvim_virtualenv_state",
  -- Polling interval in milliseconds
  poll_interval = 2000,
  -- Enable debug messages
  debug = false
}

-- Internal state
local current_virtualenv = nil
local timer = nil
local last_state_check = 0

-- Debug logging
local function debug_log(msg)
  if config.debug then
    print("[VirtualEnv Sync] " .. msg)
  end
end

-- Get current virtualenv from environment and state file
local function get_current_virtualenv()
  -- First, try to get from current Neovim environment
  local virtual_env = vim.fn.getenv("VIRTUAL_ENV")
  if virtual_env and virtual_env ~= vim.NIL and virtual_env ~= "" then
    return virtual_env
  end
  
  -- If not found, try to read from state file (updated by shell integration)
  local state = load_state()
  if state and state ~= "" then
    -- Verify the virtualenv still exists and is valid
    local python_path = state .. "/bin/python"
    if vim.fn.executable(python_path) == 1 then
      return state
    end
  end
  
  -- Try to detect from parent shell process (if running in terminal)
  if vim.fn.exists("$NVIM") == 1 then
    local handle = io.popen("ps -o pid,ppid,command -p $PPID 2>/dev/null | grep -E '(bash|zsh|fish)' | head -1")
    if handle then
      local line = handle:read("*line")
      handle:close()
      if line then
        -- Try to get VIRTUAL_ENV from parent shell
        local parent_pid = line:match("(%d+)%s+%d+")
        if parent_pid then
          local env_handle = io.popen("ps eww " .. parent_pid .. " 2>/dev/null | tr ' ' '\\n' | grep '^VIRTUAL_ENV=' | cut -d= -f2-")
          if env_handle then
            local venv_path = env_handle:read("*line")
            env_handle:close()
            if venv_path and venv_path ~= "" then
              return venv_path
            end
          end
        end
      end
    end
  end
  
  return nil
end

-- Find all available virtualenvs
local function find_virtualenvs()
  local virtualenvs = {}
  
  for _, path in ipairs(config.search_paths) do
    local expanded_path = vim.fn.expand(path)
    if vim.fn.isdirectory(expanded_path) == 1 then
      local handle = io.popen("find '" .. expanded_path .. "' -name 'pyvenv.cfg' -o -name 'activate' | head -20")
      if handle then
        for line in handle:lines() do
          local venv_path
          if line:match("pyvenv%.cfg$") then
            venv_path = vim.fn.fnamemodify(line, ":h")
          elseif line:match("activate$") then
            venv_path = vim.fn.fnamemodify(line, ":h:h")
          end
          
          if venv_path and vim.fn.isdirectory(venv_path) == 1 then
            local python_path = venv_path .. "/bin/python"
            if vim.fn.executable(python_path) == 1 then
              local name = vim.fn.fnamemodify(venv_path, ":t")
              table.insert(virtualenvs, {
                name = name,
                path = venv_path,
                python_path = python_path
              })
            end
          end
        end
        handle:close()
      end
    end
  end
  
  -- Add system python
  local system_python = vim.fn.exepath("python3") or vim.fn.exepath("python")
  if system_python then
    table.insert(virtualenvs, {
      name = "system",
      path = "/usr",
      python_path = system_python
    })
  end
  
  return virtualenvs
end

-- Update CoC python path
local function update_coc_python(python_path)
  if not python_path then
    debug_log("No python path provided")
    return false
  end
  
  debug_log("Updating CoC python path to: " .. python_path)
  
  -- Update CoC configuration
  vim.fn['coc#config']('python.pythonPath', python_path)
  
  -- Restart Python language server
  vim.defer_fn(function()
    vim.fn.CocRestart()
  end, 500)
  
  return true
end

-- Save current state
local function save_state(venv_path)
  local file = io.open(config.state_file, "w")
  if file then
    file:write(venv_path or "")
    file:close()
  end
end

-- Load saved state
local function load_state()
  local file = io.open(config.state_file, "r")
  if file then
    local content = file:read("*all")
    file:close()
    return content ~= "" and content or nil
  end
  return nil
end

-- Check if state file has been updated
local function has_state_file_changed()
  local timestamp_file = config.state_file .. ".timestamp"
  if vim.fn.filereadable(timestamp_file) == 1 then
    local timestamp = tonumber(vim.fn.readfile(timestamp_file)[1] or "0")
    if timestamp > last_state_check then
      last_state_check = timestamp
      return true
    end
  end
  return false
end

-- Check for virtualenv changes and prompt user
local function check_virtualenv_change()
  -- Check if state file was updated (faster check)
  local state_changed = has_state_file_changed()
  
  local new_venv = get_current_virtualenv()
  
  if new_venv ~= current_virtualenv or state_changed then
    debug_log("Virtualenv change detected: " .. (current_virtualenv or "none") .. " -> " .. (new_venv or "none"))
    
    if new_venv then
      local python_path = new_venv .. "/bin/python"
      if vim.fn.executable(python_path) == 1 then
        -- Ask user if they want to sync
        vim.schedule(function()
          local choice = vim.fn.confirm(
            "Virtual environment changed to:\n" .. new_venv .. "\n\nUpdate CoC Python path?",
            "&Yes\n&No",
            1
          )
          
          if choice == 1 then
            update_coc_python(python_path)
            save_state(new_venv)
            vim.notify("CoC Python updated to: " .. new_venv, vim.log.levels.INFO)
          end
        end)
      end
    else
      -- Virtualenv deactivated, ask if should revert to system python
      vim.schedule(function()
        local choice = vim.fn.confirm(
          "Virtual environment deactivated.\n\nRevert CoC to system Python?",
          "&Yes\n&No",
          1
        )
        
        if choice == 1 then
          local system_python = vim.fn.exepath("python3") or vim.fn.exepath("python")
          if system_python then
            update_coc_python(system_python)
            save_state(nil)
            vim.notify("CoC Python reverted to system Python", vim.log.levels.INFO)
          end
        end
      end)
    end
    
    current_virtualenv = new_venv
  end
end

-- Start monitoring for virtualenv changes
function M.start_monitoring()
  if timer then
    timer:stop()
    timer:close()
  end
  
  current_virtualenv = get_current_virtualenv()
  debug_log("Starting virtualenv monitoring. Current: " .. (current_virtualenv or "none"))
  
  timer = vim.loop.new_timer()
  timer:start(config.poll_interval, config.poll_interval, vim.schedule_wrap(check_virtualenv_change))
end

-- Stop monitoring
function M.stop_monitoring()
  if timer then
    timer:stop()
    timer:close()
    timer = nil
  end
  debug_log("Stopped virtualenv monitoring")
end

-- Manual virtualenv picker
function M.pick_virtualenv()
  local virtualenvs = find_virtualenvs()
  
  if #virtualenvs == 0 then
    vim.notify("No virtual environments found", vim.log.levels.WARN)
    return
  end
  
  -- Create selection list
  local items = {}
  for i, venv in ipairs(virtualenvs) do
    table.insert(items, string.format("%d. %s (%s)", i, venv.name, venv.path))
  end
  
  vim.ui.select(items, {
    prompt = "Select Virtual Environment:",
    format_item = function(item)
      return item
    end
  }, function(choice, idx)
    if choice and idx then
      local selected_venv = virtualenvs[idx]
      debug_log("Selected virtualenv: " .. selected_venv.name)
      
      update_coc_python(selected_venv.python_path)
      save_state(selected_venv.path ~= "/usr" and selected_venv.path or nil)
      
      vim.notify("CoC Python updated to: " .. selected_venv.name, vim.log.levels.INFO)
    end
  end)
end

-- Get current virtualenv info
function M.get_current_info()
  local venv = get_current_virtualenv()
  local python_path = vim.fn['coc#util#get_config']('python').pythonPath or "system"
  
  return {
    terminal_venv = venv,
    coc_python = python_path,
    is_synced = (venv and (venv .. "/bin/python") == python_path) or 
                (not venv and python_path:match("/usr/bin/python"))
  }
end

-- Setup function
function M.setup(opts)
  config = vim.tbl_deep_extend("force", config, opts or {})
  
  -- Ensure cache directory exists
  vim.fn.mkdir(vim.fn.fnamemodify(config.state_file, ":h"), "p")
  
  -- Start monitoring if enabled
  if config.auto_monitor ~= false then
    M.start_monitoring()
  end
  
  -- Create user commands
  vim.api.nvim_create_user_command("VirtualEnvPick", function()
    M.pick_virtualenv()
  end, { desc = "Pick virtual environment for CoC" })
  
  vim.api.nvim_create_user_command("VirtualEnvInfo", function()
    local info = M.get_current_info()
    local msg = string.format(
      "Terminal VEnv: %s\nCoC Python: %s\nSynced: %s",
      info.terminal_venv or "none",
      info.coc_python,
      info.is_synced and "✓" or "✗"
    )
    vim.notify(msg, vim.log.levels.INFO)
  end, { desc = "Show virtual environment sync status" })
  
  vim.api.nvim_create_user_command("VirtualEnvSync", function()
    check_virtualenv_change()
  end, { desc = "Manually check and sync virtual environment" })
  
  vim.api.nvim_create_user_command("VirtualEnvToggleMonitoring", function()
    if timer then
      M.stop_monitoring()
      vim.notify("VirtualEnv monitoring stopped", vim.log.levels.INFO)
    else
      M.start_monitoring()
      vim.notify("VirtualEnv monitoring started", vim.log.levels.INFO)
    end
  end, { desc = "Toggle virtual environment monitoring" })
end

return M