local M = {}

-- Simple diagnostic display using native vim.diagnostic functions
-- Compatible with vim.lsp - works just like K (vim.lsp.buf.hover)

-- Show line diagnostics - simple implementation like vim.lsp.buf.hover
function M.show_line_diagnostics()
  vim.diagnostic.open_float(nil, {
    border = "rounded",
    source = "always",
    focusable = true,  -- This allows focusing the window on second press
  })
end

-- Show file diagnostics using quickfix list
function M.show_file_diagnostics()
  local diagnostics = vim.diagnostic.get(0) -- Current buffer only
  
  if #diagnostics == 0 then
    vim.notify("No diagnostics in current file", vim.log.levels.INFO)
    return
  end
  
  -- Convert diagnostics to quickfix format
  local qf_list = {}
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(qf_list, {
      bufnr = diagnostic.bufnr or 0,
      lnum = diagnostic.lnum + 1, -- Convert to 1-based
      col = diagnostic.col + 1,   -- Convert to 1-based
      text = diagnostic.message,
      type = diagnostic.severity == vim.diagnostic.severity.ERROR and "E" or
             diagnostic.severity == vim.diagnostic.severity.WARN and "W" or
             diagnostic.severity == vim.diagnostic.severity.INFO and "I" or "H"
    })
  end
  
  vim.fn.setqflist(qf_list, "r")
  vim.cmd("copen")
  vim.notify(string.format("Found %d diagnostics in current file", #diagnostics), vim.log.levels.INFO)
end

-- Show workspace diagnostics using quickfix list
function M.show_workspace_diagnostics()
  local diagnostics = vim.diagnostic.get() -- All buffers
  
  if #diagnostics == 0 then
    vim.notify("No diagnostics in workspace", vim.log.levels.INFO)
    return
  end
  
  -- Convert diagnostics to quickfix format
  local qf_list = {}
  for _, diagnostic in ipairs(diagnostics) do
    local filename = vim.api.nvim_buf_get_name(diagnostic.bufnr or 0)
    table.insert(qf_list, {
      filename = filename,
      lnum = diagnostic.lnum + 1, -- Convert to 1-based
      col = diagnostic.col + 1,   -- Convert to 1-based
      text = diagnostic.message,
      type = diagnostic.severity == vim.diagnostic.severity.ERROR and "E" or
             diagnostic.severity == vim.diagnostic.severity.WARN and "W" or
             diagnostic.severity == vim.diagnostic.severity.INFO and "I" or "H"
    })
  end
  
  vim.fn.setqflist(qf_list, "r")
  vim.cmd("copen")
  vim.notify(string.format("Found %d diagnostics in workspace", #diagnostics), vim.log.levels.INFO)
end

-- Setup function to configure diagnostics
function M.setup()
  -- Configure diagnostic display
  vim.diagnostic.config({
    virtual_text = false, -- Disable inline virtual text for cleaner display
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
      focusable = true,  -- Make all diagnostic floats focusable by default
    },
  })
end

return M