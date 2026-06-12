return {
  {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nsidorenco/neotest-vstest",
    },
    config = function()
      local neotest = require("neotest")

      neotest.setup({
        adapters = {
          require("neotest-vstest"),
        },
      })

      vim.keymap.set("n", "<leader>ta", function()
        neotest.run.run(vim.loop.cwd())
      end, { desc = "Run all tests" })

      vim.keymap.set("n", "<leader>ts", function()
        neotest.summary.toggle()
      end, { desc = "Test summary" })

    end,
  },
}
