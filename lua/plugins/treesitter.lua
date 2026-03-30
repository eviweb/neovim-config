-- lua/plugins/treesitter.lua

return {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        require('config.treesitter')
    end,
}
