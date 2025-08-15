-- Blink.cmp configuration for fast LSP completion
-- https://github.com/Saghen/blink.cmp

require('blink.cmp').setup({
  -- 'default' for mappings similar to built-in completion
  -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
  -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
  -- See the "default configuration" section below for full documentation on how to define
  -- your own keymap.
  keymap = { preset = 'default' },

  appearance = {
    -- Sets the fallback highlight groups to nvim-cmp's highlight groups
    -- Useful for when your theme doesn't support blink.cmp
    -- will be removed in a future release
    use_nvim_cmp_as_default = true,
    -- Set to 'mono' for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
    -- Adjusts spacing to ensure icons are aligned
    nerd_font_variant = 'mono'
  },

  -- default list of enabled providers defined so that you can extend it
  -- elsewhere in your config, without redefining it, due to `opts_extend`
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
    -- optionally disable cmdline completions
    -- cmdline = {},
  },

  -- experimental signature help support
  signature = { enabled = true },

  completion = {
    -- 'prefix' will fuzzy match on the text before the cursor
    -- 'full' will fuzzy match on the text before and after the cursor
    -- example: 'foo_|_bar' will match 'foo_' for 'prefix' and 'foo__bar' for 'full'
    keyword = { range = 'full' },

    -- Disable auto brackets
    -- NOTE: some LSPs may add auto brackets themselves anyway
    accept = { auto_brackets = { enabled = true } },

    -- Insert completion item on selection, don't select by default
    list = { selection = 'preselect' },

    menu = {
      -- Don't automatically show the completion menu
      auto_show = true,

      -- nvim-cmp style menu
      draw = {
        treesitter = { "lsp" },
        columns = {
          { "kind_icon" },
          { "label", "label_description", gap = 1 },
          { "source_name" },
        },
      }
    },

    -- Show documentation when selecting a completion item
    documentation = {
      auto_show = true,
      auto_show_delay_ms = 200,
      treesitter_highlighting = true,
      window = { border = 'rounded' }
    },

    -- Display a preview of the selected item on the current line
    ghost_text = { enabled = true },
  },

  -- Experimental auto-brackets support
  snippets = {
    expand = function(snippet) vim.snippet.expand(snippet) end,
    active = function(filter)
      if filter and filter.direction then
        return vim.snippet.active({ direction = filter.direction })
      end
      return vim.snippet.active()
    end,
    jump = function(direction) vim.snippet.jump(direction) end,
  },

  -- Default list of providers
  providers = {
    lsp = {
      name = 'LSP',
      module = 'blink.cmp.sources.lsp',
      
      --- *All* of the providers have the following options available
      --- NOTE: All of these options may be functions to get dynamic behavior
      --- See the type definitions for more information
      enabled = true, -- Whether or not to enable the provider
      async = true, -- Whether we should wait for the provider to return before showing the completions
      timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
      transform_items = nil, -- Function to transform the items before they're returned
      should_show_items = true, -- Whether or not to show the items
      max_items = nil, -- Maximum number of items to display in the menu
      min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
      -- If this provider returns 0 items, it will fallback to these providers.
      fallbacks = { 'buffer' },
      score_offset = 0, -- Boost/penalize the score of the items
      override = nil, -- Override the source's functions
    },
    path = {
      name = 'Path',
      module = 'blink.cmp.sources.path',
      score_offset = 3,
      fallbacks = { 'buffer' },
      opts = {
        trailing_slash = false,
        label_trailing_slash = true,
        get_cwd = function(context) return vim.fn.expand(('#%d:p:h'):format(context.bufnr)) end,
        show_hidden_files_by_default = false,
      }
    },
    snippets = {
      name = 'Snippets',
      module = 'blink.cmp.sources.snippets',
      score_offset = -3,
      fallbacks = { 'buffer' },
      opts = {
        friendly_snippets = true,
        search_paths = { vim.fn.stdpath('config') .. '/snippets' },
        global_snippets = { 'all' },
        extended_filetypes = {},
        ignored_filetypes = {},
      }
    },
    buffer = {
      name = 'Buffer',
      module = 'blink.cmp.sources.buffer',
      fallbacks = {},
      opts = {
        -- default to all visible buffers
        get_bufnrs = function()
          return vim
            .iter(vim.api.nvim_list_wins())
            :map(function(win) return vim.api.nvim_win_get_buf(win) end)
            :filter(function(buf) return vim.bo[buf].buftype ~= 'nofile' end)
            :totable()
        end,
      }
    }
  }
})