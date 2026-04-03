-- lua/config/avante.lua

-- Workaround for avante auth flow bugs:
--   1. native.lua passes a non-sequential table as items to vim.ui.select
--   2. native.lua passes nil as the on_choice callback
-- Both trigger vim.validate errors. The wrapper normalises these before
-- delegating to the real implementation (dressing input or builtin).
do
    local orig = vim.ui.select
    vim.ui.select = function(items, opts, on_choice)
        -- avante calls with 2 args: (items, callback) — no opts table
        if type(opts) == 'function' and on_choice == nil then
            on_choice = opts
            opts = {}
        end
        -- normalise items to a proper list
        if type(items) == 'table' and not vim.islist(items) then
            local list = {}
            for _, v in pairs(items) do
                table.insert(list, v)
            end
            items = list
        end
        -- ensure on_choice is always a function
        if type(on_choice) ~= 'function' then
            on_choice = function() end
        end
        orig(items, opts, on_choice)
    end
end

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
