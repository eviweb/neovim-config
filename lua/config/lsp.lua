-- lua/config/lsp.lua

-- lua/config/lsp.lua

local lsp_installer = require('nvim-lsp-installer')
local lspkind = require('lspkind')
local schemastore = require('schemastore')
local opts = { noremap = true, silent = true }

-- adds icon to the popup
lspkind.init({
    mode = 'symbol',
})

-- maps the current keys after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

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
    vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- configuration settings passed to the LSP's
local settings = {
    Lua = {
        diagnostics = {
            globals = { 'vim' },
        },
    },
    json = {
        schemas = schemastore.json.schemas(),
    },
}

-- shows popup borders on hover
local handlers = {
    ['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, { border = 'rounded' }),
    ['textDocument/signatureHelp'] = vim.lsp.with(vim.lsp.handlers.signature_help, { border = 'rounded' }),
}

-- adds capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- extends capabilities if completion engine is installed
local is_cmp_nvim_lsp_present, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if is_cmp_nvim_lsp_present then
    capabilities = cmp_nvim_lsp.update_capabilities(capabilities)
end

-- configures a server
lsp_installer.on_server_ready(function(server)
    server:setup({
        on_attach = on_attach,
        flags = flags,
        settings = settings,
        handlers = handlers,
        capabilities = capabilities,
    })
end)

-- installs LSP's
local servers = vim.g.lsp_servers or {}
for _, name in pairs(servers) do
    local is_server_found, server = lsp_installer.get_server(name)
    if is_server_found and not server:is_installed() then
        print('Installing ' .. name)
        server:install()
    end
end

-- hides diagnostic messages
vim.diagnostic.config({
    virtual_text = false,
    float = {
        border = 'rounded',
    },
})

-- changes letters in the diagnostics gutter to symboles
local signs = { Error = ' ', Warn = ' ', Hint = ' ', Info = ' ' }
for type, icon in pairs(signs) do
    local hl = 'DiagnosticSign' .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

