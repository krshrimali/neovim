local M = {}

-- Treesitter query patterns for different languages
local ts_queries = {
  lua = {
    functions = [[
      (function_declaration name: (identifier) @name)
      (local_function name: (identifier) @name)
      (assignment_statement 
        (variable_list name: (identifier) @name) 
        (expression_list value: (function_definition)))
      (field name: (identifier) @name value: (function_definition))
    ]],
    variables = [[
      (local_variable_declaration 
        (variable_list name: (identifier) @name))
      (assignment_statement 
        (variable_list name: (identifier) @name))
    ]],
    comments = [[
      (comment) @comment
    ]]
  },
  
  javascript = {
    functions = [[
      (function_declaration name: (identifier) @name)
      (function_expression name: (identifier) @name)
      (arrow_function) @name
      (method_definition name: (property_identifier) @name)
      (variable_declarator name: (identifier) @name value: (function_expression))
      (variable_declarator name: (identifier) @name value: (arrow_function))
    ]],
    variables = [[
      (variable_declaration 
        (variable_declarator name: (identifier) @name))
      (lexical_declaration 
        (variable_declarator name: (identifier) @name))
    ]],
    comments = [[
      (comment) @comment
    ]]
  },
  
  python = {
    functions = [[
      (function_definition name: (identifier) @name)
      (async_function_definition name: (identifier) @name)
    ]],
    variables = [[
      (assignment left: (identifier) @name)
      (assignment left: (pattern_list (identifier) @name))
    ]],
    comments = [[
      (comment) @comment
    ]]
  },
  
  typescript = {
    functions = [[
      (function_declaration name: (identifier) @name)
      (function_signature name: (identifier) @name)
      (method_definition name: (property_identifier) @name)
      (method_signature name: (property_identifier) @name)
      (variable_declarator name: (identifier) @name value: (function_expression))
      (variable_declarator name: (identifier) @name value: (arrow_function))
    ]],
    variables = [[
      (variable_declaration 
        (variable_declarator name: (identifier) @name))
      (lexical_declaration 
        (variable_declarator name: (identifier) @name))
    ]],
    comments = [[
      (comment) @comment
    ]]
  }
}

-- Map file extensions to parser names
local extension_to_parser = {
  lua = "lua",
  js = "javascript",
  jsx = "javascript", 
  ts = "typescript",
  tsx = "typescript",
  py = "python",
  pyw = "python"
}

-- Get parser name from filename
local function get_parser_name(filename)
  local ext = filename:match("%.([^%.]+)$")
  if not ext then return nil end
  return extension_to_parser[ext:lower()]
end

-- Search in a single buffer using treesitter
local function search_buffer_with_treesitter(bufnr, query_string, parser_name)
  local results = {}
  
  if not vim.treesitter.get_parser then
    return results
  end
  
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, parser_name)
  if not ok or not parser then
    return results
  end
  
  local tree = parser:parse()[1]
  if not tree then
    return results
  end
  
  local query_ok, query = pcall(vim.treesitter.query.parse, parser_name, query_string)
  if not query_ok or not query then
    return results
  end
  
  local root = tree:root()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id]
    if name == "name" or name == "comment" then
      local start_row, start_col, end_row, end_col = node:range()
      local text = vim.treesitter.get_node_text(node, bufnr)
      
      table.insert(results, {
        filename = filename,
        lnum = start_row + 1,
        col = start_col + 1,
        text = text,
        type = name
      })
    end
  end
  
  return results
end

-- Search across all buffers
local function search_all_buffers(search_type)
  local all_results = {}
  
  -- Get all loaded buffers
  for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(bufnr) and vim.api.nvim_buf_get_option(bufnr, 'buflisted') then
      local filename = vim.api.nvim_buf_get_name(bufnr)
      if filename and filename ~= "" then
        local parser_name = get_parser_name(filename)
        if parser_name and ts_queries[parser_name] and ts_queries[parser_name][search_type] then
          local results = search_buffer_with_treesitter(bufnr, ts_queries[parser_name][search_type], parser_name)
          for _, result in ipairs(results) do
            table.insert(all_results, result)
          end
        end
      end
    end
  end
  
  return all_results
