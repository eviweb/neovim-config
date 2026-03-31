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

- [ ] Write a keybindings cheatsheet covering all custom mappings and plugin shortcuts
- [ ] Write extended usage documentation (LSP workflow, completion, diagnostics, telescope, bufferline)

## Phase 7 - Install And Portability

- [x] Add bash completion support to the CLI
- [ ] Add zsh completion support to the CLI
- [ ] Add fish completion support to the CLI
- [x] Rewrite `install` to cover symlink/bootstrap flows explicitly
- [ ] Document external dependencies required by the Neovim config
- [x] Document bootstrap limitations in sandboxed or Snap-based environments

## Phase 8 - Optional Modernization

- [x] Decide whether to keep `packer.nvim` or migrate to a maintained plugin manager
- [x] Normalize plugin declarations and config loading patterns
- [x] Reduce eager startup side effects where not needed
- [ ] Design project profiles so Neovim can enable only relevant tooling per repository
- [ ] Decide whether the CLI should manage project profiles or only bootstrap them
- [ ] Move frontend-only tooling such as `emmet-vim` behind project profiles
- [ ] Move Node-specific Telescope integrations behind project profiles
- [ ] Decide whether `none-ls.nvim` should remain global or have profile-driven sources

## Phase 9 - UI Consolidation (Long-term)

> Evaluate adopting a unified UI suite (e.g. `snacks.nvim`) that would replace several
> standalone plugins. These items are low priority and should be revisited together as a
> single design decision, not piecemeal.

- [ ] Evaluate replacing `trouble.nvim` with native diagnostics UI or a unified suite
- [ ] Evaluate replacing `telescope.nvim` with `snacks.nvim` picker or `fzf-lua`
- [ ] Evaluate replacing `lualine.nvim` with `mini.statusline` or a built-in statusline
- [ ] Evaluate replacing `bufferline.nvim` with native tabs or a unified suite tabline
- [ ] Evaluate adopting `snacks.nvim` as a unified dashboard / notifier / picker layer
- [ ] Evaluate replacing `nvim-navic` breadcrumb with `aerial.nvim` or `snacks.nvim` equivalent
