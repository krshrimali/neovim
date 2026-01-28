local M = {}

function M.toggle_option(option)
  local value = not vim.api.nvim_get_option_value(option, {})
  vim.opt[option] = value
  vim.notify(option .. " set to " .. tostring(value))
end

function M.toggle_tabline()
  local value = vim.api.nvim_get_option_value("showtabline", {})

  if value == 2 then
    value = 0
  else
    value = 2
  end

  vim.opt.showtabline = value

  vim.notify("showtabline" .. " set to " .. tostring(value))
end

local diagnostics_active = true
function M.toggle_diagnostics()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.show()
  else
    vim.diagnostic.hide()
  end
end

function M.isempty(s) return s == nil or s == "" end

function M.force_quit()
  vim.cmd "q!"
end

function M.smart_quit()
  local bufnr = vim.api.nvim_get_current_buf()
  local modified = vim.api.nvim_buf_get_option(bufnr, "modified")
  if modified then
    -- Temporarily disable blink.cmp to prevent completion in the prompt
    local blink_was_enabled = _G.blink_enabled
    _G.blink_enabled = false

    -- Hide any visible completion menu
    pcall(function() require("blink.cmp").hide() end)

    vim.ui.input({
      prompt = "You have unsaved changes. Quit anyway? (y/n) ",
    }, function(input)
      -- Restore blink.cmp state after prompt
      _G.blink_enabled = blink_was_enabled

      if input == "y" then vim.cmd "q!" end
    end)
  else
    vim.cmd "q!"
  end
end

return M
