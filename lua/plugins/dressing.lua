-- lua/plugins/dressing.lua
-- Improves vim.ui.select and vim.ui.input with Telescope/fzf-backed pickers.
-- Loaded early so :Cheat, :NvimProfile and other vim.ui.select callers
-- benefit from keyboard navigation immediately.

return {
    'stevearc/dressing.nvim',
    event = 'VimEnter',
    opts  = {
        -- :Cheat and :NvimProfile use Telescope directly — disable dressing's
        -- select override to avoid "items: expected list-like table" errors
        -- when plugins pass non-sequential tables to vim.ui.select.
        select = { enabled = false },
        -- Keep dressing's improved input for vim.ui.input (rename, search prompts…)
        input  = { enabled = true },
    },
}
