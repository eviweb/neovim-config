-- lua/profiles/laravel.lua
--
-- Laravel profile: PHP + Laravel framework.
-- Auto-detected when composer.json declares laravel/framework.
-- Extends the php profile — all PHP tooling is included automatically.

return {
    name = 'laravel',
    extends = { 'php' },

    lsp_servers = {},

    plugins = {},

    null_ls_sources = function(null_ls)
        return {
            null_ls.builtins.formatting.blade_formatter,
        }
    end,
}
