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
-- Language server: bash-language-server (`bashls`), for completion, hover, go
-- to definition and symbols. It is an npm package (Node is optional in this
-- config), so it is requested only when npm is available (see
-- lua/lsp_requirements.lua). It runs shellcheck itself, which would double
-- every diagnostic from nvim-lint, so that integration is switched off in
-- lua/config/lsp.lua. Without npm the profile is what it was before the server
-- existed: shellcheck and shfmt.

return {
    name = 'shell',
    extends = {},

    lsp_servers = { 'bashls' },

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
