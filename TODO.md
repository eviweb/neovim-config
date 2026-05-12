# TODO

## Phase 0 - Repository Hygiene

- [x] Replace the old install script with a real CLI in `bin/`
- [x] Add a dedicated test runner under `tests/`
- [x] Rename `TODO` to `TODO.md`
- [x] Remove exploratory Lua files not used by the runtime config
- [x] Decide whether `.tmux.conf` belongs in this repository
- [x] Add `LICENSE.md` after validating the license choice

## Phase 1 - Safety Net

- [x] Add a first failing smoke-level CLI test suite
- [x] Make the initial CLI tests pass
- [x] Add a Neovim startup smoke test for `init.lua`
- [x] Add regression tests for startup failures fixed in the config

## Phase 2 - Startup Stability

- [x] Fix invalid `null-ls` sources
- [x] Remove or replace deprecated `nvim-tree` options
- [x] Migrate legacy `kyazdani42` plugin namespaces to maintained repositories
- [x] Replace `null-ls.nvim` with the maintained `none-ls.nvim` repository
- [x] Remove references to plugins or features that are not installed
- [x] Consolidate diagnostics UX on `trouble.nvim` and remove `diaglist`
- [x] Audit keymaps that depend on optional plugins

## Phase 3 - LSP And Completion

- [x] Replace `nvim-lsp-installer` with a maintained setup
- [x] Update deprecated LSP capability and formatting calls
- [x] Define an explicit maintained baseline for default LSP servers
- [x] Validate `nvim-cmp` and `LuaSnip` end-to-end
- [x] Add regression coverage for LSP bootstrap failures
- [x] Migrate LSP config to mason-lspconfig v2 API (`setup_handlers` removed in v2.0.0)

## Phase 4 - Treesitter And UI Reliability

- [x] Replace `ensure_installed = 'all'` with an explicit parser list
- [x] Remove unsupported Treesitter modules or add the missing plugins
- [x] Verify `lualine`, `bufferline`, `telescope`, and `trouble` startup paths
- [x] Migrate Trouble keymaps from v1 API (`workspace_diagnostics`, `document_diagnostics`) to current API
- [x] Replace `nvim-tree` with `neo-tree.nvim`
- [x] Decide whether `nvim-gps` should be replaced with `nvim-navic` or `aerial.nvim`
- [x] Remove `lsp-colors.nvim` (redundant with Neovim 0.9+ built-in diagnostic highlights)
- [x] Audit Telescope extensions and remove unused or redundant integrations

## Phase 5 - Documentation

- [x] Write a keybindings cheatsheet covering all custom mappings and plugin shortcuts
- [x] Write extended usage documentation (LSP workflow, completion, diagnostics, telescope, bufferline)
- [x] Add `<Leader>?` keymap to open Telescope keymaps picker (in-Neovim discoverability)
- [x] Annotate which-key groups with descriptions (`<Leader>f` = Find, `<Leader>d` = Diagnostics, etc.)

## Phase 7 - Install And Portability

- [x] Add bash completion support to the CLI
- [x] Add zsh completion support to the CLI
- [x] Add fish completion support to the CLI
- [x] Rewrite `install` to cover symlink/bootstrap flows explicitly
- [x] Document external dependencies required by the Neovim config
- [x] Document bootstrap limitations in sandboxed or Snap-based environments
- [x] Add `install nvim [--snap|--apt]` subcommand (snap by default, checks if already installed)
- [x] Extend `install all` to include `install nvim` in the full bootstrap chain
- [x] Add `update nvim` subcommand (snap refresh or apt upgrade depending on install method)
- [x] Add `update plugins` subcommand (headless `Lazy! sync` via nvim --headless)
- [x] Add `update` subcommand dispatching to `update nvim` + `update plugins`
- [x] Document Neovim installation (minimum version, recommended method per platform)
- [x] Document first-run initialization sequence (lazy.nvim bootstrap → plugin install → Mason LSP server install)
- [x] Document full end-to-end setup flow for a new machine in README

