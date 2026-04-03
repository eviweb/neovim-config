-- lua/plugins/render-markdown.lua

return {
    'MeanderingProgrammer/render-markdown.nvim',
    ft           = { 'markdown' },
    dependencies = {
        'nvim-treesitter/nvim-treesitter',
        'nvim-tree/nvim-web-devicons',
    },
    config = function()
        require('config.render-markdown')
    end,
}
