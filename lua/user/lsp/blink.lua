-- Blink.cmp Completion Configuration
-- Fast, modern completion engine with auto-trigger enabled by default

local M = {}

function M.setup()
  require("blink.cmp").setup {
    -- Keymap configuration (matching CoC keybindings)
    keymap = {
      preset = "default",
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-y>"] = { "accept", "fallback" },
      ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-j>"] = { "snippet_forward", "fallback" },
    },

    -- Appearance settings
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = "mono",
    },

    -- Sources configuration
    sources = {
      default = { "lsp", "path", "snippets", "buffer" },
    },

    -- Completion behavior
    completion = {
      -- Documentation window
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 200,
        window = {
          border = "rounded",
        },
      },

      -- Menu configuration
      menu = {
        border = "rounded",
        draw = {
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },

      -- Ghost text (inline preview)
      ghost_text = {
        enabled = true,
      },
    },

    -- Signature help
    signature = {
      enabled = true,
      window = {
        border = "rounded",
      },
    },
  }
end

-- Toggle auto-completion (matching CoC's <leader>tc)
_G.blink_autocomplete_enabled = true

function M.toggle_autocomplete()
  _G.blink_autocomplete_enabled = not _G.blink_autocomplete_enabled

  local blink = require "blink.cmp"

  if _G.blink_autocomplete_enabled then
    -- Enable auto-trigger
    blink.setup {
      completion = {
        trigger = {
          show_on_insert_on_trigger_character = true,
        },
      },
    }
    vim.notify("Auto-completion enabled", vim.log.levels.INFO)
  else
    -- Disable auto-trigger (manual only with C-Space)
    blink.setup {
      completion = {
        trigger = {
          show_on_insert_on_trigger_character = false,
        },
      },
    }
    vim.notify("Auto-completion disabled (use C-Space to trigger)", vim.log.levels.INFO)
  end
end

return M
