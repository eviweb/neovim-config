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
- [ ] `nvim-spectre` — project-wide search/replace with regex and preview before applying
- [x] `mini.ai` — extended text objects: function args, brackets across lines (`ia`/`aa`), n_lines=500

### Git
- [x] `diffview.nvim` — enhanced diff view (`<Leader>gv`) and per-file git history (`<Leader>gH`); complements gitsigns
- [ ] `lazygit.nvim` — open lazygit in a floating terminal window from inside Neovim

### Code quality
- [x] `todo-comments.nvim` — colorise TODO/FIXME/HACK/NOTE in code; list all via Telescope (`<Leader>ft`)
- [x] `indent-blankline.nvim` — visual indent guides (essential for YAML, Python, nested Lua)

### Testing and debugging
- [ ] `neotest` — run and visualise test results inside Neovim (bats, phpunit, jest...)
- [ ] `nvim-dap` + `nvim-dap-ui` — interactive debugger with breakpoints and UI

### Writing
- [ ] `zen-mode.nvim` — distraction-free fullscreen mode for markdown and prose

### Terminal and AI agents
- [x] `toggleterm.nvim` — floating terminal (`<C-\>`, `<Leader>tt`); dedicated Claude Code (`<Leader>tC`) and Codex CLI (`<Leader>tX`) instances
- [x] `install claude` CLI subcommand — install Claude Code CLI (`npm install -g @anthropic-ai/claude-code`); skips if present; errors if npm missing
- [x] `install codex` CLI subcommand — install OpenAI Codex CLI (`npm install -g @openai/codex`); same guards
- [ ] `avante.nvim` — Cursor-like AI assistant (chat + inline edits); supports Claude
  (Anthropic API key) and GPT-4o (OpenAI API key); requires API billing separate from
  chat subscriptions
- [ ] `copilot.lua` (zbirenbaum) — inline AI completions via GitHub Copilot subscription
  (~$10/month or free tier); pairs with `CopilotChat.nvim` for chat interface
- [x] `codeium.nvim` — free inline AI completion; nvim-cmp source `[AI]`; `:Codeium Auth` on first use
