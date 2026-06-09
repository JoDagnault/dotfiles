return {
    {
        "sainnhe/gruvbox-material",
        priority = 1000,
        config = function()
            if vim.fn.has("termguicolors") == 1 then
                vim.o.termguicolors = true
            end

            vim.o.background = "dark"

            vim.g.gruvbox_material_background = 'medium'
            vim.g.gruvbox_material_better_performance = 1

            vim.cmd('colorscheme gruvbox-material')

            vim.g.lightline = { colorscheme = 'gruvbox_material' }
        end
    }
}
