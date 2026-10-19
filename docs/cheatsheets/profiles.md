# Profiles & UI Variants — Quick Reference

## Profiles

Available: `web` · `php` · `laravel` · `rust` · `python` · `shell` · `devops` · `termux` · `ai`

Auto-detected from: `package.json` → web · `composer.json` → php/laravel · `Cargo.toml` → rust ·
`pyproject.toml` / `setup.py` / `setup.cfg` / `requirements.txt` → python ·
`.shellcheckrc` / root `*.sh` `*.bash` / `tests/*.bats` → shell ·
`Dockerfile` / `compose.y*ml` / `docker-compose.y*ml` / `.github/workflows/` → devops ·
`TERMUX_VERSION` env var → termux

`shell`: shellcheck on save, shfmt only on `<Space>f` (not on save).
Needs `sudo apt install shellcheck shfmt`.

`devops`: hadolint (Dockerfile) + actionlint (`.github/workflows`, filetype `yaml.github`),
installed by Neovim through Mason (`mason_packages`) when the profile is active.

`ai` is opt-in (never detected): `nvim-config profile set ai`.

Each profile also installs its treesitter parsers (background, at startup and on
`:NvimProfile`): web → tsx vue svelte · php → php · laravel → blade · rust → rust toml ·
python → python toml

### In-editor
| Key / Command          | Action                                     |
|------------------------|--------------------------------------------|
| `:NvimProfile web`     | Activate profile (LSP, null-ls, parsers)   |
| `:NvimProfile`         | Open profile picker                        |
| `<Leader>fp`           | Open profile picker (Telescope)            |

Picker: `<CR>` activate · `●` active · `○` inactive
Plugin changes take effect after restart (LSP, null-ls and parsers apply immediately).

### CLI
```
nvim-config profile list
nvim-config profile detect
nvim-config profile set <name>
nvim-config profile unset
nvim-config profile create <name>
```

---

## UI Variants

| Variant   | Picker      | Extra                    |
|-----------|-------------|--------------------------|
| `classic` | Telescope   | which-key, trouble       |
| `modern`  | snacks.nvim | notifier, dashboard      |

Both share: nightfox · lualine · bufferline · nvim-navic

### Switch variant
```
nvim-config ui set classic
nvim-config ui set modern
nvim-config ui unset          # reverts to classic
```

`.nvim-ui` is written at the config root and gitignored.
Change takes effect on next Neovim startup.
