local M = {}

local curl = require("plenary.curl")
local job = require("plenary.job")

-- Module state
local state = {
  config = {},
  initialized = false,
  auth_token = nil,
}

-- Setup Copilot integration
function M.setup(config)
  state.config = config or {}
  
  -- Initialize Copilot authentication
  M.init_auth()
  
  state.initialized = true
end

-- Initialize Copilot authentication
function M.init_auth()
  -- Try to get auth token from Copilot CLI or environment
  local auth_methods = {
    function() return vim.fn.system("gh auth token 2>/dev/null"):gsub("\n", "") end,
    function() return os.getenv("GITHUB_TOKEN") end,
    function() return os.getenv("COPILOT_TOKEN") end,
  }
  
  for _, method in ipairs(auth_methods) do
    local token = method()
    if token and token ~= "" and not token:match("command not found") then
      state.auth_token = token
      break
    end
  end
  
  if not state.auth_token then
    vim.notify("Next Edit Suggestions: No GitHub auth token found. Please authenticate with GitHub CLI or set GITHUB_TOKEN environment variable.", vim.log.levels.WARN)
  end
end

-- Get suggestions from Copilot
function M.get_suggestions(context, callback)
  if not state.initialized then
    callback(nil)
    return
  end
  
  if not state.auth_token then
    callback(nil)
    return
  end
  
  -- Prepare the request payload
  local payload = {
    model = state.config.model or "gpt-4",
    messages = {
      {
        role = "system",
        content = "You are an AI coding assistant. Provide intelligent code completion suggestions based on the context. Return only the suggested code completion, no explanations."
      },
      {
        role = "user", 
        content = M.format_context_for_copilot(context)
      }
    },
    temperature = state.config.temperature or 0.1,
    max_tokens = state.config.max_tokens or 500,
    n = state.config.max_suggestions or 3,
  }
  
  -- Make async request to OpenAI API (Copilot uses OpenAI backend)
  curl.post("https://api.openai.com/v1/chat/completions", {
    headers = {
      ["Authorization"] = "Bearer " .. state.auth_token,
      ["Content-Type"] = "application/json",
    },
    body = vim.json.encode(payload),
    callback = function(response)
      vim.schedule(function()
        M.handle_copilot_response(response, callback)
      end)
    end,
  })
end

-- Format context for Copilot API
function M.format_context_for_copilot(context)
  local prompt = string.format([[
File: %s
Language: %s

Context (lines before cursor):
%s

Current line (cursor at |):
%s

Context (lines after cursor):
%s

Please suggest the most likely code completion for the cursor position. Provide up to 3 different suggestions if applicable.
]], 
    context.filename or "unknown",
    context.filetype or "text",
    table.concat(context.lines_before or {}, "\n"),
    (context.current_line or ""):sub(1, context.col) .. "|" .. (context.current_line or ""):sub(context.col + 1),
    table.concat(context.lines_after or {}, "\n")
  )
  
  return prompt
end

-- Handle Copilot API response
function M.handle_copilot_response(response, callback)
  if response.status ~= 200 then
    vim.notify("Copilot API error: " .. (response.body or "Unknown error"), vim.log.levels.ERROR)
    callback(nil)
    return
  end
  
  local ok, data = pcall(vim.json.decode, response.body)
  if not ok or not data.choices then
    callback(nil)
    return
  end
  
  local suggestions = {}
  for _, choice in ipairs(data.choices) do
    if choice.message and choice.message.content then
      local suggestion = M.parse_suggestion(choice.message.content)
      if suggestion then
        table.insert(suggestions, suggestion)
      end
    end
  end
  
  callback(suggestions)
end

-- Parse suggestion from Copilot response
function M.parse_suggestion(content)
  if not content or content == "" then
    return nil
  end
  
  -- Clean up the suggestion
  local suggestion = content:gsub("^%s+", ""):gsub("%s+$", "")
  
  -- Split into lines for multi-line suggestions
  local lines = vim.split(suggestion, "\n")
  
  return {
    text = suggestion,
    lines = lines,
    type = "completion",
    source = "copilot",
  }
end

-- Get inline suggestion (single line completion)
function M.get_inline_suggestion(context, callback)
  if not state.initialized or not state.auth_token then
    callback(nil)
    return
  end
  
  -- For inline suggestions, we want shorter, single-line completions
  local payload = {
    model = "gpt-3.5-turbo",  -- Use faster model for inline suggestions
    messages = {
      {
        role = "system",
        content = "Complete the current line of code. Return only the completion text, no explanations. Keep it concise and relevant."
      },
      {
        role = "user",
        content = M.format_inline_context(context)
      }
    },
    temperature = 0.1,
    max_tokens = 100,
    n = 1,
  }
  
  curl.post("https://api.openai.com/v1/chat/completions", {
    headers = {
      ["Authorization"] = "Bearer " .. state.auth_token,
      ["Content-Type"] = "application/json",
    },
    body = vim.json.encode(payload),
    callback = function(response)
      vim.schedule(function()
        if response.status == 200 then
          local ok, data = pcall(vim.json.decode, response.body)
          if ok and data.choices and data.choices[1] then
            local suggestion = data.choices[1].message.content
            if suggestion and suggestion ~= "" then
              callback({
                text = suggestion:gsub("^%s+", ""):gsub("%s+$", ""),
                type = "inline",
                source = "copilot",
              })
              return
            end
          end
        end
        callback(nil)
      end)
    end,
  })
end

-- Format context for inline suggestions
function M.format_inline_context(context)
  return string.format([[
Language: %s
Current line: %s
Complete this line starting from the cursor position.
]], 
    context.filetype or "text",
    (context.current_line or ""):sub(1, context.col) .. "|"
  )
end

-- Check if Copilot is available
function M.is_available()
  return state.initialized and state.auth_token ~= nil
end

-- Get Copilot status
function M.get_status()
  return {
    initialized = state.initialized,
    authenticated = state.auth_token ~= nil,
    model = state.config.model,
  }
end

-- Refresh authentication
function M.refresh_auth()
  M.init_auth()
  return state.auth_token ~= nil
end

return M