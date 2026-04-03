-- lua/config/avante.lua

require('avante').setup({
    provider = 'claude',

    providers = {
        claude = {
            -- Authenticate via Claude Pro subscription (browser OAuth).
            -- Run :AvanteSwitchProvider claude if another provider was active.
            auth_type = 'pro',
        },
    },

    mappings = {
        ask      = '<Leader>aa',
        edit     = '<Leader>ae',
        refresh  = '<Leader>ar',
        focus    = '<Leader>af',
        toggle   = {
            default = '<Leader>at',
        },
    },
})
