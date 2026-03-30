# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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

## [0.1.0] - 2026-03-26

### Added
- `bin/nvim-config` CLI with `install`, `--help`, `--version`, `--dry-run`, logging, and bash completion support
- `bats` test suite and a dedicated test runner under `tests/`

### Changed
- Replaced the old `install.sh` bootstrap script with `bin/nvim-config`
- Replaced the old `TODO` note with a structured roadmap in `TODO.md`

### Removed
- Exploratory Lua files that were not part of the runtime config

[Unreleased]: https://github.com/username/neovim-config/compare/0.2.0...HEAD
[0.2.0]: https://github.com/username/neovim-config/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/username/neovim-config/releases/tag/0.1.0
