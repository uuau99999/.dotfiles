return {
  {
    "telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
      "nvim-telescope/telescope-file-browser.nvim",
      "Marskey/telescope-sg",
    },
    opts = function(_, opts)
      local actions = require("telescope.actions")
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

      return vim.tbl_deep_extend("force", opts or {}, {
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
              ["<C-Q>"] = actions.send_to_qflist + actions.open_qflist,
            },
            n = {
              ["<C-Q>"] = actions.send_to_qflist + actions.open_qflist,
              ["<leader>ff"] = false,
              ["<leader>fg"] = false,
              ["<leader>fz"] = false,
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
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          file_browser = {
            hijack_netrw = false,
            theme = "dropdown",
          },
          ast_grep = {
            command = {
              "sg",
              "--json=stream",
            },
            grep_open_files = false,
            lang = nil,
          },
        },
      })
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)

      for _, extension in ipairs({ "harpoon", "fzf", "file_browser", "ast_grep" }) do
        pcall(telescope.load_extension, extension)
      end
    end,
  },
  {
    "folke/flash.nvim",
    enabled = false,
  },
  {
    "Exafunction/codeium.nvim",
    enabled = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "hrsh7th/nvim-cmp",
    },
    config = function()
      require("codeium").setup({})
    end,
  },
  {
    "Exafunction/codeium.vim",
    enabled = false,
    event = "BufEnter",
    config = function()
      -- Change '<C-g>' here to any keycode you like.
      vim.keymap.set("i", "<c-g>", function()
        return vim.fn["codeium#Accept"]()
      end, { expr = true })
      vim.keymap.set("i", "<c-;>", function()
        return vim.fn["codeium#CycleCompletions"](1)
      end, { expr = true })
      vim.keymap.set("i", "<c-,>", function()
        return vim.fn["codeium#CycleCompletions"](-1)
      end, { expr = true })
      vim.keymap.set("i", "<c-x>", function()
        return vim.fn["codeium#Clear"]()
      end, { expr = true })
    end,
  },
  {
    "github/copilot.vim",
    enabled = false,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    enabled = false,
    branch = "canary",
    dependencies = {
      -- { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
      { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
    },
    opts = {
      -- debug = true, -- Enable debugging
      -- See Configuration section for rest
      window = {
        layout = "float",
        relative = "cursor",
        width = 1,
        height = 0.4,
        row = 1,
      },
    },
    -- See Commands section for default commands if you want to lazy load on them
  },
  {
    "supermaven-inc/supermaven-nvim",
    config = function()
      require("supermaven-nvim").setup({
        keymaps = {
          accept_suggestion = "<c-g>",
        },
        color = {
          suggestion_color = "gray",
          cterm = 244,
        },
      })
    end,
  },
}
