-- lua/plugins/codecompanion.lua
--
-- CodeCompanion is loaded alongside avante.nvim for evaluation.
-- Goal: benchmark on a real project before deciding which to keep.
--
-- Key differences from avante:
--   - Native MCP support (no mcphub bridge needed)
--   - Supports CLAUDE.md / .cursor/rules natively
--   - CLI adapters: claude_code, codex, gemini (same underlying CLIs)
--   - Lighter footprint, more composable

return {
    'olimorris/codecompanion.nvim',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        -- mcphub extension: reuses the same MCP servers already configured
        'ravitemer/mcphub.nvim',
    },
    cond = function() return not require('profiles').is_active('termux') end,
    cmd  = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
    keys = {
        { '<Leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', mode = { 'n', 'v' }, desc = 'Toggle CodeCompanion chat' },
        { '<Leader>cx', '<Cmd>CodeCompanionActions<CR>',    mode = { 'n', 'v' }, desc = 'CodeCompanion action palette' },
    },
    config = function()
        require('config.codecompanion')
    end,
}
