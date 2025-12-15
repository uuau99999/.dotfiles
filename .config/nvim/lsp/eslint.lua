return {
  cmd = { "eslint", "--stdin", "--stdin-filename", "$FILENAME", "--format", "json" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  },
  settings = {
    eslint = {
      enable = true,
      validate = true,
      run = "onType",
      nodePath = "",
      codeAction = {
        showDocumentation = {
          enable = true,
        },
        autoFix = {
          enable = true,
        },
      },

      globals = {
        "Atomics",
        "SharedArrayBuffer",
      },
    },
  },
  single_file_support = true,
}
