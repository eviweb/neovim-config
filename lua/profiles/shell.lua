-- lua/profiles/shell.lua
--
-- Shell scripts: shellcheck diagnostics (nvim-lint) and shfmt formatting
-- (conform). Both are expected on PATH: `sudo apt install shellcheck shfmt`.
-- Auto-detected from .shellcheckrc, a root-level *.sh / *.bash file, or bats
-- tests under tests/; otherwise opt in with `nvim-config profile set shell`.
--
-- Neovim reports sh, bash, ksh, extensionless bash scripts and .bats files as
-- filetype `sh`, so a single key covers all of them. shellcheck understands
-- the bats syntax when the file starts with a `#!/usr/bin/env bats` shebang,
-- and shfmt picks its dialect (bash, posix, bats...) from the file itself.
--
-- shfmt runs on demand (<Space>f), not on save: see lua/config/conform.lua.
--
-- No language server on purpose: bash-language-server is an npm package (Node
-- is optional in this config) and runs shellcheck itself, which would double
-- every diagnostic. Tracked as deferred in TODO.md.

return {
    name = 'shell',
    extends = {},

    lsp_servers = {},

    plugins = {},

    -- A cheatsheet that :Cheat only offers while this profile is active.
    cheatsheets = { 'docs/profile-cheatsheets/shell' },

    conform_formatters = function()
        return { sh = { 'shfmt' } }
    end,

    lint_linters = function()
        return { sh = { 'shellcheck' } }
    end,
}
