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
            'nvim-telescope/telescope-node_modules.nvim',
            lazy = true,
        },
    },

    null_ls_sources = function(null_ls)
        return {
            null_ls.builtins.diagnostics.eslint.with({
                command = find_bin('eslint'),
            }),
            null_ls.builtins.formatting.prettier.with({
                command = find_bin('prettier'),
            }),
        }
    end,
}
