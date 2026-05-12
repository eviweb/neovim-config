local profiles = require('profiles')
local is_navic_present, navic = pcall(require, 'nvim-navic')
local lspkind = require('lspkind')
local schemastore = require('schemastore')
local opts = { noremap = true, silent = true }

lspkind.init({
    mode = 'symbol',
})

local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    if is_navic_present and client.server_capabilities.documentSymbolProvider then
        navic.attach(client, bufnr)
    end

    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
    -- K is handled globally by nvim-ufo (peek fold, falls back to hover).
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    -- <C-h> in normal mode is the global window-navigation key; signature help
    -- is triggered automatically on call-site characters by the LSP server.
    vim.api.nvim_buf_set_keymap(bufnr, 'i', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
    vim.api.nvim_buf_set_keymap(
        bufnr,
        'n',
        '<space>wl',
        '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
        opts
    )
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
    -- <Space>f is defined globally in lua/config/conform.lua (conform.format with LSP fallback).
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
local is_cmp_nvim_lsp_present, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if is_cmp_nvim_lsp_present then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

-- Replace vim.lsp.with() (deprecated in Neovim 0.11+) with direct handler
-- overrides that inject border configuration via the config argument.
local _hover = vim.lsp.handlers['textDocument/hover']
vim.lsp.handlers['textDocument/hover'] = function(err, result, ctx, config)
    return _hover(err, result, ctx, vim.tbl_extend('force', { border = 'rounded' }, config or {}))
end

local _sig_help = vim.lsp.handlers['textDocument/signatureHelp']
vim.lsp.handlers['textDocument/signatureHelp'] = function(err, result, ctx, config)
    return _sig_help(err, result, ctx, vim.tbl_extend('force', { border = 'rounded' }, config or {}))
end

-- Global defaults applied to every LSP server (mason-lspconfig v2 / Neovim 0.11+).
vim.lsp.config('*', {
    on_attach = on_attach,
    capabilities = capabilities,
})

-- Per-server overrides.
vim.lsp.config('jsonls', {
    settings = {
        json = {
            schemas = schemastore.json.schemas(),
        },
    },
})

vim.lsp.config('lua_ls', {
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT' },
            workspace = {
                -- Include the config's lua/ directory and the Neovim runtime so
                -- LuaLS resolves require('plugins.foo') as lua/plugins/foo.lua
                -- (module root = lua/) rather than lua.plugins.foo (project root),
                -- which avoids the "same file required with different names" warning.
                library = {
                    vim.fn.stdpath('config') .. '/lua',
                    vim.env.VIMRUNTIME,
                },
                checkThirdParty = false,
            },
            diagnostics = {
                globals = { 'vim' },
            },
        },
    },
})

require('mason').setup()
-- On Termux, Mason binaries are often unavailable for ARM; skip auto-install
-- and rely on manually installed servers only.
if not profiles.is_active('termux') then
    require('mason-lspconfig').setup({
        ensure_installed = vim.list_extend({ 'jsonls', 'lua_ls' }, profiles.get_lsp_servers()),
    })
else
    require('mason-lspconfig').setup({})
end

-- Auto-install DAP Mason packages required by active profiles.
-- Runs at startup so adapters are ready before the first debug session.
local registry = require('mason-registry')
for _, pkg_name in ipairs(profiles.get_dap_mason_packages()) do
    local ok, pkg = pcall(registry.get_package, pkg_name)
    if ok and not pkg:is_installed() then
        pkg:install()
    end
end

vim.diagnostic.config({
    virtual_text = false,
    float = {
        border = 'rounded',
    },
})

local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
