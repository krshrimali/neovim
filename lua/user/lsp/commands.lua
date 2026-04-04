-- LSP Commands
-- Recreates CoC commands: :Format, :OR (organize imports), plus :lsp aliases

local M = {}

function M.setup()
  -- :Format command (matching CoC)
  vim.api.nvim_create_user_command("Format", function(args)
    local range = nil
    if args.count ~= -1 then
      local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
      range = {
        start = { args.line1, 0 },
        ["end"] = { args.line2, end_line:len() },
      }
    end
    vim.lsp.buf.format {
      async = true,
      range = range,
    }
  end, { range = true, desc = "Format code with LSP" })

  -- :OR command (Organize imports)
  vim.api.nvim_create_user_command("OR", function()
    local win = vim.api.nvim_get_current_win()
    local client = vim.lsp.get_clients({ bufnr = 0 })[1]
    local offset_encoding = client and client.offset_encoding or "utf-16"
    local params = vim.lsp.util.make_range_params(win, offset_encoding)
    params.context = { only = { "source.organizeImports" } }

    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 1000)
    if not result or vim.tbl_isempty(result) then
      vim.notify("No organize imports action available", vim.log.levels.WARN)
      return
    end

    for _, res in pairs(result) do
      if res.result then
        for _, action in pairs(res.result) do
          if action.edit then
            vim.lsp.util.apply_workspace_edit(action.edit, offset_encoding)
          elseif action.command then
            vim.lsp.buf.execute_command(action.command)
          end
        end
      end
    end
  end, { desc = "Organize imports" })

  -- Aliases for :lsp subcommands (Neovim 0.12+)
  vim.api.nvim_create_user_command("LI", "lsp status", { desc = "Show LSP info" })
  vim.api.nvim_create_user_command("LR", "lsp restart", { desc = "Restart LSP" })
  vim.api.nvim_create_user_command("LS", "lsp start", { desc = "Start LSP" })
end

return M
