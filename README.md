# Neovim Config

Personal Neovim configuration with a small project CLI for bootstrap tasks.

## Supported Platforms

- **OS**: Ubuntu 22.04 LTS, Ubuntu 24.04 LTS
- **Shell**: Bash 5+
- **Neovim**: 0.9+

## Dependencies

### System packages

Installed automatically by `install deps`:

| Package | Purpose |
|---------|---------|
| `curl` | Plugin download, nvm install |
| `ripgrep` | Telescope live grep |
| `fd-find` | Telescope file finder |
| `xsel` / `xclip` | System clipboard integration |
| `lolcat` | Colored CLI output |

`git` is also required and assumed to be present before running the install script.

### Node.js

Required by Mason-managed LSP servers (TypeScript, ESLint, and others).
**Not installed by `install deps` by default.**

- Minimum version: **Node 18+**
- Recommended: manage Node via [nvm](https://github.com/nvm-sh/nvm) or [fnm](https://github.com/Schniz/fnm) rather than via apt — the apt package is often outdated and may conflict with an existing Node setup.

To install nvm and Node LTS automatically as part of the bootstrap:

```bash
./bin/nvim-config install deps --with-node
./bin/nvim-config install all --with-node   # deps + config symlink
```

The `--with-node` flag installs nvm `v0.39.7` then runs `nvm install --lts`.
It is a no-op if nvm is already present at `~/.nvm`.

### Neovim plugins

- `lazy.nvim` — plugin manager (bootstrapped automatically on first startup)
- `mason.nvim` + `mason-lspconfig.nvim` — LSP server management
- `nvim-treesitter` — syntax parsing with an explicit parser baseline

### Test dependencies

- `bats-core` — required to run the test suite (`tests/run`)

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
