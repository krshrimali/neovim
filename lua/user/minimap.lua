-- Minimap configuration for VSCode-like functionality
-- Plugin: wfxr/minimap.vim

local M = {}

-- Minimap configuration
vim.g.minimap_width = 10
vim.g.minimap_auto_start = 0  -- Don't start automatically
vim.g.minimap_auto_start_win_enter = 0  -- Don't start when entering windows
vim.g.minimap_block_filetypes = {
  'fugitive',
  'nerdtree',
  'tagbar',
  'fzf',
  'help',
  'qf',
  'terminal',
  'NvimTree',
  'trouble',
  'outline',
  'spectre_panel'
}
vim.g.minimap_block_buftypes = {
  'nofile',
  'nowrite',
  'quickfix',
  'terminal',
  'prompt'
}
vim.g.minimap_close_filetypes = {
  'startify',
  'netrw',
  'vim-plug'
}
vim.g.minimap_highlight_range = 1  -- Highlight current viewport
vim.g.minimap_highlight_search = 1  -- Highlight search results
vim.g.minimap_git_colors = 1  -- Enable git colors if available
vim.g.minimap_cursor_color = 'MinimapCurrentLine'  -- Cursor line color
vim.g.minimap_range_color = 'MinimapRange'  -- Range highlight color
vim.g.minimap_search_color = 'MinimapSearch'  -- Search highlight color

-- Custom highlight groups for better visibility
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    -- Set minimap colors to blend well with the theme
    vim.api.nvim_set_hl(0, 'MinimapCurrentLine', { bg = '#3e4451', fg = '#61afef' })
    vim.api.nvim_set_hl(0, 'MinimapRange', { bg = '#2c313c', fg = '#abb2bf' })
    vim.api.nvim_set_hl(0, 'MinimapSearch', { bg = '#e5c07b', fg = '#282c34' })
  end,
})

-- Apply colors immediately
vim.api.nvim_set_hl(0, 'MinimapCurrentLine', { bg = '#3e4451', fg = '#61afef' })
vim.api.nvim_set_hl(0, 'MinimapRange', { bg = '#2c313c', fg = '#abb2bf' })
vim.api.nvim_set_hl(0, 'MinimapSearch', { bg = '#e5c07b', fg = '#282c34' })

-- Auto-close minimap when only minimap window remains
vim.api.nvim_create_autocmd("WinEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.filetype == 'minimap' then
      local wins = vim.api.nvim_list_wins()
      local normal_wins = 0
      for _, win in ipairs(wins) do
        local buf = vim.api.nvim_win_get_buf(win)
        local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
        if ft ~= 'minimap' and ft ~= 'NvimTree' and ft ~= 'trouble' then
          normal_wins = normal_wins + 1
        end
      end
      if normal_wins == 0 then
        vim.cmd('MinimapClose')
      end
    end
  end,
})

-- Function to toggle minimap with smart positioning
function M.smart_toggle()
  local minimap_wins = vim.tbl_filter(function(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.api.nvim_buf_get_option(buf, 'filetype') == 'minimap'
  end, vim.api.nvim_list_wins())
  
  if #minimap_wins > 0 then
    vim.cmd('MinimapClose')
  else
    vim.cmd('Minimap')
    -- Focus back to the original window
    vim.cmd('wincmd p')
  end
end

-- Function to refresh minimap if open
function M.refresh_if_open()
  local minimap_wins = vim.tbl_filter(function(win)
    local buf = vim.api.nvim_win_get_buf(win)
    return vim.api.nvim_buf_get_option(buf, 'filetype') == 'minimap'
  end, vim.api.nvim_list_wins())
  
  if #minimap_wins > 0 then
    vim.cmd('MinimapRefresh')
  end
end

-- Auto-refresh minimap on certain events
vim.api.nvim_create_autocmd({ "BufWritePost", "TextChanged", "TextChangedI" }, {
  pattern = "*",
  callback = function()
    -- Small delay to avoid too frequent refreshes
    vim.defer_fn(function()
      M.refresh_if_open()
    end, 100)
  end,
})

-- Setup function
function M.setup()
  -- Additional setup can go here if needed
  vim.notify("Minimap configuration loaded", vim.log.levels.INFO)
end

return M