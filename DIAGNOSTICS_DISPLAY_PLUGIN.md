# COC Diagnostics Display Plugin

A Neovim plugin that displays COC.nvim diagnostics for the current line or current file in a nicely formatted floating window.

## Features

- **COC.nvim Integration**: Uses COC.nvim diagnostics exclusively
- **Current Line Diagnostics**: Shows all COC diagnostics for the line where your cursor is positioned
- **Current File Diagnostics**: Shows all COC diagnostics for the entire current file
- **Beautiful UI**: Floating window with rounded borders and proper highlighting
- **Organized Display**: Diagnostics are grouped by severity (Error, Warning, Info, Hint)
- **Detailed Information**: Shows line numbers, columns, diagnostic codes, and sources
- **Easy Navigation**: Simple keymaps to close the window

## Keymaps

| Keymap | Function | Description |
|--------|----------|-------------|
| `<leader>dl` | `show_current_line_diagnostics()` | Show diagnostics for current line |
| `<leader>df` | `show_current_file_diagnostics()` | Show diagnostics for current file |

### Within the diagnostic window:
- `q` or `<Esc>` - Close the window
- `<CR>` - Close the window (future: jump to diagnostic)

## Display Format

The plugin shows COC diagnostics in a structured format:

```
  Current Line Diagnostics (COC)
─────────────────────────────────

E Error (2)
───────────
  E Error: Expected ';' after expression (ts2304) [typescript]
  E Error: Variable 'foo' is not defined (undefined-variable) [eslint]

W Warning (1)
─────────────
  W Warning: Line 45, Col 12: Unused variable 'bar' [eslint]

Total: 3 diagnostics
```

## Configuration

The plugin can be configured by calling the setup function:

```lua
require('user.diagnostics_display').setup({
  border = "rounded",        -- Border style for floating window
  width = 80,               -- Default width
  height = 20,              -- Default height
  max_width = 120,          -- Maximum width
  max_height = 30,          -- Maximum height
  title_current_line = "  Current Line Diagnostics (COC)",
  title_current_file = "  Current File Diagnostics (COC)",
})
```

## Requirements

- COC.nvim must be installed and configured
- COC language servers must be set up for your file types

## Integration

The plugin integrates with:
- **COC.nvim diagnostics exclusively** - uses `CocAction('diagnosticList')`
- Which-key for keymap descriptions
- Your existing diagnostic icons configuration
- COC highlight groups for proper theming

## Installation

The plugin is already integrated into this Neovim configuration. It's loaded in `init.lua` and keymaps are defined in both `keymaps.lua` and `whichkey.lua`.

## Files

- `lua/user/diagnostics_display.lua` - Main plugin code
- Keymaps added to `lua/user/keymaps.lua`
- Which-key integration in `lua/user/whichkey.lua`
- Loaded in `init.lua`

## Usage Examples

1. **Check current line**: Place cursor on a line with diagnostics and press `<leader>dl`
2. **Check entire file**: Press `<leader>df` to see all diagnostics in the current file
3. **Quick overview**: The window shows diagnostics grouped by severity for easy scanning