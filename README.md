# Neovim Config

[![CI](https://github.com/eviweb/neovim-config/actions/workflows/ci.yml/badge.svg)](https://github.com/eviweb/neovim-config/actions/workflows/ci.yml)

Personal Neovim configuration with a small project CLI for bootstrap tasks.

## Supported Platforms

- **OS**: Ubuntu 22.04 LTS, Ubuntu 24.04 LTS
- **Shell**: Bash 5+
- **Neovim**: 0.11+ (0.12 recommended)

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

Minimum required version: **0.11+**. The LSP setup uses `vim.lsp.config` / `vim.lsp.enable`, which
do not exist in 0.10 — there the configuration fails at startup. Verified by starting it, with its
plugins, on 0.10.4 (fails), 0.11.0, 0.11.7 and 0.12.0 (clean start, parsers and highlighting work).
0.12 is recommended: the `main` branch of nvim-treesitter, which this config uses, officially
requires it, so 0.11 works but is not a combination upstream supports. On an older Neovim the configuration now stops at once with a one-line message
(`This configuration requires Neovim 0.11 or newer (found 0.10.4)`) instead of a Lua error.
Check with `nvim --version`.

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
anything. Without a TTY or under `--quiet` they decline, so automated runs never
hang or remove something unexpectedly. `--dry-run` skips the prompt (nothing runs,
so there is nothing to consent to) and prints the plan instead — for example
`mise unuse -g neovim` then `mise uninstall neovim@<version>`, `sudo snap remove nvim`
or `sudo apt remove -y neovim`, depending on how Neovim was installed. The other
prompts of this CLI (`install`) offer alternatives rather than ask for consent, so
they still decline under `--dry-run`.

## Project Profiles

Profiles enable per-project tooling — only the LSP servers, treesitter parsers,
null-ls sources, and plugins relevant to the current project are activated.

Available profiles: `web`, `php`, `laravel` (extends `php`), `rust`, `python`,
`shell`, `devops`, `termux`, `ai`.

### Auto-detection

Profiles are detected automatically at startup, from the directory Neovim was
launched in:

| Marker | Profile |
|--------|---------|
| `package.json` | `web` |
| `composer.json` | `php` |
| `composer.json` + `laravel/framework` | `laravel` |
| `Cargo.toml` | `rust` |
| `pyproject.toml`, `setup.py`, `setup.cfg` or `requirements.txt` | `python` |
| `.shellcheckrc`, a root-level `*.sh` or `*.bash` file, or `tests/*.bats` | `shell` |
| `Dockerfile`, `compose.y*ml`, `docker-compose.y*ml` or `.github/workflows/` | `devops` |
| `TERMUX_VERSION` environment variable (set by Termux) | `termux` |

`ai` is opt-in and never auto-detected: it only turns on the AI plugins (avante,
codecompanion, codeium, mcphub) when you pin it with `profile set ai`.

### What each profile provides

| Profile | LSP | Treesitter parsers | Debug adapter |
|---------|-----|--------------------|---------------|
| `web` | `ts_ls`, `vue_ls`, `svelte` | `tsx`, `vue`, `svelte` | `js-debug-adapter` |
| `php` | `intelephense` | `php` | `php-debug-adapter` (Xdebug) |
| `laravel` | via `php` | `blade` | via `php` |
| `rust` | `rust_analyzer` | `rust`, `toml` | `codelldb` |
| `python` | `pyright` | `python`, `toml` | `debugpy` |
| `shell` | — (see below) | — (`bash` is global) | — |
| `devops` | — (see below) | `dockerfile` | — |
| `termux` | `lua_ls` only | — | none (no DAP, no OAuth plugins) |
| `ai` | — | — | — |

Profiles also bring their formatters (conform.nvim), linters (nvim-lint) and
neotest adapters. A profile is a Lua table in `lua/profiles/<name>.lua`; besides
`lsp_servers`, `plugins`, `dap_mason_packages` and the tool hooks it may declare
`treesitter_parsers` and `mason_packages`. Without a parser a language gets no treesitter highlighting,
folds or textobjects (`af`, `]m`, `]a`…). Parsers declared by the active profiles
are installed in the background at startup, and also when a profile is switched on
at runtime.

### The `shell` profile

Lints shell scripts with [shellcheck](https://www.shellcheck.net) (on save and when
leaving insert mode) and formats them with [shfmt](https://github.com/mvdan/sh). Both
are expected on `PATH` — `nvim-config doctor` lists them:

```bash
sudo apt install shellcheck shfmt
```

It applies to every buffer Neovim calls `sh`: `.sh`, `.bash`, `.bats` and scripts with a
shell shebang. **shfmt runs on demand (`<Space>f`), not on save**, unlike every other
formatter here: its defaults (tabs, its own redirect and alignment style) rewrite most of
an existing script the first time it is saved — about half the lines of this repository's
own `bin/nvim-config`. It reads `.editorconfig` when one covers the file. There is no
language server on purpose (`bash-language-server` is an npm package and would duplicate
shellcheck's diagnostics).

### The `devops` profile

Lints Dockerfiles with [hadolint](https://github.com/hadolint/hadolint) and GitHub Actions
workflows with [actionlint](https://github.com/rhysd/actionlint). Neither is in apt, so
the profile declares them in `mason_packages` — a profile field for Mason-installed tools,
next to `dap_mason_packages` — and Neovim installs them in the background at startup, or
when you switch the profile on with `:NvimProfile devops` (needs network; skipped on
Termux, where Mason has no ARM binaries). Mason's `bin` directory is on Neovim's `PATH`
but not on your shell's, so `nvim-config doctor` looks there too.

actionlint reports errors on any YAML that is not a workflow, so workflow files
(`.github/workflows/*.yml|yaml`) get the compound filetype `yaml.github` (set in
`lua/options.lua`). Neovim plugins split a compound filetype on the dot: `yaml` keeps its
own linters and formatters and only `github` adds actionlint. There is no language server
on purpose (`yaml-language-server` and `dockerfile-language-server` are npm packages).

### Manual override

Pin a profile for the current project by writing `.nvim-profile` at the project root:

```bash
./bin/nvim-config profile set web
./bin/nvim-config profile unset
```

### Runtime switching

Switch the active profile without restarting Neovim (LSP and null-ls update immediately,
treesitter parsers install in the background; plugin changes require a restart):

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

- [Vim/Neovim basics](docs/cheatsheets/basics.md) — new to Neovim? Start here: modes, motions, windows, command-line — none of it specific to this config
- [Usage guide](docs/usage.md) — LSP, completion, diagnostics, git, testing, debugging, AI tools, and more
- [Keymaps cheatsheet](docs/keymaps.md) — all custom mappings and plugin shortcuts
- [Plugin quick-reference](docs/cheatsheets/plugins.md) — concise tables per plugin
- [Cheatsheets](docs/cheatsheets/) — basics, editing, git, LSP, profiles

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
| `tests/ci.bats` | CI workflow guards (triggers, pinned and verified downloads) |

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

### Full startup check

`tests/run` is offline and takes under a minute. `tests/full-startup` is the one test that starts the
real configuration with every plugin: it clones them at the commits pinned in `lazy-lock.json` (about
200 MB) into a throwaway directory, then fails if Neovim reports an error or if the config was not
actually read. It never touches your own `~/.config/nvim` or `~/.local/share/nvim`.

```bash
tests/full-startup                       # uses nvim from PATH
NVIM=/path/to/nvim tests/full-startup    # a specific version
```

CI runs it on the oldest supported Neovim and on the one used by the `Test` job (job `Startup`, not a
required check, since it depends on the network).

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
