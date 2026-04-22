-- lua/plugins/avante.lua

return {
    'yetone/avante.nvim',
    build = 'make',
    -- Load on demand only — avante triggers OAuth at setup time, so loading
    -- at VeryLazy causes an auth prompt on every Neovim startup.
    cmd  = { 'AvanteAsk', 'AvanteEdit', 'AvanteToggle', 'AvanteFocus', 'AvanteRefresh' },
    keys = {
        '<Leader>aa', '<Leader>ae', '<Leader>at', '<Leader>af', '<Leader>ar',
        -- <Leader>aP is defined in config.avante but declared here so lazy.nvim
        -- registers a stub immediately — avoids falling through to native P (paste).
        { '<Leader>aP', desc = 'Switch Avante provider' },
    },
    dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
        'nvim-treesitter/nvim-treesitter',
        'MeanderingProgrammer/render-markdown.nvim',
    },
    config = function()
        -- vim.schedule defers config past lazy.nvim's load callback context,
        -- which forbids window creation (E565). avante's claude provider calls
        -- dressing.input during setup() when the OAuth token is missing —
        -- that must happen outside the load callback.
        vim.schedule(function()
            require('config.avante')
        end)
    end,
}
