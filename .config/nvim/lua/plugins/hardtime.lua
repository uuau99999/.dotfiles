return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
  opts = {
    showmode = false,
    restricted_keys = {
      ["j"] = false,
      ["k"] = false,
      ["w"] = { "n", "x" },
      ["b"] = { "n", "x" },
      ["e"] = { "n", "x" },
    },
  },
}
