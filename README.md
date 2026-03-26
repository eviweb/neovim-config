# Neovim Config

Personal Neovim configuration with a small project CLI for bootstrap tasks.

## Requirements

- Bash
- `bats` for the test suite

## Neovim Dependencies

The Neovim configuration currently depends on:

- `packer.nvim` for plugin management
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

Run the test suite with:

```bash
bash tests/run
```

## Notes

- The current CLI scope is intentionally small and focused on the `install` command.
- Bash completion is implemented in this version. Zsh and fish remain roadmap items.
- The repository is validated in this project mainly through text-based regression tests because a full Neovim startup test is not always available in sandboxed environments.

## Environment Limitations

- Snap-packaged Neovim can fail in restricted sandbox environments, which blocks reliable headless startup validation there.
- Some workflows that depend on external agents, sockets, or mounted key material can behave differently in a sandbox than on the host system.
- For this reason, bootstrap and plugin wiring are currently guarded first by targeted regression tests and incremental config cleanup.