## Phase 8 - Optional Modernization

- [x] Decide whether to keep `packer.nvim` or migrate to a maintained plugin manager
- [x] Normalize plugin declarations and config loading patterns
- [x] Reduce eager startup side effects where not needed
- [x] Design project profiles so Neovim can enable only relevant tooling per repository
- [x] Decide whether the CLI should manage project profiles or only bootstrap them
- [x] Add in-Neovim profile switcher: `:NvimProfile <name>` user command + Telescope picker (depends on profile design)
- [x] Move frontend-only tooling such as `emmet-vim` behind project profiles
- [x] Move Node-specific Telescope integrations behind project profiles
- [x] Decide whether `none-ls.nvim` should remain global or have profile-driven sources

## Phase 9 - UI Consolidation (Long-term)

> Two interchangeable UI variants: `classic` (current stack) and `modern` (snacks.nvim suite).
> Variant chosen at Neovim startup. Default is `classic` unless `.nvim-ui` exists at the
> config root. CLI manages the file; `.nvim-ui` is gitignored.
>
> Design: Option B — independent of the profile system.
> Layout:
>   lua/ui/variant.lua  — reads .nvim-ui, returns 'classic' (default) or 'modern'
>   lua/ui/shared.lua   — colorscheme, lualine, bufferline, nvim-navic (common to both variants)
>   lua/ui/classic.lua  — telescope (fzf + node_modules extensions), which-key, trouble
>   lua/ui/modern.lua   — snacks.nvim (picker, notifier, dashboard)
>
> Evaluation result: snacks.nvim has no statusline or breadcrumb module.
> lualine and nvim-navic stay in shared.lua for both variants.
> The visible difference: picker (snacks vs telescope) and notifications.
>
> CLI: nvim-config ui set classic|modern  /  nvim-config ui unset

- [x] Evaluate `snacks.nvim` as the modern variant foundation (picker, statusline, notifier, dashboard, breadcrumb)
- [x] Implement `lua/ui/` structure (variant, shared, classic, modern)
- [x] Move current UI plugins into `lua/ui/classic.lua`
- [x] Implement `lua/ui/modern.lua` once evaluation is done
- [x] Add `nvim-config ui set|unset` CLI subcommand
- [x] Add `.nvim-ui` to `.gitignore`

## Phase 10 - Test Suite Maintenance

- [x] Split `tests/nvim-config.bats` by domain (CLI, profiles, LSP/completion, UI/plugins, docs) for readability

## Phase 11 - Quality of Life

> Incremental improvements with high daily value, low implementation cost.
> Ordered by recommended priority.

### High value

- [x] Clear search highlight — `<Leader><CR>` in normal mode to call `:noh`
- [x] Auto-save on focus loss — autocmd `FocusLost`/`BufLeave` → `:silent! wa`
- [x] `gitsigns.nvim` — inline diff signs, line blame, hunk navigation (`]h`/`[h`), stage/reset hunk
- [x] Line number toggle — `<Leader>tn` cycles absolute → relative → none; new `<Leader>t` Toggle group

### Medium value

- [x] `:w!!` sudo save — write system files without relaunching Neovim as root
- [x] `:Cheat` picker — `:Cheat` with no argument opens `vim.ui.select` (variant-agnostic); with argument opens directly
- [x] Session restore — `persistence.nvim`: auto-restore on startup (no args), `<Leader>qs` restore, `<Leader>qd` stop

## Phase 12 - Themes, Markdown And Filetype Detection

