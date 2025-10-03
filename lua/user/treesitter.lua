local status_ok, configs = pcall(require, "nvim-treesitter.configs")
if not status_ok then return end

configs.setup {
  -- Only install minimal parsers to reduce startup time
  ensure_installed = { "lua", "python" }, -- Minimal set, others installed on demand
  sync_install = false, -- install languages synchronously (only applied to `ensure_installed`)
  -- max_file_lines = 3000, -- Removed to ensure no interference with LSP
  ignore_install = { "" }, -- List of parsers to ignore installing

  highlight = {
    enable = true, -- false will disable the whole extension
    disable = { "markdown", "css", "html" }, -- Disable for heavy file types
    -- Disable only for VERY large files and terminal buffers
    disable = function(lang, buf)
      -- Disable for terminal buffers to prevent highlighting errors
      local buftype = vim.api.nvim_buf_get_option(buf, "buftype")
      if buftype == "terminal" then return true end

      local max_filesize = 500 * 1024 -- 500KB limit - only disable for very large files
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
      if ok and stats and stats.size > max_filesize then return true end
    end,
  },

  -- Disable heavy features for startup performance
  autopairs = {
    enable = false, -- Disabled for better performance
  },

  indent = {
    enable = true,
    disable = { "python", "css", "rust", "cpp", "yaml", "json", "html", "javascript" }, -- More disabled for performance
  },

  -- Disable incremental selection to reduce startup time
  incremental_selection = {
    enable = false, -- Disabled for better startup performance
  },

  -- Disable matchup for better performance
  matchup = {
    enable = false, -- Disabled for better startup performance
  },

  -- Disable autotag for better performance
  autotag = {
    enable = false, -- Disabled for better startup performance
  },

  -- Disable rainbow for better performance
  rainbow = {
    enable = false, -- Disabled for better startup performance
  },

  -- Disable playground for better performance
  playground = {
    enable = false, -- Disabled for better startup performance
  },

  -- Simplify textobjects or disable for better performance
  textobjects = {
    select = {
      enable = true,
      lookahead = false, -- Disabled for better performance
      keymaps = {
        -- Keep only essential textobjects
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
    move = {
      enable = false, -- Disabled for better startup performance
    },
    swap = {
      enable = false, -- Disabled for better startup performance
    },
  },
}
