local ok, cybu = pcall(require, "cybu")
if not ok then
  return
end
cybu.setup {
  position = {
    relative_to = "win", -- win, editor, cursor
    anchor = "topright", -- topleft, topcenter, topright,
    -- centerleft, center, centerright,
    -- bottomleft, bottomcenter, bottomright
    -- vertical_offset = 10, -- vertical offset from anchor in lines
    -- horizontal_offset = 0, -- vertical offset from anchor in columns
    -- max_win_height = 5, -- height of cybu window in lines
    -- max_win_width = 0.5, -- integer for absolute in columns
    -- float for relative to win/editor width
  },
  display_time = 1750, -- time the cybu window is displayed
  style = {
    path = "absolute", -- absolute, relative, tail (filename only)
    border = "rounded", -- single, double, rounded, none
    separator = " ", -- string used as separator
    -- prefix = "…", -- string used as prefix for truncated paths
    padding = 1, -- left & right padding in number of spaces
    hide_buffer_id = true,
    devicons = {
      enabled = false, -- disable web dev icons to avoid nerd fonts
      colored = false, -- disable color for web dev icons
    },
    highlights = {
      current_buffer = "CybuFocus",
      adjacent_buffers = "CybuAdjacent",
      background = "CybuBackground",
      border = "CybuBorder",
    },
    behavior = {
      mode = {
        default = {
          switch = "immediate",
          view = "rolling",
        },
        auto = {
          view = "rolling",
        },
      },
      show_on_autocmd = false,
    }
  },
}
-- vim.keymap.set("n", "<up>", "<Plug>(CybuPrev)")
-- vim.keymap.set("n", "<down>", "<Plug>(CybuNext)")
vim.keymap.set("n", "<C-S-h>", "<Plug>(CybuLastusedPrev)")
vim.keymap.set("n", "<C-S-l>", "<Plug>(CybuLastusedNext)")
vim.keymap.set("n", "<C-h>", "<Plug>(CybuPrev)")
vim.keymap.set("n", "<C-l>", "<Plug>(CybuNext)")
