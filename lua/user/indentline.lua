local status_ok, indent_blankline = pcall(require, "ibl")
if not status_ok then
  return
end

vim.opt.list = true
-- vim.opt.listchars:append "space:⋅"
-- vim.opt.listchars:append "space:"
-- vim.opt.listchars:append "eol:↴"

indent_blankline.setup({enabled=true})
