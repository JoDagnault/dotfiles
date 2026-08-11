return {
    "nvim-telescope/telescope.nvim",
    version = "*",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    config = function()
        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
        vim.keymap.set("n", "<leader>fw", builtin.live_grep, { desc = "Find text" })
        vim.keymap.set("n", "<leader>dl", builtin.diagnostics, { desc = "List diagnostics" })
    end,
}
