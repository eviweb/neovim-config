# Contributing

This is a personal Neovim configuration, shared publicly in case it's useful
to others. It's tailored to one person's workflow, so contributions are
welcome but curated — not every PR will fit the project's direction, and
that's fine.

## Before opening a PR

- For small fixes (typos, a broken command, a clear bug) — open a PR
  directly.
- For anything larger (new profile, new plugin, behavior change) — open an
  issue first to discuss it. Saves everyone time if it doesn't fit.
- Check [`TODO.md`](TODO.md) — it tracks completed phases and the current
  backlog (`Deferred / Under Consideration`), so you can see what's already
  planned or intentionally deferred.

## Workflow

1. Fork and create a branch from `main` (`fix/...`, `feat/...`, `docs/...`).
2. Follow [Conventional Commits](https://www.conventionalcommits.org/) for
   commit messages (`type(scope): summary`).
3. This project uses TDD: every change to `bin/nvim-config` needs a
   corresponding [bats-core](https://github.com/bats-core/bats-core) test in
   `tests/`, and every change to `lua/` needs a matching test in the
   relevant `tests/*.bats` file.
4. Run the test suite before opening a PR:
   ```bash
   ./tests/run
   ```
5. Run [ShellCheck](https://www.shellcheck.net/) on `bin/nvim-config` if you
   touched it:
   ```bash
   shellcheck bin/nvim-config
   ```
6. Update `README.md` and `CHANGELOG.md` (`[Unreleased]` section) alongside
   any user-facing change, in the same PR.

## Reporting bugs

Open an issue with:
- What you ran and what happened
- What you expected instead
- Your environment (OS, Neovim version, shell — `nvim-config doctor` output
  is a good start)

## Security issues

Do not open a public issue — see [`SECURITY.md`](SECURITY.md).
