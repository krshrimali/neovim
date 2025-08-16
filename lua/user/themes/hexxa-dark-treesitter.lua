-- Hexxa Dark Theme - Treesitter Highlights
-- Advanced syntax highlighting for Treesitter

local M = {}

function M.setup()
  local colors = require("user.themes.hexxa-dark").colors

  -- Helper function to set highlights
  local function hl(group, opts) vim.api.nvim_set_hl(0, group, opts) end

  -- Treesitter syntax groups
  -- Comments
  hl("@comment", { fg = colors.comment, italic = true })
  hl("@comment.documentation", { fg = colors.comment, italic = true })
  hl("@comment.error", { fg = colors.error, italic = true })
  hl("@comment.warning", { fg = colors.warning, italic = true })
  hl("@comment.todo", { fg = colors.orange, bold = true, italic = true })
  hl("@comment.note", { fg = colors.info, italic = true })

  -- Constants
  hl("@constant", { fg = colors.blue })
  hl("@constant.builtin", { fg = colors.blue })
  hl("@constant.macro", { fg = colors.pink })

  -- Strings
  hl("@string", { fg = colors.green })
  hl("@string.documentation", { fg = colors.green, italic = true })
  hl("@string.regexp", { fg = colors.orange })
  hl("@string.escape", { fg = colors.orange })
  hl("@string.special", { fg = colors.orange })
  hl("@string.special.symbol", { fg = colors.blue })
  hl("@string.special.url", { fg = colors.cyan, underline = true })

  -- Characters
  hl("@character", { fg = colors.green })
  hl("@character.special", { fg = colors.orange })

  -- Numbers
  hl("@number", { fg = colors.blue })
  hl("@number.float", { fg = colors.blue })

  -- Booleans
  hl("@boolean", { fg = colors.blue })

  -- Functions
  hl("@function", { fg = colors.lime })
  hl("@function.builtin", { fg = colors.lime })
  hl("@function.call", { fg = colors.lime })
  hl("@function.macro", { fg = colors.pink })
  hl("@function.method", { fg = colors.lime })
  hl("@function.method.call", { fg = colors.lime })

  -- Constructors
  hl("@constructor", { fg = colors.cyan })

  -- Parameters
  hl("@parameter", { fg = colors.pink, italic = true })
  hl("@parameter.builtin", { fg = colors.pink, italic = true })
  hl("@parameter.reference", { fg = colors.pink })

  -- Variables
  hl("@variable", { fg = colors.fg_alt })
  hl("@variable.builtin", { fg = colors.blue })
  hl("@variable.parameter", { fg = colors.pink, italic = true })
  hl("@variable.member", { fg = colors.fg_alt })

  -- Properties
  hl("@property", { fg = colors.fg_alt })
  hl("@field", { fg = colors.fg_alt })

  -- Keywords
  hl("@keyword", { fg = colors.orange })
  hl("@keyword.function", { fg = colors.pink })
  hl("@keyword.operator", { fg = colors.orange })
  hl("@keyword.return", { fg = colors.pink })
  hl("@keyword.conditional", { fg = colors.pink })
  hl("@keyword.conditional.ternary", { fg = colors.orange })
  hl("@keyword.repeat", { fg = colors.pink })
  hl("@keyword.debug", { fg = colors.red })
  hl("@keyword.exception", { fg = colors.pink })
  hl("@keyword.import", { fg = colors.pink })
  hl("@keyword.export", { fg = colors.pink })
  hl("@keyword.storage", { fg = colors.pink })
  hl("@keyword.directive", { fg = colors.pink })
  hl("@keyword.directive.define", { fg = colors.pink })

  -- Operators
  hl("@operator", { fg = colors.orange })

  -- Punctuation
  hl("@punctuation.delimiter", { fg = colors.fg_alt })
  hl("@punctuation.bracket", { fg = colors.fg_alt })
  hl("@punctuation.special", { fg = colors.orange })

  -- Types
  hl("@type", { fg = colors.cyan })
  hl("@type.builtin", { fg = colors.cyan })
  hl("@type.definition", { fg = colors.cyan })
  hl("@type.qualifier", { fg = colors.pink })

  -- Attributes
  hl("@attribute", { fg = colors.pink })
  hl("@attribute.builtin", { fg = colors.pink })

  -- Labels
  hl("@label", { fg = colors.pink })

  -- Namespaces
  hl("@namespace", { fg = colors.cyan })
  hl("@module", { fg = colors.cyan })
  hl("@module.builtin", { fg = colors.cyan })

  -- Include/Preproc
  hl("@preproc", { fg = colors.pink })
  hl("@include", { fg = colors.pink })
  hl("@define", { fg = colors.pink })
  hl("@macro", { fg = colors.pink })

  -- Tags (HTML/XML)
  hl("@tag", { fg = colors.pink })
  hl("@tag.attribute", { fg = colors.lime })
  hl("@tag.delimiter", { fg = colors.fg_alt })

  -- Markup (Markdown)
  hl("@markup.strong", { fg = colors.fg, bold = true })
  hl("@markup.italic", { fg = colors.fg, italic = true })
  hl("@markup.strikethrough", { fg = colors.fg, strikethrough = true })
  hl("@markup.underline", { fg = colors.cyan, underline = true })
  hl("@markup.heading", { fg = colors.lime, bold = true })
  hl("@markup.heading.1", { fg = colors.lime, bold = true })
  hl("@markup.heading.2", { fg = colors.cyan, bold = true })
  hl("@markup.heading.3", { fg = colors.green, bold = true })
  hl("@markup.heading.4", { fg = colors.orange, bold = true })
  hl("@markup.heading.5", { fg = colors.pink, bold = true })
  hl("@markup.heading.6", { fg = colors.blue, bold = true })
  hl("@markup.quote", { fg = colors.lime, italic = true })
  hl("@markup.math", { fg = colors.blue })
  hl("@markup.environment", { fg = colors.pink })
  hl("@markup.link", { fg = colors.cyan, underline = true })
  hl("@markup.link.label", { fg = colors.cyan })
  hl("@markup.link.url", { fg = colors.blue, underline = true })
  hl("@markup.raw", { fg = colors.cyan })
  hl("@markup.raw.block", { fg = colors.cyan })
  hl("@markup.list", { fg = colors.pink })
  hl("@markup.list.checked", { fg = colors.green })
  hl("@markup.list.unchecked", { fg = colors.orange })

  -- Diff
  hl("@diff.plus", { fg = colors.git_add })
  hl("@diff.minus", { fg = colors.git_delete })
  hl("@diff.delta", { fg = colors.git_change })

  -- Language-specific highlights

  -- JavaScript/TypeScript
  hl("@variable.builtin.javascript", { fg = colors.blue })
  hl("@variable.builtin.typescript", { fg = colors.blue })
  hl("@keyword.export.javascript", { fg = colors.pink })
  hl("@keyword.export.typescript", { fg = colors.pink })
  hl("@keyword.import.javascript", { fg = colors.pink })
  hl("@keyword.import.typescript", { fg = colors.pink })
  hl("@constructor.javascript", { fg = colors.cyan })
  hl("@constructor.typescript", { fg = colors.cyan })

  -- JSX/TSX
  hl("@tag.jsx", { fg = colors.pink })
  hl("@tag.tsx", { fg = colors.pink })
  hl("@tag.attribute.jsx", { fg = colors.lime })
  hl("@tag.attribute.tsx", { fg = colors.lime })
  hl("@tag.delimiter.jsx", { fg = colors.fg_alt })
  hl("@tag.delimiter.tsx", { fg = colors.fg_alt })

  -- Python
  hl("@variable.builtin.python", { fg = colors.blue })
  hl("@function.builtin.python", { fg = colors.lime })
  hl("@keyword.function.python", { fg = colors.pink })
  hl("@keyword.import.python", { fg = colors.pink })

  -- Lua
  hl("@variable.builtin.lua", { fg = colors.blue })
  hl("@function.builtin.lua", { fg = colors.lime })
  hl("@keyword.function.lua", { fg = colors.pink })

  -- CSS
  hl("@property.css", { fg = colors.cyan })
  hl("@type.css", { fg = colors.orange })
  hl("@string.css", { fg = colors.green })
  hl("@number.css", { fg = colors.blue })
  hl("@function.css", { fg = colors.lime })

  -- JSON
  hl("@property.json", { fg = colors.cyan })
  hl("@string.json", { fg = colors.green })
  hl("@number.json", { fg = colors.blue })
  hl("@boolean.json", { fg = colors.blue })

  -- YAML
  hl("@property.yaml", { fg = colors.cyan })
  hl("@string.yaml", { fg = colors.green })
  hl("@number.yaml", { fg = colors.blue })
  hl("@boolean.yaml", { fg = colors.blue })

  -- TOML
  hl("@property.toml", { fg = colors.cyan })
  hl("@string.toml", { fg = colors.green })
  hl("@number.toml", { fg = colors.blue })
  hl("@boolean.toml", { fg = colors.blue })

  -- Git
  hl("@keyword.gitcommit", { fg = colors.pink })
  hl("@string.gitcommit", { fg = colors.green })

  -- SQL
  hl("@keyword.sql", { fg = colors.pink })
  hl("@function.sql", { fg = colors.lime })
  hl("@type.sql", { fg = colors.cyan })

  -- Bash/Shell
  hl("@variable.bash", { fg = colors.fg_alt })
  hl("@variable.builtin.bash", { fg = colors.blue })
  hl("@function.bash", { fg = colors.lime })
  hl("@keyword.bash", { fg = colors.pink })

  -- Vim
  hl("@variable.vim", { fg = colors.fg_alt })
  hl("@function.vim", { fg = colors.lime })
  hl("@keyword.vim", { fg = colors.pink })

  -- Error/Warning/Info/Hint (for diagnostics integration)
  hl("@error", { fg = colors.error })
  hl("@warning", { fg = colors.warning })
  hl("@info", { fg = colors.info })
  hl("@hint", { fg = colors.hint })

  -- Semantic tokens (LSP)
  hl("@lsp.type.class", { fg = colors.cyan })
  hl("@lsp.type.decorator", { fg = colors.pink })
  hl("@lsp.type.enum", { fg = colors.cyan })
  hl("@lsp.type.enumMember", { fg = colors.blue })
  hl("@lsp.type.function", { fg = colors.lime })
  hl("@lsp.type.interface", { fg = colors.cyan })
  hl("@lsp.type.macro", { fg = colors.pink })
  hl("@lsp.type.method", { fg = colors.lime })
  hl("@lsp.type.namespace", { fg = colors.cyan })
  hl("@lsp.type.parameter", { fg = colors.pink, italic = true })
  hl("@lsp.type.property", { fg = colors.fg_alt })
  hl("@lsp.type.struct", { fg = colors.cyan })
  hl("@lsp.type.type", { fg = colors.cyan })
  hl("@lsp.type.typeParameter", { fg = colors.cyan })
  hl("@lsp.type.variable", { fg = colors.fg_alt })
end

return M
