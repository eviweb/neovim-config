-- lua/plugins/dressing.lua
-- Improves vim.ui.select and vim.ui.input with Telescope/fzf-backed pickers.
-- Loaded early so :Cheat, :NvimProfile and other vim.ui.select callers
-- benefit from keyboard navigation immediately.

return {
    'stevearc/dressing.nvim',
    event = 'VimEnter',
    opts  = {},
}
