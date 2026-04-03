-- lua/plugins/avante.lua

return {
    'yetone/avante.nvim',
    build = 'make',
    event = 'VeryLazy',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'stevearc/dressing.nvim',
        'nvim-treesitter/nvim-treesitter',
        'MeanderingProgrammer/render-markdown.nvim',
    },
    config = function()
        require('config.avante')
    end,
}
