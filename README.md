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

### tmux / byobu integration

The repository includes a `.tmux.conf` with settings required for Neovim to work
correctly inside tmux and byobu:

| Setting | Purpose |
|---------|---------|
| `focus-events on` | Lets Neovim receive focus events (autoread, LSP hover on focus) |
| `default-terminal screen-256color` | Enables 256-colour support in the tmux pane |
| `terminal-overrides Tc` | Enables true colour (24-bit) so the colorscheme renders correctly |

Without these settings, the colorscheme may appear degraded and autoread/LSP
focus-based features will not trigger inside a tmux session.

To activate this configuration, inject a `source-file` entry into `~/.tmux.conf`:

```bash
./bin/nvim-config install tmux
```

This appends `source-file /path/to/neovim-config/.tmux.conf` to your existing
`~/.tmux.conf` (creating it if absent) and is idempotent — running it multiple
times has no effect. Your existing tmux configuration is preserved.

### Neovim plugins

- `lazy.nvim` — plugin manager (bootstrapped automatically on first startup)
- `mason.nvim` + `mason-lspconfig.nvim` — LSP server management
- `nvim-treesitter` — syntax parsing with an explicit parser baseline

### Test dependencies

- `bats-core` — required to run the test suite (`tests/run`)

## Documentation

- [Keymaps cheatsheet](docs/keymaps.md) — all custom mappings and plugin shortcuts

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

`tests/startup.bats` also runs `nvim --headless` against the core modules
(`options.lua`, `keymaps.lua`) to detect hard Lua errors at startup.

Snap confinement behaviour:

| Confinement | Effect |
|-------------|--------|
| Classic | Full host access — headless tests run normally |
| Strict / devmode | Sandbox restrictions — headless tests are skipped automatically |

To force-enable or force-disable regardless of environment:

```bash
NVIM_HEADLESS_TESTS_SKIP=0 bash tests/run   # force enable
NVIM_HEADLESS_TESTS_SKIP=1 bash tests/run   # force disable
```

## Notes

- The current CLI scope is intentionally small and focused on the `install` command.
- Bash completion is implemented in this version. Zsh and fish remain roadmap items.

## Environment Limitations

Neovim installed via Snap exists in two confinement modes:

- **Classic** — full host filesystem access, no sandbox restrictions. Headless tests
  run normally. This is the recommended install mode for development use.
- **Strict / devmode** — sandboxed environment. Some workflows that depend on external
  agents, sockets, or mounted key material may behave differently from the host system.
  Headless startup tests are skipped automatically in this mode.

Check the active confinement mode with:

```bash
snap list nvim
```

The `Notes` column shows `classic` for classic confinement; empty means strict.

Bootstrap and plugin wiring are covered by static regression tests regardless of
confinement mode, and by headless smoke tests where the environment permits.
