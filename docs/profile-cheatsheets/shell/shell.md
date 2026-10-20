# Shell profile — Quick Reference

Active when `nvim-config profile detect` lists `shell` (a `.shellcheckrc`, a root-level `*.sh` / `*.bash`,
or `tests/*.bats`), or after `nvim-config profile set shell`. Applies to `.sh`, `.bash`, `.bats` and
scripts with a shell shebang (all filetype `sh`).

## What runs
| Tool | When | Needs |
|------|------|-------|
| shellcheck | On save and when leaving insert mode (diagnostics) | `sudo apt install shellcheck` |
| shfmt | **On demand only**, `<Space>f` — not on save | `sudo apt install shfmt` |

shfmt is not run on save: its defaults (tabs unless an `.editorconfig` section matches the file, its own
redirect and alignment style) rewrite most of an existing script on the first save.
`nvim-config doctor` tells you whether both tools are installed.

## Diagnostics
| Key | Action |
|-----|--------|
| `]d` / `[d` | Next / previous diagnostic |
| `<Leader>dd` | Diagnostics of the buffer (Trouble) |

## Silencing a finding
| Where | How |
|-------|-----|
| One line | `# shellcheck disable=SC2086` on the line above |
| Following `source` | `# shellcheck source=./lib.sh` |
| Whole project | `disable=SC2086` in a `.shellcheckrc` at the project root |

Prefer fixing the finding (quote the variable) over disabling it; leave a short reason next to a disable.
