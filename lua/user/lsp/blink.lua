-- Blink.cmp completion configuration
local M = {}

-- Global state for toggling completion
_G.blink_enabled = true

function M.setup()
  require("blink.cmp").setup {
    -- Control enabled state with a function
    enabled = function()
      -- Check global toggle state first
      if not _G.blink_enabled then return false end

      -- Don't enable in certain buffer types and filetypes
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = 0 })
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })

      -- Disable in prompts, terminals, and tree viewers
      if buftype == "prompt" or buftype == "terminal" or buftype == "nofile" then return false end

      -- Disable in specific filetypes
      local disabled_filetypes = {
        "NvimTree",
        "TelescopePrompt",
        "fzf",
        "help",
        "vim",
      }

      for _, ft in ipairs(disabled_filetypes) do
        if filetype == ft then return false end
      end

      -- Additional check: don't enable in very small buffers (likely prompts)
      local bufname = vim.api.nvim_buf_get_name(0)
      if bufname:match "^%s*$" or bufname:match "input://" then return false end

      return true
    end,

    -- Custom keymap: Tab/Shift+Tab for navigation, Enter/Ctrl+y to accept, Ctrl+Space to trigger
    keymap = {
      preset = "default",
      ["<C-Space>"] = { "show", "fallback" }, -- Manual trigger with Ctrl+Space
      ["<Tab>"] = { "select_next", "fallback" },
      ["<S-Tab>"] = { "select_prev", "fallback" },
      ["<CR>"] = { "accept", "fallback" },
      ["<C-y>"] = { "accept", "fallback" },
    },

    -- Appearance settings
    appearance = {
      -- Nerd fonts disabled - use ASCII icons only
      use_nvim_cmp_as_default = false,
      kind_icons = {
        Text = "T",
        Method = "m",
        Function = "f",
        Constructor = "c",
        Field = "F",
        Variable = "v",
        Class = "C",
        Interface = "I",
        Module = "M",
        Property = "p",
        Unit = "u",
        Value = "V",
        Enum = "E",
        Keyword = "k",
        Snippet = "s",
        Color = "C",
        File = "f",
        Reference = "r",
        Folder = "d",
        EnumMember = "e",
        Constant = "c",
        Struct = "S",
        Event = "E",
        Operator = "o",
        TypeParameter = "t",
      },
    },

    -- Completion settings
    completion = {
      menu = {
        auto_show = false, -- Disable auto-show, only show on Ctrl+Space
        draw = {
          -- Disable all icon sources, use only our custom kind_icons
          columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
        },
      },
      documentation = {
        auto_show = true, -- Auto-show documentation when menu is visible
        auto_show_delay_ms = 200,
      },
    },

    -- Sources configuration
    sources = {
      default = { "lsp", "path", "buffer" },
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
