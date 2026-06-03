local function source_action_keys()
  return {
    {
      "<leader>co",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.organizeImports" },
            diagnostics = {},
          },
        })
      end,
      desc = "Organize Imports",
    },
    {
      "<leader>cR",
      function()
        vim.lsp.buf.code_action({
          apply = true,
          context = {
            only = { "source.fixAll" },
            diagnostics = {},
          },
        })
      end,
      desc = "Remove Unused Imports",
    },
  }
end

local function find_upward_with_glob(filename, patterns)
  local dir = vim.fs.dirname(filename)

  while dir and dir ~= "" do
    for _, pattern in ipairs(patterns) do
      if #vim.fn.globpath(dir, pattern, false, true) > 0 then
        return dir
      end
    end

    local parent = vim.fs.dirname(dir)
    if not parent or parent == dir then
      return nil
    end
    dir = parent
  end
end

local function sourcekit_root(arg, callback)
  local filename = type(arg) == "number" and vim.api.nvim_buf_get_name(arg) or arg
  local root = vim.fs.root(filename, { "buildServer.json", ".bsp" })
    or find_upward_with_glob(filename, { "*.xcodeproj", "*.xcworkspace" })
    or vim.fs.root(filename, { "compile_commands.json", "Package.swift", ".git" })

  if type(callback) == "function" then
    callback(root)
  else
    return root
  end
end

local vue_language_server_package = vim.fn.stdpath("data") .. "/mason/packages/vue-language-server"
local vue_typescript_sdk = vue_language_server_package .. "/node_modules/typescript/lib"
local js_lint = require("local.js_lint")

local function find_typescript_sdk(root_dir)
  local search_path = root_dir or vim.fn.getcwd()
  local node_modules = vim.fs.find("node_modules", {
    path = search_path,
    upward = true,
    limit = math.huge,
  })

  for _, node_module in ipairs(node_modules) do
    local tsdk = vim.fs.joinpath(node_module, "typescript", "lib")
    if vim.uv.fs_stat(tsdk) then
      return tsdk
    end
  end

  return vue_typescript_sdk
end

return {
  -- tools
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        -- "typescript-language-server",
        "css-lsp",
        "eslint-lsp",
        "vue-language-server",
        "astro-language-server",
        "oxlint",
        "oxfmt",
        "swiftformat",
        "goimports",
        "gofumpt",
        "gomodifytags",
        "impl",
        "golangci-lint",
      })
    end,
  },
  {
    "folke/neoconf.nvim",
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        underline = true,
        virtual_text = true,
        update_in_insert = false,
      },
      inlay_hints = { enabled = true },
      servers = {
        tsserver = {
          enabled = false,
        },
        ts_ls = {
          enabled = false,
        },
        volar = {
          enabled = false,
        },
        eslint = {
          root_dir = function(bufnr, callback)
            local filename = vim.api.nvim_buf_get_name(bufnr)
            if js_lint.should_use_eslint(filename) then
              callback(js_lint.find_workspace_root(filename))
            end
          end,
        },
        vue_ls = {
          filetypes = { "vue" },
          init_options = {
            typescript = {
              tsdk = vue_typescript_sdk,
            },
          },
          before_init = function(_, config)
            config.init_options = config.init_options or {}
            config.init_options.typescript = config.init_options.typescript or {}
            config.init_options.typescript.tsdk = find_typescript_sdk(config.root_dir)
          end,
          keys = source_action_keys(),
        },
        vtsls = {
          keys = source_action_keys(),
          settings = {
            complete_function_calls = true,
            vtsls = {
              enableMoveToFileCodeAction = true,
              autoUseWorkspaceTsdk = true,
              experimental = {
                completion = {
                  enableServerSideFuzzyMatch = true,
                },
              },
            },
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              suggest = {
                completeFunctionCalls = true,
              },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = false },
              },
            },
          },
        },
        sourcekit = {
          cmd = { "sourcekit-lsp" },
          filetypes = { "swift", "objective-c", "objective-cpp" },
          root_dir = sourcekit_root,
          capabilities = {
            workspace = {
              didChangeWatchedFiles = { dynamicRegistration = true },
            },
            textDocument = {
              diagnostic = {
                dynamicRegistration = true,
                relatedDocumentSupport = true,
              },
            },
          },
          settings = {},
        },
        gopls = {
          settings = {
            gopls = {
              gofumpt = true,
              codelenses = {
                gc_details = false,
                generate = true,
                regenerate_cgo = true,
                run_govulncheck = true,
                test = true,
                tidy = true,
                upgrade_dependency = true,
                vendor = true,
              },
              hints = {
                assignVariableTypes = true,
                compositeLiteralFields = true,
                compositeLiteralTypes = true,
                constantValues = true,
                functionTypeParameters = true,
                parameterNames = true,
                rangeVariableTypes = true,
              },
              analyses = {
                nilness = true,
                unusedparams = true,
                unusedwrite = true,
                useany = true,
              },
              usePlaceholders = true,
              completeUnimported = true,
              staticcheck = true,
              directoryFilters = { "-.git", "-.vscode", "-.idea", "-.vscode-test", "-node_modules" },
              semanticTokens = true,
            },
          },
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {
      ensure_installed = {
        "vue_ls",
        "vtsls",
        "cssls",
        "eslint",
        "tailwindcss",
        "lua_ls",
        "html",
        "jsonls",
        "astro",
        "gopls",
      },
    },
  },
}
