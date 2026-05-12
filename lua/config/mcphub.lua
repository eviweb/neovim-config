-- lua/config/mcphub.lua
--
-- MCP Hub configuration.
-- Servers are defined inline here rather than in ~/.config/mcphub/servers.json
-- so they stay version-controlled alongside the Neovim config.
--
-- Active servers:
--   mcp-server-git        — git operations (log, diff, blame) via uvx
--   context7              — versioned library documentation via npx
--   mcp-diagnostics       — LSP diagnostics via mcp-diagnostics.nvim (native Lua, no server)
--   mcp-server-filesystem — secure file read/write with configurable access
--   mcp-server-fetch      — web page fetch and HTML→Markdown conversion

require('mcphub').setup({
    -- Path to the mcp-hub binary (installed via build command).
    -- Resolved at runtime; falls back to PATH if not found here.
    port       = 37373,
    config     = vim.fn.expand('~/.config/mcphub/servers.json'),

    -- Define servers inline (written to config path on first run).
    servers = {
        -- ── mcp-server-git ────────────────────────────────────────────────
        -- Exposes git log, diff, blame, show to LLMs via MCP.
        -- Requires: uvx (pip install uv, or cargo install uv)
        ['mcp-server-git'] = {
            command = 'uvx',
            args    = { 'mcp-server-git', '--repository', '.' },
        },

        -- ── Context7 ──────────────────────────────────────────────────────
        -- Injects up-to-date, version-specific library docs into LLM prompts.
        -- Eliminates hallucinated APIs. No API key required for basic usage.
        -- Requires: Node.js (npx downloads on first use)
        ['context7'] = {
            command = 'npx',
            args    = { '-y', '@upstash/context7-mcp' },
            env     = { NODE_NO_WARNINGS = '1' },
        },

        -- ── mcp-server-filesystem ─────────────────────────────────────────
        -- Secure file read/write with per-directory access control.
        -- The '.' arg grants access to the current working directory only.
        -- Requires: Node.js
        ['mcp-server-filesystem'] = {
            command = 'npx',
            args    = { '-y', '@modelcontextprotocol/server-filesystem', '.' },
            env     = { NODE_NO_WARNINGS = '1' },
        },

        -- ── mcp-server-fetch ──────────────────────────────────────────────
        -- Fetches web pages and converts HTML to Markdown for LLM consumption.
        -- Useful for querying online docs directly from the chat sidebar.
        -- Requires: Python (uvx)
        ['mcp-server-fetch'] = {
            command = 'uvx',
            args    = { 'mcp-server-fetch' },
        },

        -- mcp-diagnostics: registered natively via mcp-diagnostics.nvim in
        -- mcphub mode (Lua integration) — no external Node.js server needed.
    },

    -- Avante integration: expose MCP tools in the avante sidebar.
    -- Avante reads active MCP servers when starting a new session.
    extensions = {
        avante = {
            make_slash_commands = true,
        },
    },
})
