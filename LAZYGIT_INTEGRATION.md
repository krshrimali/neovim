# Lazygit Integration

This configuration provides comprehensive lazygit integration with Neovim using toggleterm, offering two distinct modes of operation.

## Features

### 🚀 Dual Mode Support
- **Floating Window Mode**: Opens lazygit in a large floating window (95% of screen size)
- **Tab Mode**: Opens lazygit in a new tab for full-screen experience

### ⌨️ Key Bindings

| Keymap | Mode | Description |
|--------|------|-------------|
| `<leader>gg` | Normal | Open lazygit in floating window |
| `<leader>gt` | Normal | Open lazygit in new tab |
| `<Esc>` | Terminal | Exit insert mode (go to normal mode) |
| `i` / `a` | Normal (in lazygit) | Enter insert mode |
| `q` | Normal (in lazygit) | Close lazygit |

### 🎯 Terminal Mode Handling

- **Always starts in insert mode**: Lazygit opens ready for interaction
- **Proper escape handling**: `<Esc>` exits to normal mode without interfering with lazygit's bindings
- **Clean UI**: Removes line numbers, sign column, and other UI elements for distraction-free experience
- **Current workspace**: Always opens in the current Neovim working directory

### 🔧 Configuration Details

#### Floating Window Configuration
- Border: Rounded
- Size: 95% of screen width and height
- Centered positioning
- Clean background with proper highlighting

#### Tab Configuration
- Full-screen experience
- Tab title set to "lazygit"
- Same key bindings as floating mode
- Closes tab when exiting lazygit

### 📁 File Structure

```
lua/user/
├── lazygit.lua          # Main lazygit configuration
├── terminal.lua         # Legacy compatibility
├── keymaps.lua          # Direct key mappings
└── whichkey.lua         # Which-key integration
```

### 🛠️ Implementation Details

The integration uses toggleterm's Terminal class to create two separate terminal instances:
- `lazygit_float` (count: 98) - For floating window mode
- `lazygit_tab` (count: 97) - For tab mode

Both instances are configured with:
- `start_in_insert = true`
- `close_on_exit = true`
- Proper key mappings for terminal mode handling
- Working directory synchronization

### 🔄 Backward Compatibility

The original `<leader>gg` keymap continues to work and now opens the floating window mode. The legacy `lazygit_toggle()` function in `terminal.lua` has been updated to use the new implementation.

### 💡 Usage Tips

1. **Floating Window**: Best for quick git operations while keeping your current buffer layout
2. **Tab Mode**: Ideal for complex git workflows that require full attention
3. **Normal Mode**: Use `q` to quickly close lazygit from normal mode
4. **Insert Mode**: Lazygit starts ready for interaction - no need to press `i` first

### 🚨 Requirements

- `lazygit` must be installed on the system
- `toggleterm.nvim` plugin must be configured
- Neovim with Lua support

The integration handles the current workspace automatically, so lazygit will always open in the correct directory context.