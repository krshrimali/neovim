local status_ok, bqf = pcall(require, "bqf")
if not status_ok then return end

bqf.setup {
  auto_enable = true,
  auto_resize_height = true,
  border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
  preview = {
    auto_preview = true,
    wrap = true,
  },
}
