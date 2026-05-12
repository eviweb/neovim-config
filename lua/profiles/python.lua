-- lua/profiles/python.lua
--
-- Python profile.
-- Auto-detected when pyproject.toml, setup.py, setup.cfg, or
-- requirements.txt is present at the project root.

return {
    name    = 'python',
    extends = {},

    lsp_servers = { 'pyright' },

    plugins = {
        { 'nvim-neotest/neotest-python', lazy = true },
    },

    neotest_adapters = function()
        local ok, adapter = pcall(require, 'neotest-python')
        if not ok then return {} end
        return { adapter({ dap = { justMyCode = false } }) }
    end,

    -- DAP: Python via debugpy (Mason: debugpy).
    -- Install with :MasonInstall debugpy
    dap_mason_packages = { 'debugpy' },

    dap_setup = function(dap)
        dap.adapters.python = {
            type    = 'executable',
            command = vim.fn.stdpath('data') .. '/mason/bin/debugpy-adapter',
        }

        dap.configurations.python = {
            {
                type    = 'python',
                request = 'launch',
                name    = 'Launch file',
                program = '${file}',
                console = 'integratedTerminal',
            },
            {
                type    = 'python',
                request = 'launch',
                name    = 'Launch module',
                module  = function()
                    return vim.fn.input('Module name: ')
                end,
                console = 'integratedTerminal',
            },
        }
    end,

    null_ls_sources = function(_)
        -- formatting: conform.nvim (ruff / black below)
        -- diagnostics: nvim-lint (ruff / mypy below)
        return {}
    end,

    conform_formatters = function()
        return {
            python = { 'ruff_format', 'black' },
        }
    end,

    lint_linters = function()
        return {
            python = { 'ruff', 'mypy' },
        }
    end,
}
