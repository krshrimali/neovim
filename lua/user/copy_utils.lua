-- Utilities for copying file paths and Python imports
-- Keymaps: <leader>ci (Python import), <leader>cp (absolute path), <leader>cr (relative path)

local M = {}

-- Get the symbol under cursor using LSP or Treesitter
local function get_symbol_under_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = cursor_pos[1] - 1 -- 0-indexed
  local col = cursor_pos[2]

  -- Try LSP first
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  if clients and #clients > 0 then
    for _, client in ipairs(clients) do
      if client.server_capabilities.documentSymbolProvider then
        local params = { textDocument = vim.lsp.util.make_text_document_params() }
        local result = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 1000)

        if result and not vim.tbl_isempty(result) then
          for _, res in pairs(result) do
            if res.result then
              -- Flatten and find symbol at cursor
              local function find_symbol_at_pos(symbols, depth)
                depth = depth or 0
                for _, symbol in ipairs(symbols) do
                  local range = symbol.range or symbol.location and symbol.location.range
                  if range then
                    local start_line = range.start.line
                    local end_line = range["end"].line
                    local start_char = range.start.character
                    local end_char = range["end"].character

                    local in_range = false
                    if line > start_line and line < end_line then
                      in_range = true
                    elseif line == start_line and line == end_line then
                      in_range = col >= start_char and col <= end_char
                    elseif line == start_line then
                      in_range = col >= start_char
                    elseif line == end_line then
                      in_range = col <= end_char
                    end

                    if in_range then
                      -- Check children first (prefer innermost)
                      if symbol.children then
                        local child_result = find_symbol_at_pos(symbol.children, depth + 1)
                        if child_result then return child_result end
                      end
                      return symbol.name
                    end
                  end
                end
                return nil
              end

              local symbol_name = find_symbol_at_pos(res.result)
              if symbol_name then return symbol_name end
            end
          end
        end
      end
    end
  end

  -- Fallback: Try Treesitter
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if ok then
    local node = ts_utils.get_node_at_cursor()
    if node then
      -- Try to find the identifier or name node
      while node do
        local node_type = node:type()
        if
          node_type == "identifier"
          or node_type == "function_definition"
          or node_type == "class_definition"
          or node_type == "variable_declarator"
        then
          -- Get the name
          if node_type == "function_definition" or node_type == "class_definition" then
            for child in node:iter_children() do
              if child:type() == "identifier" then
                local name = vim.treesitter.get_node_text(child, bufnr)
                if name then return name end
              end
            end
          else
            local name = vim.treesitter.get_node_text(node, bufnr)
            if name then return name end
          end
        end
        node = node:parent()
      end
    end
  end

  -- Last resort: get word under cursor
  local word = vim.fn.expand "<cword>"
  if word and word ~= "" then return word end

  return nil
end

-- Convert file path to Python module path
local function file_path_to_python_module(filepath)
  -- Remove .py extension
  local module_path = filepath:gsub("%.py$", "")

  -- Replace path separators with dots
  module_path = module_path:gsub("/", ".")

  -- Remove __init__ from the end if present
  module_path = module_path:gsub("%.__init__$", "")

  return module_path
end

-- Find the Python package root (directory containing the module)
local function find_python_package_root(filepath)
  local dir = vim.fn.fnamemodify(filepath, ":h")
  local parts = {}

  -- Split the path into parts
  for part in dir:gmatch "[^/]+" do
    table.insert(parts, part)
  end

  -- Look for common project indicators
  -- Start from the end and work backwards to find the package root
  local cwd = vim.fn.getcwd()

  -- If file is under cwd, make it relative to cwd
  if filepath:find(cwd, 1, true) == 1 then
    -- Get relative path from cwd
    local rel_path = filepath:sub(#cwd + 2) -- +2 to skip the trailing /
    return rel_path
  end

  -- Otherwise return the full path
  return filepath
end

-- Copy Python import statement for current symbol
function M.copy_python_import()
  local bufnr = vim.api.nvim_get_current_buf()
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")

  if filetype ~= "python" then
    vim.notify("Not a Python file", vim.log.levels.WARN)
    return
  end

  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if filepath == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  -- Get relative path from cwd or use the path as-is
  local module_file = find_python_package_root(filepath)

  -- Convert to module path
  local module_path = file_path_to_python_module(module_file)

  -- Get symbol under cursor
  local symbol = get_symbol_under_cursor()

  local import_statement
  if symbol and symbol ~= "" then
    import_statement = string.format("from %s import %s", module_path, symbol)
  else
    import_statement = string.format("from %s import ", module_path)
  end

  -- Copy to clipboard
  vim.fn.setreg("+", import_statement)
  vim.fn.setreg('"', import_statement)

  -- Show notification
  vim.notify(string.format("Copied: %s", import_statement), vim.log.levels.INFO)
end

-- Copy absolute file path
function M.copy_absolute_path()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  -- Expand to absolute path
  local abs_path = vim.fn.fnamemodify(filepath, ":p")

  -- Copy to clipboard
  vim.fn.setreg("+", abs_path)
  vim.fn.setreg('"', abs_path)

  vim.notify(string.format("Copied absolute path: %s", abs_path), vim.log.levels.INFO)
end

-- Copy relative file path (relative to cwd)
function M.copy_relative_path()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  local cwd = vim.fn.getcwd()
  local abs_path = vim.fn.fnamemodify(filepath, ":p")

  local rel_path
  if abs_path:find(cwd, 1, true) == 1 then
    -- File is under cwd
    rel_path = abs_path:sub(#cwd + 2) -- +2 to skip the trailing /
  else
    -- File is outside cwd, use relative path from cwd
    rel_path = vim.fn.fnamemodify(filepath, ":~:.")
  end

  -- Copy to clipboard
  vim.fn.setreg("+", rel_path)
  vim.fn.setreg('"', rel_path)

  vim.notify(string.format("Copied relative path: %s", rel_path), vim.log.levels.INFO)
end

return M
