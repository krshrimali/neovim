local M = {}

local icons = require("user.icons")

-- Configuration
local config = {
  border = "rounded",
  width = 80,
  height = 20,
  title_current_line = "  Current Line Diagnostics (COC)",
  title_current_file = "  Current File Diagnostics (COC)",
  max_width = 120,
  max_height = 30,
}

-- COC diagnostic severity mapping
local severity_map = {
  ["Error"] = {
    icon = icons.diagnostics.Error,
    name = "Error",
    hl = "CocErrorSign"
  },
  ["Warning"] = {
    icon = icons.diagnostics.Warning,
    name = "Warning", 
    hl = "CocWarningSign"
  },
  ["Information"] = {
    icon = icons.diagnostics.Information,
    name = "Info",
    hl = "CocInfoSign"
  },
  ["Hint"] = {
    icon = icons.diagnostics.Hint,
    name = "Hint",
    hl = "CocHintSign"
  },
  -- Fallback mappings for lowercase
  ["error"] = {
    icon = icons.diagnostics.Error,
    name = "Error",
    hl = "CocErrorSign"
  },
  ["warning"] = {
    icon = icons.diagnostics.Warning,
    name = "Warning", 
    hl = "CocWarningSign"
  },
  ["information"] = {
    icon = icons.diagnostics.Information,
    name = "Info",
    hl = "CocInfoSign"
  },
  ["hint"] = {
    icon = icons.diagnostics.Hint,
    name = "Hint",
    hl = "CocHintSign"
  }
}

-- Helper function to check if COC is available
local function is_coc_available()
  return vim.fn.exists('*CocAction') == 1
end

