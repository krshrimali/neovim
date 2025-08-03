local M = {}

-- Simple function to check if treesitter is available
local function has_treesitter()
  return pcall(require, 'nvim-treesitter')
end

-- Get parser name from file extension
local function get_parser_name(filename)
  local ext = filename:match("%.([^%.]+)$")
  if not ext then return nil end
  
  local map = {
    lua = "lua",
    js = "javascript",
    jsx = "javascript", 
    ts = "typescript",
    tsx = "typescript",
    py = "python",
    pyw = "python"
  }
  
  return map[ext:lower()]
end

-- Simple treesitter-based search in current buffer
local function search_current_buffer_treesitter(search_type)
  local bufnr = vim.api.nvim_get_current_buf()
  local filename = vim.api.nvim_buf_get_name(bufnr)
  local parser_name = get_parser_name(filename)
  
  if not parser_name then
    vim.notify("File type not supported for Treesitter search", vim.log.levels.WARN)
    return {}
  end
  
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr, parser_name)
  if not ok then
    vim.notify("Treesitter parser not available for " .. parser_name, vim.log.levels.WARN)
    return {}
  end
  
  local tree = parser:parse()[1]
  if not tree then
    return {}
  end
  
  local results = {}
  local root = tree:root()
  
  -- Simple node traversal
  local function traverse(node, depth)
    if depth > 10 then return end -- Prevent infinite recursion
    
    local node_type = node:type()
    local start_row, start_col = node:range()
    
    -- Check for different node types based on search_type
    local should_include = false
    local display_text = ""
    
    if search_type == "functions" then
      if node_type:match("function") or 
         node_type:match("method") or
         node_type == "function_declaration" or
         node_type == "function_definition" then
        should_include = true
        display_text = vim.treesitter.get_node_text(node, bufnr):gsub("\n.*", "...") -- First line only
      end
    elseif search_type == "variables" then
      if node_type:match("variable") or
         node_type:match("identifier") or
         node_type == "assignment" or
         node_type == "local_variable_declaration" then
        should_include = true
        display_text = vim.treesitter.get_node_text(node, bufnr):gsub("\n.*", "...")
      end
    elseif search_type == "comments" then
      if node_type == "comment" then
        should_include = true
        display_text = vim.treesitter.get_node_text(node, bufnr):gsub("\n.*", "...")
      end
    end
    
    if should_include and #display_text > 0 and #display_text < 200 then
      table.insert(results, {
        filename = filename,
        lnum = start_row + 1,
        col = start_col + 1,
        text = display_text:gsub("^%s+", ""):gsub("%s+$", ""), -- Trim whitespace
        type = node_type
      })
    end
    
    -- Traverse children
    for child in node:iter_children() do
      traverse(child, depth + 1)
    end
  end
  
  traverse(root, 0)
  return results
end

-- Fallback text-based search
local function fallback_text_search(search_type)
  local patterns = {
    functions = "\\(function\\|def\\|fn\\)\\s\\+\\w\\+",
    variables = "\\(local\\|let\\|const\\|var\\)\\s\\+\\w\\+",
    comments = "\\(--\\|#\\|//\\).*"
  }
  
  local pattern = patterns[search_type]
  if not pattern then
    vim.notify("No pattern available for " .. search_type, vim.log.levels.WARN)
    return
  end
  
  -- Use vimgrep for reliable searching
  local ok, _ = pcall(vim.cmd, string.format("silent vimgrep /%s/gj **/*", pattern))
  if ok then
    vim.cmd('copen')
    vim.notify("Search completed using text patterns", vim.log.levels.INFO)
  else
    vim.notify("Search failed", vim.log.levels.ERROR)
  end
end

-- Show results in quickfix
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
  if has_treesitter() then
    local results = search_current_buffer_treesitter("functions")
    if #results > 0 then
      show_results(results, "🔧 Functions (Treesitter)")
      return
    end
  end
  
  -- Fallback to text search
  fallback_text_search("functions")
end

function M.search_variables()
  if has_treesitter() then
    local results = search_current_buffer_treesitter("variables")
    if #results > 0 then
      show_results(results, "📝 Variables (Treesitter)")
      return
    end
  end
  
  -- Fallback to text search
  fallback_text_search("variables")
end

function M.search_comments()
  if has_treesitter() then
    local results = search_current_buffer_treesitter("comments")
    if #results > 0 then
      show_results(results, "💬 Comments (Treesitter)")
      return
    end
  end
  
  -- Fallback to text search
  fallback_text_search("comments")
end

-- Universal search with type selection
function M.universal_search()
  local choices = {
    "Functions",
    "Variables", 
    "Comments",
    "Text Search"
  }
  
  vim.ui.select(choices, {
    prompt = "Select search type:",
  }, function(choice)
    if not choice then return end
    
    if choice == "Functions" then
      M.search_functions()
    elseif choice == "Variables" then
      M.search_variables()
    elseif choice == "Comments" then
      M.search_comments()
    elseif choice == "Text Search" then
      vim.ui.input({prompt = "Search text: "}, function(input)
        if input and input ~= "" then
          local ok, _ = pcall(vim.cmd, string.format("silent vimgrep /%s/gj **/*", vim.fn.escape(input, '/')))
          if ok then
            vim.cmd('copen')
          else
            vim.notify("Search failed", vim.log.levels.ERROR)
          end
        end
      end)
    end
  end)
end

return M