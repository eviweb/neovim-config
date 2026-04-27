-- lua/plugins/conform.lua

return {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd   = { 'ConformInfo' },
    config = function()
        require('config.conform')
    end,
}
