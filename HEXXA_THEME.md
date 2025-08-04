# Hexxa Dark Theme for Neovim

A beautiful dark theme for Neovim inspired by the [Hexxa theme](https://github.com/diogomoretti/hexxa-theme) by Diogo Moretti. This theme provides comprehensive support for all your plugins and maintains the elegant color palette of the original Hexxa theme.

## 🎨 Color Palette

The theme uses the following color scheme:

- **Background**: `#120E1D` - Deep dark purple
- **Foreground**: `#F8F8F8` - Clean white
- **Blue**: `#4D5BFC` - Vibrant blue for constants and keywords
- **Cyan**: `#00D0FF` - Bright cyan for types and classes
- **Green**: `#49DCB1` - Teal green for strings and success
- **Lime**: `#CCFF66` - Bright lime for functions and headings
- **Orange**: `#EE964B` - Warm orange for operators and keywords
- **Pink**: `#FF5FA7` - Vibrant pink for statements and tags
- **Red**: `#DB5461` - Error red for warnings and errors

## ✨ Features

- **Complete Plugin Support**: Supports all major Neovim plugins including:
  - FZF-Lua (file finder)
  - Lualine (status line)
  - GitSigns (git integration)
  - Treesitter (syntax highlighting)
  - CoC.nvim (completion and LSP)
  - Bufferline (buffer tabs)
  - Which-Key (key bindings)
  - Notify (notifications)
  - And many more!

- **Advanced Syntax Highlighting**: Full Treesitter support with language-specific highlighting
- **LSP Integration**: Comprehensive LSP and CoC diagnostics styling
- **Terminal Colors**: Properly configured terminal colors
- **Consistent Theming**: All UI elements follow the same color scheme

## 🚀 Installation

The theme is already installed in your Neovim configuration. You have several ways to activate it:

### Method 1: Switch Colorscheme Configuration

Edit your `init.lua` file and change the colorscheme line from:
```lua
require "user.colorscheme"
```

to:
```lua
require "user.colorscheme-hexxa"
```

### Method 2: Use Colorscheme Command

You can switch to the theme temporarily using:
```vim
:colorscheme hexxa-dark
```

### Method 3: Use Toggle Command

The theme provides a convenient toggle command:
```vim
:HexxaToggle
```

This will switch between Hexxa Dark and your current Cursor theme.

## 🔧 Commands

The theme provides several useful commands:

- `:HexxaToggle` - Toggle between Hexxa Dark and Cursor Dark themes
- `:HexxaReload` - Reload the Hexxa theme (useful during development)
- `:colorscheme hexxa-dark` - Switch to Hexxa Dark theme

## 🎯 Supported Plugins

The theme includes specific styling for:

### Core Plugins
- **Treesitter** - Advanced syntax highlighting
- **LSP/CoC** - Diagnostics, completion, and references
- **FZF-Lua** - File finder and fuzzy search
- **Lualine** - Status line with mode-specific colors

### UI Plugins
- **Bufferline** - Buffer tabs
- **Which-Key** - Key binding hints
- **Notify** - Notification system
- **Dressing** - UI improvements

### Git Integration
- **GitSigns** - Git diff indicators
- **Neogit** - Git interface (if used)

### File Management
- **Nvim-Tree** - File explorer
- **Simple Tree** - Custom file browser

### Development Tools
- **Comment.nvim** - Code commenting
- **Todo Comments** - TODO highlighting
- **Illuminate** - Word highlighting
- **Indent Blankline** - Indentation guides
- **Colorizer** - Color preview

### Search and Navigation
- **Telescope** - Fuzzy finder (if used)
- **Trouble** - Diagnostics list
- **Cybu** - Buffer switcher
- **Registers** - Register preview
- **Spectre** - Search and replace

## 🎨 Customization

The theme is highly customizable. You can modify colors by editing the files in `lua/user/themes/`:

- `hexxa-dark.lua` - Base colors and editor styling
- `hexxa-dark-treesitter.lua` - Syntax highlighting
- `hexxa-dark-plugins.lua` - Plugin-specific styling
- `hexxa-dark-lsp.lua` - LSP and diagnostics styling

## 🔍 Color Reference

### Syntax Highlighting
- **Comments**: Gray (`#666666`) with italic style
- **Strings**: Teal green (`#49DCB1`)
- **Numbers/Constants**: Blue (`#4D5BFC`)
- **Functions**: Lime green (`#CCFF66`)
- **Keywords**: Orange (`#EE964B`)
- **Types/Classes**: Cyan (`#00D0FF`)
- **Variables**: White (`#EEEEEE`)
- **Operators**: Orange (`#EE964B`)

### UI Elements
- **Error**: Red (`#DB5461`)
- **Warning**: Blue (`#4D5BFC`)
- **Info**: Teal (`#49DCB1`)
- **Hint**: Cyan (`#00D0FF`)
- **Git Add**: Lime (`#CCFF66`)
- **Git Change**: Cyan (`#00D0FF`)
- **Git Delete**: Red (`#DB5461`)

## 🐛 Troubleshooting

If you encounter any issues:

1. **Theme not loading**: Make sure you've changed the require statement in `init.lua`
2. **Colors not appearing correctly**: Try running `:HexxaReload`
3. **Plugin colors missing**: Ensure your plugins are loaded after the theme

## 📝 Notes

- The theme is designed to work with your existing plugin configuration
- Terminal colors are automatically configured
- The theme includes autocommands to maintain consistency when plugins load
- All colors are carefully chosen to provide excellent readability and contrast

Enjoy your new Hexxa Dark theme! 🎉