-- subfolder.lua

local M = {}

function M.copySubfolderPath()
  local current_file_path = vim.fn.expand "%:p" -- Get the full path of the current file
  local current_folder = vim.fn.fnamemodify(current_file_path, ":h") -- Get the directory of the current file

  -- Copy the relative path to the system clipboard using xclip (Linux)
  vim.fn.system('echo "' .. current_folder .. '" | pbcopy') -- Copy the relative path to the system clipboard using pbcopy (Mac)

  -- Print a message indicating the path has been copied
  vim.api.nvim_out_write("Copied subfolder path to clipboard: " .. current_folder .. "\n")
end

function M.copyRelativeFolderPath()
  -- Get the path of the current file
  local current_path = vim.fn.expand "%:p:h"

  -- Get the relative path from the project root (assuming the project root is the Git root)
  local project_root = vim.fn.system "git rev-parse --show-toplevel 2>/dev/null"
  local relative_path = vim.fn.fnamemodify(current_path, ":~:.")

  -- Remove newline characters from the relative path
  relative_path = string.gsub(relative_path, "\n", "")

  -- Copy the relative path to the system clipboard
  -- vim.fn.system('echo "' .. relative_path .. '" | pbcopy') -- for macOS
  vim.fn.system('printf "%s" "' .. relative_path .. '" | pbcopy')  -- for macOS
  -- vim.fn.system('echo "' .. relative_path .. '" | xclip -selection clipboard')  -- for Linux

  -- Provide a message in the command line
  vim.api.nvim_out_write("Relative subfolder path copied to clipboard: " .. relative_path .. "\n")
end

return M
