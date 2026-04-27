-- lua/config/conform.lua

local conform = require('conform')

-- Resolve a binary from node_modules/.bin first, then fall back to global.
local function node_bin(name)
    local bin = vim.fn.getcwd() .. '/node_modules/.bin/' .. name
    return vim.fn.executable(bin) == 1 and bin or name
end

-- Resolve a binary from vendor/bin first, then fall back to global.
local function vendor_bin(name)
    local bin = vim.fn.getcwd() .. '/vendor/bin/' .. name
    return vim.fn.executable(bin) == 1 and bin or name
end

conform.setup({
    formatters_by_ft = require('profiles').get_conform_formatters(),

    format_on_save = {
        timeout_ms = 1000,
        lsp_format = 'fallback',
    },

    -- Per-formatter binary resolution (evaluated at format time).
    formatters = {
        prettier = {
            command = function() return node_bin('prettier') end,
        },
        php_cs_fixer = {
            command = function() return vendor_bin('php-cs-fixer') end,
        },
        blade_formatter = {
            command = function() return node_bin('blade-formatter') end,
        },
    },
})

-- <Space>f: format current buffer (replaces the LSP on_attach binding).
-- Falls back to LSP formatting when no conform formatter is configured.
vim.keymap.set({ 'n', 'v' }, '<Space>f', function()
    conform.format({ async = true, lsp_format = 'fallback' })
end, { noremap = true, silent = true, desc = 'Format buffer' })
