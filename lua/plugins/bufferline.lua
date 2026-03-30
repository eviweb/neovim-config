-- lua/plugins/bufferline.lua

return {
    'akinsho/bufferline.nvim',
    lazy = false,
    version = '*',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    config = function()
        require('config.bufferline')
    end,
}
