return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    formatters_by_ft = {
      go = { "goimports", "gofmt" }, -- Use goimports first, then gofmt
      -- Add other language formatters here
    },
  },
}
