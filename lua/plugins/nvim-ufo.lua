-- lua/plugins/nvim-ufo.lua

return {
    'kevinhwang91/nvim-ufo',
    dependencies = { 'kevinhwang91/promise-async' },
    event = 'BufReadPost',
    config = function()
        require('config.nvim-ufo')
    end,
}
