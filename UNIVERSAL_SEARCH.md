# Universal Search - JetBrains-Style Search Everywhere

This module provides a comprehensive search system similar to JetBrains IDEs' "Shift+Shift" functionality, with support for searching functions, classes, variables, and comments across all programming languages.

## Features

- **Multi-language support**: JavaScript/TypeScript, Python, Lua, Java, C/C++, Rust, Go, Ruby, PHP
- **Smart pattern matching**: Language-specific regex patterns for accurate results
- **Live search**: Real-time results as you type using fzf-lua and ripgrep
- **Multiple search types**: Functions, Classes/Types, Variables, Comments, or general search
- **Fallback patterns**: Generic patterns for unsupported languages

## Usage

### Activation Methods

1. **Double Comma** (Recommended - similar to Shift+Shift): `,,`
2. **Double Space**: `<Space><Space>`
3. **Ctrl+Shift+F**: `<C-S-f>`
4. **Ctrl+Shift+P**: `<C-S-p>`

### Direct Search Types

- `<leader>ss` - Universal Search (with type selection)
- `<leader>sf` - Search Functions directly
- `<leader>sc` - Search Classes/Types directly
- `<leader>sv` - Search Variables directly
- `<leader>sm` - Search Comments directly

### Search Flow

1. Trigger universal search using any activation method
2. Select search type from the menu:
   - 🔍 All (general search)
   - 🔧 Functions
   - 📦 Classes/Types
   - 📝 Variables
   - 💬 Comments
3. Type your search query in the live grep interface
4. Navigate results and press Enter to jump to the selected item

## Language Support

### JavaScript/TypeScript
- **Functions**: `function`, arrow functions, async functions, method definitions
- **Classes**: `class`, `interface`, `type`, `enum`
- **Variables**: `let`, `const`, `var`
- **Comments**: `//` and `/* */`

### Python
- **Functions**: `def`, `async def`
- **Classes**: `class`
- **Variables**: Variable assignments
- **Comments**: `#`

### Lua
- **Functions**: `function`, `local function`, function assignments
- **Classes**: Table definitions
- **Variables**: `local` variables, assignments
- **Comments**: `--`

### Java
- **Functions**: Methods with visibility modifiers, static methods
- **Classes**: `class`, `interface`, `enum`
- **Variables**: Field declarations
- **Comments**: `//` and `/* */`

### C/C++
- **Functions**: Function definitions, static functions
- **Classes**: `class`, `struct`, `typedef`
- **Variables**: Variable declarations
- **Comments**: `//` and `/* */`

### Rust
- **Functions**: `fn`, `pub fn`, `async fn`
- **Classes**: `struct`, `enum`, `trait`, `impl`
- **Variables**: `let`, `const`, `static`
- **Comments**: `//` and `/* */`

### Go
- **Functions**: `func`, method definitions
- **Classes**: `struct`, `interface` types
- **Variables**: `var`, `:=` assignments
- **Comments**: `//` and `/* */`

### Ruby
- **Functions**: `def`
- **Classes**: `class`, `module`
- **Variables**: Variables, instance variables (`@`), class variables (`@@`)
- **Comments**: `#`

### PHP
- **Functions**: `function`, method definitions with visibility
- **Classes**: `class`, `interface`, `trait`
- **Variables**: `$` variables
- **Comments**: `//`, `/* */`, `#`

## Key Features

- **Context-aware**: Automatically detects the current file's language for better pattern matching
- **Fallback support**: Uses generic patterns for unknown file types
- **Live results**: Real-time search results as you type
- **Multiple actions**: 
  - Enter: Jump to result
  - Ctrl+S: Send results to quickfix list
- **Performance optimized**: Uses ripgrep for fast searching across large codebases

## Customization

The search patterns can be extended by modifying the `language_patterns` table in `lua/user/universal_search.lua`. Each language can have custom patterns for different search types.

## Dependencies

- `fzf-lua`: For the search interface
- `ripgrep`: For fast text searching (should be installed system-wide)
- `nvim-web-devicons`: For file type icons (optional)

## Tips

- Use the double comma (`,,`) for quick access - it's the most JetBrains-like experience
- The search is case-insensitive by default
- Results show file path, line number, and matched content
- Preview is available using F4 in the search interface
- Use Ctrl+S to send interesting results to the quickfix list for later reference