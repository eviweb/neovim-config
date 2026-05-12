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
        -- hover and signature kept native (avoid E565 in lazy callback context
        -- and conflicts with nvim-ufo K mapping).
        hover     = { enabled = false },
        signature = { enabled = false },
        -- Route markdown rendering through noice for better formatting.
        -- Does not affect hover/signature behaviour — only the markdown
        -- conversion utilities used by cmp and other sources.
        override  = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown']                = true,
            ['cmp.entry.get_documentation']                  = true,
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
