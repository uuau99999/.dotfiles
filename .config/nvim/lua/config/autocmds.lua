-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "json", "jsonc" },
  callback = function()
    vim.wo.conceallevel = 0
  end,
})
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "*" },
  callback = function()
    vim.opt.formatoptions:remove("c")
    vim.opt.formatoptions:remove("r")
    vim.opt.formatoptions:remove("o")
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "yaml" },
  callback = function()
    vim.b.autoformat = false
  end,
})

-- Rename integrate with mini files
vim.api.nvim_create_autocmd("User", {
  pattern = "MiniFilesActionRename",
  callback = function(event)
    Snacks.rename.on_rename_file(event.data.from, event.data.to)
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(event)
    -- vim.keymap.set("n", "fr", function()
    --   -- require('telescope.builtin').lsp_references()
    --   require("snacks").picker.lsp_references()
    -- end, { buffer = event.buf, desc = "LSP: Goto References" })

    --disgnostic floag window
    vim.keymap.set("n", "<leader>ld", function()
      vim.diagnostic.open_float({ source = true })
    end, {
      buffer = event.buf,
      desc = "Open diagnostic float window",
    })
    --folding
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
    if client and client.supports_method("textDocument/foldingRange") then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end
    -- Inlay hint
    ---@diagnostic disable-next-line: missing-parameter, param-type-mismatch
    if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      -- vim.lsp.inlay_hint.enable()
      vim.keymap.set("n", "<leader>T", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
      end, { buffer = event.buf, desc = "LSP: Toggle Inlay Hints" })
    end
  end,
})
