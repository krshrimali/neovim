local M = {}

local next_edit = require("next-edit-suggestions")

-- Setup user commands
function M.setup()
  -- Main toggle command
  vim.api.nvim_create_user_command("NextEditToggle", function()
    next_edit.toggle()
  end, {
    desc = "Toggle Next Edit Suggestions",
  })
  
  -- Status command
  vim.api.nvim_create_user_command("NextEditStatus", function()
    local status = next_edit.status()
    local ui = require("next-edit-suggestions.ui")
    ui.show_status_window(status)
  end, {
    desc = "Show Next Edit Suggestions status",
  })
  
  -- Clear cache command
  vim.api.nvim_create_user_command("NextEditClearCache", function()
    local cache = require("next-edit-suggestions.cache")
    cache.clear()
    vim.notify("Next Edit Suggestions: Cache cleared", vim.log.levels.INFO)
  end, {
    desc = "Clear Next Edit Suggestions cache",
  })
  
  -- Refresh auth command
  vim.api.nvim_create_user_command("NextEditRefreshAuth", function()
    local copilot = require("next-edit-suggestions.copilot")
    local success = copilot.refresh_auth()
    if success then
      vim.notify("Next Edit Suggestions: Authentication refreshed", vim.log.levels.INFO)
    else
      vim.notify("Next Edit Suggestions: Failed to refresh authentication", vim.log.levels.ERROR)
    end
  end, {
    desc = "Refresh GitHub authentication for Copilot",
  })
  
  -- Debug command
  vim.api.nvim_create_user_command("NextEditDebug", function()
    local cache = require("next-edit-suggestions.cache")
    local copilot = require("next-edit-suggestions.copilot")
    
    local debug_info = {
      plugin_status = next_edit.status(),
      cache_debug = cache.debug_info(),
      copilot_status = copilot.get_status(),
    }
    
    print(vim.inspect(debug_info))
  end, {
    desc = "Show debug information for Next Edit Suggestions",
  })
  
  -- Manual trigger command
  vim.api.nvim_create_user_command("NextEditTrigger", function()
    print("Manually triggering next edit suggestions...")
    next_edit.detect_symbol_changes()
  end, {
    desc = "Manually trigger suggestions",
  })
  
  -- Test command to create fake suggestions
  vim.api.nvim_create_user_command("NextEditTest", function()
    print("Creating test suggestions...")
    local bufnr = vim.api.nvim_get_current_buf()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local line = cursor[1] - 1
    
    -- Create fake suggestions for testing
    local test_suggestions = {
      {
        line = line + 1,
        col_start = 0,
        col_end = 5,
        text = "testVar",
        type = "rename_suggestion",
        distance = 1,
        priority = "nearby"
      },
      {
        line = line + 3,
        col_start = 10,
        col_end = 15,
        text = "testVar",
        type = "rename_suggestion", 
        distance = 3,
        priority = "nearby"
      }
    }
    
    local change_info = {
      new_name = "testVar",
      line = line,
      col = cursor[2],
      type = "variable"
    }
    
    next_edit.display_edit_suggestions(test_suggestions, change_info)
  end, {
    desc = "Test suggestions display",
  })
  
  -- Configuration command
  vim.api.nvim_create_user_command("NextEditConfig", function(opts)
    if opts.args == "" then
      -- Show current configuration
      local status = next_edit.status()
      print("Next Edit Suggestions Configuration:")
      print(vim.inspect(status))
    else
      -- Parse configuration changes
      local config_parts = vim.split(opts.args, "=")
      if #config_parts == 2 then
        local key = config_parts[1]:gsub("^%s*(.-)%s*$", "%1")
        local value = config_parts[2]:gsub("^%s*(.-)%s*$", "%1")
        
        -- Handle boolean values
        if value == "true" then
          value = true
        elseif value == "false" then
          value = false
        elseif tonumber(value) then
          value = tonumber(value)
        end
        
        -- Apply configuration (simplified - would need more robust implementation)
        vim.notify(string.format("Next Edit Suggestions: Would set %s = %s", key, tostring(value)), vim.log.levels.INFO)
      else
        vim.notify("Next Edit Suggestions: Invalid configuration format. Use key=value", vim.log.levels.ERROR)
      end
    end
  end, {
    desc = "Configure Next Edit Suggestions",
    nargs = "?",
    complete = function()
      return {
        "debounce_ms=100",
        "max_suggestions=5",
        "cache_size=1000",
        "ghost_text=true",
        "inline_suggestions=true",
      }
    end,
  })
end

