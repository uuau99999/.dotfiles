return {
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })
      vim.treesitter.language.register("markdown", "mdx")
    end,
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
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = "LazyFile",
    opts = {
      enable = false,
    },
  },
}
