local M = {}

local icons = require "user.icons"

-- Configuration
local config = {
  border = "rounded",
  width = 80,
  height = 20,
  title_current_line = "  Current Line Diagnostics (LSP)",
  title_current_file = "  Current File Diagnostics (LSP)",
  max_width = 120,
  max_height = 30,
}

-- Native LSP diagnostic severity mapping
local severity_map = {
  [vim.diagnostic.severity.ERROR] = {
    icon = icons.diagnostics.Error,
    name = "Error",
    hl = "DiagnosticError",
  },
  [vim.diagnostic.severity.WARN] = {
    icon = icons.diagnostics.Warning,
    name = "Warning",
    hl = "DiagnosticWarn",
  },
  [vim.diagnostic.severity.INFO] = {
    icon = icons.diagnostics.Information,
    name = "Info",
    hl = "DiagnosticInfo",
  },
  [vim.diagnostic.severity.HINT] = {
    icon = icons.diagnostics.Hint,
    name = "Hint",
    hl = "DiagnosticHint",
  },
}

-- Create floating window for diagnostics
local function create_float_win(content, title)
  local buf = vim.api.nvim_create_buf(false, true)

  -- Set content
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

  -- Calculate window size
  local width = math.min(config.max_width, math.max(config.width, vim.fn.max(vim.fn.map(content, "len(v:val)"))))
  local height = math.min(config.max_height, math.max(config.height, #content))

  -- Center the window
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win_opts = {
    relative = "editor",
    row = row,
    col = col,
    width = width,
    height = height,
    border = config.border,
    title = title,
    title_pos = "center",
    style = "minimal",
  }

  local win = vim.api.nvim_open_win(buf, true, win_opts)

  -- Set buffer options
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "filetype", "diagnostics")
  vim.api.nvim_buf_set_option(buf, "modifiable", false)

  -- Close on escape
  vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
  vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })

  return win, buf
end

-- Format diagnostic for display
local function format_diagnostic(diagnostic, line_num)
  local severity_info = severity_map[diagnostic.severity] or severity_map[vim.diagnostic.severity.ERROR]
  local source = diagnostic.source and string.format(" [%s]", diagnostic.source) or ""
  local code = diagnostic.code and string.format(" (%s)", diagnostic.code) or ""

  return string.format("%s %s: %s%s%s", severity_info.icon, severity_info.name, diagnostic.message, code, source)
end

-- Show current line diagnostics
function M.show_line_diagnostics()
  local line = vim.fn.line "." - 1
  local diagnostics = vim.diagnostic.get(0, { lnum = line })

  if #diagnostics == 0 then
    vim.notify("No diagnostics on current line", vim.log.levels.INFO)
    return
  end

  local content = {}
  table.insert(content, string.format("Line %d:", line + 1))
  table.insert(content, "")

  for _, diagnostic in ipairs(diagnostics) do
    table.insert(content, format_diagnostic(diagnostic, line + 1))
  end

  create_float_win(content, config.title_current_line)
end

-- Show current file diagnostics
function M.show_file_diagnostics()
  local diagnostics = vim.diagnostic.get(0)

  if #diagnostics == 0 then
    vim.notify("No diagnostics in current file", vim.log.levels.INFO)
    return
  end

  local content = {}
  table.insert(content, string.format("File: %s", vim.fn.expand "%:t"))
  table.insert(content, string.format("Total diagnostics: %d", #diagnostics))
  table.insert(content, "")

  -- Group diagnostics by line
  local by_line = {}
  for _, diagnostic in ipairs(diagnostics) do
    local line = diagnostic.lnum + 1
    if not by_line[line] then by_line[line] = {} end
    table.insert(by_line[line], diagnostic)
  end

  -- Sort lines
  local lines = {}
  for line, _ in pairs(by_line) do
    table.insert(lines, line)
  end
  table.sort(lines)

  -- Format output
  for _, line in ipairs(lines) do
    table.insert(content, string.format("Line %d:", line))
    for _, diagnostic in ipairs(by_line[line]) do
      table.insert(content, "  " .. format_diagnostic(diagnostic, line))
    end
    table.insert(content, "")
  end

  create_float_win(content, config.title_current_file)
end

-- Show workspace diagnostics
function M.show_workspace_diagnostics()
  local diagnostics = vim.diagnostic.get()

  if #diagnostics == 0 then
    vim.notify("No diagnostics in workspace", vim.log.levels.INFO)
    return
  end

  local content = {}
  table.insert(content, "Workspace Diagnostics")
  table.insert(content, string.format("Total diagnostics: %d", #diagnostics))
  table.insert(content, "")

  -- Group by file
  local by_file = {}
  for _, diagnostic in ipairs(diagnostics) do
    local bufnr = diagnostic.bufnr or 0
    local filename = vim.api.nvim_buf_get_name(bufnr)
    filename = vim.fn.fnamemodify(filename, ":.")

    if not by_file[filename] then by_file[filename] = {} end
    table.insert(by_file[filename], diagnostic)
  end

  -- Sort files
  local files = {}
  for file, _ in pairs(by_file) do
    table.insert(files, file)
  end
  table.sort(files)

  -- Format output
  for _, file in ipairs(files) do
    table.insert(content, string.format("%s (%d):", file, #by_file[file]))

    -- Sort diagnostics by line
    table.sort(by_file[file], function(a, b) return a.lnum < b.lnum end)

    for _, diagnostic in ipairs(by_file[file]) do
      table.insert(
        content,
        string.format("  L%d: %s", diagnostic.lnum + 1, format_diagnostic(diagnostic, diagnostic.lnum + 1))
      )
    end
    table.insert(content, "")
  end

  create_float_win(content, "  Workspace Diagnostics (LSP)")
end

-- Get diagnostic counts
function M.get_diagnostic_counts(bufnr)
  bufnr = bufnr or 0
  local diagnostics = vim.diagnostic.get(bufnr)

  local counts = {
    error = 0,
    warning = 0,
    info = 0,
    hint = 0,
    total = #diagnostics,
  }

  for _, diagnostic in ipairs(diagnostics) do
    if diagnostic.severity == vim.diagnostic.severity.ERROR then
      counts.error = counts.error + 1
    elseif diagnostic.severity == vim.diagnostic.severity.WARN then
      counts.warning = counts.warning + 1
    elseif diagnostic.severity == vim.diagnostic.severity.INFO then
      counts.info = counts.info + 1
    elseif diagnostic.severity == vim.diagnostic.severity.HINT then
      counts.hint = counts.hint + 1
    end
  end

  return counts
end

-- Setup diagnostic display
function M.setup()
  -- Configure diagnostic display
  vim.diagnostic.config {
    virtual_text = false, -- We handle this in LSP config
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = config.border,
      source = "always",
      header = "",
      prefix = "",
    },
  }

  -- Keymaps are handled in keymaps.lua to avoid conflicts
  
  -- Auto-show diagnostics on cursor hold
  vim.api.nvim_create_autocmd("CursorHold", {
    callback = function()
      local opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = config.border,
        source = "always",
        prefix = " ",
        scope = "cursor",
      }
      vim.diagnostic.open_float(nil, opts)
    end,
  })
end

return M
