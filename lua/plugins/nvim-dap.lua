-- lua/plugins/nvim-dap.lua

return {
    'mfussenegger/nvim-dap',
    dependencies = {
        {
            'rcarriga/nvim-dap-ui',
            dependencies = { 'nvim-neotest/nvim-nio' },
        },
        'theHamsta/nvim-dap-virtual-text',
        -- Lua DAP adapter (no external executable required)
        'jbyuki/one-small-step-for-vimkind',
    },
    keys = {
        '<Leader>Db', '<Leader>DB', '<Leader>Dc',
        '<Leader>Di', '<Leader>Do', '<Leader>DO',
        '<Leader>Dr', '<Leader>Dl', '<Leader>Du', '<Leader>Dt',
    },
    config = function()
        require('config.nvim-dap')
    end,
}
