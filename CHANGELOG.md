# Changelog

## Unreleased

- Added `tests/startup.bats` with static `require()` integrity checks and headless Neovim smoke tests
- Headless tests skip automatically under Snap; override with `NVIM_HEADLESS_TESTS_SKIP=0`
- Completed Phase 1 of the roadmap

## 0.1.0 - 2026-03-26

- Added the `bin/nvim-config` CLI with `install`, `--help`, `--version`, `--dry-run`, logging, and bash completion support
- Added a `bats` test suite and a dedicated test runner
- Replaced the old `install.sh` bootstrap script
- Replaced the old `TODO` note with a roadmap in `TODO.md`
- Removed exploratory Lua files that were not part of the runtime config
