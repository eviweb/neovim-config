-- lua/plugins/which-key.lua

return {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    config = function()
        require('config.which-key')
    end,
}
