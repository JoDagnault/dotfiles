return {
    "nvim-treesitter/nvim-treesitter",
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
            "c_sharp"
        }

        require("nvim-treesitter").install(parsers)

        vim.api.nvim_create_autocmd("FileType", {
            pattern = parsers,
            callback = function()
                vim.treesitter.start()
            end,
        })
    end,
}