-- Debug function to inspect COC diagnostic structure
local function debug_coc_diagnostics()
  if not is_coc_available() then
    print("COC not available")
    return
  end
  
  local ok, diagnostics = pcall(vim.fn.CocAction, 'diagnosticList')
  if ok and diagnostics and #diagnostics > 0 then
    print("COC Diagnostics found:", #diagnostics)
    print("First diagnostic structure:")
    print(vim.inspect(diagnostics[1]))
    
    -- Check if current window is valid before getting cursor position
    local current_win = vim.api.nvim_get_current_win()
    if not vim.api.nvim_win_is_valid(current_win) then
      print("Current window is not valid")
      return {}
    end
    
    local cursor_pos = vim.api.nvim_win_get_cursor(current_win)
    local current_line_1based = cursor_pos[1]
    local current_line_0based = cursor_pos[1] - 1
    print("Current cursor position (1-based):", current_line_1based)
    print("Current cursor position (0-based):", current_line_0based)
    
    -- Filter diagnostics for current buffer
    local current_file = vim.api.nvim_buf_get_name(0)
    local buffer_diagnostics = {}
    for _, diag in ipairs(diagnostics) do
      if diag.file == current_file then
        table.insert(buffer_diagnostics, diag)
      end
    end
    print("Buffer diagnostics found:", #buffer_diagnostics)
    
    for i, diag in ipairs(buffer_diagnostics) do
      if i <= 5 then -- Show first 5 diagnostics
        print(string.format("Diagnostic %d: lnum=%s (display: Line %d), col=%s, severity=%s", 
          i, 
          diag.lnum or "nil",
          (diag.lnum and (diag.lnum + 1)) or "nil",
          diag.col or "nil",
          diag.severity or "nil"
        ))
      end
    end
    
    -- Test current line filtering
    local line_diagnostics = {}
    for _, diag in ipairs(buffer_diagnostics) do
      if diag.lnum == current_line_0based then
        table.insert(line_diagnostics, diag)
      end
    end
    print("Line diagnostics found for current line (0-based " .. current_line_0based .. "):", #line_diagnostics)
  else
    print("No COC diagnostics found or error:", diagnostics)
  end
end

-- Helper function to get COC diagnostics for current buffer
local function get_coc_diagnostics()
  if not is_coc_available() then
    vim.notify("COC.nvim is not available", vim.log.levels.ERROR)
    return {}
  end
  
  -- Get COC diagnostics using CocAction
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

-- Helper function to get COC diagnostics for current line
local function get_coc_line_diagnostics()
  if not is_coc_available() then
    vim.notify("COC.nvim is not available", vim.log.levels.ERROR)
    return {}
  end
  
  -- Check if current window is valid before getting cursor position
  local current_win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(current_win) then
    return {}
  end
  
  local cursor_pos = vim.api.nvim_win_get_cursor(current_win)
  local current_line_1based = cursor_pos[1]
  local current_line_0based = cursor_pos[1] - 1
  
  -- Get all diagnostics and filter for current line
  local all_diagnostics = get_coc_diagnostics()
  local line_diagnostics = {}
  
  -- Debug: print what we're looking for
  -- print(string.format("Looking for diagnostics on line %d (1-based) / %d (0-based)", current_line_1based, current_line_0based))
  
  for _, diagnostic in ipairs(all_diagnostics) do
    local diag_line = diagnostic.lnum
    
    -- Debug: print diagnostic line numbers
    -- if diag_line ~= nil then
    --   print(string.format("Found diagnostic on lnum=%d (display: Line %d)", diag_line, diag_line + 1))
    -- end
    
    -- COC diagnostic lnum is 0-based; compare with 0-based cursor line
    if diag_line ~= nil and diag_line == current_line_0based then
      table.insert(line_diagnostics, diagnostic)
    end
  end
  
  -- Debug: print results
  -- print(string.format("Found %d diagnostics for current line", #line_diagnostics))
  
  return line_diagnostics
end

-- Helper function to format COC diagnostic message
local function format_diagnostic(diagnostic, show_line_info)
  -- Based on debug output, COC diagnostics have 'severity' field as string like "Warning"
  local severity = diagnostic.severity or "Error"
  local severity_info = severity_map[severity] or {
    icon = "?", 
    name = "Unknown", 
    hl = "Normal"
  }
  
  local line_info = ""
  -- Test: COC diagnostics might use 'lnum' (1-based) and 'col' (0-based)
  if show_line_info and diagnostic.lnum ~= nil then
    -- lnum from COC is 0-based; display as 1-based
    line_info = string.format("Line %d, Col %d: ", (diagnostic.lnum + 1), (diagnostic.col or 0) + 1)
  end
  
  local source_info = ""
  if diagnostic.source then
    source_info = string.format(" [%s]", diagnostic.source)
  end
  
  local code_info = ""
  if diagnostic.code then
    code_info = string.format(" (%s)", diagnostic.code)
  end
  
  local message = diagnostic.message or "No message"
  
  return {
    icon = severity_info.icon,
    severity = severity_info.name,
    hl = severity_info.hl,
    line_info = line_info,
    message = message,
    source_info = source_info,
    code_info = code_info,
    full_text = string.format("%s %s: %s%s%s%s", 
      severity_info.icon, 
      severity_info.name,
      line_info,
      message,
      code_info,
      source_info
    )
  }
end

-- Helper function to create buffer content
local function create_buffer_content(diagnostics, title, show_line_info)
  local content = {}
  local highlights = {}
  local diagnostic_map = {} -- Map line numbers to diagnostics for navigation
  
  -- Add title
  table.insert(content, title)
  table.insert(content, string.rep("─", #title))
  table.insert(content, "")
  
  if #diagnostics == 0 then
    table.insert(content, "  No diagnostics found")
    return content, highlights, diagnostic_map
  end
  
  -- Group diagnostics by severity
  local grouped = {
    ["Error"] = {},
    ["Warning"] = {},
    ["Information"] = {},
    ["Hint"] = {},
    -- Fallbacks for lowercase
    ["error"] = {},
    ["warning"] = {},
    ["information"] = {},
    ["hint"] = {}
  }
  
  for _, diagnostic in ipairs(diagnostics) do
    local severity = diagnostic.severity or "Error"
    if grouped[severity] then
      table.insert(grouped[severity], diagnostic)
    else
      table.insert(grouped["Error"], diagnostic) -- fallback to error
    end
  end
  
  -- Add diagnostics by severity (errors first) - check both cases
  for _, severity in ipairs({
    "Error", "error",
    "Warning", "warning", 
    "Information", "information",
    "Hint", "hint"
  }) do
    local group = grouped[severity]
    if #group > 0 then
      local severity_info = severity_map[severity]
      local section_title = string.format("%s %s (%d)", 
        severity_info.icon, 
        severity_info.name, 
        #group
      )
      
      table.insert(content, section_title)
      table.insert(highlights, {
        line = #content - 1,
        col_start = 0,
        col_end = #section_title,
        hl_group = severity_info.hl
      })
      
      table.insert(content, string.rep("─", #section_title))
      table.insert(content, "")
      
      for _, diagnostic in ipairs(group) do
        local formatted = format_diagnostic(diagnostic, show_line_info)
        
        -- Add the main diagnostic line
        local main_line = string.format("  %s", formatted.full_text)
        table.insert(content, main_line)
        
        -- Store diagnostic info for navigation (map content line to diagnostic)
        diagnostic_map[#content] = diagnostic
        
        -- Highlight the icon and severity
        table.insert(highlights, {
          line = #content - 1,
          col_start = 2,
          col_end = 2 + #formatted.icon + 1 + #formatted.severity,
          hl_group = formatted.hl
        })
        
        -- Add empty line for spacing
        table.insert(content, "")
      end
    end
  end
  
  -- Add summary
  table.insert(content, "")
  table.insert(content, string.rep("─", 40))
  local summary = string.format("Total: %d diagnostics", #diagnostics)
  table.insert(content, summary)
  
  return content, highlights, diagnostic_map
end

-- Helper function to create and show the diagnostic buffer
local function show_diagnostic_buffer(diagnostics, title, show_line_info)
  local content, highlights, diagnostic_map = create_buffer_content(diagnostics, title, show_line_info)
  
  -- Calculate window dimensions
  local max_line_length = 0
  for _, line in ipairs(content) do
    if #line > max_line_length then
      max_line_length = #line
    end
  end
  
  local width = math.min(math.max(max_line_length + 4, config.width), config.max_width)
  local height = math.min(math.max(#content + 2, config.height), config.max_height)
  
  -- Create buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "diagnostics")
  
  -- Apply highlights
  local ns_id = vim.api.nvim_create_namespace("diagnostics_display")
  for _, hl in ipairs(highlights) do
    vim.api.nvim_buf_add_highlight(buf, ns_id, hl.hl_group, hl.line, hl.col_start, hl.col_end)
  end
  
  -- Calculate window position (center of screen)
  local ui = vim.api.nvim_list_uis()[1]
  local win_row = math.floor((ui.height - height) / 2)
  local win_col = math.floor((ui.width - width) / 2)
  
  -- Create window
  local win_opts = {
    relative = "editor",
    width = width,
    height = height,
    row = win_row,
    col = win_col,
    style = "minimal",
    border = config.border,
    title = title,
    title_pos = "center",
  }
  
  local win = vim.api.nvim_open_win(buf, true, win_opts)
  
  -- Set window options
  vim.api.nvim_win_set_option(win, "wrap", true)
  vim.api.nvim_win_set_option(win, "cursorline", true)
  
  -- Helper function to navigate to diagnostic
  local function navigate_to_diagnostic()
    -- Check if window is still valid
    if not vim.api.nvim_win_is_valid(win) then
      return
    end
    
    local cursor_line = vim.api.nvim_win_get_cursor(win)[1]
    local diagnostic = diagnostic_map[cursor_line]
    
    if diagnostic then
      -- Close the diagnostic window first
      vim.cmd("close")
      
      -- Navigate to the diagnostic location
      -- Test: COC diagnostics might use 'lnum' (1-based) and 'col' (0-based)
      local target_line = diagnostic.lnum
      local target_col = diagnostic.col or 0
      
      if target_line ~= nil then
        -- COC lnum is 0-based; win_set_cursor expects 1-based
        vim.api.nvim_win_set_cursor(0, {target_line + 1, target_col})
        
        -- Center the line on screen
        vim.cmd("normal! zz")
        
        -- Flash the line to show where we jumped
        vim.defer_fn(function()
          local ns_id = vim.api.nvim_create_namespace("diagnostic_jump_flash")
          -- Highlight uses 0-based line numbers
          vim.api.nvim_buf_add_highlight(0, ns_id, "Search", target_line, 0, -1)
          vim.defer_fn(function()
            vim.api.nvim_buf_clear_namespace(0, ns_id, 0, -1)
          end, 500)
        end, 10)
      else
        vim.notify("Could not determine diagnostic location", vim.log.levels.WARN)
      end
    else
      -- No diagnostic on this line, just close
      vim.cmd("close")
    end
  end
  
  -- Set keymaps for the buffer
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "<CR>", navigate_to_diagnostic, opts)
  
  return buf, win
end

-- Show diagnostics for current line
function M.show_current_line_diagnostics()
  local diagnostics = get_coc_line_diagnostics()
  
  show_diagnostic_buffer(
    diagnostics, 
    config.title_current_line, 
    false -- don't show line info since it's all the same line
  )
end

-- Show diagnostics for current file
function M.show_current_file_diagnostics()
  local diagnostics = get_coc_diagnostics()
  
  show_diagnostic_buffer(
    diagnostics, 
    config.title_current_file, 
    true -- show line info since diagnostics are from different lines
  )
end

-- Debug function for troubleshooting
function M.debug()
  debug_coc_diagnostics()
end

-- Temporary debug function to test line number assumptions
function M.test_line_numbers()
  if not is_coc_available() then
    print("COC not available")
    return
  end
  
  -- Check if current window is valid before getting cursor position
  local current_win = vim.api.nvim_get_current_win()
  if not vim.api.nvim_win_is_valid(current_win) then
    print("Current window is not valid")
    return
  end
  
  local cursor_pos = vim.api.nvim_win_get_cursor(current_win)
  local current_line_1based = cursor_pos[1]
  local current_line_0based = cursor_pos[1] - 1
  
  print("=== LINE NUMBER TEST ===")
  print("Cursor position (1-based):", current_line_1based)
  print("Cursor position (0-based):", current_line_0based)
  
  local all_diagnostics = get_coc_diagnostics()
  print("Total buffer diagnostics:", #all_diagnostics)
  
  -- Test both 0-based and 1-based matching
  local matches_0based = 0
  local matches_1based = 0
  
  for _, diag in ipairs(all_diagnostics) do
    if diag.lnum == current_line_0based then
      matches_0based = matches_0based + 1
    end
    if diag.lnum == current_line_1based then
      matches_1based = matches_1based + 1
    end
  end
  
  print("Diagnostics matching current line (0-based):", matches_0based)
  print("Diagnostics matching current line (1-based):", matches_1based)
  
  -- Show nearby diagnostics
  print("Nearby diagnostics:")
  for _, diag in ipairs(all_diagnostics) do
    local diff_0based = math.abs(diag.lnum - current_line_0based)
    local diff_1based = math.abs(diag.lnum - current_line_1based)
    if diff_0based <= 2 or diff_1based <= 2 then
      print(string.format("  lnum=%d (display: Line %d), distance from cursor: 0-based=%d, 1-based=%d", 
        diag.lnum, diag.lnum + 1, diff_0based, diff_1based))
    end
  end
end

-- Setup function to configure the plugin
function M.setup(user_config)
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end
end

return M