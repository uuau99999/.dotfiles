return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/nvim-treesitter-context",
    },
    opts = {
      ensure_installed = {
        "css",
        "fish",
        "gitignore",
        "http",
        "rust",
        "scss",
        "sql",
        "markdown",
        "javascript",
        "lua",
        "tsx",
        "typescript",
        "vue",
        "yaml",
        "astro",
        "svelte",
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
      local tsc = require("treesitter-context")
      tsc.disable()

      -- require("treesitter-context").setup({
      --   separator = "-",
      -- })

      -- MDX
      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
}