- [x] Persistent colorscheme system — `lua/ui/theme.lua`, `.nvim-theme` (gitignored), 14 dark themes
- [x] 4 new colorscheme plugins — catppuccin (3 variants), tokyonight (3), kanagawa (2), gruvbox-material
- [x] `theme-init` lazy.nvim spec at `priority=0` — applies active colorscheme after all plugins, prevents flash
- [x] `:Theme [name]` user command — applies and persists colorscheme, tab-completion on all 14 names
- [x] `nvim-config theme set|unset` CLI subcommand — mirrors `ui` command; bash and zsh completions updated
- [x] `render-markdown.nvim` — in-buffer markdown rendering (headings, code blocks, bullets, checkboxes, tables); lazy-loaded on `ft=markdown`
- [x] Bash shebang detection — extensionless files with `#!/.../bin/bash` or `#!/.../env bash` auto-detected as `sh` via `vim.filetype.add`
- [x] Keymaps cleanup — `<C-s>` added in normal mode; `<C-z>` and `<C-r>` removed from insert mode (terminal conflicts, native Vim override)
- [x] Test coverage — 43 new tests (229 total) covering all Phase 12 additions

## Phase 13 - Quality Of Life And AI

### Navigation
- [x] `harpoon` (ThePrimeagen/harpoon2) — mark/jump to 4-5 key files per project (`<Leader>ha`, `<Leader>hh`, `<C-1..4>`)
- [x] `vim-illuminate` — auto-highlight all occurrences of the word under cursor

### Editing
- [x] `friendly-snippets` — already wired as LuaSnip dependency with lazy_load()
- [x] `nvim-spectre` — project-wide search/replace (`<Leader>sr`, `<Leader>sw`)
- [x] `mini.ai` — extended text objects: function args, brackets across lines (`ia`/`aa`), n_lines=500

### Git
- [x] `diffview.nvim` — enhanced diff view (`<Leader>gv`) and per-file git history (`<Leader>gH`); complements gitsigns
- [x] `lazygit.nvim` — open lazygit in a floating terminal window from inside Neovim

### Code quality
- [x] `todo-comments.nvim` — colorise TODO/FIXME/HACK/NOTE in code; list all via Telescope (`<Leader>ft`)
- [x] `indent-blankline.nvim` — visual indent guides (essential for YAML, Python, nested Lua)

### Testing and debugging
- [x] `neotest` — run and visualise test results inside Neovim (bats, phpunit, jest...)
  - [x] `neotest-bash` adapter — bats-core support
  - [x] Profile-driven adapters: `neotest-vitest` (web), `neotest-phpunit` (php/laravel), `neotest-rust` (rust) — loaded via `profiles.get_neotest_adapters()` + profile `neotest_adapters` field
- [x] `nvim-dap` + `nvim-dap-ui` — interactive debugger with breakpoints and UI
  - [x] `nvim-dap-virtual-text` — inline variable values during debug
  - [x] `one-small-step-for-vimkind` — Lua DAP adapter (built-in, no Mason install)
  - [x] Profile-driven adapters: pwa-node/JS-TS (web), Xdebug/PHP (php/laravel), codelldb/Rust (rust)
  - [x] Auto-install DAP Mason packages at startup via `profiles.get_dap_mason_packages()` + Mason registry

### Writing
- [x] `zen-mode.nvim` — distraction-free fullscreen mode (`<Leader>tz`)

### Terminal and AI agents
- [x] `toggleterm.nvim` — floating terminal (`<C-\>`, `<Leader>tt`); dedicated Claude Code (`<Leader>tC`) and Codex CLI (`<Leader>tX`) instances
- [x] `install claude` CLI subcommand — install Claude Code CLI (`npm install -g @anthropic-ai/claude-code`); skips if present; errors if npm missing
- [x] `install codex` CLI subcommand — install OpenAI Codex CLI (`npm install -g @openai/codex`); same guards
- [x] `codeium.nvim` — free inline AI completion; nvim-cmp source `[AI]`; `:Codeium Auth` on first use
- [x] `avante.nvim` — Cursor-like AI assistant (chat + inline edits); `auth_type = "pro"` authenticates via Claude Pro subscription (browser OAuth, no API key required); also supports GPT-4o
- [x] Gemini CLI — `@google/gemini-cli` (npm); free tier via Google account; `install gemini` CLI subcommand + dedicated toggleterm terminal `<Leader>tG`

