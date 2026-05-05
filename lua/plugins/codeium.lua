-- lua/plugins/codeium.lua

return {
    'Exafunction/codeium.nvim',
    -- Requires network auth flow not suitable for Termux headless env.
    cond = function() return not require('profiles').is_active('termux') end,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'hrsh7th/nvim-cmp',
    },
    event  = 'InsertEnter',
    config = function()
        require('codeium').setup()
    end,
}
