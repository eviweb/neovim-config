-- lua/profiles/rust.lua
--
-- Rust profile.
-- Auto-detected when Cargo.toml is present at the project root.
-- rust_analyzer is a heavy LSP (~300 MB RAM) and should only load
-- in Rust projects.

return {
    name = 'rust',
    extends = {},

    lsp_servers = { 'rust_analyzer' },

    plugins = {},

    null_ls_sources = function(null_ls)
        return {
            null_ls.builtins.formatting.rustfmt,
        }
    end,
}
