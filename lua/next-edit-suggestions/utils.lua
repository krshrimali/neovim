local M = {}

-- Get context around cursor position
function M.get_context(bufnr, line, col)
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  
  -- Get filename and filetype
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  
  -- Get current line
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
  
  -- Get context lines before cursor (up to 10 lines)
  local context_before = 10
  local start_line = math.max(0, line - context_before)
  local lines_before = vim.api.nvim_buf_get_lines(bufnr, start_line, line, false)
  
  -- Get context lines after cursor (up to 5 lines)
  local context_after = 5
  local end_line = math.min(total_lines, line + context_after + 1)
  local lines_after = vim.api.nvim_buf_get_lines(bufnr, line + 1, end_line, false)
  
  -- Get indentation level
  local indent = M.get_indent_level(current_line)
  
  -- Get language-specific context
  local lang_context = M.get_language_context(bufnr, line, col, filetype)
  
  return {
    filename = filename,
    filetype = filetype,
    line = line,
    col = col,
    current_line = current_line,
    lines_before = lines_before,
    lines_after = lines_after,
    indent = indent,
    total_lines = total_lines,
    lang_context = lang_context,
  }
end

-- Get indentation level
function M.get_indent_level(line)
  local indent = 0
  for i = 1, #line do
    local char = line:sub(i, i)
    if char == " " then
      indent = indent + 1
    elseif char == "\t" then
      indent = indent + vim.bo.tabstop
    else
      break
    end
  end
  return indent
end

-- Get language-specific context
function M.get_language_context(bufnr, line, col, filetype)
  local context = {
    in_string = false,
    in_comment = false,
    in_function = false,
    function_name = nil,
    class_name = nil,
    imports = {},
  }
  
  -- Use treesitter if available
  local ok, ts = pcall(require, "nvim-treesitter.parsers")
  if ok and ts.has_parser(filetype) then
    context = M.get_treesitter_context(bufnr, line, col, filetype)
  else
    -- Fallback to simple pattern matching
    context = M.get_simple_context(bufnr, line, col, filetype)
  end
  
  return context
end

-- Get context using treesitter
function M.get_treesitter_context(bufnr, line, col, filetype)
  local context = {
    in_string = false,
    in_comment = false,
    in_function = false,
    function_name = nil,
    class_name = nil,
    imports = {},
  }
  
  local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
  if not ok then
    return context
  end
  
  local node = ts_utils.get_node_at_cursor()
  if not node then
    return context
  end
  
  -- Walk up the tree to find context
  local current = node
  while current do
    local node_type = current:type()
    
    -- Check for strings
    if node_type:match("string") then
      context.in_string = true
    end
    
    -- Check for comments
    if node_type:match("comment") then
      context.in_comment = true
    end
    
    -- Check for functions
    if node_type:match("function") or node_type:match("method") then
      context.in_function = true
      -- Try to get function name
      for child in current:iter_children() do
        if child:type():match("identifier") or child:type():match("name") then
          local name = ts_utils.get_node_text(child, bufnr)[1]
          if name then
            context.function_name = name
            break
          end
        end
      end
    end
    
    -- Check for classes
    if node_type:match("class") then
      for child in current:iter_children() do
        if child:type():match("identifier") or child:type():match("name") then
          local name = ts_utils.get_node_text(child, bufnr)[1]
          if name then
            context.class_name = name
            break
          end
        end
      end
    end
    
    current = current:parent()
  end
  
  -- Get imports (simplified)
  context.imports = M.get_imports(bufnr, filetype)
  
  return context
end

-- Get context using simple pattern matching
function M.get_simple_context(bufnr, line, col, filetype)
  local context = {
    in_string = false,
    in_comment = false,
    in_function = false,
    function_name = nil,
    class_name = nil,
    imports = {},
  }
  
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
  local before_cursor = current_line:sub(1, col)
  
  -- Simple string detection
  local quote_count = 0
  for i = 1, #before_cursor do
    local char = before_cursor:sub(i, i)
    if char == '"' or char == "'" then
      quote_count = quote_count + 1
    end
  end
  context.in_string = quote_count % 2 == 1
  
  -- Simple comment detection
  if filetype == "lua" then
    context.in_comment = current_line:match("^%s*%-%-") ~= nil
  elseif filetype == "javascript" or filetype == "typescript" then
    context.in_comment = current_line:match("^%s*//") ~= nil
  elseif filetype == "python" then
    context.in_comment = current_line:match("^%s*#") ~= nil
  end
  
  -- Look for function context in previous lines
  local lines_before = vim.api.nvim_buf_get_lines(bufnr, math.max(0, line - 20), line, false)
  for i = #lines_before, 1, -1 do
    local l = lines_before[i]
    local func_name = M.extract_function_name(l, filetype)
    if func_name then
      context.in_function = true
      context.function_name = func_name
      break
    end
  end
  
  -- Get imports
  context.imports = M.get_imports(bufnr, filetype)
  
  return context
