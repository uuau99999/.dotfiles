-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

require("telescope").load_extension("harpoon")
require("telescope").load_extension("fzf")
require("telescope").load_extension("file_browser")
require("telescope").load_extension("ast_grep")

local fzy = require("telescope.algos.fzy")
local sorters = require("telescope.sorters")

local custom_live_grep_sorter = sorters.Sorter:new({
  scoring_function = function(_, _, line)
    if line:find("vue") then
      return 0
    elseif line:find("lua") then
      return 0
    elseif line:find("ts") then
      return 1
    elseif line:find("js") then
      return 2
    elseif line:find("json") then
      return 3
    elseif line:find("html") then
      return 4
    elseif line:find("yml") then
      return 5
    elseif line:find("css") then
      return 6
    else
      return 100
    end
  end,
  highlighter = function(_, prompt, display)
    return fzy.positions(prompt, display)
  end,
})

require("telescope").setup({
  defaults = {
    layout_strategy = "horizontal",
    layout_config = {
      prompt_position = "bottom",
      horizontal = {
        preview_cutoff = 0,
      },
    },
    mappings = {
      i = {
        ["<C-Q>"] = require("telescope.actions").send_to_qflist + require("telescope.actions").open_qflist,
      },
      n = {
        ["<C-Q>"] = require("telescope.actions").send_to_qflist + require("telescope.actions").open_qflist,
      },
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    },
    live_grep = {
      theme = "dropdown",
      sorter = custom_live_grep_sorter,
    },
    git_files = {
      theme = "dropdown",
    },
    oldfiles = {
      theme = "dropdown",
    },
  },
})
local lspconfig = require("lspconfig")
lspconfig.volar.setup({
  filetypes = { "vue" },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
})

-- vim.cmd.colorscheme("catppuccin")
vim.cmd.colorscheme("nightfly")
