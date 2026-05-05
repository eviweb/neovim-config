-- lua/profiles/termux.lua
--
-- Environment profile for Android/Termux.
-- Auto-detected when TERMUX_VERSION is set; overridable via .nvim-profile.
--
-- Constraints: no sudo, no browser (no OAuth), ARM64 arch, pkg package manager.
-- DAP adapters and AI OAuth plugins are disabled; LSP is minimal.

return {
    lsp_servers        = { 'lua_ls' },
    dap_mason_packages = {},
    neotest_adapters   = function() return {} end,
    null_ls_sources    = function() return {} end,
    conform_formatters = function() return {} end,
    lint_linters       = function() return {} end,
}
