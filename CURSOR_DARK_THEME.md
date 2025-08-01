# Cursor Dark Theme for Neovim

A comprehensive dark theme for Neovim inspired by Cursor IDE's dark theme and VS Code's Dark+ theme. This theme provides complete coverage for all your plugins and ensures a consistent, modern dark IDE experience.

## Features

- 🎨 **Complete Coverage**: Themes all major Neovim plugins and LSP features
- 🌈 **Modern Syntax Highlighting**: Full Treesitter support with semantic highlighting
- 🔧 **LSP Integration**: Comprehensive CoC.nvim and native LSP support
- 🎯 **Plugin Support**: Covers 40+ popular plugins including:
  - Telescope & FZF-Lua
  - NvimTree
  - Lualine & Bufferline
  - GitSigns & Neogit
  - Which-key
  - Trouble & LSP Saga
  - And many more...

## Color Palette

The theme uses a carefully crafted color palette based on Cursor IDE's dark theme:

### Base Colors
- **Background**: `#1e1e1e` - Main editor background
- **Foreground**: `#d4d4d4` - Main text color
- **Alt Background**: `#252526` - Sidebar and secondary backgrounds
- **Selection**: `#264f78` - Text selection background

### Accent Colors
- **Blue**: `#569cd6` - Keywords, types, functions
- **Cyan**: `#4ec9b0` - Constants, properties
- **Green**: `#6a9955` - Comments, strings
- **Yellow**: `#dcdcaa` - Functions, methods
- **Orange**: `#ce9178` - Strings, numbers
- **Red**: `#f44747` - Errors, deletions
- **Purple**: `#c586c0` - Keywords, operators

## Installation

The theme is already installed in your configuration. It's located in the `lua/user/themes/` directory with the following structure:

```
lua/user/themes/
├── init.lua                    # Main theme loader
├── cursor-dark.lua            # Base theme and color palette
├── cursor-dark-treesitter.lua # Treesitter highlights
├── cursor-dark-plugins.lua    # Plugin-specific highlights
└── cursor-dark-lsp.lua        # LSP and CoC.nvim highlights
```

## Usage

### Automatic Loading
The theme is automatically loaded through your `lua/user/colorscheme.lua` configuration.

### Manual Loading
You can also load the theme manually:

```lua
-- Load via the theme system
local cursor_theme = require("user.themes.init")
cursor_theme.setup()

-- Or load as a standard colorscheme
vim.cmd("colorscheme cursor-dark")
```

### Getting Theme Colors
You can access the theme colors in your other configurations:

```lua
local colors = require("user.themes.init").get_colors()

-- Use specific colors
local blue = colors.blue
local background = colors.bg

-- Or get a specific color
local cursor_theme = require("user.themes.init")
local error_color = cursor_theme.get_color("error")
```

## Plugin Coverage

This theme provides comprehensive support for all your installed plugins:

### Core Plugins
- **Telescope**: Complete theming for all telescope windows and components
- **FZF-Lua**: Full support for fzf-lua interface and previews
- **NvimTree**: File explorer with proper git status colors
- **Lualine**: Custom theme matching the overall color scheme
- **Bufferline**: Consistent tab and buffer styling

### LSP & Completion
- **CoC.nvim**: Complete coverage including diagnostics, completion, and semantic highlighting
- **Native LSP**: Full diagnostic and semantic token support
- **LSP Saga**: Themed floating windows and code actions
- **Trouble**: Error and diagnostic list styling

### Git Integration
- **GitSigns**: Proper git change indicators
- **Neogit**: Complete git interface theming
- **Diffview**: Diff viewer with proper highlighting
- **Git Blame**: Subtle blame text styling

### UI Enhancement
- **Which-key**: Key binding helper styling
- **Notify**: Notification system theming
- **Dressing**: Input and select UI improvements
- **Transparent**: Transparency support

### Development Tools
- **Treesitter**: Modern syntax highlighting for all languages
- **Comment.nvim**: Todo comment highlighting
- **Spectre**: Search and replace interface
- **Outline**: Code outline viewer
- **Illuminate**: Word highlighting under cursor

### Terminal & Navigation
- **Toggleterm**: Terminal integration
- **Cybu**: Buffer switcher
- **Spider**: Enhanced word motion
- **Goto Preview**: Definition preview windows

### Markdown & Documentation
- **Render Markdown**: Enhanced markdown display
- **Avante.nvim**: AI-powered editing assistance

### Additional Plugins
- **Snacks.nvim**: Various UI enhancements
- **Context Pilot**: Context-aware assistance
- **BQF**: Better quickfix window
- **Registers**: Register preview
- **Mini.pick**: File picker interface

## Customization

### Future Options
The theme system is designed to support customization options:

```lua
local cursor_theme = require("user.themes.init")
cursor_theme.setup({
  -- transparent = true,        -- Enable transparency (future)
  -- italic_comments = false,   -- Disable italic comments (future)
})
```

### Extending the Theme
You can extend the theme by creating additional highlight files:

```lua
-- lua/user/themes/cursor-dark-custom.lua
local colors = require("user.themes.cursor-dark").colors

local M = {}

function M.setup()
  -- Add your custom highlights here
  vim.api.nvim_set_hl(0, "MyCustomHighlight", { fg = colors.blue, bold = true })
end

return M
```

Then load it in your theme loader:

```lua
-- In lua/user/themes/init.lua
local custom_theme = require("user.themes.cursor-dark-custom")
custom_theme.setup()
```

## Troubleshooting

### Theme Not Loading
If the theme doesn't load properly:

1. Check for errors: `:messages`
2. Reload the theme: `:lua require("user.themes.init").reload()`
3. Ensure all theme files are present in `lua/user/themes/`

### Plugin Highlights Missing
If a plugin isn't properly themed:

1. The theme includes autocommands to reapply highlights when plugins load
2. You can manually reapply: `:lua require("user.themes.cursor-dark-plugins").setup()`
3. Check if the plugin is in the supported list above

### Colors Look Wrong
If colors appear different than expected:

1. Ensure your terminal supports true colors: `set termguicolors`
2. Check your terminal's color profile settings
3. Some terminals may have color correction that affects appearance

## Contributing

To add support for a new plugin:

1. Add highlights to `lua/user/themes/cursor-dark-plugins.lua`
2. Use the existing color palette from `cursor-dark.lua`
3. Follow the naming conventions used by other plugin highlights
4. Test with the actual plugin to ensure proper appearance

## Technical Details

### Theme Architecture
- **Modular Design**: Separate files for different highlight categories
- **Automatic Reloading**: Autocommands ensure highlights persist through plugin loading
- **Color Consistency**: Single color palette used across all components
- **Performance**: Efficient loading with minimal startup impact

### Color Selection
Colors were chosen based on:
- Cursor IDE's default dark theme
- VS Code Dark+ theme compatibility
- Accessibility and contrast guidelines
- Consistency across different file types and plugins

### Maintenance
The theme automatically:
- Reapplies highlights when colorscheme changes
- Updates plugin highlights when new plugins load
- Maintains consistency across different filetypes
- Handles lazy-loaded plugins correctly

## License

This theme is part of your Neovim configuration and follows the same license terms.