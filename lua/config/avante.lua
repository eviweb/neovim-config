-- lua/config/avante.lua
--
-- Provider switch: <Leader>aP (Telescope picker)
-- Available providers:
--   claude-code   — Claude Code CLI (reuses `claude` login) ← default
--   gemini-cli    — Gemini CLI      (reuses `gemini` login)
--   codex         — Codex CLI ACP   (requires OPENAI_API_KEY env var)
--   claude        — Sonnet 4.6 API  (OAuth Pro/Max — triggers browser auth)
--   claude-opus   — Opus 4.7 API    (OAuth Max only)
--   gemini        — Gemini API      (requires GEMINI_API_KEY env var)

require('avante').setup({
    -- CLI providers first: no OAuth prompt at load time.
    -- Switch at runtime with <Leader>aP.
    provider = 'claude-code',

    providers = {
        -- ── Claude Sonnet 4.6 — OAuth Pro/Max ─────────────────────────────
        claude = {
            auth_type = 'max',
            model     = 'claude-sonnet-4-6',
            timeout   = 30000,
            extra_request_body = {
                max_tokens  = 64000,
                temperature = 0.75,
            },
        },

        -- ── Claude Opus 4.7 — OAuth Max only ──────────────────────────────
        ['claude-opus'] = {
            endpoint  = 'https://api.anthropic.com',
            auth_type = 'max',
            model     = 'claude-opus-4-7',
            timeout   = 60000,
            extra_request_body = {
                max_tokens  = 32000,
                temperature = 0.75,
            },
        },

        -- ── Gemini 2.5 Pro — API key ───────────────────────────────────────
        -- Requires: export GEMINI_API_KEY=<key> in ~/.zshrc or ~/.bashrc
        gemini = {
            model   = 'gemini-2.5-pro',
            timeout = 30000,
            extra_request_body = {
                generationConfig = { temperature = 0.75 },
            },
        },
    },

    -- ── ACP providers — override defaults ─────────────────────────────────
    acp_providers = {
        -- claude-code and codex: default commands are 'claude-agent-acp' and
        -- 'codex-acp'. Both binaries are installed globally by the codecompanion
        -- build step (npm install -g @agentclientprotocol/claude-agent-acp).
        -- No override needed — avante uses the binaries directly.
        -- gemini-cli: the avante default forces auth_method="gemini-api-key".
        -- The actual id for Google OAuth in gemini CLI ACP is "oauth-personal"
        -- (confirmed via initialize response). This reuses the OAuth token
        -- already stored by `gemini` CLI in terminal — no browser needed.
        ['gemini-cli'] = {
            command     = 'gemini',
            args        = { '--experimental-acp' },
            env         = { NODE_NO_WARNINGS = '1' },
            auth_method = 'oauth-personal',
        },
    },
    -- Activate any provider with <Leader>aP or:
    --   :lua require('avante.api').switch_provider('claude-code')

    -- Use dressing.nvim for the auth key input prompt.
    -- The default "native" provider calls vim.ui.select (not vim.ui.input),
    -- which closes on FocusLost — unusable when switching to the browser.
    input = {
        provider = 'dressing',
    },

    mappings = {
        ask      = '<Leader>aa',
        edit     = '<Leader>ae',
        refresh  = '<Leader>ar',
        focus    = '<Leader>af',
        toggle   = {
            default = '<Leader>at',
        },
    },
})

-- Switch provider with <Leader>aP — uses Telescope for a consistent picker.
vim.keymap.set('n', '<Leader>aP', function()
    local providers = { 'claude-code', 'gemini-cli', 'codex', 'claude', 'claude-opus', 'gemini' }
    local pickers   = require('telescope.pickers')
    local finders   = require('telescope.finders')
    local conf      = require('telescope.config').values
    local actions   = require('telescope.actions')
    local action_state = require('telescope.actions.state')

    pickers.new({}, {
        prompt_title = 'Avante: switch provider',
        finder = finders.new_table({ results = providers }),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(buf, map)
            actions.select_default:replace(function()
                actions.close(buf)
                local choice = action_state.get_selected_entry()[1]
                -- ACP providers (claude-code, gemini-cli, codex) are not registered
                -- in avante's API provider module table, so refresh() throws
                -- "Failed to find provider: X". Config.provider is already updated
                -- before refresh() throws, so the switch still takes effect.
                local ok, err = pcall(require('avante.api').switch_provider, choice)
                if not ok and err and not err:find('Failed to find provider') then
                    vim.notify('Avante: ' .. err, vim.log.levels.ERROR)
                end
                local sidebar = require('avante').current.sidebar
                if sidebar then
                    sidebar.acp_client = nil
                    if sidebar.chat_history then
                        sidebar.chat_history.acp_session_id = nil
                    end
                end
                require('avante').open_sidebar({ ask = false })
            end)
            return true
        end,
    }):find()
end, { noremap = true, silent = true, desc = 'Switch Avante provider' })
