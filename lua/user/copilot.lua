-- -- For copilot.vim
-- -- vim.g.copilot_filetypes = {
-- --   ["*"] = false,
-- -- }

-- -- vim.cmd [[
-- --   imap <silent><script><expr> <C-A> copilot#Accept("\<CR>")
-- --   let g:copilot_no_tab_map = v:true
-- -- ]]

-- local status_ok, copilot = pcall(require, "copilot")
-- if not status_ok then
--   return
-- end

-- copilot.setup {
--   cmp = {
--     enabled = true,
--     method = "getCompletionsCycling",
--   },
--   panel = { -- no config options yet
--     enabled = true,
--   },
--   ft_disable = { "markdown" },
--   -- plugin_manager_path = vim.fn.stdpath "data" .. "/site/pack/packer",
--   server_opts_overrides = {
--     -- trace = "verbose",
--     settings = {
--       advanced = {
--         -- listCount = 10, -- #completions for panel
--         inlineSuggestCount = 3, -- #completions for getCompletions
--       },
--     },
--   },
-- }

require('copilot').setup({
  panel = {
    enabled = true,
    auto_refresh = false,
    keymap = {
      jump_prev = "[[",
      jump_next = "]]",
      accept = "<CR>",
      refresh = "gr",
      open = "<M-CR>"
    },
    layout = {
      position = "bottom", -- | top | left | right
      ratio = 0.4
    },
  },
  suggestion = {
    enabled = true,
    auto_trigger = true,
    hide_during_completion = false,
    debounce = 75,
    keymap = {
      accept = "<C-l>",
      accept_word = false,
      accept_line = false,
      next = "<C-]>",
      prev = "<C-[>",
      dismiss = "<C-]>",
    },
  },
  filetypes = {
    yaml = false,
    markdown = false,
    help = false,
    gitcommit = false,
    gitrebase = false,
    hgcommit = false,
    svn = false,
    cvs = false,
    ["."] = false,
  },
  copilot_node_command = 'node', -- Node.js version must be > 18.x
  server_opts_overrides = {},
})
