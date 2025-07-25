local lspconfig = require('lspconfig')

-- Configure pyright to use virtual environment
lspconfig.pyright.setup({
  before_init = function(_, config)
    if vim.env.VIRTUAL_ENV then
      config.settings.python.pythonPath = vim.env.VIRTUAL_ENV .. '/bin/python'
    end
  end,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = false,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        reportMissingImports = "none",
        reportMissingTypeStubs = "none",
        reportImportCycles = "none",
        reportUnusedImport = "none",
        stubPath = "",
        typeshedPaths = {},
        extraPaths = {},
        include = {},
        exclude = {
          "**/node_modules",
          "**/__pycache__",
          ".git",
          "**/.pytest_cache",
          "**/.mypy_cache",
          "**/site-packages",
          "**/dist",
          "**/build"
        }
      }
    }
  }
})