---

## Phase 14 - CLI Enhancements

### Info and diagnostics
- [x] `nvim-config status` — summary: active variant, theme, profile, Neovim version
- [x] `nvim-config doctor` — health check: Neovim, required binaries (git, make, rg, fdfind, node, npm), optional tools (lazygit, tmux, claude, codex, gemini, cargo, gcc)
- [x] `nvim-config theme info` — current active theme (reads `.nvim-theme`)
- [x] `nvim-config ui info` — current active UI variant (reads `.nvim-ui`)
- [x] `nvim-config profile info` — active profile + associated LSP servers and DAP packages (parsed from profile lua file)

### Discovery
- [x] `nvim-config theme list` — list all 14 available themes, mark the active one with `*`
- [x] `nvim-config profile list` — list all available profiles, mark active with `*`; skip internal files (init, picker)
- [x] `nvim-config keymaps` — open `docs/keymaps.md` in `$PAGER`

### Maintenance
- [x] `nvim-config update dap-adapters` — show DAP packages for active profile, trigger Mason install headlessly

---

## Phase 15 - Plugin Modernization And UX

### Formatters and linters (modernization)
- [x] `conform.nvim` — modern formatter replacing none-ls formatting sources; per-filetype formatter chains; `format_on_save` option
- [x] `nvim-lint` — modern linter replacing none-ls diagnostic sources; event-driven (`BufWritePost`, `InsertLeave`)
- [x] Migrate profiles to use conform/nvim-lint sources instead of none-ls (additive, keep none-ls as fallback during transition)

### UI enhancements
- [x] `noice.nvim` — floating cmdline (`cmdline_popup`), popup messages, LSP progress; `notify.enabled` false in modern variant (snacks owns `vim.notify`); LSP hover/signature kept native
- [x] `nvim-ufo` — LSP/treesitter-aware folding; `zR` open all, `zM` close all, `K` peek fold (falls back to LSP hover); provider chain: lsp → treesitter → indent

### File management
- [x] `oil.nvim` — edit filesystem as a buffer (rename, move, delete via normal editing); `-` to open parent dir; `default_file_explorer = false` to coexist with neo-tree

### Navigation
- [x] `marks.nvim` — visual marks in sign column with `m[a-z]` gutter indicators; `]'`/`['` line jumps, `` ]` ``/`` [` `` column jumps; builtin marks (`. < > ^`) shown

---

## Phase 16 — Portability and MCP ecosystem (target 0.5.0)

### Portability

- [x] Termux profile (`lua/profiles/termux.lua`) — environment profile for Android ARM:

- [x] Python language profile (`lua/profiles/python.lua`) — auto-detected from `pyproject.toml`,
  `setup.py`, `setup.cfg`, `requirements.txt`; LSP: `pyright`; conform: `ruff_format`+`black`;
  lint: `ruff`, `mypy`; neotest: `neotest-python`; DAP: `debugpy` (Mason)
  - *(details in `.private/termux.md`)*

### MCP ecosystem

- [x] `mcphub.nvim` — MCP client hub; `<Leader>am` UI; avante integration; disabled on Termux
  → https://github.com/ravitemer/mcphub.nvim
- [x] `mcp-server-git` *(official Anthropic)* — git operations via MCP (`uvx mcp-server-git`)
  → https://github.com/modelcontextprotocol/servers/tree/main/src/git
- [x] `mcp-diagnostics.nvim` — LSP diagnostics exposed to AI via MCP; bundled Node.js server registered in mcphub config; pending live validation
  → https://github.com/georgeharker/mcp-diagnostics.nvim
- [x] `Context7` *(Upstash)* — versioned library docs injected into LLM prompts (`@upstash/context7-mcp`)
  → https://github.com/upstash/context7

### AI stack (after codecompanion.nvim benchmark)

