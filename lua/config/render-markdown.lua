-- lua/config/render-markdown.lua

require('render-markdown').setup({
    enabled      = true,
    render_modes = { 'n', 'c' },
    heading      = { enabled = true, sign = true },
    code         = { enabled = true, sign = false },
    bullet       = { enabled = true },
    checkbox     = { enabled = true },
    table        = { enabled = true },
})
