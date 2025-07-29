require "user.plugins"
require "user.keymaps"
require "user.autocommands"
require "user.colorscheme"
require "user.options"

-- Load UI components immediately for consistent experience
-- require "user.lualine" -- Now loaded in plugin config
-- require "user.notify" -- Now loaded in plugin config  
-- require "user.dressing" -- Now loaded in plugin config

-- Defer loading of heavy components
vim.defer_fn(function()
    -- Load terminal configuration when needed
    require "user.terminal"
end, 100)

-- Load these only when plugins are loaded (handled by lazy loading now)
-- require "user.telescope" -- Now lazy loaded
-- require "user.treesitter" -- Now lazy loaded
-- require "user.comment" -- Now lazy loaded
-- require "user.gitsigns" -- Now lazy loaded
-- require "user.nvim-tree" -- Now lazy loaded
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
-- require "user.coc" -- Now lazy loaded with defer

-- Keep essential immediate configurations
require "user.colorizer"
require "user.functions" 
require "user.surround"
require "user.nvim_transparent"

-- Setup buffer browser (lazy loaded on keymap)
vim.keymap.set("n", "<leader>bb", function()
  require("user.buffer_browser").open_buffer_browser()
end, { desc = "Buffer Browser", silent = true })

vim.keymap.set("n", "<leader>bs", function()
  require("user.buffer_browser").toggle_sidebar()
end, { desc = "Buffer Sidebar", silent = true })

-- These are now handled by plugin lazy loading
-- require("goto-preview").setup {} -- Now lazy loaded
-- require("neogit").setup {} -- Now lazy loaded  
-- require("telescope").load_extension "cmdline" -- Now lazy loaded
-- require("telescope").load_extension "projects" -- Now lazy loaded
