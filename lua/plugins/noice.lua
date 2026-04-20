-- lua/plugins/noice.lua

return {
    'folke/noice.nvim',
    event = 'VeryLazy',
    dependencies = {
        'MunifTanjim/nui.nvim',
        { 'rcarriga/nvim-notify', opts = { timeout = 3000, max_width = 60 } },
    },
    config = function()
        require('config.noice')
    end,
}
