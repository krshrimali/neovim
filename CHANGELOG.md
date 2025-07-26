# Changelog

All notable changes to this Neovim configuration will be documented in this file.

## Major Changes

- **Replaced nvim-lsp with coc.nvim** - Complete migration from native Neovim LSP to coc.nvim for better VS Code-like experience ([aca060f](https://github.com/krshrimali/neovim/commit/aca060fa23b73bbc4a8635c24ab4f2f0eb7eab08))
- **Removed nerd font dependencies** - All plugins now use ASCII characters for better compatibility ([7e9ba40](https://github.com/krshrimali/neovim/commit/7e9ba40be99bfc4ae81f4d70d59ad04b7f9842f3), [4574df2](https://github.com/krshrimali/neovim/commit/4574df2466445f87e12b4c9d3bb54e74a34c2985))
- **Hierarchical winbar breadcrumbs** - Shows `class → function → current_node` context using Treesitter ([467eb49](https://github.com/krshrimali/neovim/commit/467eb491a3f18ceda44ac982f9efdc0e245faa91))
- **Auto-installation of language servers** - coc-pyright, coc-tsserver, coc-rust-analyzer, coc-lua, coc-json, coc-snippets ([aca060f](https://github.com/krshrimali/neovim/commit/aca060fa23b73bbc4a8635c24ab4f2f0eb7eab08))
- **Enhanced key mappings** for coc.nvim:
  - `Tab`/`Shift-Tab` for completion navigation
  - `Enter` to accept completions
  - `gd`, `gy`, `gi`, `gr` for go-to commands
  - `,rn` for rename, `,lf` for format, `,ld` for line diagnostics
  ([f7ee734](https://github.com/krshrimali/neovim/commit/f7ee734bcd4a8f08a64c2bdddea16ff3ac8b2df6), [bc83e4d](https://github.com/krshrimali/neovim/commit/bc83e4d50ba3c20b5f58790c6e22d29e8e7305cf))
- **Comprehensive README.md** with key mappings and features documentation
- **File finder** - Changed `<leader>ff` from git_files to find_files (respects .gitignore)
- **Diagnostic display** - Disabled nerd font icons, configured text-based diagnostics ([0303391](https://github.com/krshrimali/neovim/commit/03033914a20062324419c0fe74c4b78697fa18de))
- **Completion system** - Migrated from blink.cmp to coc.nvim's native completion ([0afa1cc](https://github.com/krshrimali/neovim/commit/0afa1ccf280b65ea2124a0950448127ea74c5de3))
- **Winbar implementation** - Replaced lspsaga winbar with Treesitter-based breadcrumbs ([467eb49](https://github.com/krshrimali/neovim/commit/467eb491a3f18ceda44ac982f9efdc0e245faa91))

## Removed Components

- **nvim-lspconfig, mason.nvim, mason-lspconfig** - Replaced with coc.nvim ([aca060f](https://github.com/krshrimali/neovim/commit/aca060fa23b73bbc4a8635c24ab4f2f0eb7eab08))
- **blink.cmp** - Completion now handled by coc.nvim ([aca060f](https://github.com/krshrimali/neovim/commit/aca060fa23b73bbc4a8635c24ab4f2f0eb7eab08))
- **bufferline.nvim** - Removed unused buffer line plugin ([7e9ba40](https://github.com/krshrimali/neovim/commit/7e9ba40be99bfc4ae81f4d70d59ad04b7f9842f3))
- **nvim-autopairs** - Cleaned up unused autopairs configuration ([762c65c](https://github.com/krshrimali/neovim/commit/762c65c84a3bba01b18b82ccba0778565ce8d2b3))
- **Nerd font icons** from all plugins (nvim-tree, trouble, outline, etc.) ([7e9ba40](https://github.com/krshrimali/neovim/commit/7e9ba40be99bfc4ae81f4d70d59ad04b7f9842f3), [4574df2](https://github.com/krshrimali/neovim/commit/4574df2466445f87e12b4c9d3bb54e74a34c2985))

## Bug Fixes

- **Enter key completion** - Fixed autopairs conflict with coc.nvim completion
- **LSP diagnostic keymaps** - Updated all diagnostic commands to use coc.nvim
- **Winbar compatibility** - Fixed lspsaga winbar to work without native LSP

## Previous Notable Changes

- **Telescope optimizations** - Finalized pickers and improved performance ([004a55d](https://github.com/krshrimali/neovim/commit/004a55d02ff1cb3ed1e465a77bc51165df5e6a56))
- **LSP configuration** - Configured pyright and other language servers ([d51dae6](https://github.com/krshrimali/neovim/commit/d51dae659e9a01726625198653e6d98a2cd7f338))
- **Icon cleanup** - Systematic removal of nerd font dependencies ([7e9ba40](https://github.com/krshrimali/neovim/commit/7e9ba40be99bfc4ae81f4d70d59ad04b7f9842f3))
- **Project management** - Added project.nvim for better workspace handling ([86a696c](https://github.com/krshrimali/neovim/commit/86a696cf2c8ed3b3179ac528302ce52c98897189))
- **Copilot integration** - Enhanced AI assistant integration ([4574df2](https://github.com/krshrimali/neovim/commit/4574df2466445f87e12b4c9d3bb54e74a34c2985))
- **Which-key cleanup** - Improved keybinding organization and documentation ([ac68e4f](https://github.com/krshrimali/neovim/commit/ac68e4f745d50745619b6cd556efcbfb5e28c882))

## Migration Notes

### From Native LSP to coc.nvim

- **Language servers** will be auto-installed on first startup
- **Keymaps** have been updated - see README.md for new bindings
- **Diagnostics** now use coc.nvim commands instead of vim.diagnostic
- **Completion** uses Tab/Enter instead of previous completion engine

### Compatibility

- **No nerd fonts required** - All icons use ASCII characters
- **Cross-platform** - Works on Linux, macOS, Windows
- **Neovim 0.8+** required for coc.nvim compatibility