- [x] Benchmark `codecompanion.nvim` vs `avante.nvim` — plugin installed alongside avante;
  `<Leader>cc`/`<Leader>cx`; evaluation pending on a real project
  → https://github.com/olimorris/codecompanion.nvim
- [ ] AI profile — opt-in profile grouping avante (or codecompanion) + codeium + mcphub; allows
  disabling all AI tooling by not activating the profile

---

## Deferred / Under Consideration

> Items intentionally set aside — not yet prioritised or waiting for a relevant project context.

### AI tooling

- [ ] AI profile — opt-in `ai` profile that loads AI plugins only when explicitly activated;
  decide on the stack before implementing (see evaluation notes below); allows disabling all
  AI tooling globally by not activating the profile

  **Stack evaluation — Avante vs CodeCompanion:**
  - `avante.nvim` — Cursor-like sidebar + inline edits; CLI-first providers (claude-code,
    gemini-cli, codex) avoid OAuth at startup; heavier, more opinionated UI
  - `codecompanion.nvim` — alternative chat + inline assistant; native MCP support (spec
    2025-11-25); multi-provider (Anthropic, Gemini, Ollama, OpenAI…); honours `CLAUDE.md` /
    `.cursor/rules`; lighter, more composable — evaluate as a replacement for Avante
  - `codeium.nvim` — ghost-text inline completion (independent of chat assistant); free,
    lightweight, no conflict with either Avante or CodeCompanion; keep regardless of choice above
  - Decision: benchmark Avante vs CodeCompanion on a real project before committing

- [ ] `copilot.lua` (zbirenbaum) — inline AI completions via GitHub Copilot subscription;
  deferred — `codeium.nvim` covers the free inline completion use case
  → https://github.com/zbirenbaum/copilot.lua

- [ ] Avante auth-mode picker — extend `<Leader>aP` provider picker with a second level to
  select the authentication mode per provider (OAuth Max, OAuth Pro, API key); REST providers
  (`claude`, `claude-opus`, `gemini`) support multiple `auth_type` values; ACP providers
  (claude-code, gemini-cli, codex) manage their own auth via CLI; requires building a two-step
  Telescope picker and a runtime `Config.override({ providers = { … } })` call

### MCP servers (usable via mcphub.nvim — deferred until Phase 16 mcphub is in place)

- [ ] `mcp-server-filesystem` *(official Anthropic)* — secure file read/write with per-directory
  access control; gives the AI access to files outside the current buffer
  → https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem

- [ ] `mcp-server-fetch` *(official Anthropic)* — fetches web pages and converts HTML to
  Markdown; useful for querying online docs directly from the chat sidebar
  → https://github.com/modelcontextprotocol/servers/tree/main/src/fetch

- [ ] `mcp-neovim-server` — exposes Neovim buffers, cursor, registers and vim commands to
  external MCP clients (Claude Desktop, etc.) via node-client; inverse direction from mcphub
  → https://github.com/bigcodegen/mcp-neovim-server

### Testing

- [ ] neotest profile-driven adapters — `neotest-jest` (web, when Jest is preferred over Vitest),
  `neotest-busted` (Lua/busted projects); deferred until relevant project context

### Plugin management

- [ ] `mason-nvim-dap.nvim` — declarative DAP adapter installation via Mason (alternative to
  current manual registry approach); evaluate if the current approach proves insufficient

### Config distribution selector

- [ ] `nvim-config install config --preset <name|url>` — extend `install config` to support
  alternative Neovim distributions as presets; back up existing `~/.config/nvim` before
  switching; supported presets to evaluate:
  - `nvchad`   → https://nvchad.com
  - `lazyvim`  → https://www.lazyvim.org
  - `astronvim` → https://astronvim.com
  - `<url>`    → any git repository (generic clone)
  - `default`  → this config (current behaviour, always available)
  - CLI clones the target repo, symlinks `~/.config/nvim`, documents prerequisites per preset
