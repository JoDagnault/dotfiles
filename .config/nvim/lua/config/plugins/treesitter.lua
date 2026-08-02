return {
    {
        "neovim-treesitter/nvim-treesitter",
        dependencies = {
            "neovim-treesitter/treesitter-parser-registry",
        },
        lazy = false,
        build = ":TSUpdate",

        config = function()
            local parsers = {
                "c",
                "cpp",
                "lua",
                "vim",
                "vimdoc",
                "javascript",
                "typescript",
                "html",
                "css",
                "rust",
                "java",
                "c_sharp",
                "sql",
                "python",
                "go",
                "bash",
                "markdown",
                "json",
                "yaml",
                "toml",
                "dockerfile"
            }

            require("nvim-treesitter").install(parsers)

            local filetypes = vim.deepcopy(parsers)
            table.insert(filetypes, "sh")
            table.insert(filetypes, "cs")

            vim.api.nvim_create_autocmd("FileType", {
                pattern = filetypes,
                callback = function()
                    vim.treesitter.start()
                end,
            })
        end,
    },
}