end

-- Extract function name from line
function M.extract_function_name(line, filetype)
  local patterns = {
    lua = "function%s+([%w_]+)",
    javascript = "function%s+([%w_]+)",
    typescript = "function%s+([%w_]+)",
    python = "def%s+([%w_]+)",
    rust = "fn%s+([%w_]+)",
    go = "func%s+([%w_]+)",
  }
  
  local pattern = patterns[filetype]
  if pattern then
    return line:match(pattern)
  end
  
  return nil
end

-- Get imports for the file
function M.get_imports(bufnr, filetype)
  local imports = {}
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, 50, false) -- Check first 50 lines
  
  local patterns = {
    lua = "require%s*%(?['\"]([^'\"]+)['\"]%)?",
    javascript = "import.+from%s+['\"]([^'\"]+)['\"]",
    typescript = "import.+from%s+['\"]([^'\"]+)['\"]",
    python = "from%s+([%w%.]+)%s+import|import%s+([%w%.]+)",
    rust = "use%s+([%w:]+)",
    go = "import%s+['\"]([^'\"]+)['\"]",
  }
  
  local pattern = patterns[filetype]
  if not pattern then
    return imports
  end
  
  for _, line in ipairs(lines) do
    local match = line:match(pattern)
    if match then
      table.insert(imports, match)
    end
  end
  
  return imports
end

-- Check if position is at end of line
function M.is_end_of_line(bufnr, line, col)
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
  return col >= #current_line
end

-- Check if position is at beginning of word
function M.is_beginning_of_word(bufnr, line, col)
  if col == 0 then
    return true
  end
  
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
  local prev_char = current_line:sub(col, col)
  local curr_char = current_line:sub(col + 1, col + 1)
  
  return prev_char:match("%s") and curr_char:match("%w")
end

-- Get word at position (fast version)
function M.get_word_at_position(line_content, col)
  if not line_content or col < 0 then
    return nil
  end
  
  -- Find word boundaries
  local start_col = col
  local end_col = col
  
  -- Find start of word
  while start_col > 0 and line_content:sub(start_col, start_col):match("[%w_]") do
    start_col = start_col - 1
  end
  start_col = start_col + 1
  
  -- Find end of word
  while end_col <= #line_content and line_content:sub(end_col + 1, end_col + 1):match("[%w_]") do
    end_col = end_col + 1
  end
  
  local word = line_content:sub(start_col, end_col)
  return word:match("^[%a_][%w_]*$") and word or nil -- Only valid identifiers
end

-- Legacy function for compatibility
function M.get_word_under_cursor(bufnr, line, col)
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
  return M.get_word_at_position(current_line, col)
end

-- Check if we should trigger suggestions
function M.should_trigger_suggestions(bufnr, line, col)
  local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1] or ""
  
  -- Don't trigger in comments (simple check)
  if current_line:match("^%s*//") or current_line:match("^%s*#") or current_line:match("^%s*%-%-") then
    return false
  end
  
  -- Don't trigger in strings (simple check)
  local before_cursor = current_line:sub(1, col)
  local quote_count = 0
  for i = 1, #before_cursor do
    local char = before_cursor:sub(i, i)
    if char == '"' or char == "'" then
      quote_count = quote_count + 1
    end
  end
  if quote_count % 2 == 1 then
    return false
  end
  
  -- Trigger after certain characters
  local trigger_chars = {
    ".", ":", "(", "[", "{", " ", "\t", "\n"
  }
  
  if col > 0 then
    local prev_char = current_line:sub(col, col)
    for _, char in ipairs(trigger_chars) do
      if prev_char == char then
        return true
      end
    end
  end
  
  -- Trigger after typing a few characters
  local word = M.get_word_under_cursor(bufnr, line, col)
  return #word >= 2
end

-- Debounce function
function M.debounce(func, delay)
  local timer = nil
  return function(...)
    local args = {...}
    if timer then
      timer:stop()
    end
    timer = vim.defer_fn(function()
      func(unpack(args))
    end, delay)
  end
end

-- Get file extension
function M.get_file_extension(filename)
  return filename:match("%.([^%.]+)$")
end

-- Check if file is supported
function M.is_supported_filetype(filetype, supported_types)
  return vim.tbl_contains(supported_types, filetype)
end

return M