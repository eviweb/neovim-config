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
    -- Install the ACP binary globally so both avante and codecompanion find
    -- 'claude-agent-acp' in PATH without needing complex config overrides.
    build = 'npm install -g @agentclientprotocol/claude-agent-acp',
    dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        -- mcphub extension: reuses the same MCP servers already configured
        'ravitemer/mcphub.nvim',
    },
    cond = function()
        local p = require('profiles')
        return p.is_active('ai') and not p.is_active('termux')
    end,
    cmd  = { 'CodeCompanion', 'CodeCompanionChat', 'CodeCompanionActions' },
    keys = {
        { '<Leader>cc', '<Cmd>CodeCompanionChat Toggle<CR>', mode = { 'n', 'v' }, desc = 'Toggle CodeCompanion chat' },
        { '<Leader>cx', '<Cmd>CodeCompanionActions<CR>',    mode = { 'n', 'v' }, desc = 'CodeCompanion action palette' },
    },
    config = function()
        require('config.codecompanion')
    end,
}
