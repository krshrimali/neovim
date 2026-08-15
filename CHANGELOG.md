# Changelog

All notable changes to this Neovim configuration will be documented in this file.

[Unreleased]

### Visible, theme-aware window separators

- **Split borders are actually drawn now** (`user/window_separators.lua`).
  `fillchars` had `vert:` set to a space, so a vertical split had no glyph to
  color - every theme's `WinSeparator` foreground was there but never rendered.
  Separators now use the box-drawing glyphs, including the junction characters
  so crossings between horizontal and vertical splits connect.
- **The color is derived from the active colorscheme** instead of hardcoded per
  theme: `Normal`'s foreground is blended into its background (45% on dark, 38%
  on light). Nothing pins a colorscheme in this config, so this follows whatever
  is loaded - the bundled themes in `user/themes`, and plugin ones too. It
  re-applies on `ColorScheme`, `VimEnter`, and `background` changes, with a
  deferred second pass to land after the theme modules' own timers.
  The themes' `border` values were only a few steps from the background
  (`#464647` on `#1e1e1e` in cursor-dark, now `#707070`).
- `NvimTreeWinSeparator` and the Diffview separator groups are linked to
  `WinSeparator`, so the sidebar border doesn't fade out mid-layout.
- Dropped the hardcoded `WinSeparator` override in `user/lsp/diagnostics.lua`,
  which ran on LSP setup and clobbered the derived color.
- Tune the contrast with `BLEND_DARK` / `BLEND_LIGHT` at the top of the module.

### Diffview: hunk staging, committing, and de-duplicated git keys

- **Partial staging in a diff** (`user/diffview.lua`) - with the cursor on a hunk,
  or lines selected in visual mode:
  - `,gs` stage the hunk / selection
  - `,gu` unstage the hunk / selection
  - `,gr` discard the hunk / selection in the working tree
  These mirror the gitsigns bindings, so the same keys do the same thing in a
  regular buffer and in a diff. Upstream's defaults are `<leader>h*`, which is
  `nohlsearch` here, so they're disabled in favour of these.
- **Commit from the file panel**: `cc` commits the staged changes, `ca` amends.
  Opens a gitcommit buffer - `<C-c><C-c>` or `:w` commits, `q` aborts.
- **Filter the file panel** with `/`, copy the path of an entry with `gy`
  (matching nvim-tree). `gy` stays LSP type-definition inside the diff buffers.
- **`]c` / `[c`** jump between changes across the whole view, rolling over into
  the next / previous file instead of stopping at the end of the current one.
- **Display toggles**: `,gw` ignore whitespace changes, `,gz` hide/show
  unchanged regions. Upstream puts these on `<leader>d*`, which is the
  black-hole delete here, so they're remapped.
- **Better diff alignment**: `diffopt` now gets `algorithm:histogram` and
  `linematch:60` while a view is open, restored on close.
- **Removed duplicate git mappings**:
  - `<leader>gd` was both a which-key group and a mapping - the group wins, use
    `,gdo` to open a Diffview.
  - The diffview lazy spec defined `<leader>gd`, `<leader>gu` and `<leader>gf`,
    colliding with the which-key git group and with gitsigns' `<leader>gu`. The
    keys now live only in which-key; the plugin still lazy-loads on its commands.
  - `<leader>gu` had pointed at `DiffviewOpen --view=diff1_plain`, which isn't a
    real flag.
- **New which-key entries**: `,gds` (staged changes), `,gdm` (changes vs the
  default branch), `,gdr` (refresh the file list).
- **`gf` from a diff no longer splits your layout**: it was mapped to
  `goto_file` (always `:sp`), which duplicated `<C-w><C-f>` and, when the file
  was already open, left you with the same file in two windows. It's now
  `goto_file_edit` (upstream's default), and the plugin focuses an existing
  window for that file instead of opening a second view of it.
- Fixed `<C-w>gf` in the file history panel: it was wired to `goto_file_split`
  while described as "new tabpage".
- **Inline (unified) diff**: `,gi` collapses the side-by-side diff into a single
  window showing the file with the removed lines spliced back in - VSCode's
  inline view. Hunk staging, `]c` / `[c`, and the display toggles all work
  there. `g<C-x>` now cycles side-by-side → stacked → inline. Upstream puts the
  toggle on `<leader>di`, which is the black-hole delete here, so it's remapped
  like the other toggles.

## [0.2.0]

- Added snacks for main features like GitBrowse (copy URL).

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
