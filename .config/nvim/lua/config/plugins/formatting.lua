return {
    {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        dependencies = {
            "mason-org/mason.nvim",
        },
        opts = {
            ensure_installed = {
                "clang-format",
                "csharpier",
                "prettierd",
                "ruff",
            },
        },
    },
    {
        "stevearc/conform.nvim",
        opts = {
            formatters_by_ft = {
                c = { "clang_format" },
                cpp = { "clang_format" },
                cs = { "csharpier" },
                python = { "ruff_format" },
                javascript = { "prettierd", "prettier", stop_after_first = true },
                javascriptreact = { "prettierd", "prettier", stop_after_first = true },
                typescript = { "prettierd", "prettier", stop_after_first = true },
                typescriptreact = { "prettierd", "prettier", stop_after_first = true },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_format = "fallback",
            },
        },
        config = function(_, opts)
            local conform = require("conform")

            conform.setup(opts)

            vim.keymap.set({ "n", "v" }, "<leader>fm", function()
                conform.format({
                    async = false,
                    timeout_ms = 500,
                    lsp_format = "fallback",
                })
            end, { desc = "Format selection or file" })
        end,
    },
}
