# Cursor Light Theme for Neovim

A beautiful, eye-friendly light theme designed for extended coding sessions with excellent readability and comprehensive plugin support.

## Features

### 🎨 Eye-Friendly Design
- **Carefully selected color palette** with optimal contrast ratios
- **Warm, soft backgrounds** that reduce eye strain
- **Professional appearance** suitable for any environment
- **High readability** with thoughtful typography choices

### 🔧 Comprehensive Plugin Support

The theme provides beautiful styling for **ALL** major Neovim plugins, including:

#### Core Plugins
- **Treesitter** - Advanced syntax highlighting with semantic tokens
- **LSP** - Complete Language Server Protocol support
- **CoC.nvim** - Full Conquer of Completion integration
- **Telescope** - Beautiful fuzzy finder interface
- **FZF-Lua** - Fast and responsive file searching
- **NvimTree** - File explorer with git integration

#### UI Enhancement
- **Lualine** - Stunning status line
- **Bufferline** - Elegant buffer tabs
- **Which-key** - Command palette styling
- **Notify** - Beautiful notifications
- **Dressing** - Enhanced UI components

#### Development Tools
- **GitSigns** - Git integration with diff highlighting
- **Neogit** - Advanced git interface
- **Diffview** - Side-by-side diff viewer
- **Trouble** - Diagnostics and quickfix styling
- **Todo-comments** - Highlighted TODO comments

#### Modern Features
- **Lazy.nvim** - Plugin manager interface
- **Mason** - LSP installer styling
- **Noice** - Command line and message styling
- **Snacks.nvim** - Additional UI components
- **Avante.nvim** - AI assistant integration

And many more! The theme is designed to work seamlessly with any plugin.

## Installation & Usage

### Quick Switch (Temporary)

To quickly try the light theme:

```vim
:colorscheme cursor-light
```

### Permanent Switch

#### Method 1: Update init.lua
Replace the colorscheme line in your `init.lua`:

```lua
-- Replace this line:
require "user.colorscheme"

-- With this:
require "user.colorscheme-light"
```

#### Method 2: Update colorscheme.lua
Edit `lua/user/colorscheme.lua` and replace the theme loading:

```lua
-- Replace the existing theme loading with:
local cursor_light_theme = require("user.themes.cursor-light-init")
cursor_light_theme.setup()
```

### Terminal Integration

The theme includes carefully selected terminal colors that work beautifully with:
- Integrated terminal
- External terminals
- Tmux sessions
- Any terminal emulator

## Color Palette

### Base Colors
- **Background**: `#fefefe` - Pure white with subtle warmth
- **Foreground**: `#2d2d2d` - Dark gray for excellent readability
- **Alt Background**: `#f8f8f8` - Light gray for sidebars
- **Selection**: `#cce8ff` - Soft blue for selections

### Syntax Colors
- **Blue**: `#0078d4` - Keywords, types (professional Microsoft blue)
- **Cyan**: `#0aa3a3` - Strings, constants (teal cyan)
- **Green**: `#107c10` - Comments (forest green)
- **Yellow**: `#ca5010` - Functions (warm orange-yellow)
- **Orange**: `#d83b01` - Numbers (vibrant orange)
- **Red**: `#d13438` - Errors (clear red)
- **Purple**: `#8764b8` - Keywords, operators (soft purple)
- **Pink**: `#e3008c` - Special keywords (magenta pink)

### Diagnostic Colors
- **Error**: `#d13438` - Clear but not overwhelming
- **Warning**: `#ca5010` - Orange for warnings
- **Info**: `#0078d4` - Blue for information
- **Hint**: `#0aa3a3` - Teal for hints

## Theme Architecture

The light theme is built with a modular architecture for maintainability:

```
lua/user/themes/
├── cursor-light.lua              # Base theme and color definitions
├── cursor-light-treesitter.lua   # Treesitter syntax highlighting
├── cursor-light-plugins.lua      # Plugin-specific highlights
├── cursor-light-lsp.lua          # LSP and diagnostic highlights
└── cursor-light-init.lua         # Theme orchestrator and autocommands
```

## Customization

### Future Options Support
The theme is designed to support customization options:

```lua
require("user.themes.cursor-light-init").setup({
  -- transparent = false,      # Future: transparency support
  -- italic_comments = true,   # Future: italic comment control
})
```

### Extending the Theme
You can extend the theme by adding custom highlights after loading:

```lua
-- Load the theme first
require("user.colorscheme-light")

-- Then add custom highlights
vim.api.nvim_set_hl(0, "MyCustomHighlight", { fg = "#0078d4", bold = true })
```

## Comparison with Dark Theme

| Feature | Dark Theme | Light Theme |
|---------|------------|-------------|
| **Eye Strain** | Good for low light | Excellent for bright environments |
| **Readability** | High contrast | Optimized contrast ratios |
| **Professional Use** | Great for evening | Perfect for office/daytime |
| **Plugin Support** | Complete | Complete |
| **Performance** | Optimized | Optimized |

## Best Practices

### When to Use Light Theme
- **Bright environments** - Offices, daytime coding
- **Extended reading** - Documentation, code review
- **Professional settings** - Presentations, pair programming
- **Eye comfort** - When dark themes cause strain

### Optimal Setup
1. **Terminal**: Use a terminal with good font rendering
2. **Font**: Choose a programming font with good readability
3. **Brightness**: Adjust monitor brightness to comfortable levels
4. **Contrast**: Ensure your monitor has good contrast settings

## Troubleshooting

### Theme Not Loading
```lua
-- Check if the theme loaded correctly
:lua print(vim.g.colors_name)
-- Should output: cursor-light
```

### Plugin Colors Not Applied
```lua
-- Reload the theme
:lua require("user.themes.cursor-light-init").reload()
```

### Performance Issues
The theme is optimized for performance with:
- Lazy loading of components
- Efficient highlight group management
- Minimal autocommand overhead

## Contributing

The theme is designed to be comprehensive and extensible. If you find a plugin that's not properly styled:

1. Check if it's using standard highlight groups
2. Add custom highlights to the appropriate theme file
3. Test with the plugin's various states and modes

## Technical Details

### Highlight Group Coverage
- **Base Vim**: All standard highlight groups
- **Treesitter**: Complete semantic token support
- **LSP**: Full protocol support including inlay hints
- **CoC.nvim**: Complete integration with all features
- **Modern Plugins**: Support for latest Neovim ecosystem

### Performance Optimizations
- **Autocommand efficiency**: Minimal performance impact
- **Lazy evaluation**: Only load what's needed
- **Memory management**: Proper cleanup and reloading
- **Plugin integration**: Seamless with plugin loading

### Compatibility
- **Neovim**: 0.8+ (optimized for 0.9+)
- **Terminal**: True color support recommended
- **Plugins**: Compatible with all major plugins
- **Platforms**: Works on all operating systems

## License

This theme is part of the Neovim configuration and follows the same license terms.

---

**Enjoy coding with beautiful, eye-friendly colors!** 🌟