# Buffer Browser Utility

A custom buffer browser utility with lazy loading that provides two interfaces for buffer management:

## Features

- **Lazy Loading**: Only loads when keymap is triggered
- **MRU Sorting**: Buffers sorted by Most Recently Used
- **Two Interfaces**: Floating window and sidebar
- **Buffer Status**: Shows current buffer (●), modified buffers ([+])
- **Quick Navigation**: Number keys (1-9) for instant selection
- **Buffer Management**: Delete, split, and vsplit operations

## Usage

### Floating Buffer Browser (`<leader>bb`)

Opens a centered floating window with all buffers listed by recency.

**Keymaps:**
- `<CR>` - Open selected buffer
- `d` - Delete selected buffer
- `s` - Open in horizontal split
- `v` - Open in vertical split
- `1-9` - Quick select buffer by number
- `q` / `<Esc>` - Close browser

### Sidebar Buffer Browser (`<leader>bs`)

Creates a persistent sidebar on the left showing all buffers.

**Keymaps:**
- `<CR>` - Open selected buffer in main window
- `d` - Delete selected buffer and refresh sidebar
- `q` - Close sidebar

## Implementation

- **File**: `lua/user/buffer_browser.lua`
- **Dependencies**: None (pure Neovim API)
- **Lazy Loading**: Configured in `init.lua`
- **Keymaps**: Registered in `lua/user/whichkey.lua`

## Buffer Information Display

- `●` - Current buffer indicator  
- `+` - Modified buffer indicator
- Directory context shown in parentheses
- Sorted by last access time (most recent first)

## Customization

The buffer browser can be customized by modifying the configuration in `lua/user/buffer_browser.lua`:

- Window dimensions
- Sorting behavior  
- Display format
- Keymaps
- Highlight groups