# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.8.0] - 2026-09-10

### Added
- `nvim-config uninstall [config|nvim|mise|deps|all]` — reverses the corresponding `install`
  subcommand(s): removes the `~/.config/nvim` symlink (only if it points at this repository,
  matching `install config`'s own safety check), removes Neovim (detects mise/snap/apt the
  same way `update nvim` does, asks for confirmation), removes the mise binary and the shell
  activation lines `install mise` added (via a new `_remove_mise_activation` helper, matched
  by the same marker comment `_offer_mise_activation` writes; other tools mise manages are
  left untouched). `uninstall deps` never runs `apt remove` — the packages `install deps`
  installs (`git`, `make`, `gcc`, `curl`, `ripgrep`, `fd-find`, `xsel`, `xclip`,
  `wl-clipboard`, `lolcat`, `gnupg`) are shared system dependencies other tools may also rely
  on, so it only prints the manual removal command; `uninstall all` follows the same policy
  and excludes `deps`. `uninstall nvim`/`uninstall mise` are gated behind `_confirm`, so they
  auto-decline under `--dry-run`/`--quiet`/outside a TTY like every other prompt in this CLI.
  Shell completion (bash/zsh/fish) and `--help` updated; README gained an "Uninstalling"
  section

### Changed
- CI (`.github/workflows/ci.yml`) no longer runs on every push and every ref: `push` is now scoped to `main`/`develop` and the conventional branch prefixes (`feat/`, `fix/`, `chore/`, `docs/`, `test/`, `release/`, `hotfix/`), tag pushes no longer trigger a run (a tag should already point at a commit CI validated on `main`), and `pull_request` is scoped to PRs targeting `main`. Added `workflow_dispatch` for manual runs and a `concurrency` group with `cancel-in-progress` to stop superseded runs, both already mandated by this project's own CI conventions but missing from the actual workflow
- A new `detect-changes` job determines whether a push/PR touched only documentation (`**/*.md`, `docs/**`, `.editorconfig`); `lint`/`test` are skipped via job-level `if:` when it did. The workflow itself still always triggers and reports — a job skipped by `if:` satisfies a required status check, whereas a workflow that never runs at all leaves a PR stuck waiting indefinitely, which is why this isn't implemented as a trigger-level `paths-ignore`

### Fixed
- `.private/` and `vendor/` (the downloaded `tree-sitter` CLI) were only kept untracked by the maintainer's personal *global* `~/.gitignore`, not the project's own `.gitignore` — invisible to anyone else cloning the repo, e.g. `git add -A` would have picked them up. Both are now explicitly ignored at the project level, alongside a missing `.nvim-profile` entry (the third local per-project override file — `.nvim-ui`/`.nvim-theme` were already covered) and standard OS/editor artifacts

## [0.7.1] - 2026-09-08

### Added
- `SECURITY.md` — vulnerability reporting policy, scoped to the CLI's privileged/network operations (sudo installs, mise's GPG-verified installer, tree-sitter CLI download, shell rc writes)
- `CONTRIBUTING.md` — contribution workflow (branch/commit conventions, TDD requirement, test/shellcheck steps); linked from a new README "Contributing" section

