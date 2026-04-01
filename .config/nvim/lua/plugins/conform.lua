return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    formatters_by_ft = {
      go = { "goimports", "gofmt" },
      typescript = { "oxfmt" },
      typescriptreact = { "oxfmt" },
      javascript = { "oxfmt" },
      javascriptreact = { "oxfmt" },
      vue = { "oxfmt" },
      swift = { "swift_format" },
    },
    formatters = {
      oxfmt = {
        command = "oxfmt",
        args = function(_, ctx)
          -- Check if project has its own oxfmt config
          local config_names =
            { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.js", "oxfmt.config.mjs", "oxfmt.config.ts" }
          local project_config = nil
          for _, name in ipairs(config_names) do
            local path = vim.fs.find(name, { upward = true, path = ctx.dirname })[1]
            if path then
              project_config = path
              break
            end
          end

          if project_config then
            -- vim.notify("[oxfmt] Using project config: " .. project_config, vim.log.levels.DEBUG)
            return { "--stdin-filepath", ctx.filename }
          end

          -- Fallback to default config
          local default_config = vim.fn.stdpath("config") .. "/defaults/oxfmtrc.json"
          -- local config_exists = vim.fn.filereadable(default_config) == 1

          -- vim.notify(
          --   string.format(
          --     "[oxfmt] No project config found (searched from: %s)\n"
          --       .. "[oxfmt] Default config: %s (exists: %s)\n"
          --       .. "[oxfmt] Final args: -c %s --stdin-filepath %s",
          --     ctx.dirname,
          --     default_config,
          --     tostring(config_exists),
          --     default_config,
          --     ctx.filename
          --   ),
          --   vim.log.levels.INFO
          -- )

          return { "-c", default_config, "--stdin-filepath", ctx.filename }
        end,
        stdin = true,
      },
    },
  },
}
