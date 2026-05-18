-- lua/plugins/mcphub.lua

return {
    'ravitemer/mcphub.nvim',
    -- mcp-hub binary is installed globally via npm (see build command).
    -- The plugin starts a lightweight Node.js background server on demand.
    build        = 'npm install -g mcp-hub@latest',
    dependencies = { 'nvim-lua/plenary.nvim' },
    -- Load when the user opens the hub UI or sends an AI request.
    -- Not loaded on Termux: no browser, limited network, Node.js optional.
    cond = function()
        local p = require('profiles')
        return p.is_active('ai') and not p.is_active('termux')
    end,
    cmd  = { 'MCPHub' },
    keys = { { '<Leader>am', '<Cmd>MCPHub<CR>', desc = 'Open MCP Hub' } },
    config = function()
        require('config.mcphub')
    end,
}
