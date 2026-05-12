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
        -- Claude Code CLI — same CLI as avante's claude-code ACP provider
        claude_code = function()
            return require('codecompanion.adapters').extend('claude_code', {
                env = {
                    -- Reuse the claude CLI already in PATH
                    api_key = '',
                },
            })
        end,

        -- Anthropic API — fallback when API key is available
        anthropic = function()
            return require('codecompanion.adapters').extend('anthropic', {
                schema = {
                    model = {
                        default = 'claude-sonnet-4-6',
                    },
                },
            })
        end,

        -- Gemini CLI — reuses Google account OAuth stored by `gemini` CLI
        gemini_cli = function()
            return require('codecompanion.adapters').extend('gemini_cli', {})
        end,
    },

    -- ── MCP integration ───────────────────────────────────────────────────
    -- Uses mcphub.nvim as the MCP bridge so server config stays in one place
    -- (lua/config/mcphub.lua) rather than being duplicated here.
    extensions = {
        mcphub = {
            callback = 'mcphub.extensions.codecompanion',
            opts     = { make_vars = true, make_slash_commands = true },
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
