# TODO

## Phase 0 - Repository Hygiene

- [x] Replace the old install script with a real CLI in `bin/`
- [x] Add a dedicated test runner under `tests/`
- [x] Rename `TODO` to `TODO.md`
- [x] Remove exploratory Lua files not used by the runtime config
- [ ] Decide whether `.tmux.conf` belongs in this repository
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
- [ ] Remove references to plugins or features that are not installed
- [x] Consolidate diagnostics UX on `trouble.nvim` and remove `diaglist`
- [ ] Audit keymaps that depend on optional plugins

## Phase 3 - LSP And Completion

- [x] Replace `nvim-lsp-installer` with a maintained setup
- [x] Update deprecated LSP capability and formatting calls
- [x] Define an explicit maintained baseline for default LSP servers
- [ ] Validate `nvim-cmp` and `LuaSnip` end-to-end
- [ ] Add regression coverage for LSP bootstrap failures

## Phase 4 - Treesitter And UI Reliability

- [x] Replace `ensure_installed = 'all'` with an explicit parser list
- [x] Remove unsupported Treesitter modules or add the missing plugins
- [ ] Verify `lualine`, `bufferline`, `telescope`, and `trouble` startup paths
- [ ] Migrate Trouble keymaps from v1 API (`workspace_diagnostics`, `document_diagnostics`) to current API
- [ ] Replace `nvim-tree` with `neo-tree.nvim`
- [x] Decide whether `nvim-gps` should be replaced with `nvim-navic` or `aerial.nvim`
- [x] Remove `lsp-colors.nvim` (redundant with Neovim 0.9+ built-in diagnostic highlights)
- [ ] Audit Telescope extensions and remove unused or redundant integrations

## Phase 5 - Install And Portability

- [x] Add bash completion support to the CLI
- [ ] Add zsh completion support to the CLI
- [ ] Add fish completion support to the CLI
- [ ] Rewrite `install` to cover symlink/bootstrap flows explicitly
- [ ] Document external dependencies required by the Neovim config
- [ ] Document bootstrap limitations in sandboxed or Snap-based environments

## Phase 6 - Optional Modernization

- [ ] Decide whether to keep `packer.nvim` or migrate to a maintained plugin manager
- [ ] Normalize plugin declarations and config loading patterns
- [ ] Reduce eager startup side effects where not needed
- [ ] Evaluate whether `trouble.nvim` should remain standalone or be consolidated later with a broader UI/tooling choice
- [ ] Design project profiles so Neovim can enable only relevant tooling per repository
- [ ] Decide whether the CLI should manage project profiles or only bootstrap them
- [ ] Move frontend-only tooling such as `emmet-vim` behind project profiles
- [ ] Move Node-specific Telescope integrations behind project profiles
- [ ] Decide whether `none-ls.nvim` should remain global or have profile-driven sources