-- Setup additional keymaps (non-conflicting)
function M.setup_keymaps()
  local opts = { noremap = true, silent = true }
  
  -- Only set up non-conflicting leader key mappings
  vim.keymap.set("n", "<leader>nc", function()
    local cache = require("next-edit-suggestions.cache")
    cache.clear()
    vim.notify("Cache cleared", vim.log.levels.INFO)
  end, vim.tbl_extend("force", opts, { desc = "Clear Next Edit Cache" }))
  
  -- Insert mode mappings for quick actions (non-conflicting)
  vim.keymap.set("i", "<C-g><C-t>", function()
    next_edit.detect_symbol_changes()
  end, vim.tbl_extend("force", opts, { desc = "Trigger suggestions manually" }))
  
  vim.keymap.set("i", "<C-g><C-c>", function()
    next_edit.clear_suggestions()
  end, vim.tbl_extend("force", opts, { desc = "Clear suggestions" }))
end

-- Setup autocommands for additional functionality
function M.setup_autocommands()
  local group = vim.api.nvim_create_augroup("NextEditSuggestionsCommands", { clear = true })
  
  -- Save cache periodically
  vim.api.nvim_create_autocmd("CursorHold", {
    group = group,
    callback = function()
      -- Could implement periodic cache cleanup here
      local cache = require("next-edit-suggestions.cache")
      cache.cleanup()
    end,
  })
  
  -- Show helpful messages for new users
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function()
      vim.defer_fn(function()
        local copilot = require("next-edit-suggestions.copilot")
        if not copilot.is_available() then
          vim.notify(
            "Next Edit Suggestions: GitHub authentication not found. Run :NextEditRefreshAuth or set GITHUB_TOKEN environment variable.",
            vim.log.levels.WARN
          )
        end
      end, 2000)
    end,
  })
  
  -- Performance monitoring
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "NextEditSuggestionAccepted",
    callback = function()
      -- Could track usage statistics here
      vim.notify("Suggestion accepted!", vim.log.levels.DEBUG)
    end,
  })
end

-- Telescope integration (if available)
function M.setup_telescope()
  local ok, telescope = pcall(require, "telescope")
  if not ok then
    return
  end
  
  local pickers = require("telescope.pickers")
  local finders = require("telescope.finders")
  local conf = require("telescope.config").values
  local actions = require("telescope.actions")
  local action_state = require("telescope.actions.state")
  
  -- Telescope picker for suggestions
  local function suggestion_picker()
    local suggestions = next_edit.status().current_suggestions or {}
    
    if #suggestions == 0 then
      vim.notify("No suggestions available", vim.log.levels.WARN)
      return
    end
    
    pickers.new({}, {
      prompt_title = "Next Edit Suggestions",
      finder = finders.new_table({
        results = suggestions,
        entry_maker = function(entry)
          return {
            value = entry,
            display = entry.text:gsub("\n", " "),
            ordinal = entry.text,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection then
            local ui = require("next-edit-suggestions.ui")
            ui.accept_suggestion(selection.value)
          end
        end)
        return true
      end,
    }):find()
  end
  
  -- Register telescope command
  vim.api.nvim_create_user_command("NextEditTelescope", suggestion_picker, {
    desc = "Browse suggestions with Telescope",
  })
  
  -- Add to telescope extensions
  telescope.register_extension({
    setup = function() end,
    exports = {
      suggestions = suggestion_picker,
    },
  })
end

-- Which-key integration (if available)
function M.setup_which_key()
  local ok, which_key = pcall(require, "which-key")
  if not ok then
    return
  end
  
  which_key.register({
    ["<leader>n"] = {
      name = "Next Edit Suggestions",
      t = { "<cmd>NextEditToggle<cr>", "Toggle" },
      s = { "<cmd>NextEditStatus<cr>", "Status" },
      c = { "<cmd>NextEditClearCache<cr>", "Clear Cache" },
      r = { "<cmd>NextEditRefreshAuth<cr>", "Refresh Auth" },
      d = { "<cmd>NextEditDebug<cr>", "Debug Info" },
      m = { "<cmd>NextEditTrigger<cr>", "Manual Trigger" },
    },
  })
  
  -- Insert mode mappings
  which_key.register({
    ["<C-g>"] = {
      name = "Next Edit",
      t = { "<cmd>NextEditTrigger<cr>", "Trigger" },
      c = { "<cmd>NextEditClear<cr>", "Clear" },
    },
  }, { mode = "i" })
end

-- Setup all integrations
function M.setup_integrations()
  M.setup_telescope()
  M.setup_which_key()
end

return M