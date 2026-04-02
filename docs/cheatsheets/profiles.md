# Profiles & UI Variants — Quick Reference

## Profiles

Available: `web` · `php` · `laravel` · `rust`

Auto-detected from: `package.json` → web · `composer.json` → php/laravel · `Cargo.toml` → rust

### In-editor
| Key / Command          | Action                                     |
|------------------------|--------------------------------------------|
| `:NvimProfile web`     | Activate profile (LSP + null-ls immediate) |
| `:NvimProfile`         | Open profile picker                        |
| `<Leader>fp`           | Open profile picker (Telescope)            |

Picker: `<CR>` activate · `●` active · `○` inactive
Plugin changes take effect after restart.

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
