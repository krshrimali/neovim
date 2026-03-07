local status_ok, bqf = pcall(require, "bqf")
if not status_ok then return end

bqf.setup {
  auto_enable = true,
  auto_resize_height = true,
  -- Disable magic window so QF+preview use a stable layout; prevents preview
  -- float from overlapping the editor when QF is in a side split.
  magic_window = false,
  border_chars = { "┃", "┃", "━", "━", "┏", "┓", "┗", "┛", "█" },
  preview = {
    auto_preview = true,
    wrap = true,
    -- Opaque preview so any remaining overlap doesn’t show editor content through.
    winblend = 0,
  },
}
