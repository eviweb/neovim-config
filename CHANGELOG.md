# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- `:NvimProfile [name]` user command: activates a profile at runtime (LSP + null-ls immediate, plugins require restart); no argument opens Telescope picker
- `<Leader>fp` keymap: opens profile picker (which-key annotated)
- `lua/profiles/picker.lua`: Telescope picker showing active (●) / inactive (○) profiles
- `lua/profiles/init.lua`: `activate()` function for runtime profile switching
- Project profile system: `lua/profiles/` with additive profiles `web`, `php`, `laravel` (extends php), `rust`; auto-detected from `package.json`, `composer.json`, `Cargo.toml`; overridable via `.nvim-profile` at project root
- `lua/profiles/init.lua`: profile manager with `detect`, `is_active`, `get_plugins`, `get_lsp_servers`, `get_null_ls_sources`
- CLI `profile` command: `list`, `detect`, `set`, `unset`, `create` subcommands
- Bash and zsh completions updated with `profile` command and subcommands
- `emmet-vim` and `telescope-node_modules` moved from global plugins to `web` profile
- none-ls sources are now profile-driven: PHP QA tools (phpstan, phpcs, phpmd, php-cs-fixer), Prettier/ESLint, rustfmt, blade-formatter
- Profile-driven LSP: `ts_ls`, `volar`, `svelte-language-server` (web); `intelephense` (php); `rust_analyzer` (rust)
- 28 new tests covering profile structure, definitions, integration, and CLI commands (128 total)
- `docs/usage.md`: extended usage guide covering LSP workflow, completion, diagnostics, Telescope, and Bufferline
- `install config` subcommand: symlinks `~/.config/nvim` to the repository; aborts safely if target exists and is not a symlink to this repo
- `install deps` subcommand: installs apt packages only
- `install all` (default): runs deps then config
- Bash completion for `install` subcommands (`deps`, `config`, `all`)
- 5 new tests covering install subcommands, symlink detection, and completion

### Changed
- Plugin loading deferred with lazy.nvim triggers: `neo-tree` and `trouble` on `cmd`; `telescope` on `cmd`; `treesitter`, `lsp`, `null-ls` on `BufReadPre/BufNewFile`; `nvim-cmp` on `InsertEnter`; `comment` and `vim-surround` on `BufReadPost`; `which-key` on `VeryLazy`; `emmet` on web filetypes only; `bufferline` explicitly `lazy = false`

## [0.3.0] - 2026-03-30

### Added
- `nvim-navic` (LSP-based breadcrumb) replaces archived `nvim-gps`; attached in LSP `on_attach` and rendered in lualine
- `neo-tree.nvim` (v3.x) replaces `nvim-tree.lua` as the file explorer
- Regression tests for LSP bootstrap, nvim-cmp mapping API, neo-tree migration, Trouble v3 keymaps, and Telescope extension loading

### Fixed
- `cmp.mapping.close()` replaced with `cmp.mapping.abort()` (current API)
- `<Tab>`/`<S-Tab>` cmp mappings now declare `{ 'i', 's' }` modes so LuaSnip jump works in select mode
- `require('nvim-navic')` in lualine config guarded with `pcall` to prevent crash when plugin is not yet installed
- Trouble keymaps migrated from v1 API (`workspace_diagnostics`, `document_diagnostics`, `quickfix`) to v3 (`diagnostics`, `qflist`)
- Telescope trouble integration updated from `open_with_trouble` to `trouble.sources.telescope` (v3 API), guarded with `pcall`
- Telescope `fzf` extension now explicitly loaded via `load_extension`
- Telescope `node_modules` extension load wrapped in `pcall` to tolerate missing build
- Bufferline offset filetype updated from `NvimTree` to `neo-tree`

### Removed
- `nvim-gps` (archived upstream, superseded by `nvim-navic`)
- `lsp-colors.nvim` (redundant with Neovim 0.9+ built-in diagnostic highlight groups)
- `lua/config/nvim-tree.lua` (replaced by `lua/config/neo-tree.lua`)

## [0.2.0] - 2026-03-30

### Added
- `.editorconfig` with per-language indentation rules (Lua, shell, bats, Markdown)
- `LICENSE.md` (MIT)
- `tests/startup.bats` with static `require()` integrity checks for `init.lua`, `plugins.lua`, and `bootstrap.lua`
- Headless Neovim smoke tests for `init.lua`, `options.lua`, and `keymaps.lua`; skipped automatically under Snap, overridable with `NVIM_HEADLESS_TESTS_SKIP=0`
- Colored terminal output in `bin/nvim-config`: INFO (white), WARN (yellow), ERROR (red), DEBUG (cyan); respects `NO_COLOR` env var and TTY detection
- Supported platforms section in `README.md` (Ubuntu 22.04/24.04, Bash 5+, Neovim 0.9+)

### Changed
- `CHANGELOG.md` reformatted to Keep a Changelog with typed sections and bracketed version headers
- ERROR-level log messages now also written to stderr

## [0.2.0] - 2026-03-30

### Added
- `nvim-navic` (LSP-based breadcrumb) replaces archived `nvim-gps`; attached in LSP `on_attach` and rendered in lualine
- `neo-tree.nvim` (v3.x) replaces `nvim-tree.lua` as the file explorer
- Regression tests for LSP bootstrap, nvim-cmp mapping API, neo-tree migration, Trouble v3 keymaps, and Telescope extension loading

### Fixed
- `cmp.mapping.close()` replaced with `cmp.mapping.abort()` (current API)
- `<Tab>`/`<S-Tab>` cmp mappings now declare `{ 'i', 's' }` modes so LuaSnip jump works in select mode
- `require('nvim-navic')` in lualine config guarded with `pcall`
- Trouble keymaps migrated from v1 API to v3 (`diagnostics`, `qflist`)
- Telescope trouble integration updated to `trouble.sources.telescope` (v3), guarded with `pcall`
- Telescope `fzf` extension now explicitly loaded; `node_modules` load wrapped in `pcall`
- Bufferline offset filetype updated from `NvimTree` to `neo-tree`

### Removed
- `nvim-gps` (archived upstream, superseded by `nvim-navic`)
- `lsp-colors.nvim` (redundant with Neovim 0.9+ built-in diagnostic highlight groups)
- `lua/config/nvim-tree.lua` (replaced by `lua/config/neo-tree.lua`)

## [0.1.0] - 2026-03-26

### Added
- `bin/nvim-config` CLI with `install`, `--help`, `--version`, `--dry-run`, logging, and bash completion support
- `bats` test suite and a dedicated test runner under `tests/`

### Changed
- Replaced the old `install.sh` bootstrap script with `bin/nvim-config`
- Replaced the old `TODO` note with a structured roadmap in `TODO.md`

### Removed
- Exploratory Lua files that were not part of the runtime config

[Unreleased]: https://github.com/eviweb/neovim-config/compare/0.3.0...HEAD
[0.3.0]: https://github.com/eviweb/neovim-config/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/eviweb/neovim-config/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/eviweb/neovim-config/releases/tag/0.1.0
