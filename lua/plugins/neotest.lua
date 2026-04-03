-- lua/plugins/neotest.lua

return {
    'nvim-neotest/neotest',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-neotest/nvim-nio',
        'rcasia/neotest-bash',
    },
    keys = {
        '<Leader>Tr', '<Leader>Tf', '<Leader>Ts', '<Leader>To',
    },
    config = function()
        require('config.neotest')
    end,
}
