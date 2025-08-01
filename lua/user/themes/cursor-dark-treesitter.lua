-- Treesitter highlights for Cursor Dark Theme
local colors = require("user.themes.cursor-dark").colors

local M = {}

-- Helper function to create highlight groups
local function hl(group, opts)
  if opts.link then
    vim.api.nvim_set_hl(0, group, { link = opts.link })
  else
    vim.api.nvim_set_hl(0, group, opts)
  end
end

function M.setup()
  -- Treesitter syntax groups
  hl("@attribute", { fg = colors.yellow })
  hl("@boolean", { fg = colors.blue })
  hl("@character", { fg = colors.orange })
  hl("@character.special", { fg = colors.orange })
  hl("@comment", { fg = colors.green, italic = true })
  hl("@comment.documentation", { fg = colors.green, italic = true })
  hl("@comment.error", { fg = colors.error })
  hl("@comment.note", { fg = colors.info })
  hl("@comment.todo", { fg = colors.bg, bg = colors.yellow, bold = true })
  hl("@comment.warning", { fg = colors.warning })
  
  hl("@constant", { fg = colors.cyan })
  hl("@constant.builtin", { fg = colors.blue })
  hl("@constant.macro", { fg = colors.purple })
  
  hl("@constructor", { fg = colors.blue })
  hl("@diff.delta", { fg = colors.git_change })
  hl("@diff.minus", { fg = colors.git_delete })
  hl("@diff.plus", { fg = colors.git_add })
  
  hl("@error", { fg = colors.error })
  hl("@exception", { fg = colors.purple })
  
  hl("@field", { fg = colors.cyan })
  hl("@float", { fg = colors.cyan })
  hl("@function", { fg = colors.yellow })
  hl("@function.builtin", { fg = colors.yellow })
  hl("@function.call", { fg = colors.yellow })
  hl("@function.macro", { fg = colors.purple })
  hl("@function.method", { fg = colors.yellow })
  hl("@function.method.call", { fg = colors.yellow })
  
  hl("@include", { fg = colors.purple })
  hl("@keyword", { fg = colors.blue })
  hl("@keyword.conditional", { fg = colors.purple })
  hl("@keyword.debug", { fg = colors.purple })
  hl("@keyword.directive", { fg = colors.purple })
  hl("@keyword.directive.define", { fg = colors.purple })
  hl("@keyword.exception", { fg = colors.purple })
  hl("@keyword.function", { fg = colors.blue })
  hl("@keyword.import", { fg = colors.purple })
  hl("@keyword.operator", { fg = colors.purple })
  hl("@keyword.repeat", { fg = colors.purple })
  hl("@keyword.return", { fg = colors.purple })
  hl("@keyword.storage", { fg = colors.blue })
  
  hl("@label", { fg = colors.purple })
  hl("@markup.emphasis", { italic = true })
  hl("@markup.environment", { fg = colors.purple })
  hl("@markup.environment.name", { fg = colors.yellow })
  hl("@markup.heading", { fg = colors.blue, bold = true })
  hl("@markup.heading.1", { fg = colors.blue, bold = true })
  hl("@markup.heading.2", { fg = colors.cyan, bold = true })
  hl("@markup.heading.3", { fg = colors.yellow, bold = true })
  hl("@markup.heading.4", { fg = colors.orange, bold = true })
  hl("@markup.heading.5", { fg = colors.purple, bold = true })
  hl("@markup.heading.6", { fg = colors.pink, bold = true })
  hl("@markup.link", { fg = colors.blue, underline = true })
  hl("@markup.link.label", { fg = colors.cyan })
  hl("@markup.link.url", { fg = colors.blue, underline = true })
  hl("@markup.list", { fg = colors.purple })
  hl("@markup.list.checked", { fg = colors.green })
  hl("@markup.list.unchecked", { fg = colors.fg_dark })
  hl("@markup.math", { fg = colors.cyan })
  hl("@markup.quote", { fg = colors.green, italic = true })
  hl("@markup.raw", { fg = colors.orange })
  hl("@markup.raw.block", { fg = colors.orange })
  hl("@markup.strikethrough", { strikethrough = true })
  hl("@markup.strong", { bold = true })
  hl("@markup.underline", { underline = true })
  
  hl("@method", { fg = colors.yellow })
  hl("@method.call", { fg = colors.yellow })
  hl("@module", { fg = colors.blue })
  hl("@namespace", { fg = colors.blue })
  hl("@none", {})
  hl("@number", { fg = colors.cyan })
  hl("@number.float", { fg = colors.cyan })
  
  hl("@operator", { fg = colors.fg })
  hl("@parameter", { fg = colors.fg })
  hl("@parameter.reference", { fg = colors.fg })
  hl("@property", { fg = colors.cyan })
  hl("@punctuation.bracket", { fg = colors.fg })
  hl("@punctuation.delimiter", { fg = colors.fg })
  hl("@punctuation.special", { fg = colors.purple })
  
  hl("@string", { fg = colors.orange })
  hl("@string.documentation", { fg = colors.green })
  hl("@string.escape", { fg = colors.cyan })
  hl("@string.regexp", { fg = colors.red })
  hl("@string.special", { fg = colors.cyan })
  hl("@string.special.path", { fg = colors.orange })
  hl("@string.special.symbol", { fg = colors.cyan })
  hl("@string.special.url", { fg = colors.blue, underline = true })
  
  hl("@tag", { fg = colors.blue })
  hl("@tag.attribute", { fg = colors.cyan })
  hl("@tag.delimiter", { fg = colors.fg })
  hl("@text", { fg = colors.fg })
  hl("@text.danger", { fg = colors.error })
  hl("@text.diff.add", { fg = colors.git_add })
  hl("@text.diff.delete", { fg = colors.git_delete })
  hl("@text.emphasis", { italic = true })
  hl("@text.environment", { fg = colors.purple })
  hl("@text.environment.name", { fg = colors.yellow })
  hl("@text.literal", { fg = colors.orange })
  hl("@text.math", { fg = colors.cyan })
  hl("@text.note", { fg = colors.info })
  hl("@text.reference", { fg = colors.blue })
  hl("@text.strike", { strikethrough = true })
  hl("@text.strong", { bold = true })
  hl("@text.title", { fg = colors.blue, bold = true })
  hl("@text.todo", { fg = colors.bg, bg = colors.yellow, bold = true })
  hl("@text.underline", { underline = true })
  hl("@text.uri", { fg = colors.blue, underline = true })
  hl("@text.warning", { fg = colors.warning })
  
  hl("@type", { fg = colors.blue })
  hl("@type.builtin", { fg = colors.blue })
  hl("@type.definition", { fg = colors.blue })
  hl("@type.qualifier", { fg = colors.blue })
  
  hl("@variable", { fg = colors.fg })
  hl("@variable.builtin", { fg = colors.blue })
  hl("@variable.member", { fg = colors.cyan })
  hl("@variable.parameter", { fg = colors.fg })
  
  -- Language-specific highlights
  
  -- HTML
  hl("@tag.html", { fg = colors.blue })
  hl("@tag.attribute.html", { fg = colors.cyan })
  hl("@tag.delimiter.html", { fg = colors.fg })
  
  -- CSS
  hl("@property.css", { fg = colors.cyan })
  hl("@type.css", { fg = colors.blue })
  hl("@string.css", { fg = colors.orange })
  hl("@number.css", { fg = colors.cyan })
  
  -- JavaScript/TypeScript
  hl("@constructor.javascript", { fg = colors.yellow })
  hl("@constructor.typescript", { fg = colors.yellow })
  hl("@keyword.export.javascript", { fg = colors.purple })
  hl("@keyword.export.typescript", { fg = colors.purple })
  hl("@keyword.import.javascript", { fg = colors.purple })
  hl("@keyword.import.typescript", { fg = colors.purple })
  
  -- JSON
  hl("@label.json", { fg = colors.cyan })
  hl("@string.json", { fg = colors.orange })
  hl("@number.json", { fg = colors.cyan })
  hl("@boolean.json", { fg = colors.blue })
  
  -- YAML
  hl("@field.yaml", { fg = colors.cyan })
  hl("@string.yaml", { fg = colors.orange })
  
  -- Markdown
  hl("@markup.heading.1.markdown", { fg = colors.blue, bold = true })
  hl("@markup.heading.2.markdown", { fg = colors.cyan, bold = true })
  hl("@markup.heading.3.markdown", { fg = colors.yellow, bold = true })
  hl("@markup.heading.4.markdown", { fg = colors.orange, bold = true })
  hl("@markup.heading.5.markdown", { fg = colors.purple, bold = true })
  hl("@markup.heading.6.markdown", { fg = colors.pink, bold = true })
  hl("@markup.link.markdown", { fg = colors.blue, underline = true })
  hl("@markup.link.label.markdown", { fg = colors.cyan })
  hl("@markup.link.url.markdown", { fg = colors.blue, underline = true })
  hl("@markup.raw.block.markdown", { fg = colors.orange })
  hl("@markup.raw.markdown", { fg = colors.orange })
  
  -- Lua
  hl("@constructor.lua", { fg = colors.yellow })
  hl("@keyword.function.lua", { fg = colors.blue })
  hl("@keyword.operator.lua", { fg = colors.purple })
  
  -- Python
  hl("@constructor.python", { fg = colors.yellow })
  hl("@keyword.import.python", { fg = colors.purple })
  hl("@exception.python", { fg = colors.purple })
  
  -- Rust
  hl("@type.rust", { fg = colors.blue })
  hl("@keyword.storage.rust", { fg = colors.blue })
  hl("@keyword.unsafe.rust", { fg = colors.red })
  
  -- Go
  hl("@type.go", { fg = colors.blue })
  hl("@keyword.package.go", { fg = colors.purple })
  hl("@keyword.import.go", { fg = colors.purple })
  
  -- C/C++
  hl("@type.c", { fg = colors.blue })
  hl("@type.cpp", { fg = colors.blue })
  hl("@keyword.storage.c", { fg = colors.blue })
  hl("@keyword.storage.cpp", { fg = colors.blue })
  
  -- Java
  hl("@type.java", { fg = colors.blue })
  hl("@keyword.import.java", { fg = colors.purple })
  hl("@keyword.package.java", { fg = colors.purple })
  
  -- PHP
  hl("@type.php", { fg = colors.blue })
  hl("@keyword.import.php", { fg = colors.purple })
  hl("@variable.php", { fg = colors.fg })
  
  -- Ruby
  hl("@symbol.ruby", { fg = colors.cyan })
  hl("@keyword.import.ruby", { fg = colors.purple })
  
  -- Shell/Bash
  hl("@function.builtin.bash", { fg = colors.yellow })
  hl("@variable.bash", { fg = colors.fg })
  hl("@string.bash", { fg = colors.orange })
  
  -- SQL
  hl("@keyword.sql", { fg = colors.blue })
  hl("@type.sql", { fg = colors.blue })
  hl("@function.sql", { fg = colors.yellow })
  
  -- Docker
  hl("@keyword.dockerfile", { fg = colors.blue })
  hl("@string.dockerfile", { fg = colors.orange })
  
  -- Git
  hl("@keyword.gitcommit", { fg = colors.blue })
  hl("@string.gitcommit", { fg = colors.orange })
  
  -- Config files
  hl("@property.toml", { fg = colors.cyan })
  hl("@string.toml", { fg = colors.orange })
  hl("@property.ini", { fg = colors.cyan })
  hl("@string.ini", { fg = colors.orange })
end

return M