local M = {}

-- Configuration
local config = {
  enabled = false,
  current_line_only = false,
  align = "below", -- "after" or "below"
  prefix = "  ▎ ",
  format = function(diagnostic)
    local severity_icons = {
      Error = "●",
      Warning = "●",
      Information = "●",
      Hint = "●"
    }
    local icon = severity_icons[diagnostic.severity] or "●"
    return string.format("%s %s", icon, diagnostic.message)
  end
}

-- State tracking
local virtual_lines_ns = vim.api.nvim_create_namespace("coc_virtual_lines")
local current_buffer_diagnostics = {}

-- Helper function to check if COC is available
local function is_coc_available()
  return vim.fn.exists('*CocAction') == 1
end

-- Helper function to get coc diagnostics for current buffer
local function get_coc_diagnostics()
  if not is_coc_available() then
    return {}
  end
  
  local ok, diagnostics = pcall(vim.fn.CocAction, 'diagnosticList')
  if not ok or not diagnostics or vim.tbl_isempty(diagnostics) then
    return {}
  end
  
  -- Filter for current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  local current_file = vim.api.nvim_buf_get_name(current_buf)
  local filtered_diagnostics = {}
  
  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.file == current_file then
      table.insert(filtered_diagnostics, diagnostic)
    end
  end
  
  return filtered_diagnostics
end

-- Helper function to clear virtual lines
local function clear_virtual_lines(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(bufnr, virtual_lines_ns, 0, -1)
end

-- Helper function to show virtual lines
local function show_virtual_lines(bufnr)
  if not config.enabled then
    return
  end
  
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  clear_virtual_lines(bufnr)
  
  local diagnostics = get_coc_diagnostics()
  if vim.tbl_isempty(diagnostics) then
    return
  end
  
  -- Group diagnostics by line
  local diagnostics_by_line = {}
  for _, diagnostic in ipairs(diagnostics) do
    -- COC diagnostic lnum is 0-based; extmarks also expect 0-based
    local line_0based = (diagnostic.lnum or 0)
    
    if not diagnostics_by_line[line_0based] then
      diagnostics_by_line[line_0based] = {}
    end
    table.insert(diagnostics_by_line[line_0based], diagnostic)
  end
  
  -- If current_line_only is enabled, filter to current line
  if config.current_line_only then
    local cursor_line = vim.api.nvim_win_get_cursor(0)[1] - 1
    local temp = {}
    if diagnostics_by_line[cursor_line] then
      temp[cursor_line] = diagnostics_by_line[cursor_line]
    end
    diagnostics_by_line = temp
  end
  
  -- Create virtual lines
  for line, line_diagnostics in pairs(diagnostics_by_line) do
    for i, diagnostic in ipairs(line_diagnostics) do
      local formatted_text = config.format(diagnostic)
      local virtual_text = {{config.prefix .. formatted_text, "CocErrorVirtualText"}}
      
      -- Determine highlight group based on severity
      local hl_group = "CocErrorVirtualText"
      if diagnostic.severity == "Warning" then
        hl_group = "CocWarningVirtualText"
      elseif diagnostic.severity == "Information" then
        hl_group = "CocInfoVirtualText"
      elseif diagnostic.severity == "Hint" then
        hl_group = "CocHintVirtualText"
      end
      
      virtual_text[1][2] = hl_group
      
      -- Place virtual line below the diagnostic line
      local virt_line_pos = line + i
      vim.api.nvim_buf_set_extmark(bufnr, virtual_lines_ns, line, 0, {
        virt_lines = {virtual_text},
        virt_lines_above = false
      })
    end
  end
end

-- Function to toggle virtual lines
function M.toggle()
  config.enabled = not config.enabled
  
  if config.enabled then
    show_virtual_lines()
    vim.notify("COC Virtual Lines: enabled", vim.log.levels.INFO)
  else
    clear_virtual_lines()
    vim.notify("COC Virtual Lines: disabled", vim.log.levels.INFO)
  end
  
  return config.enabled
end

-- Function to toggle current line only mode
function M.toggle_current_line_only()
  config.current_line_only = not config.current_line_only
  
  if config.enabled then
    show_virtual_lines()
  end
  
  vim.notify("COC Virtual Lines Current Line Only: " .. (config.current_line_only and "enabled" or "disabled"), vim.log.levels.INFO)
  return config.current_line_only
end

-- Function to set alignment
function M.set_align(align)
  if align ~= "after" and align ~= "below" then
    vim.notify("Invalid alignment. Use 'after' or 'below'", vim.log.levels.ERROR)
    return
  end
  
  config.align = align
  if config.enabled then
    show_virtual_lines()
  end
  
  vim.notify("COC Virtual Lines alignment: " .. align, vim.log.levels.INFO)
end

-- Function to enable virtual lines
function M.enable()
  config.enabled = true
  show_virtual_lines()
  vim.notify("COC Virtual Lines: enabled", vim.log.levels.INFO)
end

-- Function to disable virtual lines
function M.disable()
  config.enabled = false
  clear_virtual_lines()
  vim.notify("COC Virtual Lines: disabled", vim.log.levels.INFO)
end

-- Function to refresh virtual lines
function M.refresh()
  if config.enabled then
    show_virtual_lines()
  end
end

-- Function to get current state
function M.is_enabled()
  return config.enabled
end

function M.is_current_line_only()
  return config.current_line_only
end

-- Setup function
function M.setup(user_config)
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end
  
  -- Set up highlight groups if they don't exist
  local highlights = {
    CocErrorVirtualText = { fg = "#f85149", italic = true },
    CocWarningVirtualText = { fg = "#f0883e", italic = true },
    CocInfoVirtualText = { fg = "#56d4dd", italic = true },
    CocHintVirtualText = { fg = "#8b949e", italic = true }
  }
  
  for group, opts in pairs(highlights) do
    if vim.fn.hlID(group) == 0 then
      vim.api.nvim_set_hl(0, group, opts)
    end
  end
  
  -- Set up autocommands for automatic refresh
  local augroup = vim.api.nvim_create_augroup("CocVirtualLines", { clear = true })
  
  -- Refresh on diagnostic changes
  vim.api.nvim_create_autocmd("User", {
    group = augroup,
    pattern = "CocDiagnosticChange",
    callback = function()
      if config.enabled then
        vim.defer_fn(function()
          show_virtual_lines()
        end, 100)
      end
    end
  })
  
  -- Refresh on cursor move if current_line_only is enabled
  vim.api.nvim_create_autocmd("CursorMoved", {
    group = augroup,
    callback = function()
      if config.enabled and config.current_line_only then
        show_virtual_lines()
      end
    end
  })
  
  -- Clear virtual lines when leaving buffer
  vim.api.nvim_create_autocmd("BufLeave", {
    group = augroup,
    callback = function()
      clear_virtual_lines()
    end
  })
  
  -- Refresh when entering buffer
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    callback = function()
      if config.enabled then
        vim.defer_fn(function()
          show_virtual_lines()
        end, 100)
      end
    end
  })
end

return M