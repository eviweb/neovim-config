-- lua/plugins/avante.lua

return {
    'yetone/avante.nvim',
    build = 'make',
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
