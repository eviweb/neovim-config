-- lua/config/codecompanion.lua
--
-- Evaluation config — running alongside avante.nvim.
-- Default adapter: claude_code (CLI, no OAuth at startup).
-- Switch adapter at runtime with :CodeCompanionChat <adapter>.
--
-- Adapters available:
--   claude_code  — Claude Code CLI (reuses `claude` login)  ← default
--   anthropic    — Anthropic API (requires ANTHROPIC_API_KEY)
--   gemini_cli   — Gemini CLI    (reuses Google account auth)

require('codecompanion').setup({
    -- ── Default adapter ───────────────────────────────────────────────────
    strategies = {
        chat   = { adapter = 'claude_code' },
        inline = { adapter = 'claude_code' },
        agent  = { adapter = 'claude_code' },
    },

    -- ── Adapters ──────────────────────────────────────────────────────────
    adapters = {
        -- Anthropic API — fallback when API key is available
        anthropic = function()
            return require('codecompanion.adapters').extend('anthropic', {
                schema = {
                    model = { default = 'claude-sonnet-4-6' },
                },
            })
        end,

        -- Gemini CLI — reuses Google account OAuth stored by `gemini` CLI
        gemini_cli = function()
            return require('codecompanion.adapters').extend('gemini_cli', {})
        end,

        -- ACP adapters: codecompanion consults config.adapters.acp[name] first
        -- (via acp/init.lua Adapter.extend). Override commands to use npx so
        -- @agentclientprotocol/claude-agent-acp downloads on demand instead of
        -- requiring a global install of the 'claude-agent-acp' binary.
        acp = {
            claude_code = {
                commands = {
                    default = { 'npx', '-y', '@agentclientprotocol/claude-agent-acp' },
                    yolo    = { 'npx', '-y', '@agentclientprotocol/claude-agent-acp', '--yolo' },
                },
            },
        },
    },

    -- ── MCP integration ───────────────────────────────────────────────────
    -- Uses mcphub.nvim as the MCP bridge so server config stays in one place
    -- (lua/config/mcphub.lua) rather than being duplicated here.
    extensions = {
        mcphub = {
            callback = 'mcphub.extensions.codecompanion',
            -- make_vars=true requires config.interactions.chat.variables which
            -- is nil in this version — causes a pairs() crash at startup.
            opts     = { make_vars = false, make_slash_commands = true },
        },
    },

    -- ── Rules ────────────────────────────────────────────────────────────
    -- Exclude ~/.claude/CLAUDE.md from automatic rules loading: it contains
    -- @rules/*.md includes that resolve to the global ai-rules repo, not the
    -- project CWD — causes "Could not find rules file" warnings on every chat.
    rules = {
        default = {
            files = {
                '.clinerules',
                '.cursorrules',
                '.goosehints',
                '.rules',
                '.windsurfrules',
                '.github/copilot-instructions.md',
                'AGENT.md',
                'AGENTS.md',
                { path = 'CLAUDE.md',       parser = 'claude' },
                { path = 'CLAUDE.local.md', parser = 'claude' },
                -- ~/.claude/CLAUDE.md intentionally omitted
            },
        },
    },

    -- ── Display ───────────────────────────────────────────────────────────
    display = {
        chat = {
            -- Show in a vertical split on the right, same side as avante
            window = {
                layout   = 'vertical',
                position = 'right',
                width    = 0.35,
            },
        },
    },
})
