local ok, ts = pcall(require, "nvim-treesitter")
if not ok then return end

-- Parsers to have available immediately; anything else installs on first
-- use of that filetype (see the FileType autocmd below).
local ensure_installed = { "lua", "python", "diff", "gitcommit", "markdown", "markdown_inline" }
ts.install(ensure_installed)

-- Filetypes intentionally kept on legacy regex `:syntax` highlighting
-- (heavy treesitter grammars / not worth the parse cost here).
local disabled_langs = { css = true, html = true }
local max_filesize = 500 * 1024 -- 500KB

local function should_highlight(bufnr, lang)
  if disabled_langs[lang] then return false end
  if vim.bo[bufnr].buftype == "terminal" then return false end
  local ok_stat, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(bufnr))
  if ok_stat and stats and stats.size > max_filesize then return false end
  return true
end

vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("user_treesitter_highlight", { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local lang = vim.treesitter.language.get_lang(args.match) or args.match
    if not require("nvim-treesitter.parsers")[lang] then return end -- unsupported language
    if not should_highlight(bufnr, lang) then return end

    if not vim.tbl_contains(require("nvim-treesitter.config").get_installed "parsers", lang) then
      ts.install(lang):wait(120000)
    end

    if pcall(vim.treesitter.start, bufnr, lang) then
      -- Avoid the legacy regex syntax engine running (and flickering) on
      -- top of treesitter's own highlighting.
      vim.bo[bufnr].syntax = "off"
    end
  end,
})
