-- lua/plugins/mcp-diagnostics.nvim
--
-- Exposes Neovim LSP diagnostics (errors, warnings, hints) to AI assistants
-- via MCP. The plugin bundles a Node.js MCP server; mcphub.nvim connects to
-- it and makes diagnostics available as MCP tools in the avante sidebar.
--
-- Not loaded on Termux (no browser, minimal LSP set).

return {
    'georgeharker/mcp-diagnostics.nvim',
    -- TypeScript plugin: compile on install/update.
    build        = 'cd server/mcp-diagnostics && npm install && npm run build',
    cond         = function() return not require('profiles').is_active('termux') end,
    dependencies = { 'ravitemer/mcphub.nvim' },
    event        = 'LspAttach',
    config       = function()
        require('mcp-diagnostics').setup({ mode = 'mcphub' })
    end,
}
