-- lua/profiles/devops.lua
--
-- Dockerfiles and GitHub Actions workflows: hadolint and actionlint
-- diagnostics through nvim-lint. Neither tool is in apt, so they are declared
-- in `mason_packages` and installed by Mason at startup (and when the profile
-- is switched on with :NvimProfile); Mason's bin directory is on Neovim's PATH.
-- Auto-detected from a Dockerfile, a compose file, or .github/workflows/;
-- otherwise opt in with `nvim-config profile set devops`.
--
-- Workflow files are plain `yaml` for Neovim, and actionlint reports errors on
-- any YAML that is not a workflow. lua/options.lua therefore gives them the
-- compound filetype `yaml.github`; nvim-lint (and conform) split a compound
-- filetype on the dot, so `yaml` keeps its own linters and formatters and the
-- `github` key below only adds actionlint.
--
-- Language servers: yaml-language-server (`yamlls`, schemas from SchemaStore.nvim)
-- and dockerfile-language-server (`dockerls`). Both are npm packages (Node is
-- optional in this config), so they are requested only when npm is available
-- (see lua/lsp_requirements.lua); without it the profile is hadolint and
-- actionlint alone. yamlls only attaches to the filetypes lspconfig gives it
-- (`yaml`, `yaml.docker-compose`, `yaml.gitlab`, `yaml.helm-values`), not to
-- `yaml.github`: workflow files stay with actionlint. dockerls leaves to
-- hadolint the three rules both check (see lua/config/lsp.lua).

return {
    name = 'devops',
    extends = {},

    lsp_servers = { 'yamlls', 'dockerls' },

    treesitter_parsers = { 'dockerfile' },

    mason_packages = { 'actionlint', 'hadolint' },

    plugins = {},

    -- A cheatsheet that :Cheat only offers while this profile is active.
    cheatsheets = { 'docs/profile-cheatsheets/devops' },

    lint_linters = function()
        return {
            dockerfile = { 'hadolint' },
            github     = { 'actionlint' },
        }
    end,
}
