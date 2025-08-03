local M = {}

-- Simplified language patterns for better reliability
local patterns = {
  lua = {
    functions = "function\\s+[a-zA-Z_][a-zA-Z0-9_]*|local\\s+function\\s+[a-zA-Z_][a-zA-Z0-9_]*|[a-zA-Z_][a-zA-Z0-9_]*\\s*=\\s*function",
    variables = "local\\s+[a-zA-Z_][a-zA-Z0-9_]*|[a-zA-Z_][a-zA-Z0-9_]*\\s*=",
    comments = "--.*"
  },
  javascript = {
    functions = "function\\s+[a-zA-Z_][a-zA-Z0-9_]*|[a-zA-Z_][a-zA-Z0-9_]*\\s*[:=]\\s*function|[a-zA-Z_][a-zA-Z0-9_]*\\s*=>",
    variables = "let\\s+[a-zA-Z_][a-zA-Z0-9_]*|const\\s+[a-zA-Z_][a-zA-Z0-9_]*|var\\s+[a-zA-Z_][a-zA-Z0-9_]*",
    comments = "//.*|/\\*.*?\\*/"
  },
  python = {
    functions = "def\\s+[a-zA-Z_][a-zA-Z0-9_]*",
    variables = "[a-zA-Z_][a-zA-Z0-9_]*\\s*=",
    comments = "#.*"
  },
  generic = {
    functions = "function\\s+[a-zA-Z_][a-zA-Z0-9_]*|def\\s+[a-zA-Z_][a-zA-Z0-9_]*|fn\\s+[a-zA-Z_][a-zA-Z0-9_]*",
    variables = "[a-zA-Z_][a-zA-Z0-9_]*\\s*=|let\\s+[a-zA-Z_][a-zA-Z0-9_]*|const\\s+[a-zA-Z_][a-zA-Z0-9_]*",
    comments = "//.*|#.*|--.*"
  }
}

-- Get language from file extension
local function get_language(filename)
  local ext = filename:match("%.([^%.]+)$")
  if not ext then return "generic" end
  
  local map = {
    lua = "lua",
    js = "javascript", jsx = "javascript", ts = "javascript", tsx = "javascript",
    py = "python", pyw = "python"
  }
  
  return map[ext:lower()] or "generic"
end

-- Simple search using vim's built-in grep
function M.search_with_pattern(pattern, title)
  if not pattern then
    vim.notify("No pattern provided", vim.log.levels.ERROR)
    return
  end
  
  -- Use vim's built-in grep with ripgrep if available
  local cmd = string.format("silent grep! -E '%s' **/*", pattern)
  vim.cmd(cmd)
  
  -- Open quickfix window
  vim.cmd("copen")
  
  -- Set quickfix title
  vim.fn.setqflist({}, 'a', {title = title or "Search Results"})
end

-- Main universal search function
function M.universal_search()
  local choices = {
    "All (general search)",
    "Functions",
    "Variables", 
    "Comments"
  }
  
  vim.ui.select(choices, {
    prompt = "Select search type:",
  }, function(choice)
    if not choice then return end
    
    if choice:match("All") then
      -- General search - let user type pattern
      vim.ui.input({prompt = "Search pattern: "}, function(input)
        if input and input ~= "" then
          M.search_with_pattern(input, "🔍 General Search")
        end
      end)
    else
      -- Pattern-based search
      local current_file = vim.fn.expand("%:t")
      local lang = get_language(current_file)
      
      local search_type = choice:lower()
      local pattern = patterns[lang] and patterns[lang][search_type] or patterns.generic[search_type]
      
      if pattern then
        M.search_with_pattern(pattern, "🔍 " .. choice .. " (" .. lang .. ")")
      else
        vim.notify("No pattern available for " .. choice, vim.log.levels.WARN)
      end
    end
  end)
end

-- Direct search functions
function M.search_functions()
  local current_file = vim.fn.expand("%:t")
  local lang = get_language(current_file)
  local pattern = patterns[lang] and patterns[lang].functions or patterns.generic.functions
  M.search_with_pattern(pattern, "🔧 Functions (" .. lang .. ")")
end

function M.search_variables()
  local current_file = vim.fn.expand("%:t")
  local lang = get_language(current_file)
  local pattern = patterns[lang] and patterns[lang].variables or patterns.generic.variables
  M.search_with_pattern(pattern, "📝 Variables (" .. lang .. ")")
end

function M.search_comments()
  local current_file = vim.fn.expand("%:t")
  local lang = get_language(current_file)
  local pattern = patterns[lang] and patterns[lang].comments or patterns.generic.comments
  M.search_with_pattern(pattern, "💬 Comments (" .. lang .. ")")
end

return M