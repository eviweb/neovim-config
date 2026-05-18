-- lua/plugins/avante.lua

return {
    'yetone/avante.nvim',
    build = 'make',
    -- Not supported on Termux: no browser for OAuth, build requires x86_64.
    cond = function()
        local p = require('profiles')
        return p.is_active('ai') and not p.is_active('termux')
    end,
    -- VeryLazy: avante's safe_keymap_set skips any key that lazy has registered as
    -- a handler (Keys:have check). String entries in `keys` would prevent avante
    -- from defining <Leader>at, <Leader>aa, etc. Loading via VeryLazy lets avante's
    -- H.keymaps() define all keymaps without interference.
    -- No OAuth prompt at startup: default provider is claude-code (ACP, no OAuth).
    event = 'VeryLazy',
    cmd   = { 'AvanteAsk', 'AvanteEdit', 'AvanteToggle', 'AvanteFocus', 'AvanteRefresh' },
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-treesitter/nvim-treesitter',
        'MeanderingProgrammer/render-markdown.nvim',
    },
    config = function()
        require('config.avante')
    end,
}
