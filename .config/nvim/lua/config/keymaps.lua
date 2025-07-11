-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local keymap = vim.keymap
local opts = { noremap = true, silent = true }
local nmap = function(keys, func, desc)
  vim.keymap.set("n", keys, func, { desc = desc })
end

-- local discipline = require("local.discipline")
-- discipline.cowboy()

keymap.set("c", "W<CR>", "w<CR>")

nmap("<leader>t", vim.cmd.Ex, "Open netwr")

keymap.set("n", "<C-p>", "<cmd>silent !tmux neww ~/.config/tmux/tmux-sessionizer<CR>")
keymap.set("n", "<C-x>", "<cmd>silent !tmux neww ~/.config/tmux/tmux-clear<CR>")
keymap.set("n", "<C-f>", "<cmd>silent !tmux neww ~/.config/tmux/tmux-fzf<CR>")

keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- keymap.set("n", "<C-j>", "<C-e>")
-- keymap.set("n", "<C-k>", "<C-y>")

keymap.set("n", "x", '"_x')
-- keymap.set("n"w, "s", '"_s')
keymap.set("n", "S", '"_S')

keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")

keymap.set("n", "dw", "diw")
keymap.set("n", "yw", "yiw")
keymap.set("n", "vw", "viw")
-- keymap.set("n", "cc", '"_cc')
keymap.set("n", "c", '"_c')
keymap.set("n", "cw", '"_ciw')
keymap.set("n", "C", '"_C')
-- keymap.set("n", "yy", "yy")
-- keymap.set("n", "y", "yi")

-- Disable macro
keymap.set("n", "q", "<nop>")

-- Select all
keymap.set("n", "<C-a>", "gg<S-v>G")

-- Split window
keymap.set("n", "<leader>ss", ":split<Return>", opts)
keymap.set("n", "<leader>sv", ":vsplit<Return>", opts)

-- Line move
keymap.set("n", "<M-UP>", ":m-2<CR>")
keymap.set("n", "<M-DOWN>", ":m+1<CR>")

-- Buffer toggle between last 2 buffers
keymap.set("n", "<C-n>", "<cmd>b#<CR>", opts)

-- keymap.set("n", "<leader>e", "<cmd>Lex<cr>", opts)

-- -- Tab close
-- local bufferlineCommands = require("bufferline.commands")
-- local bufferlineConfig = require("bufferline.config")
-- local state = require("bufferline.state")
-- local closeF = function()
--   local index = bufferlineCommands.get_current_element_index(state)
--   for _, item in ipairs(vim.list_slice(state.components, index, index)) do
--     bufferlineConfig.options.close_command(item.id)
--   end
-- end
-- keymap.set("n", "<leader>tw", closeF, { desc = "Close current tab" })
--
keymap.set("n", "<leader>?", function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 0,
    previewer = false,
  }))
end, { desc = "[/] Fuzzily search in current buffer" })
-- nmap("<leader><leader>", "<Cmd>Telescope frecency workspace=CWD<CR>")
-- nmap("<leader>fo", "<Cmd>Telescope oldfiles only_cwd=true<CR>", "Find Old files")
nmap("<leader>/", require("telescope.builtin").live_grep, "Find Text")
nmap("<leader>fg", "<cmd>Telescope git_files<cr>", "Find Git files")
nmap("<leader>ff", "<cmd>Telescope find_files hidden=true no_ignore=false<cr>", "Find files")
-- nmap("<leader><leader>", "<cmd>Telescope find_files hidden=true no_ignore=false<cr>", "Find files")
nmap("<leader><leader>", function()
  require("snacks").picker.smart()
  -- require("telescope").extensions.smart_open.smart_open({
  --   cwd_only = true,
  --   filename_first = false,
  -- })
end, "Smart Find files")
nmap("<leader>fr", function()
  require("telescope.builtin").lsp_references()
end, "Find lsp references")
nmap("<leader>fw", function()
  require("telescope.builtin").grep_string({ search = vim.fn.expand("<cword>"), word_match = "-w" })
end, "Find Words")

nmap("<leader>fh", "<cmd>Telescope help_tags<cr>", "Find Help tags")
nmap("<leader>sr", "<cmd>Telescope lsp_references<cr>", "Search references")
nmap("<leader>fb", "<cmd>Telescope buffers<cr>")
nmap("<leader>fj", "<cmd>Telescope jumplist<cr>", "Jumplist")

-- nmap("<leader>o", "<cmd>Lspsaga outline<cr>", "Open Outline")
nmap("<leader>]", "<cmd>Lspsaga outline<cr>", "Open Outline")
nmap("<leader>e", "<cmd>Lspsaga code_action<cr>", "Code Action")

-- harpoon keymap
local harpoon = require("harpoon")
nmap("<leader>1", function()
  harpoon:list():select(1)
end, "Goto harpoon file 1")
nmap("<leader>2", function()
  harpoon:list():select(2)
end, "Goto harpoon file 2")
nmap("<leader>3", function()
  harpoon:list():select(3)
end, "Goto harpoon file 3")
nmap("<leader>4", function()
  harpoon:list():select(4)
end, "Goto harpoon file 4")
nmap("<leader>p", function()
  harpoon:list():prev()
end, "Goto harpoon prev")
nmap("<leader>n", function()
  harpoon:list():next()
end, "Goto harpoon next")

nmap("<leader>gc", function()
  vim.cmd.Git({ "commit" })
end, "Git commit")
nmap("<leader>ga", function()
  vim.cmd.Git({ "add --patch" })
end, "Git add")
nmap("<leader>gp", function()
  vim.cmd.Git({ "pull --rebase" })
end, "Git pull")
nmap("<leader>gP", function()
  vim.cmd.Git({ "push" })
end, "Git push")
keymap.set("n", "<leader>gr", "<cmd>Gitsigns refresh<cr>")

--neogit keymap
nmap("<leader>gg", function()
  vim.cmd.Neogit()
end, "Neogit")

nmap("<leader>lr", function()
  vim.cmd.LspRestart()
end, "Restart LSP")

--nvim-tree keymap
-- local api = require("nvim-tree.api")
-- nmap("<leader>e", function()
--   api.tree.toggle({})
-- end, "Toggle Nvim tree")

--mini-files keymap
nmap("<leader>o", require("mini.files").open, "Open mini-files")

--leap
vim.keymap.set("n", "s", "<Plug>(leap)", { desc = "Leap from window" })
keymap.set("n", "S", '"_S')

--floaterm
-- keymap.set("n", "<leader>p", "<cmd>FloatermToggle<cr>")

-- ast_grep
keymap.set("n", "<leader>as", "<cmd>Telescope ast_grep<cr>")

-- diffview
keymap.set("n", "<leader>dv", "<cmd>DiffviewOpen<cr>", { desc = "Open diffview" })
keymap.set("n", "<leader>dc", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
keymap.set("n", "<leader>dg", "<cmd>DiffviewFileHistory<cr>", { desc = "Open git history" })
keymap.set("n", "<leader>df", "<cmd>DiffviewFileHistory --follow %<cr>", { desc = "File history" })

-- github copilot
-- vim.keymap.set("i", "<C-G>", 'copilot#Accept("\\<CR>")', {
--   expr = true,
--   replace_keycodes = false,
-- })
-- vim.g.copilot_no_tab_map = true
-- vim.keymap.set("n", "<leader>n", "<cmd>CopilotChat<cr>", { desc = "Open Copilot chat" })
