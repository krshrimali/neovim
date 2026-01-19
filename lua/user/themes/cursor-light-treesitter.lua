-- Treesitter highlights for Cursor Light Theme
local colors = require("user.themes.cursor-light").colors

local M = {}

-- Helper function to create highlight groups (respects transparency)
local function hl(group, opts)
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
  else
    -- Respect transparency setting
    if vim.g.transparent_enabled and opts.bg then opts = vim.tbl_extend("force", opts, { bg = "NONE" }) end
    vim.api.nvim_set_hl(0, group, opts)
  end
end

function M.setup()
  -- Basic syntax groups (fallback for non-treesitter)
  hl("@comment", { fg = colors.green, italic = true })
  hl("@comment.documentation", { fg = colors.green, italic = true, bold = true })
  hl("@comment.error", { fg = colors.error, bold = true })
  hl("@comment.warning", { fg = colors.warning, bold = true })
  hl("@comment.todo", { fg = colors.bg, bg = colors.yellow, bold = true })
  hl("@comment.note", { fg = colors.info, bold = true })

  -- Constants
  hl("@constant", { fg = colors.cyan })
  hl("@constant.builtin", { fg = colors.cyan, bold = true })
  hl("@constant.macro", { fg = colors.pink })
  hl("@string", { fg = colors.cyan })
  hl("@string.documentation", { fg = colors.cyan, italic = true })
  hl("@string.regex", { fg = colors.red })
  hl("@string.escape", { fg = colors.orange, bold = true })
  hl("@string.special", { fg = colors.orange })
  hl("@character", { fg = colors.cyan })
  hl("@character.special", { fg = colors.orange })
  hl("@number", { fg = colors.orange })
  hl("@number.float", { fg = colors.orange })
  hl("@boolean", { fg = colors.orange, bold = true })

  -- Identifiers
  hl("@variable", { fg = colors.fg })
  hl("@variable.builtin", { fg = colors.purple, italic = true })
  hl("@variable.parameter", { fg = colors.fg, italic = true })
  hl("@variable.member", { fg = colors.blue })
  hl("@property", { fg = colors.blue })
  hl("@field", { fg = colors.blue })

  -- Functions
  hl("@function", { fg = colors.yellow })
  hl("@function.builtin", { fg = colors.yellow, bold = true })
  hl("@function.call", { fg = colors.yellow })
  hl("@function.macro", { fg = colors.pink })
  hl("@method", { fg = colors.yellow })
  hl("@method.call", { fg = colors.yellow })
  hl("@constructor", { fg = colors.blue, bold = true })

  -- Types
  hl("@type", { fg = colors.blue })
  hl("@type.builtin", { fg = colors.blue, bold = true })
  hl("@type.definition", { fg = colors.blue, bold = true })
  hl("@type.qualifier", { fg = colors.purple })
  hl("@storageclass", { fg = colors.purple, bold = true })
  hl("@attribute", { fg = colors.pink })
  hl("@namespace", { fg = colors.blue, italic = true })
  hl("@module", { fg = colors.blue, italic = true })

  -- Keywords
  hl("@keyword", { fg = colors.purple, bold = true })
  hl("@keyword.function", { fg = colors.purple, bold = true })
  hl("@keyword.operator", { fg = colors.purple })
  hl("@keyword.return", { fg = colors.purple, bold = true })
  hl("@keyword.conditional", { fg = colors.purple, bold = true })
  hl("@keyword.repeat", { fg = colors.purple, bold = true })
  hl("@keyword.import", { fg = colors.pink, bold = true })
  hl("@keyword.export", { fg = colors.pink, bold = true })
  hl("@keyword.exception", { fg = colors.red, bold = true })
  hl("@keyword.directive", { fg = colors.pink })
  hl("@keyword.directive.define", { fg = colors.pink })

  -- Operators
  hl("@operator", { fg = colors.purple })
  hl("@punctuation.delimiter", { fg = colors.fg })
  hl("@punctuation.bracket", { fg = colors.fg })
  hl("@punctuation.special", { fg = colors.red })

  -- Literals
  hl("@string.special.symbol", { fg = colors.cyan })
  hl("@string.special.url", { fg = colors.blue, underline = true })
  hl("@string.special.path", { fg = colors.cyan })

  -- Markup (for documentation, markdown, etc.)
  hl("@markup.strong", { bold = true })
  hl("@markup.italic", { italic = true })
  hl("@markup.strikethrough", { strikethrough = true })
  hl("@markup.underline", { underline = true })
  hl("@markup.heading", { fg = colors.purple, bold = true })
  hl("@markup.heading.1", { fg = colors.purple, bold = true })
  hl("@markup.heading.2", { fg = colors.blue, bold = true })
  hl("@markup.heading.3", { fg = colors.yellow, bold = true })
  hl("@markup.heading.4", { fg = colors.green, bold = true })
  hl("@markup.heading.5", { fg = colors.cyan, bold = true })
  hl("@markup.heading.6", { fg = colors.red, bold = true })
  hl("@markup.quote", { fg = colors.green, italic = true })
  hl("@markup.math", { fg = colors.orange })
  hl("@markup.link", { fg = colors.blue, underline = true })
  hl("@markup.link.label", { fg = colors.cyan })
  hl("@markup.link.url", { fg = colors.blue, underline = true })
  hl("@markup.raw", { fg = colors.cyan, bg = colors.bg_dark })
  hl("@markup.raw.block", { fg = colors.cyan, bg = colors.bg_dark })
  hl("@markup.list", { fg = colors.purple })
  hl("@markup.list.checked", { fg = colors.green })
  hl("@markup.list.unchecked", { fg = colors.orange })

  -- Tags (HTML, XML, etc.)
  hl("@tag", { fg = colors.red })
  hl("@tag.attribute", { fg = colors.blue })
  hl("@tag.delimiter", { fg = colors.fg_dark })

  -- Language-specific highlights

  -- JavaScript/TypeScript
  hl("@variable.builtin.javascript", { fg = colors.purple, italic = true })
  hl("@variable.builtin.typescript", { fg = colors.purple, italic = true })
  hl("@constructor.javascript", { fg = colors.blue, bold = true })
  hl("@constructor.typescript", { fg = colors.blue, bold = true })

  -- Python
  hl("@variable.builtin.python", { fg = colors.purple, italic = true })
  hl("@function.builtin.python", { fg = colors.yellow, bold = true })
  hl("@constant.builtin.python", { fg = colors.cyan, bold = true })

  -- Lua
  hl("@variable.builtin.lua", { fg = colors.purple, italic = true })
  hl("@function.builtin.lua", { fg = colors.yellow, bold = true })

  -- Rust
  hl("@type.builtin.rust", { fg = colors.blue, bold = true })
  hl("@attribute.rust", { fg = colors.pink })
  hl("@punctuation.special.rust", { fg = colors.purple })

  -- Go
  hl("@type.builtin.go", { fg = colors.blue, bold = true })
  hl("@function.builtin.go", { fg = colors.yellow, bold = true })

  -- C/C++
  hl("@type.builtin.c", { fg = colors.blue, bold = true })
  hl("@type.builtin.cpp", { fg = colors.blue, bold = true })
  hl("@storageclass.c", { fg = colors.purple, bold = true })
  hl("@storageclass.cpp", { fg = colors.purple, bold = true })

  -- Java
  hl("@type.builtin.java", { fg = colors.blue, bold = true })
  hl("@storageclass.java", { fg = colors.purple, bold = true })

  -- CSS
  hl("@property.css", { fg = colors.blue })
  hl("@string.css", { fg = colors.cyan })
  hl("@number.css", { fg = colors.orange })
  hl("@type.css", { fg = colors.red })
  hl("@type.tag.css", { fg = colors.red })
  hl("@attribute.css", { fg = colors.yellow })

  -- JSON
  hl("@label.json", { fg = colors.blue })
  hl("@string.json", { fg = colors.cyan })
  hl("@number.json", { fg = colors.orange })
  hl("@boolean.json", { fg = colors.orange, bold = true })

  -- YAML
  hl("@field.yaml", { fg = colors.blue })
  hl("@string.yaml", { fg = colors.cyan })
  hl("@punctuation.delimiter.yaml", { fg = colors.purple })

  -- SQL
  hl("@keyword.sql", { fg = colors.purple, bold = true })
  hl("@type.sql", { fg = colors.blue, bold = true })
  hl("@function.sql", { fg = colors.yellow })

  -- Shell/Bash
  hl("@variable.bash", { fg = colors.fg })
  hl("@variable.builtin.bash", { fg = colors.purple, italic = true })
  hl("@function.builtin.bash", { fg = colors.yellow, bold = true })
  hl("@string.bash", { fg = colors.cyan })

  -- Git
  hl("@string.special.url.gitcommit", { fg = colors.blue, underline = true })
  hl("@comment.gitcommit", { fg = colors.green, italic = true })

  -- Diagnostics integration
  hl("@error", { fg = colors.error })
  hl("@warning", { fg = colors.warning })
  hl("@info", { fg = colors.info })
  hl("@hint", { fg = colors.hint })

  -- Special semantic tokens
  hl("@lsp.type.class", { fg = colors.blue, bold = true })
  hl("@lsp.type.decorator", { fg = colors.pink })
  hl("@lsp.type.enum", { fg = colors.blue, bold = true })
  hl("@lsp.type.enumMember", { fg = colors.cyan })
  hl("@lsp.type.function", { fg = colors.yellow })
  hl("@lsp.type.interface", { fg = colors.blue, italic = true })
  hl("@lsp.type.macro", { fg = colors.pink })
  hl("@lsp.type.method", { fg = colors.yellow })
  hl("@lsp.type.namespace", { fg = colors.blue, italic = true })
  hl("@lsp.type.parameter", { fg = colors.fg, italic = true })
  hl("@lsp.type.property", { fg = colors.blue })
  hl("@lsp.type.struct", { fg = colors.blue, bold = true })
  hl("@lsp.type.type", { fg = colors.blue })
  hl("@lsp.type.typeParameter", { fg = colors.blue, italic = true })
  hl("@lsp.type.variable", { fg = colors.fg })

  -- Modifiers
  hl("@lsp.mod.deprecated", { strikethrough = true })
  hl("@lsp.mod.readonly", { italic = true })
  hl("@lsp.mod.static", { bold = true })

  -- Additional semantic highlighting for better code comprehension
  hl("@conceal", { fg = colors.fg_dark })
  hl("@spell", { undercurl = true })
  hl("@nospell", {})

  -- Tree-sitter context
  hl("TreesitterContext", { bg = colors.bg_dark })
  hl("TreesitterContextLineNumber", { fg = colors.line_number_current, bg = colors.bg_dark })
  hl("TreesitterContextSeparator", { fg = colors.border })
end

return M
