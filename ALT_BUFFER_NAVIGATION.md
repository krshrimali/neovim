# Alt+H/J/K/L Buffer Navigation

This feature enables seamless navigation between **all** Neovim buffers using Alt+H/J/K/L keys, including special buffers like SimpleTree, terminals, quickfix windows, and more.

## 🚀 Features

- **Universal Navigation**: Works with ALL buffer types including:
  - Regular file buffers
  - SimpleTree (file explorer)
  - Terminal buffers
  - Quickfix windows
  - Help buffers
  - Any other special buffers

- **Smart Direction Detection**: Uses intelligent positioning logic to find the best window in each direction
- **Multi-Mode Support**: Works in Normal, Insert, and Terminal modes
- **Fallback Support**: Falls back to Vim's default `<C-w>hjkl` when no suitable window is found
- **No Conflicts**: Carefully designed to avoid conflicts with existing keybindings

## ⌨️ Keybindings

| Key | Mode | Action |
|-----|------|--------|
| `Alt+H` | Normal, Insert, Terminal | Move to window on the left |
| `Alt+J` | Normal, Insert, Terminal | Move to window below |
| `Alt+K` | Normal, Insert, Terminal | Move to window above |
| `Alt+L` | Normal, Insert, Terminal | Move to window on the right |
| `<leader>wd` | Normal | Debug window layout (troubleshooting) |

## 🔧 Implementation Details

### Files Modified/Created

1. **`lua/user/buffer_navigation.lua`** (NEW)
   - Core navigation logic
   - Window position detection
   - Smart direction finding
   - Debug functionality

2. **`lua/user/keymaps.lua`** (MODIFIED)
   - Added Alt+H/J/K/L keybindings for all modes
   - Added debug keybinding

3. **`init.lua`** (MODIFIED)
   - Added require for buffer_navigation module

### How It Works

1. **Window Detection**: Scans all windows in the current tabpage
2. **Position Calculation**: Determines each window's position and dimensions
3. **Direction Logic**: Finds windows in the requested direction based on geometric positioning
4. **Smart Selection**: Chooses the closest window with best alignment
5. **Fallback**: Uses Vim's default navigation if no suitable window found

### Key Features

- **Floating Window Support**: Handles both normal and floating windows
- **Buffer Type Agnostic**: Works with any focusable buffer
- **Distance-Based Selection**: Chooses the nearest window in the direction
- **Alignment Preference**: Prefers better-aligned windows when distances are equal

## 🧪 Testing

Run the test script to verify everything works:

```vim
:luafile test_buffer_navigation.lua
```

This will:
- Test module loading
- Verify all functions exist
- Check keybinding registration
- Show current window layout
- Display usage instructions

## 🐛 Troubleshooting

### Debug Window Layout
Use `<leader>wd` to see the current window layout:
```
=== Window Layout Debug ===
Current window: 1000
Win 1000: pos(0,0) size(80x24) buf=normal ft=lua focusable=yes [CURRENT]
  Name: buffer_navigation.lua
Win 1001: pos(80,0) size(30x24) buf=nofile ft=SimpleTree focusable=yes
  Name: 
```

### Common Issues

1. **Navigation not working**: 
   - Check if keybindings are registered with `:map <A-h>`
   - Verify module loads with `:lua print(require('user.buffer_navigation'))`

2. **Can't navigate to specific buffer**:
   - Use `<leader>wd` to see if the window is detected
   - Check if the buffer is marked as focusable

3. **Alt keys not working**:
   - Some terminals may not send Alt key combinations correctly
   - Try using `<M-h>` instead of `<A-h>` if needed

## 🎯 Usage Examples

### Basic Navigation
- Open SimpleTree with `-` (Oil command)
- Open a file in a split: `:vsplit filename.lua`
- Use `Alt+H` to move to SimpleTree
- Use `Alt+L` to move back to your file

### Terminal Navigation
- Open terminal with `Alt+1` (existing binding)
- Use `Alt+H/J/K/L` to navigate between terminal and other windows
- Works even when terminal is in insert mode

### Multi-Window Setup
- Split windows: `:split`, `:vsplit`
- Open multiple files
- Navigate seamlessly with `Alt+H/J/K/L`

## 🔄 Compatibility

- **No Conflicts**: Checked against all existing Alt keybindings
- **Mode Support**: Works in Normal, Insert, and Terminal modes
- **Fallback**: Uses Vim's default navigation when needed
- **Special Buffers**: Designed to work with SimpleTree and other special buffers

## 📝 Notes

- The feature is loaded immediately on Neovim startup for instant availability
- All navigation is logged for debugging purposes when needed
- The system is designed to be robust and handle edge cases gracefully
- Works with both regular and floating windows

---

**Enjoy seamless buffer navigation! 🎉**