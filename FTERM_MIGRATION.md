# FTerm Migration - Toggleterm Replacement

This document outlines the complete migration from `toggleterm.nvim` to `FTerm.nvim` with enhanced functionality and fish shell integration.

## 🚀 What Changed

### Plugin Replacement
- **Removed**: `akinsho/toggleterm.nvim`
- **Added**: `numToStr/FTerm.nvim` - A cleaner, more lightweight floating terminal plugin

### Key Improvements
- ✅ **Fish Shell Default**: All terminals now use fish as the default shell
- ✅ **Beautiful Styling**: Rounded borders and improved visual appearance
- ✅ **No Keybinding Conflicts**: Carefully mapped keybindings to avoid conflicts
- ✅ **Cleaner Architecture**: Simpler, more maintainable code structure
- ✅ **Better Performance**: Lighter weight plugin with faster startup

## 🎯 Terminal Types Available

### Main Terminals
- **Float Terminal** (`Alt+1`): Main floating terminal with fish shell
- **Vertical Terminal** (`Alt+2`): Side-mounted vertical terminal
- **Horizontal Terminal** (`Alt+3`): Bottom-mounted horizontal terminal

### Specialized Terminals
- **Node Terminal** (`<leader>Tn`): Interactive Node.js REPL
- **NCDU Terminal** (`<leader>Tu`): Disk usage analyzer
- **Htop Terminal** (`<leader>Tt`): System process monitor
- **Make Terminal** (`<leader>Tm`): Build system execution
- **Cargo Run** (`<leader>Tr`): Rust project runner
- **Cargo Test** (`<leader>TR`): Rust test runner

### Git Integration
- **Lazygit Float** (`<leader>gg`): Floating lazygit interface
- **Lazygit Tab** (`<leader>gG`): Fullscreen lazygit interface

## ⌨️ Keybinding Changes

### Primary Terminal Access
| Old Keybinding | New Keybinding | Description |
|----------------|----------------|-------------|
| `<m-1>` | `<A-1>` | Float terminal toggle |
| `<m-2>` | `<A-2>` | Vertical terminal toggle |
| `<m-3>` | `<A-3>` | Horizontal terminal toggle |

### Leader Key Mappings
| Keybinding | Function | Description |
|------------|----------|-------------|
| `<leader>T1` | Float Terminal | Primary floating terminal |
| `<leader>T2` | Vertical Terminal | Side terminal |
| `<leader>T3` | Horizontal Terminal | Bottom terminal |
| `<leader>T4` | Default Terminal | Standard FTerm instance |
| `<leader>Tf` | Float Terminal | Same as T1 |
| `<leader>Th` | Horizontal Terminal | Same as T3 |
| `<leader>Tv` | Vertical Terminal | Same as T2 |

### Terminal Navigation (All terminal buffers)
| Keybinding | Action |
|------------|--------|
| `<Esc>` | Exit terminal mode |
| `jk` | Exit terminal mode |
| `<C-h>` | Navigate to left window |
| `<C-j>` | Navigate to down window |
| `<C-k>` | Navigate to up window |
| `<C-l>` | Navigate to right window |

## 🐟 Fish Shell Integration

All terminals now default to fish shell with the following benefits:
- **Smart Autocompletion**: Fish's intelligent tab completion
- **Syntax Highlighting**: Real-time command highlighting
- **Better History**: Advanced history search and suggestions
- **Modern Features**: Web-based configuration and modern shell features

## 🔧 Configuration Details

### Main FTerm Setup
```lua
fterm.setup({
  border = "rounded",
  dimensions = {
    height = 0.8,
    width = 0.8,
  },
  cmd = "fish",
  auto_close = false,
  hl = "Normal",
  blend = 0,
})
```

### Custom Terminal Configurations
Each specialized terminal has its own configuration:
- **Optimized dimensions** for specific use cases
- **Proper filetypes** for statusline integration
- **Auto-close settings** based on terminal purpose

## 🔄 Migration Benefits

### Performance
- **Faster startup**: FTerm is lighter than toggleterm
- **Less memory usage**: Simpler architecture
- **Better responsiveness**: Optimized for floating windows

### User Experience
- **Cleaner interface**: Rounded borders and better styling
- **Fish shell power**: Modern shell features out of the box
- **No conflicts**: Carefully designed keybindings
- **Better integration**: Improved statusline and UI integration

### Maintainability
- **Simpler codebase**: Less complex than toggleterm setup
- **Better organized**: Clear separation of terminal types
- **Easier to extend**: Simple API for adding new terminals

## 🚨 Breaking Changes

### Removed Features
- ToggleTerm commands (`:1ToggleTerm`, `:2ToggleTerm`, etc.)
- Toggleterm-specific statusline indicators
- Some advanced toggleterm features not needed

### Changed Behavior
- All terminals now use fish by default (was system shell)
- Terminal numbering system changed
- Some keybindings changed for consistency

## 📁 File Changes

### New Files
- `lua/user/fterm.lua` - Main FTerm configuration

### Modified Files
- `lua/user/plugins.lua` - Plugin replacement
- `lua/user/lazygit.lua` - Updated for FTerm integration
- `lua/user/lualine.lua` - Statusline integration updates
- `lua/user/illuminate.lua` - Filetype exclusions updated
- `lua/user/terminal.lua` - Legacy compatibility maintained

### Removed Files
- `lua/user/toggleterm.lua` - No longer needed

## 🎉 Ready to Use

The migration is complete and ready to use! All your familiar keybindings work, but now with:
- 🐟 Fish shell by default
- 🎨 Beautiful rounded borders
- ⚡ Better performance
- 🔧 Cleaner configuration
- 🚀 Enhanced functionality

Enjoy your new and improved terminal experience!