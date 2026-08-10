return {
  {
    "mason-org/mason.nvim",
    opts = {},
  },

  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = {
      "mason-org/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      vim.lsp.config('lua_ls', {
          settings = {
              Lua = {
                  diagnostics = {
                      globals = { "vim", "it", "describe", "before_each", "after_each" },
                  },
              },
          },
      })
      require("mason-lspconfig").setup({
        ensure_installed = {
          "lua_ls",
          "omnisharp",
          "rust_analyzer",
          "basedpyright",
          "ts_ls",
          "clangd",
          "neocmake",
          "gopls",
          "jdtls",
          "sqls",
          "html",
          "cssls",
          "jsonls",
          "yamlls",
          "marksman"
      },
        automatic_enable = true,
      })
    end,
  },
}
