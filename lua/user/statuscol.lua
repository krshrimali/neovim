local builtin = require "statuscol.builtin"
local cfg = {
  setopt = true,
  relculright = true,
  segments = {

    { text = { builtin.foldfunc, " " }, click = "v:lua.ScFa", hl = "Comment" },

    { text = { "%s" }, click = "v:lua.ScSa" },
    { text = { builtin.lnumfunc, " " }, click = "v:lua.ScLa" },
  },
}

require("statuscol").setup(cfg)
