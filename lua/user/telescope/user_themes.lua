local themes = {}

-- Custom path display function to show relative paths from workspace root
local function relative_path_display(opts, path)
  local cwd = vim.fn.getcwd()
  local relative_path = vim.fn.fnamemodify(path, ":~:.")
  if path:sub(1, #cwd) == cwd then
    relative_path = path:sub(#cwd + 2) -- +2 to remove the leading slash
  end
  return relative_path
end

function themes.get_ivy_vertical(opts)
  opts = opts or {}

  local theme_opts = {
    theme = "ivy_vertical",

    sorting_strategy = "ascending",

    layout_strategy = "horizontal",
    layout_config = {
      height = 80,
      prompt_position = "top",
      width = 0.9
    },

    wrap_results = true,
    path_display = relative_path_display,

    border = true,
    borderchars = {
      prompt = { "─", " ", " ", " ", "─", "─", " ", " " },
      results = { " " },
      preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
    },
  }
  if opts.layout_config and opts.layout_config.prompt_position == "bottom" then
    theme_opts.borderchars = {
      prompt = { " ", " ", "─", " ", " ", " ", "─", "─" },
      results = { "─", " ", " ", " ", "─", "─", " ", " " },
      preview = { "─", " ", "─", "│", "┬", "─", "─", "╰" },
    }
  end

  return vim.tbl_deep_extend("force", theme_opts, opts)
end

return themes
