-- lua/plugins/treesitter.lua

return {
    'nvim-treesitter/nvim-treesitter',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    config = function()
        require('config.treesitter')
    end,
}
