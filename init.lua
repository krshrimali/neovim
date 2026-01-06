require "user.options" -- Load options first
require "user.plugins" -- Load plugins (native LSP with nvim-lspconfig)
require "user.keymaps"
require "user.autocommands"
require "user.colorscheme"

-- Load UI components immediately for consistent experience
-- require "user.lualine" -- Now loaded in plugin config
-- require "user.notify" -- Now loaded in plugin config
-- require "user.dressing" -- Now loaded in plugin config

-- Defer loading of heavy components
vim.defer_fn(function()
  -- Load native terminal configuration (includes lazygit)
  require "user.terminal"
end, 500) -- Increased delay for better startup

-- Load these only when plugins are loaded (handled by lazy loading now)
-- telescope replaced with fzf-lua
-- require "user.treesitter" -- Now lazy loaded
-- require "user.comment" -- Now lazy loaded
-- require "user.gitsigns" -- Now lazy loaded
-- require "user.nvim-tree" -- Replaced with custom simple_tree.lua
-- require "user.toggleterm" -- Now lazy loaded
-- require "user.whichkey" -- Now lazy loaded
-- require "user.numb" -- Now lazy loaded
-- require "user.colorizer" -- Still needed immediately for syntax highlighting
-- require "user.spectre" -- Now lazy loaded
-- require "user.todo-comments" -- Now lazy loaded
-- require "user.git-blame" -- Now lazy loaded
-- require "user.registers" -- Now lazy loaded
-- require "user.functions" -- Keep for immediate functions
-- require "user.illuminate" -- Now lazy loaded
-- require "user.cybu" -- Now lazy loaded
-- require "user.bqf" -- Now lazy loaded
-- require "user.surround" -- Still needed for immediate text operations
-- require "user.nvim_transparent" -- Keep for immediate UI
-- Native LSP configured in lua/user/lsp/init.lua (via plugins.lua)

-- Defer non-essential configurations
vim.defer_fn(function()
  require "user.colorizer"
  require "user.functions"
  require "user.surround"
  require "user.nvim_transparent"
  require("user.diagnostics_display").setup()
  require "user.buffer_navigation"
  -- Native LSP virtual diagnostics is loaded via lsp/init.lua
  -- Outline/breadcrumbs available via <leader>lb keymap
end, 50) -- Small delay for better startup

-- Native LSP completion handled by Neovim's built-in vim.lsp.completion (configured in lua/user/lsp/blink.lua)

-- fzf-lua is now loaded via lazy.nvim

-- Initialize Keymap Viewer (after plugins are loaded)
vim.defer_fn(function() require "user.keymap_viewer" end, 100) -- Small delay to ensure FzfLua is available

-- Buffer management with FzfLua
vim.keymap.set(
  "n",
  "<leader>bb",
  "<cmd>FzfLua buffers<cr>",
  { desc = "FzfLua Buffers", silent = true }
)

vim.keymap.set(
  "n",
  "<leader>bs",
  "<cmd>FzfLua buffers<cr>",
  { desc = "FzfLua Buffers", silent = true }
)

-- These are now handled by plugin lazy loading
-- require("goto-preview").setup {} -- Now configured via goto_preview_lsp.lua
-- require("neogit").setup {} -- Now lazy loaded
-- telescope extensions replaced with fzf-lua
-- Diagnostic config is now handled by lsp.lua and diagnostics_display.lua
-- vim.diagnostic.config { virtual_lines = true }
-- Defer sign definitions
vim.defer_fn(function()
  vim.fn.sign_define("LspCodeAction", { text = "", texthl = "", linehl = "", numhl = "" })
  vim.fn.sign_define("LspCodeActionAvailable", { text = "", texthl = "", linehl = "", numhl = "" })
end, 100)
