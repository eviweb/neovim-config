# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
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
- Tests: 44 new tests (230 total) covering theme system, render-markdown, bash shebang detection, keymaps cleanup, and `:w!!`; treesitter regression test narrowed to `require(...)` calls only

### Fixed
- `<C-s>` added in normal mode (`:w`); `<C-z>` removed from normal and insert modes (conflicts with shell `SIGTSTP`); `<C-r>` removed from insert mode (overwrote native "insert register" — redo remains on `<C-r>` in normal mode)
- `nvim-treesitter` v1.0 migration: rewrote `lua/config/treesitter.lua` — `nvim-treesitter.configs` removed; highlight via FileType autocmd + `vim.treesitter.start()`, folds via `vim.treesitter.foldexpr()`, textobjects migrated to `nvim-treesitter-textobjects` v2 explicit keymaps
- which-key v3: disabled automatic keymap icons (`icons.mappings = false`) to avoid rendering issues without a Nerd Font

### Added
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
- Auto-save: all modified buffers saved automatically on `FocusLost` and `BufLeave`
- Tests: 19 new tests (169 total) covering keymaps (pass 1), cheatsheets and `:Cheat` command (pass 2) — 167 total, all green
- `:Cheat [topic]` user command: opens a cheatsheet in a centered floating window (`q`/`Esc` to close); tab-completion on topics
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
- Bash and zsh completions updated with `ui` command and subcommands
- `.nvim-ui` added to `.gitignore`
- Split `tests/nvim-config.bats` into domain-specific files: `cli.bats`, `lsp.bats`, `ui.bats`, `docs.bats`, `profiles.bats`

### Changed
- `lua/plugins.lua`: UI plugins (telescope, lualine, bufferline, which-key, trouble, nvim-navic, nightfox) are now loaded via `lua/ui/` instead of inline requires

- `:NvimProfile [name]` user command: activates a profile at runtime (LSP + null-ls immediate, plugins require restart); no argument opens Telescope picker
- `<Leader>fp` keymap: opens profile picker (which-key annotated)
- `lua/profiles/picker.lua`: Telescope picker showing active (●) / inactive (○) profiles
- `lua/profiles/init.lua`: `activate()` function for runtime profile switching
- Project profile system: `lua/profiles/` with additive profiles `web`, `php`, `laravel` (extends php), `rust`; auto-detected from `package.json`, `composer.json`, `Cargo.toml`; overridable via `.nvim-profile` at project root
- `lua/profiles/init.lua`: profile manager with `detect`, `is_active`, `get_plugins`, `get_lsp_servers`, `get_null_ls_sources`
- CLI `profile` command: `list`, `detect`, `set`, `unset`, `create` subcommands
- Bash and zsh completions updated with `profile` command and subcommands
- `emmet-vim` and `telescope-node_modules` moved from global plugins to `web` profile
- none-ls sources are now profile-driven: PHP QA tools (phpstan, phpcs, phpmd, php-cs-fixer), Prettier/ESLint, rustfmt, blade-formatter
- Profile-driven LSP: `ts_ls`, `volar`, `svelte-language-server` (web); `intelephense` (php); `rust_analyzer` (rust)
- 28 new tests covering profile structure, definitions, integration, and CLI commands (128 total)
- `docs/usage.md`: extended usage guide covering LSP workflow, completion, diagnostics, Telescope, and Bufferline
- `install config` subcommand: symlinks `~/.config/nvim` to the repository; aborts safely if target exists and is not a symlink to this repo
- `install deps` subcommand: installs apt packages only
- `install all` (default): runs deps then config
- Bash completion for `install` subcommands (`deps`, `config`, `all`)
- 5 new tests covering install subcommands, symlink detection, and completion

### Changed
- Plugin loading deferred with lazy.nvim triggers: `neo-tree` and `trouble` on `cmd`; `telescope` on `cmd`; `treesitter`, `lsp`, `null-ls` on `BufReadPre/BufNewFile`; `nvim-cmp` on `InsertEnter`; `comment` and `vim-surround` on `BufReadPost`; `which-key` on `VeryLazy`; `emmet` on web filetypes only; `bufferline` explicitly `lazy = false`

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

## [0.2.0] - 2026-03-30

### Added
- `nvim-navic` (LSP-based breadcrumb) replaces archived `nvim-gps`; attached in LSP `on_attach` and rendered in lualine
- `neo-tree.nvim` (v3.x) replaces `nvim-tree.lua` as the file explorer
- Regression tests for LSP bootstrap, nvim-cmp mapping API, neo-tree migration, Trouble v3 keymaps, and Telescope extension loading

### Fixed
- `cmp.mapping.close()` replaced with `cmp.mapping.abort()` (current API)
- `<Tab>`/`<S-Tab>` cmp mappings now declare `{ 'i', 's' }` modes so LuaSnip jump works in select mode
- `require('nvim-navic')` in lualine config guarded with `pcall`
- Trouble keymaps migrated from v1 API to v3 (`diagnostics`, `qflist`)
- Telescope trouble integration updated to `trouble.sources.telescope` (v3), guarded with `pcall`
- Telescope `fzf` extension now explicitly loaded; `node_modules` load wrapped in `pcall`
- Bufferline offset filetype updated from `NvimTree` to `neo-tree`

### Removed
- `nvim-gps` (archived upstream, superseded by `nvim-navic`)
- `lsp-colors.nvim` (redundant with Neovim 0.9+ built-in diagnostic highlight groups)
- `lua/config/nvim-tree.lua` (replaced by `lua/config/neo-tree.lua`)

## [0.1.0] - 2026-03-26

### Added
- `bin/nvim-config` CLI with `install`, `--help`, `--version`, `--dry-run`, logging, and bash completion support
- `bats` test suite and a dedicated test runner under `tests/`

### Changed
- Replaced the old `install.sh` bootstrap script with `bin/nvim-config`
- Replaced the old `TODO` note with a structured roadmap in `TODO.md`

### Removed
- Exploratory Lua files that were not part of the runtime config

[Unreleased]: https://github.com/eviweb/neovim-config/compare/0.3.0...HEAD
[0.3.0]: https://github.com/eviweb/neovim-config/compare/0.2.0...0.3.0
[0.2.0]: https://github.com/eviweb/neovim-config/compare/0.1.0...0.2.0
[0.1.0]: https://github.com/eviweb/neovim-config/releases/tag/0.1.0
