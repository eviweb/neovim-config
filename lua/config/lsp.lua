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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-h>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.format({ async = true })<CR>', opts)
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
            diagnostics = {
                globals = { 'vim' },
            },
        },
    },
})

require('mason').setup()
require('mason-lspconfig').setup({
    ensure_installed = vim.list_extend({ 'jsonls', 'lua_ls' }, profiles.get_lsp_servers()),
})

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
