return {
  -- Lua LSP support for editing this config
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- LSP server installer UI
  { "mason-org/mason.nvim", opts = {} },

  -- Auto-install formatters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    event = "VeryLazy",
    opts = { ensure_installed = { "stylua", "goimports", "ruff", "prettier" } },
  },

  -- LSP servers: install, configure, enable
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.INFO] = " ",
            [vim.diagnostic.severity.HINT] = " ",
          },
        },
      })

      vim.lsp.config("gopls", {
        settings = {
          gopls = {
            staticcheck = true,
            usePlaceholders = true,
            analyses = { unusedparams = true, unusedwrite = true },
            hints = {
              parameterNames = true,
              assignVariableTypes = true,
              compositeLiteralFields = true,
              functionTypeParameters = true,
            },
          },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = { Lua = { workspace = { checkThirdParty = false } } },
      })

      -- Remove builtin gr* maps so `gr` (references) has no keypress delay
      for _, lhs in ipairs({ "grn", "grr", "gra", "gri", "grt" }) do
        pcall(vim.keymap.del, "n", lhs)
      end
      pcall(vim.keymap.del, "x", "gra")

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
        callback = function(ev)
          local function bmap(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = ev.buf, desc = desc })
          end
          bmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
          bmap("n", "<F12>", vim.lsp.buf.definition, "Go to definition")
          bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          bmap("n", "gI", vim.lsp.buf.implementation, "Go to implementation")
          bmap("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
          bmap("n", "gr", "<cmd>Telescope lsp_references<cr>", "References")
          bmap("n", "<S-F12>", "<cmd>Telescope lsp_references<cr>", "References")
          bmap("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
          bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          bmap({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action (quick fix)")
          bmap("n", "<leader>e", vim.diagnostic.open_float, "Line diagnostics")
          bmap("n", "<leader>th", function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
          end, "Toggle inlay hints")
        end,
      })

      require("mason-lspconfig").setup({
        ensure_installed = { "gopls", "lua_ls", "ts_ls", "jsonls", "yamlls",
            "pyright", "ruff", "intelephense", "eslint" 
          },
      })
    end,
  },
}
