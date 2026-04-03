-- lua/plugins/persistence.lua

return {
    'folke/persistence.nvim',
    event  = 'BufReadPre',
    config = function()
        require('config.persistence')
    end,
}
