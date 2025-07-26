local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup {
  options = {
    -- numbers = "both",
    show_buffer_icons = vim.g.enable_nerd_icons,
    show_close_icon = false,
    show_buffer_close_icons = false,
    separator_style = "|",
    indicator = {
      -- style = 'underline',
    },
    hover = {
      enabled = true,
    },
  }
}
