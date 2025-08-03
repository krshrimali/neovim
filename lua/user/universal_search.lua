local M = {}

-- Language-specific patterns for different search types
local language_patterns = {
  -- JavaScript/TypeScript
  javascript = {
    functions = {
      "function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*[:=]\\s*function",
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*[:=]\\s*\\([^)]*\\)\\s*=>",
      "async\\s+function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\([^)]*\\)\\s*{",
    },
    classes = {
      "class\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "interface\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "type\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "enum\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    variables = {
      "let\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "const\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "var\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    comments = { "//.*", "/\\*[\\s\\S]*?\\*/" }
  },
  
  -- Python
  python = {
    functions = {
      "def\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "async\\s+def\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    classes = {
      "class\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    variables = {
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*=",
    },
    comments = { "#.*" }
  },
  
  -- Lua
  lua = {
    functions = {
      "function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "local\\s+function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*=\\s*function",
    },
    classes = {
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*=\\s*{",
    },
    variables = {
      "local\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*=",
    },
    comments = { "--.*" }
  },
  
  -- Java
  java = {
    functions = {
      "public\\s+.*\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(",
      "private\\s+.*\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(",
      "protected\\s+.*\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(",
      "static\\s+.*\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(",
    },
    classes = {
      "class\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "interface\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "enum\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    variables = {
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*[=;]",
    },
    comments = { "//.*", "/\\*[\\s\\S]*?\\*/" }
  },
  
  -- C/C++
  c = {
    functions = {
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\([^)]*\\)\\s*{",
      "static\\s+.*\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\(",
    },
    classes = {
      "class\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "struct\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "typedef\\s+.*\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    variables = {
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s*[=;]",
    },
    comments = { "//.*", "/\\*[\\s\\S]*?\\*/" }
  },
  
  -- Rust
  rust = {
    functions = {
      "fn\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "pub\\s+fn\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "async\\s+fn\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    classes = {
      "struct\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "enum\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "trait\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "impl\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    variables = {
      "let\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "const\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "static\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    comments = { "//.*", "/\\*[\\s\\S]*?\\*/" }
  },
  
  -- Go
  go = {
    functions = {
      "func\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "func\\s+\\([^)]*\\)\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    classes = {
      "type\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s+struct",
      "type\\s+([a-zA-Z_][a-zA-Z0-9_]*)\\s+interface",
    },
    variables = {
      "var\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*:=",
    },
    comments = { "//.*", "/\\*[\\s\\S]*?\\*/" }
  },
  
  -- Ruby
  ruby = {
    functions = {
      "def\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    classes = {
      "class\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "module\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    variables = {
      "([a-zA-Z_][a-zA-Z0-9_]*)\\s*=",
      "@([a-zA-Z_][a-zA-Z0-9_]*)",
      "@@([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    comments = { "#.*" }
  },
  
  -- PHP
  php = {
    functions = {
      "function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "public\\s+function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "private\\s+function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "protected\\s+function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    classes = {
      "class\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "interface\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
      "trait\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    variables = {
      "\\$([a-zA-Z_][a-zA-Z0-9_]*)",
    },
    comments = { "//.*", "/\\*[\\s\\S]*?\\*/", "#.*" }
  }
}

-- Generic fallback patterns for unknown languages
local generic_patterns = {
  functions = {
    "function\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "def\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "fn\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "([a-zA-Z_][a-zA-Z0-9_]*)\\s*\\([^)]*\\)\\s*{",
  },
  classes = {
    "class\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "struct\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "interface\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "type\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
  },
  variables = {
    "([a-zA-Z_][a-zA-Z0-9_]*)\\s*=",
    "let\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "const\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
    "var\\s+([a-zA-Z_][a-zA-Z0-9_]*)",
  },
  comments = { "//.*", "#.*", "/\\*[\\s\\S]*?\\*/" }
}

-- Get file extension to determine language
local function get_language_from_extension(filename)
  local ext = filename:match("%.([^%.]+)$")
  if not ext then return nil end
  
  local lang_map = {
    js = "javascript", jsx = "javascript", ts = "javascript", tsx = "javascript",
    py = "python", pyw = "python",
    lua = "lua",
    java = "java",
    c = "c", cpp = "c", cc = "c", cxx = "c", h = "c", hpp = "c",
    rs = "rust",
    go = "go",
    rb = "ruby",
    php = "php",
  }
  
  return lang_map[ext:lower()]
end

-- Get patterns for a specific search type and language
local function get_patterns(search_type, language)
  local patterns = {}
  
  -- Try language-specific patterns first
  if language and language_patterns[language] and language_patterns[language][search_type] then
    for _, pattern in ipairs(language_patterns[language][search_type]) do
      table.insert(patterns, pattern)
    end
  end
  
  -- Add generic patterns as fallback
  if generic_patterns[search_type] then
    for _, pattern in ipairs(generic_patterns[search_type]) do
      table.insert(patterns, pattern)
    end
  end
  
  return patterns
end

-- Create search pattern string for ripgrep
local function create_search_pattern(search_type, language)
  local patterns = get_patterns(search_type, language)
  if #patterns == 0 then
    return nil
  end
  
  -- Join patterns with OR operator for ripgrep
  -- Wrap each pattern in parentheses for proper grouping
  local wrapped_patterns = {}
  for _, pattern in ipairs(patterns) do
    table.insert(wrapped_patterns, "(" .. pattern .. ")")
  end
  return table.concat(wrapped_patterns, "|")
end

-- Main search function
function M.universal_search()
  local fzf_lua = require("fzf-lua")
  
  -- Search type options
  local search_types = {
    "🔍 All (general search)",
    "🔧 Functions",
    "📦 Classes/Types",
    "📝 Variables",
    "💬 Comments",
  }
  
  -- Show search type selection
  vim.ui.select(search_types, {
    prompt = "Select search type:",
    format_item = function(item)
      return item
    end,
  }, function(choice)
    if not choice then return end
    
    local search_type = choice:match("^🔍") and "all" or
                       choice:match("^🔧") and "functions" or
                       choice:match("^📦") and "classes" or
                       choice:match("^📝") and "variables" or
                       choice:match("^💬") and "comments"
    
    if search_type == "all" then
      -- Standard live grep for general search
      fzf_lua.live_grep({
        prompt = "Search everywhere> ",
        winopts = {
          title = "🔍 Universal Search - All",
          height = 0.9,
          width = 0.9,
        }
      })
    else
      -- Get current file's language for context
      local current_file = vim.fn.expand("%:t")
      local language = get_language_from_extension(current_file)
      
      -- Create search pattern
      local pattern = create_search_pattern(search_type, language)
      
      if not pattern then
        vim.notify("No patterns available for " .. search_type, vim.log.levels.WARN)
        return
      end
      
      -- Use fzf-lua live_grep with custom pattern
      fzf_lua.live_grep({
        prompt = string.format("Search %s> ", search_type),
        rg_opts = string.format("--column --line-number --no-heading --color=always --smart-case --max-columns=512 -e '%s'", pattern),
        winopts = {
          title = string.format("🔍 Universal Search - %s%s", 
            string.upper(search_type:sub(1,1)) .. search_type:sub(2),
            language and (" (" .. language .. ")") or ""
          ),
          height = 0.9,
          width = 0.9,
        },
        -- Allow user to modify the search after pattern is applied
        query = "",
        -- Custom actions
        actions = {
          ["default"] = function(selected)
            -- Default action: go to selected item
            fzf_lua.actions.file_edit_or_qf(selected)
          end,
          ["ctrl-s"] = function(selected)
            -- Send to quickfix
            fzf_lua.actions.file_sel_to_qf(selected)
          end,
        }
      })
    end
  end)
end

-- Quick search functions for direct access
function M.search_functions()
  local fzf_lua = require("fzf-lua")
  local current_file = vim.fn.expand("%:t")
  local language = get_language_from_extension(current_file)
  local pattern = create_search_pattern("functions", language)
  
  if not pattern then
    vim.notify("No function patterns available", vim.log.levels.WARN)
    return
  end
  
  fzf_lua.live_grep({
    prompt = "Search functions> ",
    rg_opts = string.format("--column --line-number --no-heading --color=always --smart-case --max-columns=512 -e '%s'", pattern),
    winopts = {
      title = "🔧 Search Functions" .. (language and (" (" .. language .. ")") or ""),
      height = 0.9,
      width = 0.9,
    }
  })
end

function M.search_classes()
  local fzf_lua = require("fzf-lua")
  local current_file = vim.fn.expand("%:t")
  local language = get_language_from_extension(current_file)
  local pattern = create_search_pattern("classes", language)
  
  if not pattern then
    vim.notify("No class patterns available", vim.log.levels.WARN)
    return
  end
  
  fzf_lua.live_grep({
    prompt = "Search classes> ",
    rg_opts = string.format("--column --line-number --no-heading --color=always --smart-case --max-columns=512 -e '%s'", pattern),
    winopts = {
      title = "📦 Search Classes" .. (language and (" (" .. language .. ")") or ""),
      height = 0.9,
      width = 0.9,
    }
  })
end

function M.search_variables()
  local fzf_lua = require("fzf-lua")
  local current_file = vim.fn.expand("%:t")
  local language = get_language_from_extension(current_file)
  local pattern = create_search_pattern("variables", language)
  
  if not pattern then
    vim.notify("No variable patterns available", vim.log.levels.WARN)
    return
  end
  
  fzf_lua.live_grep({
    prompt = "Search variables> ",
    rg_opts = string.format("--column --line-number --no-heading --color=always --smart-case --max-columns=512 -e '%s'", pattern),
    winopts = {
      title = "📝 Search Variables" .. (language and (" (" .. language .. ")") or ""),
      height = 0.9,
      width = 0.9,
    }
  })
end

function M.search_comments()
  local fzf_lua = require("fzf-lua")
  local current_file = vim.fn.expand("%:t")
  local language = get_language_from_extension(current_file)
  local pattern = create_search_pattern("comments", language)
  
  if not pattern then
    vim.notify("No comment patterns available", vim.log.levels.WARN)
    return
  end
  
  fzf_lua.live_grep({
    prompt = "Search comments> ",
    rg_opts = string.format("--column --line-number --no-heading --color=always --smart-case --max-columns=512 -e '%s'", pattern),
    winopts = {
      title = "💬 Search Comments" .. (language and (" (" .. language .. ")") or ""),
      height = 0.9,
      width = 0.9,
    }
  })
end

return M