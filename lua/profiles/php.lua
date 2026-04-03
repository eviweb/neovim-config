-- lua/profiles/php.lua
--
-- PHP profile: standalone PHP projects without Laravel.
-- Auto-detected when composer.json is present but does not declare
-- laravel/framework.
--
-- QA tools (phpstan, phpcs, phpmd, php-cs-fixer) are resolved from
-- vendor/bin first so that projects using eviweb/php-qa-tools work
-- without any global installation.

local function find_bin(name)
    local bin = vim.fn.getcwd() .. '/vendor/bin/' .. name
    if vim.fn.executable(bin) == 1 then
        return bin
    end
    return name
end

return {
    name = 'php',
    extends = {},

    lsp_servers = { 'intelephense' },

    plugins = {
        { 'olimorris/neotest-phpunit', lazy = true },
    },

    neotest_adapters = function()
        local ok, adapter = pcall(require, 'neotest-phpunit')
        if not ok then return {} end
        return { adapter }
    end,

    dap_mason_packages = { 'php-debug-adapter' },

    -- DAP: PHP via Xdebug (Mason: php-debug-adapter).
    -- Install with :MasonInstall php-debug-adapter
    dap_setup = function(dap)
        dap.adapters.php = {
            type    = 'executable',
            command = vim.fn.stdpath('data') .. '/mason/bin/php-debug-adapter',
        }

        dap.configurations.php = {
            {
                type    = 'php',
                request = 'launch',
                name    = 'Listen for Xdebug',
                port    = 9003,
            },
        }
    end,

    null_ls_sources = function(null_ls)
        return {
            null_ls.builtins.diagnostics.phpstan.with({
                command = find_bin('phpstan'),
            }),
            null_ls.builtins.diagnostics.phpmd.with({
                command = find_bin('phpmd'),
                extra_args = { 'text', 'cleancode,codesize,controversial,design,naming,unusedcode' },
            }),
            null_ls.builtins.diagnostics.phpcs.with({
                command = find_bin('phpcs'),
            }),
            null_ls.builtins.formatting.phpcsfixer.with({
                command = find_bin('php-cs-fixer'),
            }),
        }
    end,
}
