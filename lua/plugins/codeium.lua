-- lua/plugins/codeium.lua

return {
    'Exafunction/codeium.nvim',
    -- Requires network auth flow not suitable for Termux headless env.
    cond = function()
        local p = require('profiles')
        return p.is_active('ai') and not p.is_active('termux')
    end,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'hrsh7th/nvim-cmp',
    },
    event  = 'InsertEnter',
    config = function()
        require('codeium').setup()
    end,
}
