-- lua/plugins/mini-ai.lua

return {
    'echasnovski/mini.ai',
    version = '*',
    event   = { 'BufReadPre', 'BufNewFile' },
    config  = function()
        require('mini.ai').setup({ n_lines = 500 })
    end,
}
