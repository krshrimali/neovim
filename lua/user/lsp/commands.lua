-- LSP Commands
-- Recreates CoC commands: :Format, :OR (organize imports), :LspInfo, :LspRestart

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
    local params = vim.lsp.util.make_range_params()
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
            vim.lsp.util.apply_workspace_edit(action.edit, "utf-8")
          elseif action.command then
            vim.lsp.buf.execute_command(action.command)
          end
        end
      end
    end
  end, { desc = "Organize imports" })

  -- :LspInfo (already built-in, but we can alias it)
  vim.api.nvim_create_user_command("LI", "LspInfo", { desc = "Show LSP info" })

  -- :LspRestart (already built-in)
  vim.api.nvim_create_user_command("LR", "LspRestart", { desc = "Restart LSP" })

  -- :LspLog to open LSP log
  vim.api.nvim_create_user_command(
    "LspLog",
    function() vim.cmd("edit " .. vim.lsp.get_log_path()) end,
    { desc = "Open LSP log file" }
  )

  -- :LspStart to manually start LSP
  vim.api.nvim_create_user_command("LS", "LspStart", { desc = "Start LSP" })

  -- :LspStop to manually stop LSP
  vim.api.nvim_create_user_command("LspStop", "LspStop", { desc = "Stop LSP" })
end

return M
