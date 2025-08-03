# Terminal Treesitter Fix

## Problem
When creating horizontal terminals in Neovim, you were experiencing this error:

```
Error in decoration provider "line" (ns=nvim.treesitter.highlighter):
Error executing lua: ....3/share/nvim/runtime/lua/vim/treesitter/highlighter.lua:370: Invalid 'end_row': out of range
```

## Root Cause
The error occurs because:
1. Treesitter tries to apply syntax highlighting to terminal buffers
2. Terminal buffers have dynamic content that changes rapidly
3. The highlighter tries to set extmarks beyond the buffer boundaries
4. This causes the "Invalid 'end_row': out of range" error

## Solution
The fix implements multiple layers of protection with safe error handling:

### 1. Treesitter Configuration Update (`lua/user/treesitter.lua`)
- Added a check in the `disable` function to exclude terminal buffers from highlighting
- Terminal buffers are identified by `buftype == "terminal"`

### 2. Terminal Buffer Safety (`lua/user/terminal.lua`)
- Added `disable_treesitter_for_terminal()` function with safe error handling
- Added `configure_terminal_buffer()` function with buffer validation and safe option setting
- Updated all terminal creation functions to use these safety functions
- Added proper buffer configuration before opening terminals
- Added autocmds to handle edge cases with error protection

### 3. Safe Buffer Configuration
All terminal buffers now have these settings applied safely:
- `buftype = "terminal"` - Properly identifies the buffer type
- `modifiable = true` - Allows terminal input
- `swapfile = false` - Prevents swap file creation
- `syntax = ""` - Disables syntax highlighting

### 4. Error Handling
- All buffer operations are wrapped in `pcall()` for safety
- Buffer validity is checked before any operations
- Invalid arguments are handled gracefully

## Files Modified
1. `lua/user/treesitter.lua` - Added terminal buffer exclusion
2. `lua/user/terminal.lua` - Added safety functions and buffer configuration

## Testing
The fix has been applied to all terminal types:
- Horizontal terminals (`<leader>T3` or `<A-3>`)
- Vertical terminals (`<leader>T2` or `<A-2>`)
- Float terminals (`<leader>T1` or `<A-1>`)
- Centered terminals (`<C-\>`)

## Verification
To test the fix:
1. Open Neovim
2. Try creating a horizontal terminal with `<leader>T3`
3. No treesitter errors should occur
4. Only one terminal window should be created (no duplicate terminals)
5. The terminal should work normally

## Additional Fixes
- Fixed duplicate terminal creation issue in horizontal terminals
- Improved buffer management to ensure only one terminal instance per window
- Enhanced TermOpen autocmd to only process actual terminal buffers
- Fixed terminal toggle functionality when terminals are manually closed
- Added proper cleanup of terminal tracking when windows are closed
- Improved toggle logic to handle edge cases and invalid buffers

## Notes
- Floating terminals (`<leader>\`) were already working because they use a different creation method
- The fix maintains all existing terminal functionality while preventing the highlighting errors
- Performance is improved as treesitter no longer processes terminal buffers unnecessarily
- Horizontal terminals now create exactly one terminal window instead of duplicate instances