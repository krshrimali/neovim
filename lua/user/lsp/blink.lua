-- Blink.cmp completion configuration
local M = {}

-- Global state for toggling completion
_G.blink_enabled = true

function M.setup()
  require("blink.cmp").setup {
    -- Control enabled state with a function
    enabled = function() return _G.blink_enabled end,

    -- Custom keymap: Tab/Shift+Tab for navigation, Enter/Ctrl+y to accept
    keymap = {
      preset = "default",
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-y>"] = { "accept", "fallback" },
    },

    -- Appearance settings
    appearance = {
      nerd_font_variant = "mono",
    },

    -- Completion settings
    completion = {
      menu = {
        auto_show = true, -- Auto-show completion menu
      },
      documentation = {
        auto_show = true, -- Auto-show documentation
        auto_show_delay_ms = 200,
      },
    },

    -- Sources configuration
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Use Rust fuzzy matcher if available
    fuzzy = {
      implementation = "prefer_rust_with_warning",
    },
  }
end

-- Toggle blink.cmp on/off
function M.toggle()
  _G.blink_enabled = not _G.blink_enabled

  if _G.blink_enabled then
    vim.notify("Blink.cmp enabled", vim.log.levels.INFO)
    -- Show completion if we're in insert mode
    if vim.fn.mode() == "i" then pcall(function() require("blink.cmp").show() end) end
  else
    vim.notify("Blink.cmp disabled", vim.log.levels.INFO)
    -- Hide completion menu if visible
    pcall(function() require("blink.cmp").hide() end)
  end
end

return M
