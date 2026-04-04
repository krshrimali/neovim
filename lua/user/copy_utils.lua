-- Utilities for copying file paths and Python imports
-- Keymaps: <leader>ci (Python import), <leader>cp (absolute path), <leader>cr (relative path)
-- <leader>cf (parent func body), <leader>cF (file:func_start:func_end)
-- <leader>cc (parent class body), <leader>cC (file:class_start:class_end)

local M = {}

-- LSP symbol kinds for functions and classes
-- https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/#symbolKind
local FUNCTION_KINDS = { [6] = true, [9] = true, [12] = true } -- Method, Constructor, Function
local CLASS_KINDS = { [5] = true, [10] = true, [11] = true, [23] = true } -- Class, Enum, Interface, Struct

-- Fetch document symbols from the first LSP client that supports it
local function get_lsp_symbols(bufnr)
  for _, client in ipairs(vim.lsp.get_clients { bufnr = bufnr }) do
    if client.server_capabilities.documentSymbolProvider then
      local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
      local result = vim.lsp.buf_request_sync(bufnr, "textDocument/documentSymbol", params, 2000)
      if result then
        for _, res in pairs(result) do
          if res.result then return res.result end
        end
      end
    end
  end
  return nil
end

-- Walk the symbol tree and return the innermost symbol of the given kinds that contains the cursor
local function find_innermost_symbol(symbols, cursor_line, cursor_col, kind_set)
  local found = nil
  for _, symbol in ipairs(symbols) do
    local range = symbol.range or (symbol.location and symbol.location.range)
    if range then
      local sl, el = range.start.line, range["end"].line
      local sc, ec = range.start.character, range["end"].character
      local in_range = (cursor_line > sl and cursor_line < el)
        or (cursor_line == sl and cursor_line == el and cursor_col >= sc and cursor_col <= ec)
        or (cursor_line == sl and cursor_line ~= el and cursor_col >= sc)
        or (cursor_line == el and cursor_line ~= sl and cursor_col <= ec)
      if in_range then
        if kind_set[symbol.kind] then found = symbol end
        if symbol.children then
          local deeper = find_innermost_symbol(symbol.children, cursor_line, cursor_col, kind_set)
          if deeper then found = deeper end
        end
      end
    end
  end
  return found
end

-- Extract buffer lines for a symbol's range
local function symbol_text(symbol, bufnr)
  local range = symbol.range
  local lines = vim.api.nvim_buf_get_lines(bufnr, range.start.line, range["end"].line + 1, false)
  return table.concat(lines, "\n")
end

local function get_relative_path()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == "" then return nil end
  local cwd = vim.fn.getcwd()
  local abs_path = vim.fn.fnamemodify(filepath, ":p")
  if abs_path:find(cwd, 1, true) == 1 then
    return abs_path:sub(#cwd + 2)
  else
    return vim.fn.fnamemodify(filepath, ":~:.")
  end
end

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
  local filetype = vim.api.nvim_get_option_value("filetype", { buf = bufnr })

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
  local rel_path = get_relative_path()
  if not rel_path then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("+", rel_path)
  vim.fn.setreg('"', rel_path)
  vim.notify(string.format("Copied relative path: %s", rel_path), vim.log.levels.INFO)
end

-- Copy file path with line range (file_path:line_start:line_end)
function M.copy_path_with_lines()
  local rel_path = get_relative_path()
  if not rel_path then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end

  local mode = vim.fn.mode()
  local line_start, line_end
  if mode == "v" or mode == "V" or mode == "\22" then
    line_start = vim.fn.line "v"
    line_end = vim.fn.line "."
    if line_start > line_end then
      line_start, line_end = line_end, line_start
    end
  else
    line_start = vim.fn.line "."
    line_end = line_start
  end

  local result = string.format("%s:%d:%d", rel_path, line_start, line_end)

  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)
  vim.notify(string.format("Copied: %s", result), vim.log.levels.INFO)
end

local function lsp_find_symbol(kind_set)
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_line = cursor[1] - 1 -- 0-indexed
  local cursor_col = cursor[2]
  local symbols = get_lsp_symbols(bufnr)
  if not symbols then return nil, nil end
  local symbol = find_innermost_symbol(symbols, cursor_line, cursor_col, kind_set)
  return symbol, bufnr
end

-- Copy the full text of the enclosing function (via LSP)
function M.copy_parent_function()
  local symbol, bufnr = lsp_find_symbol(FUNCTION_KINDS)
  if not symbol then
    vim.notify("No parent function found", vim.log.levels.WARN)
    return
  end
  local text = symbol_text(symbol, bufnr)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify("Copied function: " .. symbol.name, vim.log.levels.INFO)
end

-- Copy the full text of the enclosing class/struct/impl (via LSP)
function M.copy_parent_class()
  local symbol, bufnr = lsp_find_symbol(CLASS_KINDS)
  if not symbol then
    vim.notify("No parent class found", vim.log.levels.WARN)
    return
  end
  local text = symbol_text(symbol, bufnr)
  vim.fn.setreg("+", text)
  vim.fn.setreg('"', text)
  vim.notify("Copied class: " .. symbol.name, vim.log.levels.INFO)
end

-- Copy file:func_start:func_end for the enclosing function (via LSP)
function M.copy_parent_function_with_lines()
  local rel_path = get_relative_path()
  if not rel_path then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end
  local symbol = lsp_find_symbol(FUNCTION_KINDS)
  if not symbol then
    vim.notify("No parent function found", vim.log.levels.WARN)
    return
  end
  local range = symbol.range
  local result = string.format("%s:%d:%d", rel_path, range.start.line + 1, range["end"].line + 1)
  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)
  vim.notify("Copied: " .. result, vim.log.levels.INFO)
end

-- Copy file:class_start:class_end for the enclosing class/struct/impl (via LSP)
function M.copy_parent_class_with_lines()
  local rel_path = get_relative_path()
  if not rel_path then
    vim.notify("No file name", vim.log.levels.WARN)
    return
  end
  local symbol = lsp_find_symbol(CLASS_KINDS)
  if not symbol then
    vim.notify("No parent class found", vim.log.levels.WARN)
    return
  end
  local range = symbol.range
  local result = string.format("%s:%d:%d", rel_path, range.start.line + 1, range["end"].line + 1)
  vim.fn.setreg("+", result)
  vim.fn.setreg('"', result)
  vim.notify("Copied: " .. result, vim.log.levels.INFO)
end

return M
