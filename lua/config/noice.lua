-- lua/config/noice.lua
-- noice.nvim: floating cmdline, popup messages, LSP progress indicator.
-- In modern variant, snacks.nvim owns vim.notify — noice's notify route is disabled.

local variant = require('ui.variant').get()

require('noice').setup({
    cmdline = {
        enabled = true,
        view    = 'cmdline_popup',
        format  = {
            cmdline     = { icon = '>' },
            search_down = { icon = '/' },
            search_up   = { icon = '?' },
        },
    },
    messages = {
        enabled = true,
    },
    popupmenu = {
        enabled = true,
    },
    lsp = {
        progress  = { enabled = true },
        hover     = { enabled = false },
        signature = { enabled = false },
        override  = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = false,
            ['vim.lsp.util.stylize_markdown']                = false,
            ['cmp.entry.get_documentation']                  = false,
        },
    },
    notify = {
        enabled = variant == 'classic',
    },
    routes = {
        -- Suppress noisy write confirmation messages
        { filter = { event = 'msg_show', find = 'written' }, opts = { skip = true } },
        -- Suppress search wrap messages
        { filter = { event = 'msg_show', find = 'search hit' }, opts = { skip = true } },
    },
    views = {
        cmdline_popup = {
            position = { row = '40%', col = '50%' },
            size     = { width = 60, height = 'auto' },
            border   = { style = 'rounded' },
        },
    },
})
