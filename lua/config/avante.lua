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
        -- claude-code: @zed-industries/claude-code-acp is deprecated (ENOENT).
        -- args must have the same length as the default { '-y', '-g', '<pkg>' } so
        -- that tbl_deep_extend replaces each element by index without leaving the
        -- old package name at index 3.
        ['claude-code'] = {
            args = { '-y', '-g', '@agentclientprotocol/claude-agent-acp' },
        },
        -- gemini-cli: the avante default forces auth_method="gemini-api-key".
        -- tbl_deep_extend preserves absent keys, so we must explicitly set
        -- auth_method=false (falsy) to bypass the API key check; the gemini
        -- CLI handles Google account auth on its own.
        ['gemini-cli'] = {
            command     = 'gemini',
            args        = { '--experimental-acp' },
            env         = { NODE_NO_WARNINGS = '1' },
            auth_method = false,
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
                require('avante.api').switch_provider(choice)
                require('avante').open_sidebar({ ask = false })
            end)
            return true
        end,
    }):find()
end, { noremap = true, silent = true, desc = 'Switch Avante provider' })
