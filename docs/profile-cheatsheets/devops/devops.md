# DevOps profile — Quick Reference

Active when `nvim-config profile detect` lists `devops` (a `Dockerfile`, a `compose.y*ml` /
`docker-compose.y*ml`, or `.github/workflows/`), or after `nvim-config profile set devops`.

## What runs
| Files | Tool | Shown as |
|-------|------|----------|
| `Dockerfile`, `Containerfile` | hadolint | diagnostics, codes `DL3xxx` / `SC2xxx` |
| `.github/workflows/*.yml\|yaml` | actionlint | diagnostics (filetype `yaml.github`) |

Both are installed by Neovim through Mason the first time the profile is active (network needed): check
with `:Mason`, or `nvim-config doctor`. Other YAML files, compose files included, are not linted by
actionlint on purpose — it reports errors on anything that is not a workflow.

actionlint also runs shellcheck on the `run:` scripts of a workflow when `shellcheck` is installed.

## Diagnostics
| Key | Action |
|-----|--------|
| `]d` / `[d` | Next / previous diagnostic |
| `<Leader>dd` | Diagnostics of the buffer (Trouble) |

## Silencing a finding
| Tool | How |
|------|-----|
| hadolint | `# hadolint ignore=DL3006` on the line above; project-wide in `.hadolint.yaml` |
| actionlint | `paths: <glob>: ignore: [<regex of the message>]` in `.github/actionlint.yaml` |
