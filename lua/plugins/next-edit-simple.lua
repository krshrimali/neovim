-- Simple Next Edit Suggestions Plugin
return {
  dir = vim.fn.stdpath("config") .. "/lua", -- Use local file
  name = "next-edit-suggestions",
  config = function()
    require("next-edit-suggestions").setup()
  end,
  event = "InsertEnter",
}