# Lazygit Terminal Integration Fixes

## Issues Fixed

### 1. Lag with Navigation Keys (j, k, etc.)
**Problem**: Pressing navigation keys in lazygit UI had noticeable lag.

**Root Cause**: The global `TermOpen` autocmd was applying generic terminal keymaps to all terminal buffers, including lazygit. This created keymap conflicts and timeout issues.

**Solution**: 
- Set lazygit buffers to have `filetype = "lazygit"` before opening the terminal
- Modified the global `TermOpen` autocmd to skip lazygit buffers
- Created specialized keymaps only for lazygit that don't conflict with its internal navigation

### 2. Escape Key Behavior
**Problem**: Pressing `<Esc>` in lazygit would exit terminal mode and enter Neovim normal mode instead of working within lazygit's UI as expected.

**Root Cause**: The global terminal keymaps were binding `<Esc>` to `<C-\><C-n>` which exits terminal mode.

**Solution**:
- Lazygit buffers now only bind `<C-\><C-n>` for exiting terminal mode
- `<Esc>` key is left unmapped so it passes through to lazygit
- This allows lazygit to handle `<Esc>` according to its own UI logic

## Technical Changes

### Modified Functions
- `M.lazygit_float()`: Optimized window creation, minimal keymaps, no unnecessary navigation bindings
- `M.lazygit_tab()`: Simplified implementation with minimal overhead
- Global `TermOpen` autocmd: Now skips lazygit buffers

### Performance Optimizations
- **Removed excessive keymaps**: Eliminated window navigation keymaps (`<C-h/j/k/l>`) that were causing conflicts
- **Streamlined buffer creation**: Set buffer properties before window creation
- **Inline window creation**: Avoided helper function overhead for floating windows
- **Minimal keymap set**: Only essential keymaps to reduce processing overhead

### Keymaps for Lazygit
- `q`: Close lazygit window (from normal mode, floating window only)
- `<Esc>`: **Unmapped** - passes through to lazygit
- **No terminal mode keymaps**: All navigation handled by lazygit itself

### Keymaps for Regular Terminals
- `<Esc>`: Exit terminal mode
- `<C-h/j/k/l>`: Window navigation
- `q`: Close terminal (from normal mode)

## Usage

Both lazygit modes should now work smoothly:
- `<leader>gg`: Floating lazygit window
- `<leader>gG`: Lazygit in new tab

Navigation within lazygit should be responsive, and `<Esc>` should work as expected within the lazygit interface.