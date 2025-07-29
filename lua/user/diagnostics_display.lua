local M = {}

local icons = require("user.icons")

-- Configuration
local config = {
  border = "rounded",
  width = 80,
  height = 20,
  title_current_line = "  Current Line Diagnostics",
  title_current_file = "  Current File Diagnostics",
  max_width = 120,
  max_height = 30,
}

-- Diagnostic severity mapping
local severity_map = {
  [vim.diagnostic.severity.ERROR] = {
    icon = icons.diagnostics.Error,
    name = "Error",
    hl = "DiagnosticError"
  },
  [vim.diagnostic.severity.WARN] = {
    icon = icons.diagnostics.Warning,
    name = "Warning", 
    hl = "DiagnosticWarn"
  },
  [vim.diagnostic.severity.INFO] = {
    icon = icons.diagnostics.Information,
    name = "Info",
    hl = "DiagnosticInfo"
  },
  [vim.diagnostic.severity.HINT] = {
    icon = icons.diagnostics.Hint,
    name = "Hint",
    hl = "DiagnosticHint"
  }
}

-- Helper function to format diagnostic message
local function format_diagnostic(diagnostic, show_line_info)
  local severity_info = severity_map[diagnostic.severity] or {
    icon = "?", 
    name = "Unknown", 
    hl = "Normal"
  }
  
  local line_info = ""
  if show_line_info and diagnostic.lnum then
    line_info = string.format("Line %d, Col %d: ", diagnostic.lnum + 1, diagnostic.col + 1)
  end
  
  local source_info = ""
  if diagnostic.source then
    source_info = string.format(" [%s]", diagnostic.source)
  end
  
  local code_info = ""
  if diagnostic.code then
    code_info = string.format(" (%s)", diagnostic.code)
  end
  
  return {
    icon = severity_info.icon,
    severity = severity_info.name,
    hl = severity_info.hl,
    line_info = line_info,
    message = diagnostic.message,
    source_info = source_info,
    code_info = code_info,
    full_text = string.format("%s %s: %s%s%s%s", 
      severity_info.icon, 
      severity_info.name,
      line_info,
      diagnostic.message,
      code_info,
      source_info
    )
  }
end

-- Helper function to create buffer content
local function create_buffer_content(diagnostics, title, show_line_info)
  local content = {}
  local highlights = {}
  
  -- Add title
  table.insert(content, title)
  table.insert(content, string.rep("─", #title))
  table.insert(content, "")
  
  if #diagnostics == 0 then
    table.insert(content, "  No diagnostics found")
    return content, highlights
  end
  
  -- Group diagnostics by severity
  local grouped = {
    [vim.diagnostic.severity.ERROR] = {},
    [vim.diagnostic.severity.WARN] = {},
    [vim.diagnostic.severity.INFO] = {},
    [vim.diagnostic.severity.HINT] = {}
  }
  
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(grouped[diagnostic.severity], diagnostic)
  end
  
  -- Add diagnostics by severity (errors first)
  for _, severity in ipairs({
    vim.diagnostic.severity.ERROR,
    vim.diagnostic.severity.WARN, 
    vim.diagnostic.severity.INFO,
    vim.diagnostic.severity.HINT
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
  
  return content, highlights
end

-- Helper function to create and show the diagnostic buffer
local function show_diagnostic_buffer(diagnostics, title, show_line_info)
  local content, highlights = create_buffer_content(diagnostics, title, show_line_info)
  
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
  
  -- Set keymaps for the buffer
  local opts = { noremap = true, silent = true, buffer = buf }
  vim.keymap.set("n", "q", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", opts)
  vim.keymap.set("n", "<CR>", function()
    local line_num = vim.api.nvim_win_get_cursor(win)[1]
    -- Try to find diagnostic info in the current line to jump to it
    -- This is a simple implementation - could be enhanced
    vim.cmd("close")
  end, opts)
  
  return buf, win
end

-- Show diagnostics for current line
function M.show_current_line_diagnostics()
  local line = vim.api.nvim_win_get_cursor(0)[1] - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = line })
  
  show_diagnostic_buffer(
    diagnostics, 
    config.title_current_line, 
    false -- don't show line info since it's all the same line
  )
end

-- Show diagnostics for current file
function M.show_current_file_diagnostics()
  local diagnostics = vim.diagnostic.get(0)
  
  show_diagnostic_buffer(
    diagnostics, 
    config.title_current_file, 
    true -- show line info since diagnostics are from different lines
  )
end

-- Setup function to configure the plugin
function M.setup(user_config)
  if user_config then
    config = vim.tbl_deep_extend("force", config, user_config)
  end
end

return M