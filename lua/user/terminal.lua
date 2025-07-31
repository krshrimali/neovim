-- Use the new comprehensive lazygit implementation
local lazygit = require("user.lazygit")

-- Legacy function for backward compatibility
M.lazygit_toggle = function()
  lazygit.lazygit_toggle_float()
end

return M
