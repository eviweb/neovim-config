-- lua/profiles/web.lua
--
-- Web profile: JavaScript, TypeScript, Vue.js, Svelte.
-- Auto-detected when package.json is present at the project root.

-- Find vendor binary in node_modules/.bin first, then fall back to global.
local function find_bin(name)
    local bin = vim.fn.getcwd() .. '/node_modules/.bin/' .. name
    if vim.fn.executable(bin) == 1 then
        return bin
    end
    return name
end

return {
    name = 'web',
    extends = {},

    lsp_servers = { 'ts_ls', 'volar', 'svelte-language-server' },

    plugins = {
        {
            'mattn/emmet-vim',
            ft = {
                'html', 'css',
                'javascript', 'javascriptreact',
                'typescript', 'typescriptreact',
                'vue', 'svelte',
            },
            dependencies = { 'mattn/webapi-vim' },
        },
        {
            'nvim-telescope/telescope-node-modules.nvim',
            lazy = true,
        },
        { 'marilari88/neotest-vitest', lazy = true },
    },

    dap_mason_packages = { 'js-debug-adapter' },

    -- DAP: JS/TS via vscode-js-debug (Mason: js-debug-adapter).
    -- Install with :MasonInstall js-debug-adapter
    dap_setup = function(dap)
        local js_debug = vim.fn.stdpath('data')
            .. '/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js'

        dap.adapters['pwa-node'] = {
            type = 'server',
            host = 'localhost',
            port = '${port}',
            executable = {
                command = 'node',
                args    = { js_debug, '${port}' },
            },
        }

        local js_config = {
            {
                type    = 'pwa-node',
                request = 'launch',
                name    = 'Launch file',
                program = '${file}',
                cwd     = '${workspaceFolder}',
            },
            {
                type      = 'pwa-node',
                request   = 'attach',
                name      = 'Attach to process',
                processId = require('dap.utils').pick_process,
                cwd       = '${workspaceFolder}',
            },
        }

        for _, ft in ipairs({ 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' }) do
            dap.configurations[ft] = js_config
        end
    end,

    -- Only activate the vitest adapter when vitest is present in the project.
    neotest_adapters = function()
        local ok, adapter = pcall(require, 'neotest-vitest')
        if not ok then return {} end
        local has_vitest = vim.fn.executable(vim.fn.getcwd() .. '/node_modules/.bin/vitest') == 1
        if not has_vitest then return {} end
        return { adapter }
    end,

    null_ls_sources = function(_)
        -- eslint: migrated to nvim-lint (lint_linters below)
        -- prettier: migrated to conform.nvim (conform_formatters below)
        return {}
    end,

    conform_formatters = function()
        local fts = {
            'javascript', 'javascriptreact',
            'typescript', 'typescriptreact',
            'vue', 'svelte',
            'css', 'html', 'json', 'yaml', 'markdown',
        }
        local result = {}
        for _, ft in ipairs(fts) do result[ft] = { 'prettier' } end
        return result
    end,

    lint_linters = function()
        local fts = {
            'javascript', 'javascriptreact',
            'typescript', 'typescriptreact',
            'vue', 'svelte',
        }
        local result = {}
        for _, ft in ipairs(fts) do result[ft] = { 'eslint' } end
        return result
    end,
}
