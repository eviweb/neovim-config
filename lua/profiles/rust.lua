-- lua/profiles/rust.lua
--
-- Rust profile.
-- Auto-detected when Cargo.toml is present at the project root.
-- rust_analyzer is a heavy LSP (~300 MB RAM) and should only load
-- in Rust projects.

return {
    name = 'rust',
    extends = {},

    lsp_servers = { 'rust_analyzer' },

    plugins = {
        { 'rouge8/neotest-rust', lazy = true },
    },

    neotest_adapters = function()
        local ok, adapter = pcall(require, 'neotest-rust')
        if not ok then return {} end
        return { adapter }
    end,

    dap_mason_packages = { 'codelldb' },

    -- DAP: Rust via codelldb (Mason: codelldb).
    -- Install with :MasonInstall codelldb
    dap_setup = function(dap)
        dap.adapters.codelldb = {
            type = 'server',
            port = '${port}',
            executable = {
                command = vim.fn.stdpath('data') .. '/mason/bin/codelldb',
                args    = { '--port', '${port}' },
            },
        }

        dap.configurations.rust = {
            {
                type    = 'codelldb',
                request = 'launch',
                name    = 'Launch',
                program = function()
                    return vim.fn.input(
                        'Executable: ',
                        vim.fn.getcwd() .. '/target/debug/',
                        'file'
                    )
                end,
                cwd         = '${workspaceFolder}',
                stopOnEntry = false,
            },
        }
    end,

    null_ls_sources = function(null_ls)
        return {
            null_ls.builtins.formatting.rustfmt,
        }
    end,

    conform_formatters = function()
        return { rust = { 'rustfmt' } }
    end,
}
