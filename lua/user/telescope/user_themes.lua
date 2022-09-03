local themes = {}

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
    path_display = "absolute",

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
