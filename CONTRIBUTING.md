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
   The runner clears `XDG_CONFIG_HOME`, `XDG_DATA_HOME`, `XDG_STATE_HOME` and
   `XDG_CACHE_HOME` so that it behaves like CI; a test must not rely on your own
   installed config (`~/.config/nvim`).
5. Run [ShellCheck](https://www.shellcheck.net/) on the shell scripts you
   touched (CI checks all three):
   ```bash
   shellcheck bin/nvim-config scripts/ci-install-neovim tests/full-startup
   ```
6. Update `README.md` and `CHANGELOG.md` (`[Unreleased]` section) alongside
   any user-facing change, in the same PR.
7. Open the PR, then follow its checks. CI runs only on pull requests (and on `main` after a
   merge), so no check exists for the first moments after the PR is created; wait a few seconds
   before watching them:
   ```bash
   gh pr create --base main --title "..." --body-file ...
   sleep 15
   gh pr checks <number> --watch
   ```
   `Lint` and `Test` are required by the `main` ruleset; the `Startup` jobs are not.

## Updating the pinned Neovim

CI never installs a moving release such as `stable`: `.github/workflows/ci.yml` pins an exact version
and its SHA-256, and `scripts/ci-install-neovim` refuses to extract anything whose checksum differs.
The `Test` job and the newest entry of the `Startup` matrix use the same version; the oldest `Startup`
entry is the minimum Neovim the config supports (`lua/minimum_version.lua`, the README and a test keep
them in agreement). To move to a new version:

1. Get the checksum. Recent releases expose it through the API (the `digest` field):
   ```bash
   gh api repos/neovim/neovim/releases/tags/v0.12.6 \
     --jq '.assets[] | select(.name=="nvim-linux-x86_64.tar.gz") | .digest'
   ```
   Older releases have no digest but publish a `shasum.txt` asset instead.
2. Replace the version and the 64-character hash in `ci.yml` (`Test` job and `Startup` matrix).
3. Run the suite locally with that version first: `PATH=/path/to/new/nvim/bin:$PATH tests/run`, and
   `NVIM=/path/to/new/nvim tests/full-startup`. The pull request's CI runs both again.
4. If the minimum changes, update `lua/minimum_version.lua`, the README ("Supported Platforms") and the
   oldest `Startup` entry together.

bats-core is pinned by commit (`6636e2c`, v1.9.0), not by tag. Nothing here is bumped automatically.

## Reporting bugs

Open an issue with:
- What you ran and what happened
- What you expected instead
- Your environment (OS, Neovim version, shell — `nvim-config doctor` output
  is a good start)

## Security issues

Do not open a public issue — see [`SECURITY.md`](SECURITY.md).
