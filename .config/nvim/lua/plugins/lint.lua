return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local lint = require("lint")

    -- Override oxlint to use Mason binary + severity-aware parser
    local mason_bin = vim.fn.stdpath("data") .. "/mason/bin"
    local oxlint_path = mason_bin .. "/oxlint"

    -- Custom parser: extract severity from [Warning/...] or [Error/...]
    local severity_map = {
      ["Warning"] = vim.diagnostic.severity.WARN,
      ["Error"] = vim.diagnostic.severity.ERROR,
    }

    lint.linters.oxlint = {
      name = "oxlint",
      cmd = vim.fn.executable(oxlint_path) == 1 and oxlint_path or "oxlint",
      stdin = false,
      args = { "--format", "unix" },
      stream = "stdout",
      ignore_exitcode = true,
      parser = function(output)
        local diagnostics = {}
        for line in output:gmatch("[^\n]+") do
          -- Format: file:line:col: message [Warning/rule(name)] or [Error/rule(name)]
          local _, lnum, col, msg, sev = line:match("^(.+):(%d+):(%d+): (.+) %[(%w+)/")
          if lnum then
            table.insert(diagnostics, {
              lnum = tonumber(lnum) - 1,
              col = tonumber(col) - 1,
              message = msg,
              severity = severity_map[sev] or vim.diagnostic.severity.WARN,
              source = "oxlint",
            })
          end
        end
        return diagnostics
      end,
    }

    lint.linters_by_ft = {
      typescript = { "oxlint" },
      typescriptreact = { "oxlint" },
      javascript = { "oxlint" },
      javascriptreact = { "oxlint" },
      vue = { "oxlint" },
    }

    vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = vim.api.nvim_create_augroup("nvim-lint", { clear = true }),
      callback = function()
        lint.try_lint()
      end,
    })
  end,
}
