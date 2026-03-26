# Neovim Config

Personal Neovim configuration with a small project CLI for bootstrap tasks.

## Requirements

- Bash
- `bats` for the test suite

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
