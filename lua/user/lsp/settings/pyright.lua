return {
  -- cmd = { "pyright" },
  settings = {
    -- analysis = {
    --   autoImportCompletions = true,
    --   autoSearchPaths = true,
    --   diagnosticMode = "workspace",
    --   exclude = {
    --     "**/__pycache__",
    --   },
    --   extraPaths = {
    --     -- os.getenv("PYENV_VIRTUAL_ENV") .. "/lib/python3.8/site-packages",
    --     "/Users/krshrimali/Documents/Projects/Abnormal/copy/source/.venv/lib/python3.8/site-packages",
    --     "/Users/krshrimali/Documents/Projects/Abnormal/copy/source/src/py",
    --     "/Users/krshrimali/Documents/Projects/Abnormal/copy/source/src/pytests",
    --     "/Users/krshrimali/Documents/Projects/Abnormal/copy/source/src/pytests/abnormal/test",
    --   },
    --   useLibraryCodeForTypes = true,
    -- },
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        inlayHints = {
          variableTypes = true,
          functionReturnTypes = true,
        },
        extraPaths = {
          -- os.getenv("PYENV_VIRTUAL_ENV") .. "/lib/python3.8/site-packages",
          -- os.getenv "SOURCE" .. ".venv/lib/python3.8/site-packages",
          -- os.getenv "SOURCE" .. "/src/py",
          -- os.getenv "SOURCE" .. "/src/pytests",
          -- os.getenv "SOURCE" .. "/src/pytests/abnormal/test",
        },
      },
    },
  },
}
