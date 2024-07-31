local status_ok, bufferline = pcall(require, "bufferline")
if not status_ok then
  return
end

bufferline.setup {
  options = {
    -- numbers = "both",
    show_buffer_icons = false,
    show_close_icon = true,
    show_buffer_close_icons = true,
    separator_style = "slant",
    indicator = {
      -- style = 'underline',
    },
    hover = {
      enabled = true,
    },
  }
}