### Fixed
- Shell completion: `nvim-config ui set <TAB>` and `nvim-config theme set <TAB>` incorrectly offered `list detect set unset create info` (profile's subcommands) instead of `classic modern` / the 14 theme names. Bash completion matched on the immediately preceding word only, and `set`/`unset`/`info` are shared between `profile`/`ui`/`theme`, so the `profile` pattern matched first — a dedicated `classic|modern)` case existed but was unreachable dead code. Bash completion now dispatches on the top-level command first, then disambiguates within it; zsh and fish gained the missing third-level completion (theme names) for parity with the `ui`/`classic`/`modern` case fish already had

## [0.7.0] - 2026-09-08

### Added
- `install mise` CLI subcommand — installs the [mise](https://mise.jdx.dev) version manager via curl, verifying the official release GPG key (`24853EC9F655CE80B48E6C3A8B81C9D17413A06D`) before executing the installer; idempotent (skips if `mise` is already present)
- `install nvim` (no explicit flag) now cascades interactively: use `mise` if present → else prompt to install it → else use `snap` if present → else prompt to install `snapd` → else fall back to `apt`; prompts auto-decline outside a TTY, under `--quiet`, or under `--dry-run` (never blocks CI or scripted runs)
- `update nvim` prefers `mise` automatically when Neovim was installed through it (`mise use -g neovim@latest`), falling back to the existing snap/apt auto-detection otherwise
- `--mise`, `--snap`, `--apt` flags now bypass the interactive cascade entirely and fail fast with a clear error if the corresponding tool is missing, instead of silently attempting to run it
- `nvim-config doctor` — `mise` added to the optional tools check
- After a fresh `install mise`, the CLI checks whether mise's shell activation line is already present in the user's shell rc (`~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`, based on `$SHELL`) and, if not, prompts to add it and reminds the user to reload their shell — required for `mise` and mise-managed tools (like `nvim`) to be found on `PATH`, per [mise's activation docs](https://mise.jdx.dev/installing-mise.html#shell-specific-installation-activation)
- `--activate` / `--no-activate` flags — bypass the mise shell-activation prompt in either direction without needing an interactive terminal: `--activate` adds the line unattended, `--no-activate` skips it entirely and just logs the manual command. Useful for automated/scripted installs, where the default prompt already auto-declines (no TTY) but an automation author may still want the line added on purpose
- `install deps` now also installs `wl-clipboard`, alongside the existing `xsel`/`xclip`, for Wayland clipboard support — previously only X11 tools were installed, so system clipboard integration silently didn't work on Wayland sessions (the default on Ubuntu 22.04+). Both are installed unconditionally rather than auto-detected at install time, since `install deps` may run over SSH or before any graphical session starts, when session-type detection would be unreliable; Neovim's own clipboard provider already picks the right tool at runtime

### Fixed
- `install nvim` / `install all` no longer crash with `sudo: snap: command not found` on systems without snap (e.g. WSL distros without snapd) — the missing case is now handled by the interactive cascade instead of being assumed available
- `log_message`: `ERROR`-level messages were printed twice — once colored on stdout, once plain on stderr. Now printed exactly once, on stderr only, per the project's error-handling convention
- `install nvim` auto mode no longer aborts the whole cascade when the optional `mise` (or `snapd`) install step fails (e.g. `gpg` missing) — it now logs a warning and falls through to the next fallback (snap, then apt) instead of failing outright, matching `mise`'s "optional" status
- `install all` no longer silently skips `install deps` / `install config` when the `nvim` step fails — each step now runs independently and the command reports overall failure via its exit code instead of aborting on the first error (a side effect of `set -e` combined with the unguarded `run_install_nvim` call)
- `install deps` now installs `gnupg`, required to verify the `mise` installer signature (previously `install mise` could fail on a fresh machine with `gpg is required` even after running `install deps`)
- `install nvim` auto mode: accepting the "install mise?" prompt when `curl` and/or `gnupg` are missing used to fail with a bare `gpg is required` error and silently fall through to snap/apt, defeating the user's explicit choice of mise. The prompt now detects and lists every missing prerequisite up front (e.g. "mise is not installed and requires: gnupg. Install gnupg + mise now?") and installs it via apt before installing mise, so answering "yes" actually results in mise being used
- `run_install_mise`: fixed `tmp_dir: unbound variable` crash at script exit after a successful (or failed) mise install. The cleanup `trap` on `EXIT INT TERM` referenced a `local` variable that goes out of scope once the function returns; since traps are process-global, the stale reference blew up later when the whole script exited (e.g. at the end of `install all`, after `install config` had already succeeded). The trap is now explicitly cleared (`trap - EXIT INT TERM`) before every return path
- All `apt install` calls the CLI runs on the user's behalf (deps, nvim via apt, mise prerequisites, snapd) now pass `-y` — the user already confirmed the action (by invoking the command or answering an interactive prompt), so apt's own confirmation prompt was redundant friction, not an extra safety check
- `install nvim --mise` / `install all --mise` used to error immediately ("mise is required — run 'install mise' first") and leave both `mise` and `nvim` uninstalled, requiring a separate manual `install mise` run — even though passing `--mise` is already an explicit, unambiguous choice. It now installs mise on the spot (missing prerequisites like `gnupg` included, no extra prompt — the flag itself is the consent) before using it. `--snap` gets the same treatment: installs `snapd` via apt first if missing, instead of erroring. `--apt` is unchanged (still errors if `apt` itself is absent — that signals the wrong OS, nothing to bootstrap)
- Fixed a `set -e`/`errexit` gotcha that let `install nvim --mise` attempt `mise use -g neovim@latest` even after the mise install had already failed (e.g. on missing `gnupg`), producing a raw `mise: command not found` instead of stopping cleanly. Root cause: `install all` calls `run_install_nvim || { ...; }` — in bash, using a function call as the left side of `||` disables `errexit` for its *entire* call subtree, not just its own top-level exit status, so a failing `run_install_mise` deep inside `_install_nvim_via` no longer aborted anything on its own. Every fallible step in `_install_nvim_via`, the `_install_nvim_auto` cascade, and `run_install_deps` is now explicitly guarded (`||`/`&&`) instead of relying on implicit propagation
- `run_install_mise`: even after a fully successful install, `mise use -g neovim@latest` still failed with `mise: command not found` in the same run — the installer places the binary at `~/.local/bin/mise`, which usually isn't on `PATH` until a login shell picks it up, so the process running `nvim-config` never saw it. The CLI now adds `~/.local/bin` to its own `PATH` right after a successful install (falling back to a clear error if `mise` still can't be found), so it can use `mise` immediately without waiting for a shell reload
- The "reload your shell" reminder after adding mise's activation line used to appear once, mid-run, right before a wall of `install deps` apt output — easy to miss. `install nvim`/`install mise`/`install all` now repeat it once more at the very end of the command if activation was added during that run
- The generated activation line used bare `mise activate bash`, which still didn't work even after `source ~/.bashrc`: that line has to run `mise` to produce its own output, but `mise` isn't resolvable via `PATH` until activation has already run — a chicken-and-egg problem. The line now uses the absolute path to the mise binary (`eval "$(/home/user/.local/bin/mise activate bash)"`), exactly as mise's own installer recommends, and the rc file also gets an explicit `~/.local/bin` PATH guard as defense in depth
- That PATH guard line itself is now idempotent at *shell-startup* time, not just at file-write time: for bash/zsh it's a `case ":$PATH:" in ...` check that only exports if `~/.local/bin` isn't already present, and for fish it uses the built-in `fish_add_path` (which deduplicates automatically). Previously it was an unconditional `export PATH=...`, so every manual `source ~/.bashrc` would prepend another duplicate entry
- `install deps` now installs `git` — it was documented as an assumed prerequisite but never actually installed, so a machine without it hit a raw, unreadable Neovim crash on startup (`E5113: ... E475: Invalid value for argument cmd: 'git' is not executable`) instead of a clean error. `lua/plugins.lua` also now checks `git` is executable before attempting the lazy.nvim bootstrap clone and, if missing, prints one clear actionable message (`git is required ... — nvim-config install deps or sudo apt install git`) instead of letting the raw `E475` propagate and silently skip the rest of plugin/bootstrap loading
- `noice.nvim`: list-style command output (`:scriptnames`, `:marks`, `:registers`, `:highlight`, `:map`, `:autocmd`, `:command`, `:buffers`, ...) shared the same `notify`-view route as `:echo`/`:echomsg`, with `opts.replace = true`. Since `nvim-notify` auto-dismisses after its configured timeout, calling the same (or another) list-style command again after the notification had already closed tried to replace an ID that no longer existed and silently showed nothing. `list_cmd`-kind messages are now routed to a `split` view instead, which has no such lifecycle and is a better fit for long, browsable output anyway
- `install deps` now installs `make` — it was checked by `nvim-config doctor` under "Required binaries" but never actually installed, so `telescope-fzf-native.nvim`'s native build silently failed on a fresh machine (`/bin/bash: line 1: make: command not found`), same class of oversight as the `git` fix above
- `make` alone isn't enough to build `telescope-fzf-native.nvim`: its Makefile also calls `cc` (`make: cc: No such file or directory`). `install deps` now installs `gcc` too, and `nvim-config doctor` moves `gcc` from the optional "Build tools" section to "Required binaries" (`cargo` stays optional — only needed for Rust-profile DAP tooling) since `telescope-fzf-native.nvim` is a baseline plugin (loaded by the default "classic" UI variant, not profile-gated)
- Removed `vim.opt.clipboard = 'unnamedplus'`: with it set, *every* yank/delete/put (`x`, `dd`, `p`, `y`, ...) shelled out to the system clipboard tool (`xclip`/`xsel`/`wl-copy`) on every single keystroke. On slower setups (e.g. containers) this lagged enough that holding a buffer-modifying key down would only register the first press — repeat presses were silently dropped while Neovim waited on the external process (confirmed: reproduced with `x`/`p`, absent with `~`/`u`, which don't touch a register; disappeared entirely with `:set clipboard=`). The config already provides explicit, on-demand system-clipboard access via `YY`/`XX`/`PP` (yank/cut/paste, see `docs/keymaps.md`), making the automatic sync both redundant and the source of the lag — normal editing no longer touches the system clipboard at all
- `jsonls` auto-install is now gated on `npm` being executable — `json-lsp` is an npm package installed by Mason via `npm install`, which failed on every Neovim startup with a Mason error (`Could not find executable "npm" in PATH`) on any machine without Node.js. Node.js is intentionally opt-in in this config (`install deps --with-node`), so `jsonls` is now simply skipped when `npm` is missing instead of repeatedly retrying a known failure; `lua_ls` (a standalone binary, no npm needed) is unaffected and always auto-installs
- `nvim-treesitter` failed to build parsers on first launch (`Error during "tree-sitter build": ... ENOENT ... 'tree-sitter'`): it shells out to a bare `tree-sitter` command with no way to configure its path, and while `nvim-config update tree-sitter` already downloaded the CLI into `vendor/tree-sitter/`, nothing ever added that directory to Neovim's `PATH`, and the command itself was never mentioned in the README's setup instructions. `lua/config/treesitter.lua` now prepends `vendor/tree-sitter` to `PATH` when the vendored binary is present, and `install all` now also runs `update tree-sitter` automatically (idempotent — downloads only if missing/outdated), so parser installs work out of the box on a fresh install without a separate manual step

### Changed
- Update pinned plugin commits in `lazy-lock.json` (routine `:Lazy sync`) — 30 plugins bumped to their latest tracked commit, no plugin added or removed

## [0.6.1] - 2026-09-01

### Security
- Harden GitHub Actions CI workflow: pin `actions/checkout` to a full commit SHA instead of the mutable `v4` tag, add `permissions: contents: read` at workflow level (least privilege), disable `persist-credentials` on checkout, pin `bats-core` install to a tagged release instead of the default branch, and fail closed on HTTP errors when downloading Neovim (`curl --fail`)

### Changed
- Update pinned plugin commits in `lazy-lock.json` (routine `:Lazy sync`); note that `neotest-rust`'s pin was dropped as a side effect of syncing without the `rust` profile active — the plugin spec in `lua/profiles/rust.lua` is unchanged and will simply reinstall unpinned on the next sync with that profile active

## [0.6.0] - 2026-05-18

### Added
- `ai` profile (`lua/profiles/ai.lua`) — opt-in flag profile activating the full AI tooling stack; never auto-detected; activate via `.nvim-profile` or `nvim-config profile set ai`; all five AI plugins (avante, codecompanion, codeium, mcphub, mcp-diagnostics) now guard their `cond` with `is_active('ai') and not is_active('termux')`
- `mcp-server-filesystem` and `mcp-server-fetch` added to `lua/config/mcphub.lua`: filesystem gives AI scoped read/write access to CWD; fetch retrieves web pages as Markdown (both official Anthropic servers)
- Python profile (`lua/profiles/python.lua`) — auto-detected from `pyproject.toml`, `setup.py`, `setup.cfg`, or `requirements.txt`; LSP: `pyright`; formatter: `ruff_format` then `black`; linters: `ruff`, `mypy`; DAP: `debugpy` (Mason); neotest: `neotest-python` with two launch configurations (file and module)
- `nvim-config doctor`: Python tools section (`python3`, `pyright`, `ruff`, `black`, `mypy`) shown as optional checks

## [0.5.0] - 2026-05-12

### Added
- Termux profile (`lua/profiles/termux.lua`) — Android/ARM environment profile; auto-detected via `$TERMUX_VERSION`; disables DAP adapters, avante, and codeium; LSP limited to `lua_ls`; `install deps` routes to `pkg install` (no `sudo`); `doctor` shows Termux-specific binaries
- `mcphub.nvim` — MCP client hub; `:MCPHub` UI; `<Leader>am`; integrates with avante and codecompanion; disabled on Termux; build installs `mcp-hub` via npm
- MCP servers: `mcp-server-git` (git log/diff/blame via `uvx`), `Context7` (versioned library docs via `npx @upstash/context7-mcp`), `mcp-diagnostics` (LSP diagnostics via bundled Node.js server)
- `mcp-diagnostics.nvim` — exposes Neovim LSP diagnostics to AI via MCP; loaded on `LspAttach`; disabled on Termux
- `codecompanion.nvim` — AI chat + inline assistant alongside avante for evaluation; default adapter `claude_code` (CLI, no OAuth); also supports `anthropic` and `gemini_cli`; native MCP via mcphub; honours `CLAUDE.md`/`.cursor/rules`; `<Leader>cc` toggle, `<Leader>cx` actions; disabled on Termux
- `mini.icons` (`echasnovski/mini.icons`) — lightweight icon provider required by which-key health check
- `<Leader>tl` — switch to last accessed tab; tab index tracked via `TabLeave` autocmd
- Bracketed paste: auto-enable `paste` mode on xterm `\e[200~` / auto-disable on `\e[201~`; works in SSH and tmux sessions

### Fixed
- `lua/profiles/web.lua`: remove stale `null_ls_sources` for `diagnostics.eslint` and `formatting.prettier` — both migrated to nvim-lint/conform; `diagnostics.eslint` removed from none-ls builtins in recent versions causing nil-index crash on startup
- `lua/config/lsp.lua`: skip `mason-lspconfig` `ensure_installed` on Termux — Mason ARM binaries often unavailable; servers must be installed manually
- `render-markdown.nvim`: remove `heading.sign` and `code.sign` (invalid in current version, caused `table - expected: nil, got: table` health ERROR); add `latex = { enabled = false }` to suppress LaTeX tool warnings
- `noice.lua`: enable `lsp.override` for `convert_input_to_markdown_lines`, `stylize_markdown`, `cmp.entry.get_documentation` — improves markdown rendering and eliminates 3 health warnings; hover and signature remain native
- `options.lua`: disable unused language providers (`python3`, `ruby`, `perl`, `node`) — eliminates 4 `:checkhealth` warnings
- `which-key.lua`: add `icons.keys = false` — eliminates `mini.icons not installed` warning
- `treesitter.lua`: add `regex` parser — required by noice.nvim for cmdline regex highlighting
- `bin/nvim-config`: resolve symlinks in `SCRIPT_DIR` (`readlink -f`) — `PROJECT_DIR` was resolving to `$HOME` when invoked via `~/bin/nvim-config` symlink, causing `install config` to link `~/.config/nvim → $HOME`
- `commands.lua`: skip trailing whitespace trim on non-modifiable / readonly buffers (E21 on `:w` in `:checkhealth` and help buffers)

## [0.4.1] - 2026-05-05

### Added
- `nvim-config update tree-sitter` — downloads the latest tree-sitter CLI binary (Linux x64/arm64) into `vendor/tree-sitter/`; skips when already up to date; integrated into `update all`; bash/zsh/fish completions updated
- `.luarc.json`: configures lua-language-server for the Neovim environment (LuaJIT runtime, snap runtime library path, `vim` declared as global) — eliminates 200+ false-positive "Undefined global `vim`" diagnostics

### Fixed
- treesitter: parser compilation failed with "subcommand 'build' not recognized" — vendored `tree-sitter` CLI was 0.20.6; nvim-treesitter v1.0 requires >= 0.22; updated to 0.26.8
- LSP: `ts_ls` attached to `.kdl` files (Zellij config) because the extension had no registered filetype; added `vim.filetype.add({ extension = { kdl = 'kdl' } })` so ts_ls ignores them
- avante: `<Leader>aP` picker threw E5108 "Failed to find provider: X" when switching to ACP providers (claude-code, gemini-cli, codex) — avante's `refresh()` looks them up in the API provider module table where they don't exist; `Config.provider` is already updated before the error, so the switch succeeds; wrapped in `pcall` and suppressed the known error

### Changed
- `docs/keymaps.md`: add missing sections for nvim-ufo (`zR`/`zM`/`K` with async fold note) and marks.nvim (`m[a-z]`, `]'`/`['`, `` ]`/[` ``); clarify `<space>f` routes through conform.nvim

## [0.4.0] - 2026-04-27

### Added
- `conform.nvim`: formatter replacing none-ls formatting sources; profile-driven `formatters_by_ft`; `format_on_save` (1 s timeout, LSP fallback); `<Space>f` global keymap; local binary resolution (`node_modules/.bin`, `vendor/bin`) evaluated at format time
- `nvim-lint`: linter replacing none-ls diagnostic sources; profile-driven `linters_by_ft`; event-driven (`BufWritePost`, `InsertLeave`); local binary resolution evaluated at lint time; phpmd ruleset configured to match prior none-ls settings
- Profiles: `conform_formatters()` and `lint_linters()` fields added to web (prettier/eslint), php (php_cs_fixer/phpstan+phpcs+phpmd), laravel (blade_formatter), rust (rustfmt)
- `profiles.get_conform_formatters()` and `profiles.get_lint_linters()` in `lua/profiles/init.lua`

### Added
- GitHub Actions CI workflow (`.github/workflows/ci.yml`): `lint` job (shellcheck on `bin/nvim-config`) and `test` job (bats-core + Neovim stable); triggers on `push` and `pull_request`
- CI status badge in `README.md`
- `tests/run`: post-run summary — total / passing / failing counts and elapsed time; failing tests listed by file (alphabetical) with tests sorted within each file
- `nvim-ufo`: LSP/treesitter-aware folding; provider chain lsp → indent; `zR` open all folds, `zM` close all folds; `K` peeks folded lines under cursor and falls back to LSP hover when not foldable; fold options (`foldlevel=99`, `foldlevelstart=99`) set in `options.lua`
- `marks.nvim`: visual marks in the sign column; `m[a-z]` to set, `]'`/`['` to navigate by line, `` ]` ``/`` [` `` by column; builtin marks (`. < > ^`) displayed
- `oil.nvim`: edit the filesystem as a buffer (rename, move, delete via normal editing); `-` opens the parent directory of the current file; coexists with neo-tree (`default_file_explorer = false`)
- `noice.nvim`: floating cmdline (`cmdline_popup` centered at 40% row), popup messages, LSP progress indicator; `notify.enabled` disabled in modern variant (snacks.nvim owns `vim.notify`); LSP hover/signature kept native to avoid conflicts
- `nvim-config status` — shows active Neovim version, UI variant, theme, and profile at a glance
- `nvim-config doctor` — checks required binaries (git, make, rg, fdfind, node, npm) and optional tools (lazygit, tmux, claude, codex, gemini, cargo, gcc)
- `nvim-config theme info` — prints the active colorscheme; `theme list` lists all 14 themes and marks the active one with `*`
- `nvim-config ui info` — prints the active UI variant
- `nvim-config profile info` — prints active profile with its LSP servers and DAP packages parsed from the profile Lua file
- `nvim-config profile list` now marks the active profile with `*` and skips internal files (init, picker)
- `nvim-config update dap-adapters` — reads the active profile's `dap_mason_packages` and triggers Mason install headlessly
- `nvim-config keymaps` — opens `docs/keymaps.md` in `$PAGER`
- bash/zsh/fish completions updated for all new commands (`status`, `doctor`, `keymaps`) and subcommands (`theme info/list`, `ui info`, `profile info`, `update dap-adapters`)
- Session restore: `persistence.nvim` saves session per directory on exit and auto-restores on startup when Neovim is opened with no arguments; `<Leader>qs` restore, `<Leader>qd` stop persistence; `<Leader>q` group annotated as Session in which-key
- `:Cheat` with no argument opens a `vim.ui.select` picker (works in both UI variants) instead of showing a usage message
- `:w!!` sudo save — write system files without relaunching Neovim as root (`cabbrev w!!` → `w !sudo tee % > /dev/null`)
- `nvim-spectre`: project-wide search/replace with regex and preview; `<Leader>sr` open, `<Leader>sw` search word under cursor
- `zen-mode.nvim`: distraction-free fullscreen mode; `<Leader>tz` toggle
- `lazygit` integration via `toggleterm.nvim`: `<Leader>gg` opens lazygit in a floating terminal; requires `lazygit` installed on the system
- `neotest` + `neotest-bash`: test runner integrated in Neovim; `<Leader>Tr` run nearest, `<Leader>Tf` run file, `<Leader>Ts` summary panel, `<Leader>To` output panel; `<Leader>T` Testing group in which-key
- neotest profile-driven adapters: `neotest-vitest` (web, vitest detection via `node_modules/.bin/vitest`), `neotest-phpunit` (php/laravel), `neotest-rust` (rust); loaded conditionally via `profiles.get_neotest_adapters()` — same pattern as LSP servers and null-ls sources
- `nvim-dap` + `nvim-dap-ui` + `nvim-dap-virtual-text`: interactive debugger with floating UI and inline variable values; `<Leader>D` group; `one-small-step-for-vimkind` Lua adapter built-in
- DAP profile-driven adapters: `pwa-node`/JS-TS (web, Mason `js-debug-adapter`), Xdebug/PHP (php/laravel, Mason `php-debug-adapter`), codelldb/Rust (rust, Mason `codelldb`); registered via `profiles.setup_dap(dap)`
- DAP Mason auto-install: `profiles.get_dap_mason_packages()` + Mason registry in `lua/config/lsp.lua`; missing packages installed at startup alongside LSP servers
- `avante.nvim`: Cursor-like AI assistant (chat + inline edits); CLI-first providers (claude-code default, gemini-cli, codex) require no OAuth at startup; API providers (claude, claude-opus, gemini) available via `<Leader>aP` picker; `<Leader>a` which-key group
- Gemini CLI: `install gemini` CLI subcommand (`@google/gemini-cli` via npm); dedicated toggleterm terminal `<Leader>tG`; bash/zsh/fish completions updated
- `codeium.nvim`: free inline AI completion; integrated as nvim-cmp source (`[AI]` label); activate with `:Codeium Auth` on first use
- `mini.ai`: extended text objects — smarter `a`/`i` for function args, brackets, quotes across multiple lines; `n_lines=500`
- `toggleterm.nvim`: persistent floating terminal (`<C-\>`); `<Leader>tt` general toggle; `<Leader>tC` dedicated Claude Code session; `<Leader>tX` dedicated Codex CLI session
- `harpoon` (v2): per-project file bookmarks; `<Leader>ha` add, `<Leader>hh` menu, `<C-1..4>` jump to file 1-4
- `todo-comments.nvim`: colorises `TODO`/`FIXME`/`HACK`/`NOTE`/`WARN` in code; `<Leader>ft` opens full list via Telescope
- `diffview.nvim`: enhanced diff view (`<Leader>gv`) and per-file git history (`<Leader>gH`); lazy-loaded on commands; complements gitsigns
- `vim-illuminate`: auto-highlights all occurrences of the word under cursor; 200ms delay; disabled in neo-tree, Telescope, Mason
- `indent-blankline.nvim` (v3/ibl): visual indent guides with `│` character and scope highlighting
- `friendly-snippets`: pre-built snippet library for LuaSnip — already wired as LuaSnip dependency with `lazy_load()`
- `install claude` CLI subcommand — installs Claude Code CLI (`@anthropic-ai/claude-code` via npm); skips if already present; errors if npm is missing
- `install codex` CLI subcommand — installs OpenAI Codex CLI (`@openai/codex` via npm); same guards
- Fish shell completion: `--show-completion fish` / `--install-completion fish`; installs to `~/.config/fish/completions/nvim-config.fish`; all commands and subcommands covered
- Theme system: 14 dark colorschemes (nightfox variants, catppuccin, tokyonight, kanagawa, gruvbox-material) with persistent selection via `.nvim-theme` (gitignored)
- `lua/ui/theme.lua`: source of truth for valid theme names; `get()` reads `.nvim-theme` with `nightfox` fallback
- `:Theme [name]` user command: applies and persists a colorscheme; no args shows current; tab-completion on all 14 names
- `bin/nvim-config theme set|unset [<name>]` CLI subcommand: mirrors `ui` command pattern; bash and zsh completions updated
- `lua/plugins/catppuccin.lua`: catppuccin-mocha, catppuccin-macchiato, catppuccin-frappe (dark variants, transparent background)
- `lua/plugins/tokyonight.lua`: tokyonight-night, tokyonight-storm, tokyonight-moon (transparent)
- `lua/plugins/kanagawa.lua`: kanagawa-wave, kanagawa-dragon (transparent)
- `lua/plugins/gruvbox-material.lua`: gruvbox-material (dark, medium contrast)
- `theme-init` lazy.nvim inline spec (`priority = 0`): applies the active colorscheme after all `priority = 1000` colorscheme plugins have completed setup — prevents flash
- `render-markdown.nvim`: in-buffer markdown rendering (headings, code blocks, bullets, checkboxes, tables); lazy-loaded on `ft = markdown`; no Node.js/browser required
- Bash shebang detection: extensionless files with `#!/.../bin/bash` or `#!/.../env bash` shebang auto-detected as `sh` filetype via `vim.filetype.add` with `priority = -math.huge`
- `<Leader>tn`: cycle line numbers (absolute → relative → none), new `<Leader>t` Toggle group in which-key
- `gitsigns.nvim`: inline diff signs in gutter, `]h`/`[h` hunk navigation, `<Leader>gs/gr/gp/gb/gd` stage/reset/preview/blame/diff — buffer-local, active in git repos only
- `docs/cheatsheets/git.md`: git cheatsheet (5th topic in `:Cheat`)
- `<Leader>g` group annotated as Git in which-key
- `<Leader><CR>`: clear search highlight without moving cursor
- Auto-save: all modified regular buffers saved automatically on `FocusLost` and `BufLeave` (guarded: skips scratch/prompt/input buffers)
- `:Cheat [topic]` user command: opens a cheatsheet in a centered floating window (`q`/`Esc` to close); tab-completion on topics; auto-discovers topics from `docs/cheatsheets/*.md`
- `<Leader>hc` keymap: opens `:Cheat` with topic prompt; `<Leader>h` group annotated as Help in which-key
- `docs/cheatsheets/`: four light quick-reference files (`editing`, `lsp`, `plugins`, `profiles`)
- `scrolloff=7`: 7-line scroll margin in `options.lua`
- `0` remapped to `^` (first non-blank character of line) in `keymaps.lua`
- Visual `*` / `#`: search forward / backward on the current selection (literal, very-nomagic)
- `<Leader>pp`: paste mode toggle (manual fallback for SSH / terminals without bracketed paste)
- `<Leader>cd`: change CWD to the directory of the current file
- `<Leader>ss/sn/sp/sa/s?`: spell checking toggle and navigation; `<Leader>s` group annotated in which-key
- UI variant system: two interchangeable variants (`classic`, `modern`) selected at startup via `.nvim-ui` at the config root (gitignored, defaults to `classic`)
- `lua/ui/variant.lua`: reads `.nvim-ui` and returns the active variant name
- `lua/ui/shared.lua`: plugin specs common to both variants (nightfox, lualine, bufferline, nvim-navic)
- `lua/ui/classic.lua`: classic variant specs (telescope, which-key, trouble)
- `lua/ui/modern.lua`: modern variant specs (snacks.nvim — picker, notifier, dashboard)
- CLI `ui` command: `set classic|modern` writes `.nvim-ui`; `unset` removes it
- `.nvim-ui` added to `.gitignore`
- Split `tests/nvim-config.bats` into domain-specific files: `cli.bats`, `lsp.bats`, `ui.bats`, `docs.bats`, `profiles.bats`
- `:NvimProfile [name]` user command: activates a profile at runtime (LSP + null-ls immediate, plugins require restart); no argument opens Telescope picker
- `<Leader>fp` keymap: opens profile picker (which-key annotated)
- `lua/profiles/picker.lua`: Telescope picker showing active (●) / inactive (○) profiles
- `lua/profiles/init.lua`: `activate()` function for runtime profile switching
- Project profile system: `lua/profiles/` with additive profiles `web`, `php`, `laravel` (extends php), `rust`; auto-detected from `package.json`, `composer.json`, `Cargo.toml`; overridable via `.nvim-profile` at project root
- `lua/profiles/init.lua`: profile manager with `detect`, `is_active`, `get_plugins`, `get_lsp_servers`, `get_null_ls_sources`
- CLI `profile` command: `list`, `detect`, `set`, `unset`, `create` subcommands
- Bash and zsh completions updated with `profile`, `ui`, and `theme` commands and subcommands
- `emmet-vim` and `telescope-node_modules` moved from global plugins to `web` profile
- none-ls sources are now profile-driven: PHP QA tools (phpstan, phpcs, phpmd, php-cs-fixer), Prettier/ESLint, rustfmt, blade-formatter
- Profile-driven LSP: `ts_ls`, `volar`, `svelte-language-server` (web); `intelephense` (php); `rust_analyzer` (rust)
- `install config` subcommand: symlinks `~/.config/nvim` to the repository; aborts safely if target exists and is not a symlink to this repo
- `install deps` subcommand: installs apt packages only
- `install all` (default): runs deps then config
- Bash completion for `install` subcommands (`deps`, `config`, `all`)
- Tests: expanded suite now at 230+ tests covering CLI, LSP, UI, profiles, docs, and startup integrity

### Fixed
- `commands.lua`: replace deprecated `vim.api.nvim_exec` with `vim.api.nvim_create_autocmd` for `disable-comments-on-new-lines` and `trim-white-space-on-save` autocmd groups; cursor position is now preserved across the trailing-whitespace substitution
- `lua_ls`: add `runtime` and `workspace.library` (config `lua/` + `VIMRUNTIME`) to the `lua_ls` LSP settings so LuaLS resolves `require('plugins.foo')` relative to `lua/` (correct module root) and not the project root, eliminating "same file required with different names" warnings
- `<C-s>` added in normal mode (`:w`); `<C-z>` removed from normal and insert modes (conflicts with shell `SIGTSTP`); `<C-r>` removed from insert mode (overwrote native "insert register" — redo remains on `<C-r>` in normal mode)
- `nvim-treesitter` v1.0 migration: rewrote `lua/config/treesitter.lua` — `nvim-treesitter.configs` removed; highlight via FileType autocmd + `vim.treesitter.start()`, folds via `vim.treesitter.foldexpr()`, textobjects migrated to `nvim-treesitter-textobjects` v2 explicit keymaps
- which-key v3: disabled automatic keymap icons (`icons.mappings = false`) to avoid rendering issues without a Nerd Font
- `avante.nvim` `auth_type` corrected from `"pro"` to `"max"` — avante only recognises `"api"` and `"max"`; `"max"` covers both Pro and Max Claude subscriptions
- nvim-ufo: `provider_selector` reduced to `{ 'lsp', 'indent' }` — API only accepts a `{main, fallback}` pair; three-value table caused an error on every file open
- avante: auth input field closed on focus return — root cause was the `"native"` input provider calling `vim.ui.select()` (a picker that closes on `BufLeave`); fixed by setting `input.provider = "dressing"` to use a proper `vim.ui.input` buffer
- avante: `<Leader>aP` provider picker — `AvanteSwitchProvider` Vim command has `nargs=0` (E488 on any argument); replaced with direct `require('avante.api').switch_provider()` Lua call; rebuilt picker using `telescope.pickers.new()` to fix invisible-on-second-use regression with `vim.ui.select`
- avante: keymaps (`<Leader>at`, `<Leader>aa`, etc.) not responding — avante's `safe_keymap_set` skips any key that lazy.nvim has registered as a handler (`Keys:have()` check); string entries in `keys` spec blocked all avante keymap definitions; reverted to `VeryLazy` loading (no OAuth prompt at init — default provider is `claude-code`, ACP-based); `<Leader>aP` uses `vim.keymap.set` directly and is unaffected
- avante: ACP providers (claude-code, codex) stuck on "generating" — avante default `args` for ACP providers use `{ '-y', '-g', '<pkg>' }`; in npm 11 `-g` means "from global install only" so the package is never downloaded; replaced `-g` with `--` (end-of-options separator) for claude-code and codex; also replaced deprecated `@zed-industries/claude-code-acp` with `@agentclientprotocol/claude-agent-acp`
- avante: provider switch routes requests to wrong ACP subprocess — `sidebar.acp_client` is cached after first connection and reused for all subsequent requests regardless of active provider; `switch_provider()` does not clear the cache; fixed by resetting `sidebar.acp_client` and `sidebar.chat_history.acp_session_id` in the `<Leader>aP` picker after the switch
- avante: sidebar not opening after provider selection — `open_sidebar({ ask = false })` now called after `switch_provider()` in the `<Leader>aP` picker
- avante: gemini-cli demanding API key — `auth_method = false` skipped auth entirely, causing `create_session` to fail because gemini CLI requires an explicit auth type; the correct Google OAuth method id is `"oauth-personal"` (confirmed via ACP `initialize` response); set `auth_method = "oauth-personal"` to reuse the OAuth token already stored by the gemini CLI
- LSP: `K → vim.lsp.buf.hover()` removed from `on_attach` buffer-local keymaps — conflicts with nvim-ufo's global `K` (peek fold / LSP hover fallback); nvim-ufo handles both cases correctly
- LSP: `<C-h> → signature help` moved from normal mode to insert mode in `on_attach` — was shadowing the global `<C-h>` window-navigation keymap in normal mode
- auto-save: `BufLeave` autocmd now guards on `buftype` (`'' or 'acwrite'` only) — previously interfered with dressing input buffers via trailing-whitespace `BufWritePre` hooks, causing the auth input field to close

### Changed
- `lua/plugins.lua`: UI plugins (telescope, lualine, bufferline, which-key, trouble, nvim-navic, nightfox) are now loaded via `lua/ui/` instead of inline requires
- Plugin loading deferred with lazy.nvim triggers: `neo-tree` and `trouble` on `cmd`; `telescope` on `cmd`; `treesitter`, `lsp`, `null-ls` on `BufReadPre/BufNewFile`; `nvim-cmp` on `InsertEnter`; `comment` and `vim-surround` on `BufReadPost`; `which-key` on `VeryLazy`; `emmet` on web filetypes only; `bufferline` explicitly `lazy = false`
- `<Space>f`: moved from `on_attach` buffer-local LSP keymap to a global keymap in `lua/config/conform.lua`; behavior unchanged (falls back to LSP when no conform formatter is configured)
- avante: model updated to `claude-sonnet-4-6` (replaces deprecated `claude-sonnet-4-5-20250929`) and `claude-opus-4-7`; provider set expanded to `claude-code` (CLI, default), `gemini-cli` (CLI), `codex` (CLI), `claude` (API, OAuth), `claude-opus` (API, OAuth), `gemini` (API key)
- `timeoutlen = 500` (explicit, was implicit 1000ms); `ttimeoutlen = 10` (was 0, caused intermittent terminal escape-sequence issues)
- `:Cheat` auto-discovers topics by scanning `docs/cheatsheets/*.md` instead of a hardcoded list — adding a file to that directory makes it immediately available in the picker and tab-completion

## [0.3.0] - 2026-03-30

### Added
- `nvim-navic` (LSP-based breadcrumb) replaces archived `nvim-gps`; attached in LSP `on_attach` and rendered in lualine
- `neo-tree.nvim` (v3.x) replaces `nvim-tree.lua` as the file explorer
- Regression tests for LSP bootstrap, nvim-cmp mapping API, neo-tree migration, Trouble v3 keymaps, and Telescope extension loading

### Fixed
- `cmp.mapping.close()` replaced with `cmp.mapping.abort()` (current API)
- `<Tab>`/`<S-Tab>` cmp mappings now declare `{ 'i', 's' }` modes so LuaSnip jump works in select mode
- `require('nvim-navic')` in lualine config guarded with `pcall` to prevent crash when plugin is not yet installed
- Trouble keymaps migrated from v1 API (`workspace_diagnostics`, `document_diagnostics`, `quickfix`) to v3 (`diagnostics`, `qflist`)
- Telescope trouble integration updated from `open_with_trouble` to `trouble.sources.telescope` (v3 API), guarded with `pcall`
- Telescope `fzf` extension now explicitly loaded via `load_extension`
- Telescope `node_modules` extension load wrapped in `pcall` to tolerate missing build
- Bufferline offset filetype updated from `NvimTree` to `neo-tree`

### Removed
- `nvim-gps` (archived upstream, superseded by `nvim-navic`)
- `lsp-colors.nvim` (redundant with Neovim 0.9+ built-in diagnostic highlight groups)
- `lua/config/nvim-tree.lua` (replaced by `lua/config/neo-tree.lua`)

## [0.2.0] - 2026-03-30

### Added
- `.editorconfig` with per-language indentation rules (Lua, shell, bats, Markdown)
- `LICENSE.md` (MIT)
- `tests/startup.bats` with static `require()` integrity checks for `init.lua`, `plugins.lua`, and `bootstrap.lua`
- Headless Neovim smoke tests for `init.lua`, `options.lua`, and `keymaps.lua`; skipped automatically under Snap, overridable with `NVIM_HEADLESS_TESTS_SKIP=0`
- Colored terminal output in `bin/nvim-config`: INFO (white), WARN (yellow), ERROR (red), DEBUG (cyan); respects `NO_COLOR` env var and TTY detection
- Supported platforms section in `README.md` (Ubuntu 22.04/24.04, Bash 5+, Neovim 0.9+)

### Changed
- `CHANGELOG.md` reformatted to Keep a Changelog with typed sections and bracketed version headers
- ERROR-level log messages now also written to stderr

## [0.1.0] - 2026-03-26

### Added
- `bin/nvim-config` CLI with `install`, `--help`, `--version`, `--dry-run`, logging, and bash completion support
- `bats` test suite and a dedicated test runner under `tests/`

### Changed
- Replaced the old `install.sh` bootstrap script with `bin/nvim-config`
- Replaced the old `TODO` note with a structured roadmap in `TODO.md`

### Removed
- Exploratory Lua files that were not part of the runtime config

[Unreleased]: https://github.com/eviweb/neovim-config/compare/0.7.1...HEAD
[0.7.1]: https://github.com/eviweb/neovim-config/compare/0.7.0...0.7.1
[0.7.0]: https://github.com/eviweb/neovim-config/compare/0.6.1...0.7.0
[0.6.1]: https://github.com/eviweb/neovim-config/compare/0.6.0...0.6.1
[0.6.0]: https://github.com/eviweb/neovim-config/compare/0.5.0...0.6.0
[0.5.0]: https://github.com/eviweb/neovim-config/compare/0.4.1...0.5.0
[0.4.1]: https://github.com/eviweb/neovim-config/compare/0.4.0...0.4.1
[0.4.0]: https://github.com/eviweb/neovim-config/compare/0.3.0...0.4.0
[0.3.0]: https://github.com/eviweb/neovim-config/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/eviweb/neovim-config/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/eviweb/neovim-config/releases/tag/0.1.0