end

-- Search in project files using find and treesitter
local function search_project_files(search_type)
  local all_results = {}
  
  -- Get current working directory
  local cwd = vim.fn.getcwd()
  
  -- Find relevant files in the project
  local file_patterns = {"*.lua", "*.js", "*.jsx", "*.ts", "*.tsx", "*.py"}
  
  for _, pattern in ipairs(file_patterns) do
    local find_cmd = string.format("find %s -name '%s' -type f 2>/dev/null", vim.fn.shellescape(cwd), pattern)
    local files = vim.fn.systemlist(find_cmd)
    
    for _, filepath in ipairs(files) do
      if vim.fn.filereadable(filepath) == 1 then
        -- Load file into a temporary buffer
        local bufnr = vim.fn.bufnr(filepath, true)
        if bufnr ~= -1 then
          -- Load the buffer content
          vim.fn.bufload(bufnr)
          
          local parser_name = get_parser_name(filepath)
          if parser_name and ts_queries[parser_name] and ts_queries[parser_name][search_type] then
            local results = search_buffer_with_treesitter(bufnr, ts_queries[parser_name][search_type], parser_name)
            for _, result in ipairs(results) do
              table.insert(all_results, result)
            end
          end
        end
      end
    end
  end
  
  return all_results
end

-- Convert results to quickfix format and display
local function show_results(results, title)
  if #results == 0 then
    vim.notify("No results found", vim.log.levels.INFO)
    return
  end
  
  -- Convert to quickfix format
  local qf_list = {}
  for _, result in ipairs(results) do
    table.insert(qf_list, {
      filename = result.filename,
      lnum = result.lnum,
      col = result.col,
      text = result.text,
      type = result.type or "I"
    })
  end
  
  -- Set quickfix list and open
  vim.fn.setqflist(qf_list, 'r')
  vim.fn.setqflist({}, 'a', {title = title})
  vim.cmd('copen')
  
  vim.notify(string.format("Found %d results", #results), vim.log.levels.INFO)
end

-- Main search functions
function M.search_functions()
  vim.notify("Searching for functions...", vim.log.levels.INFO)
  local results = search_project_files("functions")
  show_results(results, "🔧 Functions (Treesitter)")
end

function M.search_variables()
  vim.notify("Searching for variables...", vim.log.levels.INFO)
  local results = search_project_files("variables")
  show_results(results, "📝 Variables (Treesitter)")
end

function M.search_comments()
  vim.notify("Searching for comments...", vim.log.levels.INFO)
  local results = search_project_files("comments")
  show_results(results, "💬 Comments (Treesitter)")
end

-- Universal search with type selection
function M.universal_search()
  local choices = {
    "All (text search)",
    "Functions",
    "Variables", 
    "Comments"
  }
  
  vim.ui.select(choices, {
    prompt = "Select search type:",
  }, function(choice)
    if not choice then return end
    
    if choice:match("All") then
      -- Fallback to simple text search
      vim.ui.input({prompt = "Search text: "}, function(input)
        if input and input ~= "" then
          -- Use vim's built-in search
          vim.cmd(string.format("vimgrep /%s/gj **/*", vim.fn.escape(input, '/')))
          vim.cmd('copen')
        end
      end)
    elseif choice:match("Functions") then
      M.search_functions()
    elseif choice:match("Variables") then
      M.search_variables()
    elseif choice:match("Comments") then
      M.search_comments()
    end
  end)
end

-- Search in current buffer only
function M.search_current_buffer(search_type)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local parser_name = get_parser_name(filename)
  
  if not parser_name or not ts_queries[parser_name] or not ts_queries[parser_name][search_type] then
    vim.notify("Treesitter not available for this file type", vim.log.levels.WARN)
    return
  end
  
  local results = search_buffer_with_treesitter(bufnr, ts_queries[parser_name][search_type], parser_name)
  show_results(results, string.format("🔍 %s in current buffer", search_type))
end

return M