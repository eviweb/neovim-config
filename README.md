# Neovim Config

[![CI](https://github.com/eviweb/neovim-config/actions/workflows/ci.yml/badge.svg)](https://github.com/eviweb/neovim-config/actions/workflows/ci.yml)

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
| `git` | Mandatory — clones plugins via lazy.nvim; Neovim refuses to load plugins without it |
| `make` | Builds the native `telescope-fzf-native.nvim` sorter |
| `gcc` | C compiler — `make` alone is not enough, the sorter's Makefile calls `cc` |
| `curl` | Plugin download, nvm install |
| `ripgrep` | Telescope live grep |
| `fd-find` | Telescope file finder |
| `xsel` / `xclip` | System clipboard integration (X11) |
| `wl-clipboard` | System clipboard integration (Wayland) |
| `lolcat` | Colored CLI output |
| `gnupg` | Verifies the `mise` installer signature (`install mise`) |

Both X11 and Wayland clipboard tools are always installed, regardless of the
current session type — `install deps` may run over SSH or before any
graphical session starts, so there's no reliable way to detect which one
will actually be used later. Neovim's own clipboard provider picks the
right tool at runtime based on the active session.

If the config was obtained without `git` already present (e.g. copied or
mounted rather than cloned), Neovim will refuse to load plugins and print a
clear error on startup until `install deps` (or `sudo apt install git`) is run.

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

## Getting Started

Complete setup sequence for a new machine.

### 1. Install Neovim

```bash
./bin/nvim-config install nvim
```

With no flag, this cascades interactively based on what's available:
[mise](https://mise.jdx.dev) if present on `PATH` → otherwise prompts to
install it (curl download, GPG signature verified against the official mise
release key — any missing prerequisite, i.e. `curl` or `gnupg`, is listed
and installed via apt in the same step) → declined or unavailable, uses
snap if present → otherwise prompts to install `snapd` → declined, falls
back to apt. Prompts auto-decline (no blocking, Ctrl+C always aborts)
outside an interactive terminal, under `--quiet`, or under `--dry-run`.

Force a specific method — skips the interactive cascade entirely:

```bash
./bin/nvim-config install nvim --mise   # installs mise first if missing
./bin/nvim-config install nvim --snap   # installs snapd first if missing
./bin/nvim-config install nvim --apt    # requires apt (never bootstrapped)
```

`--mise`/`--snap` bootstrap their own package manager (and, for mise, any
missing prerequisite like `gnupg`) if it's missing — passing the flag is
already an explicit choice, so no further prompt is needed. `--apt` still
errors if `apt` itself isn't present (that signals the wrong OS entirely,
nothing to install).

After a fresh mise install, `mise` needs to be activated in your shell rc
for itself and any mise-managed tool (like `nvim`) to be found on `PATH` —
see [mise's shell-specific activation
docs](https://mise.jdx.dev/installing-mise.html#shell-specific-installation-activation).
The CLI detects whether the activation line is already present and, if
not, offers to add it to `~/.bashrc` / `~/.zshrc` / `~/.config/fish/config.fish`
(based on `$SHELL`) and tells you to reload your shell afterwards. Two
flags bypass this prompt for automated/non-interactive installs, where
the default prompt already silently declines (no TTY) but an automation
author may still want a definite outcome either way:

```bash
./bin/nvim-config install mise --activate      # add the line unattended
./bin/nvim-config install mise --no-activate   # skip it, log the manual command
```

Snap is recommended when not using mise — it always provides the latest
stable release with classic confinement (full host access, no sandbox
restrictions):

```bash
sudo snap install nvim --classic
```

Minimum required version: **0.9+**. Check with `nvim --version`.

Alternatively, via apt (version depends on the Ubuntu release):

```bash
sudo apt install neovim
```

### 2. Clone this repository

```bash
git clone https://github.com/eviweb/neovim-config.git ~/path/to/neovim-config
cd ~/path/to/neovim-config
```

### 3. Install system dependencies

```bash
./bin/nvim-config install deps
```

Add `--with-node` to also install nvm and Node.js LTS (required for TypeScript,
ESLint, and other Node-based LSP servers):

```bash
./bin/nvim-config install deps --with-node
```

### 4. Link the configuration

```bash
./bin/nvim-config install config
```

This creates a symlink `~/.config/nvim → /path/to/neovim-config`.

### 5. tmux / byobu integration (optional)

```bash
./bin/nvim-config install tmux
```

Required for correct colours and focus events when running Neovim inside tmux
or byobu. See [Dependencies — tmux / byobu integration](#tmux--byobu-integration)
for details.

### 6. First run

Open Neovim:

```bash
nvim
```

On first startup, lazy.nvim bootstraps itself and installs all declared plugins
automatically. This may take a minute. `install all` also fetches the
`tree-sitter` CLI (into `vendor/tree-sitter/`) beforehand — nvim-treesitter
needs it on `PATH` to build parsers; without it, parser installs fail with
`ENOENT ... 'tree-sitter'` on first launch. Once complete:

- Run `:Lazy` to review plugin status
- Run `:Mason` to open the LSP server manager and install servers for your
  languages — `lua_ls` (Lua, standalone binary) is pre-configured and
  installed automatically; `jsonls` (JSON) is too, but only if `npm` is
  present, since `json-lsp` is an npm package (see [Node.js](#nodejs) —
  Node.js is opt-in, run `install deps --with-node` first if you need it)
- Restart Neovim after Mason finishes

## Updating

```bash
./bin/nvim-config update                   # nvim + plugins
./bin/nvim-config update nvim              # Neovim only
./bin/nvim-config update plugins           # plugins only
./bin/nvim-config update dap-adapters      # Mason DAP packages for the active profile
./bin/nvim-config update tree-sitter       # tree-sitter CLI (vendor/tree-sitter/) — also run by `install all`
```

### Neovim (manual)

```bash
# mise (auto-detected if Neovim was installed via mise)
mise use -g neovim@latest

# Snap
sudo snap refresh nvim

# apt
sudo apt upgrade neovim
```

### Plugins (manual)

From inside Neovim:

```vim
:Lazy sync
```

Or headlessly from the terminal:

```bash
nvim --headless -u init.lua +"Lazy! sync" +qa
```

`Lazy sync` installs missing plugins, updates existing ones, and removes unused
ones. The `lazy-lock.json` file pins exact plugin versions — commit it to lock
your plugin state across machines.

## Uninstalling

```bash
./bin/nvim-config uninstall config   # remove the ~/.config/nvim symlink (only if it points here)
./bin/nvim-config uninstall nvim     # remove Neovim (detects mise/snap/apt, asks for confirmation)
./bin/nvim-config uninstall mise     # remove the mise binary + its shell activation lines
./bin/nvim-config uninstall deps     # never removes apt packages — prints the manual command instead
./bin/nvim-config uninstall all      # config, nvim, then mise (deps stays informational, see above)
```

`uninstall deps` is intentionally informational only: the packages installed by
`install deps` (`git`, `make`, `gcc`, `curl`, `ripgrep`, `fd-find`, `xsel`,
`xclip`, `wl-clipboard`, `lolcat`, `gnupg`) are shared system dependencies that
other tools may also rely on — nvim-config never runs `apt remove` on your
behalf. `uninstall all` follows the same policy and leaves them untouched.

`uninstall nvim` and `uninstall mise` each ask for confirmation before removing
anything — like every interactive prompt in this CLI, they auto-decline under
`--dry-run`, `--quiet`, or outside a TTY, so automated runs never hang or
remove something unexpectedly.

## Project Profiles

Profiles enable per-project tooling — only the LSP servers, null-ls sources, and
plugins relevant to the current project are activated.

Available profiles: `web`, `php`, `laravel` (extends `php`), `rust`.

### Auto-detection

Profiles are detected automatically at startup:

| File | Profile |
|------|---------|
| `package.json` | `web` |
| `composer.json` | `php` |
| `composer.json` + `laravel/framework` | `laravel` |
| `Cargo.toml` | `rust` |

### Manual override

Pin a profile for the current project by writing `.nvim-profile` at the project root:

```bash
./bin/nvim-config profile set web
./bin/nvim-config profile unset
```

### Runtime switching

Switch the active profile without restarting Neovim (LSP and null-ls update immediately;
plugin changes require a restart):

```vim
:NvimProfile web
```

Or use the Telescope picker: `<Leader>fp` — shows active (●) / inactive (○) profiles.

### DAP adapters

Profile-driven DAP adapters are installed automatically via Mason at Neovim startup.
To install or refresh them from the terminal:

```bash
./bin/nvim-config update dap-adapters
```

### CLI

```bash
./bin/nvim-config profile list            # list profiles, marks active with *
./bin/nvim-config profile detect          # detect for the current directory
./bin/nvim-config profile set <name>      # write .nvim-profile
./bin/nvim-config profile unset           # remove .nvim-profile
./bin/nvim-config profile create <name>   # generate a new profile template
./bin/nvim-config profile info            # active profile + LSP servers + DAP packages
```

## UI Variants

Two interchangeable UI variants are available. The variant is chosen at Neovim
startup and defaults to `classic`.

| Variant | Stack |
|---------|-------|
| `classic` | telescope, which-key, trouble |
| `modern` | snacks.nvim (picker, notifier, dashboard) |

Both variants share: lualine statusline, bufferline, nvim-navic breadcrumb, and all installed colorschemes.

### Switch variant

```bash
./bin/nvim-config ui set classic   # write .nvim-ui at the config root
./bin/nvim-config ui set modern
./bin/nvim-config ui unset         # remove .nvim-ui (reverts to classic)
```

`.nvim-ui` is gitignored — the setting is local to the machine.

## Colorschemes

14 dark colorschemes are available. The active theme is persisted in `.nvim-theme` (gitignored) and defaults to `nightfox`.

| Family | Variants |
|--------|---------|
| nightfox | `nightfox`, `nordfox`, `duskfox`, `terafox`, `carbonfox` |
| catppuccin | `catppuccin-mocha`, `catppuccin-macchiato`, `catppuccin-frappe` |
| tokyonight | `tokyonight-night`, `tokyonight-storm`, `tokyonight-moon` |
| kanagawa | `kanagawa-wave`, `kanagawa-dragon` |
| gruvbox | `gruvbox-material` |

Switch from inside Neovim (with tab-completion):

```vim
:Theme catppuccin-mocha
```

Or via the CLI:

```bash
./bin/nvim-config theme set catppuccin-mocha
./bin/nvim-config theme unset   # revert to nightfox
```

## AI Tools

### Avante

Cursor-like AI sidebar for code chat and inline edits. Authenticates via Claude Pro/Max subscription (browser OAuth, no API key required):

```vim
<Leader>aa   " ask
<Leader>ae   " edit selection (visual mode)
<Leader>at   " toggle sidebar
```

### Codeium

Free inline AI completion, active alongside LSP suggestions (`[AI]` label in the completion menu). Activate once:

```vim
:Codeium Auth
```

### Terminal AI agents

Install the CLIs, then toggle their dedicated floating terminals from inside Neovim:

```bash
./bin/nvim-config install claude   # Claude Code CLI
./bin/nvim-config install codex    # OpenAI Codex CLI
./bin/nvim-config install gemini   # Google Gemini CLI
```

| Key | Agent |
|-----|-------|
| `<Leader>tC` | Claude Code |
| `<Leader>tX` | Codex |
| `<Leader>tG` | Gemini |

Requires Node.js / npm. Use `install deps --with-node` if not already installed.

## Diagnostics and status

```bash
./bin/nvim-config status    # Neovim version, UI variant, theme, active profile
./bin/nvim-config doctor    # check required and optional binaries
./bin/nvim-config keymaps   # open keymaps reference in $PAGER
```

## Documentation

- [Usage guide](docs/usage.md) — LSP, completion, diagnostics, git, testing, debugging, AI tools, and more
- [Keymaps cheatsheet](docs/keymaps.md) — all custom mappings and plugin shortcuts
- [Plugin quick-reference](docs/cheatsheets/plugins.md) — concise tables per plugin
- [Cheatsheets](docs/cheatsheets/) — editing, git, LSP, profiles

## Usage

```bash
./bin/nvim-config --help
./bin/nvim-config --version
./bin/nvim-config --dry-run install
```

## Shell Completion

Supported shells: **bash**, **zsh**, **fish**

Show the completion script:

```bash
./bin/nvim-config --show-completion bash
./bin/nvim-config --show-completion zsh
./bin/nvim-config --show-completion fish
```

Install completion for the current user:

```bash
./bin/nvim-config --install-completion bash
./bin/nvim-config --install-completion zsh
./bin/nvim-config --install-completion fish
```

Installed paths:

| Shell | Path |
|-------|------|
| bash | `~/.local/share/bash-completion/completions/nvim-config` |
| zsh | `~/.zfunc/_nvim-config` |
| fish | `~/.config/fish/completions/nvim-config.fish` |

For zsh, add `~/.zfunc` to your `fpath` before calling `compinit`:

```zsh
fpath=(~/.zfunc $fpath)
autoload -Uz compinit && compinit
```

Fish picks up completions from `~/.config/fish/completions/` automatically — no extra setup required.

## Tests

### Static regression tests

Domain-specific bats files contain grep-based tests that verify structural invariants without needing a running Neovim process: deprecated options, removed plugins, namespace migrations, and similar one-way ratchets.

| File | Domain |
|------|--------|
| `tests/cli.bats` | CLI commands, install, update, completion |
| `tests/lsp.bats` | LSP, mason, nvim-cmp, treesitter, null-ls |
| `tests/ui.bats` | UI plugins: telescope, neo-tree, lualine, trouble, which-key, bufferline, variant system |
| `tests/docs.bats` | README and keymaps cheatsheet coverage |
| `tests/profiles.bats` | Profile system, CLI profile commands, NvimProfile switcher |

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

## Contributing

See [`CONTRIBUTING.md`](CONTRIBUTING.md). Found a security issue? See
[`SECURITY.md`](SECURITY.md) instead of opening a public issue.
