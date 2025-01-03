return {
  settings = {
    pyright = {
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        ignore = { '*' },
        -- typeCheckingMode = "basic",
        -- autoImportCompletions = true,
        -- autoSearchPaths = true,
        -- diagnosticMode = "openFilesOnly",
        -- inlayHints = {
        --     variableTypes = false,
        --     functionReturnTypes = false,
        -- },
      },
    },
  },
}
