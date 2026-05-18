-- lua/profiles/ai.lua
--
-- AI tooling profile — opt-in only, never auto-detected.
-- Activate via .nvim-profile or: nvim-config profile set ai
--
-- This profile is a flag: its presence enables avante, codecompanion,
-- codeium, and mcphub. Those plugins guard themselves with
-- cond = is_active('ai'), so they only load when this profile is active.

return {
    name       = 'ai',
    extends    = {},
    lsp_servers = {},
    plugins    = {},
}
