# Security Policy

## Supported Versions

This is a personal Neovim configuration. Only the latest tagged release
receives fixes; older versions are not maintained.

| Version | Supported |
|---------|-----------|
| latest  | ✅ |
| older   | ❌ |

## Scope

`bin/nvim-config` performs privileged and network-facing operations as part
of normal setup, which makes it worth a real security policy despite this
being a personal project:

- `sudo apt install` / `sudo snap install` (package installation)
- Downloading and executing the [mise](https://mise.jdx.dev) installer,
  with GPG signature verification against the official release key
- Downloading the `tree-sitter` CLI binary from GitHub releases
- Writing to shell rc files (`~/.bashrc`, `~/.zshrc`, `~/.config/fish/config.fish`)

Reports involving any of the above — e.g. a way to make the CLI run
attacker-controlled code, bypass the GPG verification step, or write
unintended content to a user's shell rc file — are in scope.

Out of scope: the Neovim configuration itself (`lua/`) and its plugins are
standard editor configuration with no elevated privileges or network access
beyond what lazy.nvim/Mason already do by design.

## Reporting a Vulnerability

Please do not open a public issue for security vulnerabilities.

Report privately via:

- [GitHub Security Advisories](https://github.com/eviweb/neovim-config/security/advisories/new)
  (preferred)
- Email: dev@eviweb.fr

Include steps to reproduce and the potential impact. This is a solo,
personal-time project, so response times are best-effort — expect an
acknowledgement within a week.
