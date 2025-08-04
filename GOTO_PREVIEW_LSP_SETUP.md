# Goto-Preview with vim.lsp Setup

This configuration enables the goto-preview plugin to use vim.lsp for preview functionality while keeping COC.nvim for all other LSP features like completion, diagnostics, formatting, etc.

## How it works

- **COC.nvim**: Handles completion, diagnostics, formatting, code actions, hover, and other LSP features
- **vim.lsp**: Provides minimal LSP functionality specifically for goto-preview (definitions, references, implementations, type definitions)
- **goto-preview**: Uses vim.lsp to show previews in floating windows

## Required Language Servers

For goto-preview to work with vim.lsp, you need to install the language servers separately:

### Python
```bash
npm install -g pyright
```

### TypeScript/JavaScript
```bash
npm install -g typescript-language-server typescript
```

### Rust
```bash
rustup component add rust-analyzer
```

### Lua
Install lua-language-server via your package manager or download from [releases](https://github.com/LuaLS/lua-language-server/releases).

#### Ubuntu/Debian:
```bash
sudo apt install lua-language-server
```

#### macOS:
```bash
brew install lua-language-server
```

#### Arch Linux:
```bash
sudo pacman -S lua-language-server
```

## Available Keymaps

The following keymaps are configured for goto-preview:

- `<leader>lgg` - Goto Preview Definition
- `<leader>lgt` - Goto Preview Type Definition  
- `<leader>lgi` - Goto Preview Implementation
- `<leader>lgr` - Goto Preview References
- `<leader>lgc` - Close all preview windows

## Configuration Files

- `lua/user/goto_preview_lsp.lua` - Main configuration for goto-preview with vim.lsp
- `lua/user/coc.lua` - COC.nvim configuration (unchanged)
- `lua/user/plugins.lua` - Plugin definitions including nvim-lspconfig dependency

## Troubleshooting

### Language server not working
1. Check if the language server is installed and in your PATH
2. Check `:LspInfo` to see if servers are attached
3. The setup will silently fail if language servers aren't available

### Conflicts with COC
The configuration disables most vim.lsp capabilities to avoid conflicts:
- Document formatting
- Hover 
- Completion
- Diagnostics
- Code actions
- Signature help
- Rename

Only navigation capabilities (definitions, references, implementations) are kept for goto-preview.

### Fallback behavior
If nvim-lspconfig fails to load, goto-preview will fall back to using COC.nvim (though with less optimal preview functionality).

## Testing the Setup

1. Open a Python/TypeScript/Rust/Lua file
2. Place cursor on a function/variable
3. Press `<leader>lgg` to see definition preview
4. Press `<leader>lgr` to see references preview
5. Press `<leader>lgc` to close preview windows

The previews should appear in floating windows while COC continues to handle completion and other features.