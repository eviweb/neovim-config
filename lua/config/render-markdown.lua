-- lua/config/render-markdown.lua

require('render-markdown').setup({
    enabled      = true,
    render_modes = { 'n', 'c' },
    heading      = { enabled = true },
    code         = { enabled = true },
    bullet       = { enabled = true },
    checkbox     = { enabled = true },
    latex        = { enabled = false },
})
