# TODO

## Phase 0 - Repository Hygiene

- [x] Replace the old install script with a real CLI in `bin/`
- [x] Add a dedicated test runner under `tests/`
- [x] Rename `TODO` to `TODO.md`
- [x] Remove exploratory Lua files not used by the runtime config
- [x] Decide whether `.tmux.conf` belongs in this repository
- [x] Add `LICENSE.md` after validating the license choice

## Phase 1 - Safety Net

- [x] Add a first failing smoke-level CLI test suite
- [x] Make the initial CLI tests pass
- [x] Add a Neovim startup smoke test for `init.lua`
- [x] Add regression tests for startup failures fixed in the config

## Phase 2 - Startup Stability

- [x] Fix invalid `null-ls` sources
- [x] Remove or replace deprecated `nvim-tree` options
- [x] Migrate legacy `kyazdani42` plugin namespaces to maintained repositories
- [x] Replace `null-ls.nvim` with the maintained `none-ls.nvim` repository
- [x] Remove references to plugins or features that are not installed
- [x] Consolidate diagnostics UX on `trouble.nvim` and remove `diaglist`
- [x] Audit keymaps that depend on optional plugins

## Phase 3 - LSP And Completion

- [x] Replace `nvim-lsp-installer` with a maintained setup
- [x] Update deprecated LSP capability and formatting calls
- [x] Define an explicit maintained baseline for default LSP servers
- [x] Validate `nvim-cmp` and `LuaSnip` end-to-end
- [x] Add regression coverage for LSP bootstrap failures
- [x] Migrate LSP config to mason-lspconfig v2 API (`setup_handlers` removed in v2.0.0)

## Phase 4 - Treesitter And UI Reliability

- [x] Replace `ensure_installed = 'all'` with an explicit parser list
- [x] Remove unsupported Treesitter modules or add the missing plugins
- [x] Verify `lualine`, `bufferline`, `telescope`, and `trouble` startup paths
- [x] Migrate Trouble keymaps from v1 API (`workspace_diagnostics`, `document_diagnostics`) to current API
- [x] Replace `nvim-tree` with `neo-tree.nvim`
- [x] Decide whether `nvim-gps` should be replaced with `nvim-navic` or `aerial.nvim`
- [x] Remove `lsp-colors.nvim` (redundant with Neovim 0.9+ built-in diagnostic highlights)
- [x] Audit Telescope extensions and remove unused or redundant integrations

## Phase 5 - Documentation

- [x] Write a keybindings cheatsheet covering all custom mappings and plugin shortcuts
- [x] Write extended usage documentation (LSP workflow, completion, diagnostics, telescope, bufferline)
- [x] Add `<Leader>?` keymap to open Telescope keymaps picker (in-Neovim discoverability)
- [x] Annotate which-key groups with descriptions (`<Leader>f` = Find, `<Leader>d` = Diagnostics, etc.)

## Phase 7 - Install And Portability

- [x] Add bash completion support to the CLI
- [x] Add zsh completion support to the CLI
- [ ] Add fish completion support to the CLI
- [x] Rewrite `install` to cover symlink/bootstrap flows explicitly
- [x] Document external dependencies required by the Neovim config
- [x] Document bootstrap limitations in sandboxed or Snap-based environments
- [x] Add `install nvim [--snap|--apt]` subcommand (snap by default, checks if already installed)
- [x] Extend `install all` to include `install nvim` in the full bootstrap chain
- [x] Add `update nvim` subcommand (snap refresh or apt upgrade depending on install method)
- [x] Add `update plugins` subcommand (headless `Lazy! sync` via nvim --headless)
- [x] Add `update` subcommand dispatching to `update nvim` + `update plugins`
- [x] Document Neovim installation (minimum version, recommended method per platform)
- [x] Document first-run initialization sequence (lazy.nvim bootstrap → plugin install → Mason LSP server install)
- [x] Document full end-to-end setup flow for a new machine in README

## Phase 8 - Optional Modernization

- [x] Decide whether to keep `packer.nvim` or migrate to a maintained plugin manager
- [x] Normalize plugin declarations and config loading patterns
- [x] Reduce eager startup side effects where not needed
- [x] Design project profiles so Neovim can enable only relevant tooling per repository
- [x] Decide whether the CLI should manage project profiles or only bootstrap them
- [x] Add in-Neovim profile switcher: `:NvimProfile <name>` user command + Telescope picker (depends on profile design)
- [x] Move frontend-only tooling such as `emmet-vim` behind project profiles
- [x] Move Node-specific Telescope integrations behind project profiles
- [x] Decide whether `none-ls.nvim` should remain global or have profile-driven sources

## Phase 10 - Test Suite Maintenance

- [ ] Split `tests/nvim-config.bats` by domain (CLI, profiles, LSP/completion, UI/plugins, docs) for readability

## Phase 9 - UI Consolidation (Long-term)

> Two interchangeable UI variants: `classic` (current stack) and `modern` (unified suite
> e.g. `snacks.nvim`). Variant chosen at Neovim startup. Default is `classic` unless
> `.nvim-ui` exists at the config root. CLI manages the file; `.nvim-ui` is gitignored.
>
> Design: Option B — independent of the profile system.
> Layout:
>   lua/ui/variant.lua  — reads .nvim-ui, returns 'classic' (default) or 'modern'
>   lua/ui/shared.lua   — colorscheme and settings common to both variants
>   lua/ui/classic.lua  — telescope, lualine, bufferline, trouble, nvim-navic
>   lua/ui/modern.lua   — snacks.nvim (picker, statusline, notifier, dashboard)
>
> CLI: nvim-config ui set classic|modern  /  nvim-config ui unset

- [ ] Evaluate `snacks.nvim` as the modern variant foundation (picker, statusline, notifier, dashboard, breadcrumb)
- [ ] Implement `lua/ui/` structure (variant, shared, classic, modern)
- [ ] Move current UI plugins into `lua/ui/classic.lua`
- [ ] Implement `lua/ui/modern.lua` once evaluation is done
- [ ] Add `nvim-config ui set|unset` CLI subcommand
- [ ] Add `.nvim-ui` to `.gitignore`
