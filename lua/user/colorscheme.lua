-- local colorscheme = "darkplus"
-- local colorscheme = "moonfly"
-- local colorscheme = "gruvbox"

-- for catppuccin
-- local colorscheme = "catppuccin"
-- vim.g.catppuccin_flavour = "mocha"
-- local colorscheme = "darkplus"
-- local colorscheme = "gruvbox"
-- local colorscheme = "darkplus"
-- -- local colorscheme = "oxocarbon"

-- local colorscheme = "gruvbox-light"
-- local colorscheme = "catppuccin"
-- vim.o.background="light"
-- vim.g.gruvbox_material_background = "hard"
-- vim.cmd [[colorscheme darkplus]]

-- local colorscheme = "bluloco-dark"
-- vim.cmd [[colorscheme bluloco-dark]]
-- local colorscheme = "darkplus"
-- vim.cmd [[colorscheme darkplus]]
-- -- vim.cmd [[ colorscheme oxocarbon ]]

-- vim.g.onedarker_italic_keywords = false

-- vim.g.onedarker_italic_functions = false

-- vim.g.onedarker_italic_comments = true

-- vim.g.onedarker_italic_loops = false

-- vim.g.onedarker_italic_conditionals = false

-- wezterm.gui is not available to the mux server, so take care to
-- do something reasonable when this config is evaluated by the mux
local colorscheme = "darkplus"

local status_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
if not status_ok then
  vim.notify("colorscheme " .. colorscheme .. " not found!")
  return
end
