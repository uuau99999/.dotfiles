return {
  -- tools
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "stylua",
        "selene",
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        -- "typescript-language-server",
        "css-lsp",
        -- "eslint-lsp",
        "vue-language-server",
        "astro-language-server",
        "oxlint",
        "oxfmt",
        "swiftformat",
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
          keys = {
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
          },
        },
        volar = {
          keys = {
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
          },
          init_options = {
            vue = {
              -- hybridMode = false,
              hybridMode = true,
            },
          },
        },
        vtsls = {
          filetypes = {
            "javascript",
            "javascriptreact",
            "javascript.jsx",
            "typescript",
            "typescriptreact",
            "typescript.tsx",
          },
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
          root_dir = function(filename, _)
            local lspconfig = require("lspconfig")
            return lspconfig.util.root_pattern(
              "buildServer.json",
              "Package.swift",
              "*.xcodeproj",
              "*.xcworkspace",
              ".git"
            )(filename)
          end,
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
    "williamboman/mason-lspconfig.nvim",
    opts = function()
      local masonLsp = require("mason-lspconfig")
      masonLsp.setup({
        automatic_installation = true,
        ensure_installed = {
          "volar",
          -- "tsserver",
          -- "eslint",
          "cssls",
          -- "clangd",
          "tailwindcss",
          "lua_ls",
          "html",
          "jsonls",
          "astro",
          "goimports",
          "gofumpt",
          "gomodifytags",
          "impl",
          "golangci-lint",
        },
      })
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local servers = {
        volar = {
          filetypes = { "vue" },
        },
        astro = {
          filetypes = { "astro" },
        },
        -- clangd = {
        --   filetypes = { "c", "cpp", "objc", "objcpp" },
        -- },
      }
      masonLsp.setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = capabilities,
            settings = servers[server_name],
            filetypes = (servers[server_name] or {}).filetypes,
          })
        end,
      })
    end,
  },
}
