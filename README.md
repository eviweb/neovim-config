# Neovim Config

Personal Neovim configuration with a small project CLI for bootstrap tasks.

## Supported Platforms

- **OS**: Ubuntu 22.04 LTS, Ubuntu 24.04 LTS
- **Shell**: Bash 5+
- **Neovim**: 0.9+

## Requirements

- Bash 5+
- `bats` for the test suite

## Neovim Dependencies

The Neovim configuration currently depends on:

- `lazy.nvim` for plugin management
- `mason.nvim` and `mason-lspconfig.nvim` for LSP bootstrap
- `nvim-treesitter` with an explicit parser baseline
- external tools commonly expected by the config and CLI such as `git`, `curl`, `ripgrep`, `fd`, `xsel`, and `xclip`

Some plugins may also require additional runtime tooling depending on language or extension usage.

## Usage

```bash
./bin/nvim-config --help
./bin/nvim-config --version
./bin/nvim-config --dry-run install
```

## Bash Completion

Show the completion script:

```bash
./bin/nvim-config --show-completion bash
```

Install completion for the current user:

```bash
./bin/nvim-config --install-completion bash
```

The script is installed to:

```text
~/.local/share/bash-completion/completions/nvim-config
```

## Tests

### Static regression tests

`tests/nvim-config.bats` contains grep-based tests that verify structural invariants without needing a running Neovim process: deprecated options, removed plugins, namespace migrations, and similar one-way ratchets.

### Structural integrity tests

`tests/startup.bats` verifies that every `require()` call in `init.lua`, `plugins.lua`, and `bootstrap.lua` has a matching file on disk.  These tests catch "file deleted but require() not updated" regressions at the source level.

### Headless startup smoke tests

`tests/startup.bats` also runs `nvim --headless` against `init.lua` and the core modules (`options.lua`, `keymaps.lua`) to detect hard Lua errors at startup.  The headless tests are skipped automatically when nvim is installed via Snap.  To force-enable them:

```bash
NVIM_HEADLESS_TESTS_SKIP=0 bash tests/run
```

## Notes

- The current CLI scope is intentionally small and focused on the `install` command.
- Bash completion is implemented in this version. Zsh and fish remain roadmap items.

## Environment Limitations

- Snap-packaged Neovim can fail in restricted sandbox environments, which causes the headless startup tests to be skipped automatically in that environment.
- Some workflows that depend on external agents, sockets, or mounted key material can behave differently in a sandbox than on the host system.
- For this reason, bootstrap and plugin wiring are guarded by both targeted static regression tests and headless smoke tests where the environment permits.
