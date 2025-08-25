return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
  opts = {
    showmode = false,
    restricted_keys = {
      ["w"] = { "n", "x" },
      ["b"] = { "n", "x" },
      ["e"] = { "n", "x" },
    },
  },
}
