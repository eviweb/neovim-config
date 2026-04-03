# Keymaps Cheatsheet

## Leader key

The leader key is set to **`Space`** — the dominant convention in modern Neovim
distributions (LazyVim, AstroNvim, kickstart.nvim).

It is defined in `lua/keymaps.lua`:

```lua
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
```

To change it, update both lines before any `map()` call. Common alternatives: `,` or `\`.

Press `<Leader>` in normal mode to open the **which-key popup** — a live guide
showing all available mappings for the current prefix.
Press `<Leader>?` to browse all keymaps with Telescope.

## All modes

| Key | Action |
|-----|--------|
| `YY` | Copy to system clipboard |
| `XX` | Cut to system clipboard |
| `PP` | Paste from system clipboard |

## Normal mode

### Navigation

| Key | Action |
|-----|--------|
| `n` / `N` | Next / previous search match (centered) |
| `j` / `k` | Move by visual line when wrapped, by real line otherwise |
| `0` | Jump to first non-blank character of the line |
| `<C-h/j/k/l>` | Move to left / down / up / right window |

### Windows

| Key | Action |
|-----|--------|
| `<C-Up>` | Decrease window height |
| `<C-Down>` | Increase window height |
| `<C-Left>` | Increase window width |
| `<C-Right>` | Decrease window width |

### Editing

| Key | Action |
|-----|--------|
| `<C-s>` | Save file |
| `<A-j>` / `<A-k>` | Move current line down / up |

### File explorer

| Key | Action |
|-----|--------|
| `<Leader>n` | Toggle neo-tree file explorer |

## Insert mode

| Key | Action |
|-----|--------|
| `jj` | Exit to normal mode |
| `<C-s>` | Save file and return to insert mode |
| `<A-j>` / `<A-k>` | Move current line down / up |

## Visual mode

| Key | Action |
|-----|--------|
| `<` / `>` | Indent left / right (stays in visual mode) |
| `*` / `#` | Search forward / backward for the current selection |

## Visual block mode

| Key | Action |
|-----|--------|
| `J` / `K` | Move selected block down / up |
| `<A-j>` / `<A-k>` | Move selected block down / up |

## Terminal mode

| Key | Action |
|-----|--------|
| `<Esc><Esc>` | Exit to normal mode |
| `<C-s>` | Exit to normal mode |

## Plugins

### Bufferline

| Key | Action |
|-----|--------|
| `<S-l>` | Next buffer |
| `<S-h>` | Previous buffer |

### Harpoon (per-project file bookmarks)

| Key | Action |
|-----|--------|
| `<Leader>ha` | Add current file to the harpoon list |
| `<Leader>hh` | Open/close the harpoon list (editable) |
| `<C-1>` | Jump to harpoon file 1 |
| `<C-2>` | Jump to harpoon file 2 |
| `<C-3>` | Jump to harpoon file 3 |
| `<C-4>` | Jump to harpoon file 4 |

The list is persisted per directory alongside the session.

### Telescope

| Key | Action |
|-----|--------|
| `<Leader>ff` | Find files |
| `<Leader>fg` | Live grep |
| `<Leader>fb` | List open buffers |
| `<Leader>fh` | Search help tags |
| `<Leader>fp` | Browse profiles (activate with `<CR>`) |
| `<Leader>ft` | Browse all TODO/FIXME/HACK/NOTE in the project |
| `<Leader>?` | Browse all keymaps (live search) |

### Trouble (diagnostics)

| Key | Action |
|-----|--------|
| `<Leader>dx` | Workspace diagnostics |
| `<Leader>dw` | Workspace diagnostics (alias) |
| `<Leader>dd` | Buffer diagnostics |
| `<Leader>dl` | Location list |
| `<Leader>dq` | Quickfix list |
| `gR` | LSP references |

### LSP (active when a language server is attached)

| Key | Action |
|-----|--------|
| `gD` | Go to declaration |
| `gd` | Go to definition |
| `K` | Hover documentation |
| `gi` | Go to implementation |
| `<C-h>` | Signature help |
| `gr` | References |
| `<space>D` | Type definition |
| `<space>rn` | Rename symbol |
| `<space>ca` | Code action |
| `<space>f` | Format buffer (async) |
| `<space>wa` | Add workspace folder |
| `<space>wr` | Remove workspace folder |
| `<space>wl` | List workspace folders |

### Cheatsheets

| Key | Action |
|-----|--------|
| `<Leader>hc` | Open cheatsheet topic picker |

`:Cheat` with no argument opens a `vim.ui.select` picker. With a topic argument (tab-completion available) it opens directly.

Available topics: `editing`, `git`, `lsp`, `plugins`, `profiles`

### Git (gitsigns — buffer-local, active in git repos)

| Key | Action |
|-----|--------|
| `]h` / `[h` | Next / previous hunk |
| `<Leader>gp` | Preview hunk |
| `<Leader>gs` | Stage hunk |
| `<Leader>gr` | Reset hunk |
| `<Leader>gb` | Blame line |
| `<Leader>gd` | Diff this file |

### Git (lazygit)

| Key | Action |
|-----|--------|
| `<Leader>gg` | Open lazygit (floating terminal) |

Requires `lazygit` installed on the system (`apt install lazygit` or equivalent).

### Git (diffview)

| Key | Action |
|-----|--------|
| `<Leader>gv` | Open diff view for the current repo |
| `<Leader>gH` | Open file history for the current file |

`:DiffviewClose` or `q` to close. Full diff and file history across all commits.

### AI Assistant (Avante)

| Key | Action |
|-----|--------|
| `<Leader>aa` | Ask AI (open sidebar with prompt) |
| `<Leader>ae` | Edit selection with AI (visual mode) |
| `<Leader>at` | Toggle AI sidebar |
| `<Leader>af` | Focus AI sidebar |
| `<Leader>ar` | Refresh AI response |

Authenticates via Claude Pro subscription (`auth_type = "pro"`, browser OAuth).
Run `:AvanteSwitchProvider claude` if a different provider was previously active.

### Debug (nvim-dap)

| Key | Action |
|-----|--------|
| `<Leader>Dc` | Continue / start session |
| `<Leader>Di` | Step into |
| `<Leader>Do` | Step over |
| `<Leader>DO` | Step out |
| `<Leader>Db` | Toggle breakpoint |
| `<Leader>DB` | Set conditional breakpoint |
| `<Leader>Dr` | Open REPL |
| `<Leader>Dl` | Run last configuration |
| `<Leader>Du` | Toggle DAP UI |
| `<Leader>Dt` | Terminate session |

Adapters are profile-driven. Required Mason packages per profile:
- **web** — `:MasonInstall js-debug-adapter` (JS/TS via pwa-node)
- **php / laravel** — `:MasonInstall php-debug-adapter` (Xdebug, port 9003)
- **rust** — `:MasonInstall codelldb`
- **core** — Lua adapter built-in (`one-small-step-for-vimkind`, no install needed)

### Testing (neotest)

| Key | Action |
|-----|--------|
| `<Leader>Tr` | Run nearest test |
| `<Leader>Tf` | Run test file |
| `<Leader>Ts` | Toggle test summary panel |
| `<Leader>To` | Toggle output panel |

Active in `.bats` files (neotest-bash adapter). Other adapters (jest, phpunit, cargo test) planned as profile-driven additions.

### Toggle / Terminal

| Key | Action |
|-----|--------|
| `<Leader>tn` | Cycle line numbers (absolute → relative → none) |
| `<Leader>tz` | Toggle Zen mode (distraction-free fullscreen) |
| `<C-\>` | Toggle floating terminal |
| `<Leader>tt` | Toggle terminal |
| `<Leader>tC` | Toggle Claude Code session (persistent) |
| `<Leader>tX` | Toggle Codex CLI session (persistent) |
| `<Leader>tG` | Toggle Gemini CLI session (persistent) |

Use `<C-\><C-n>` or `<C-s>` to exit terminal mode and return to normal mode.

### Session

| Key | Action |
|-----|--------|
| `<Leader>qs` | Restore session for the current directory |
| `<Leader>qd` | Stop session persistence (next quit will not save) |

Session is saved automatically per directory on exit and restored on startup when Neovim is opened with no file arguments.

### Search / Replace (Spectre)

| Key | Action |
|-----|--------|
| `<Leader>sr` | Open Spectre (project-wide search/replace) |
| `<Leader>sw` | Search word under cursor across project |

Inside Spectre: `<CR>` to confirm replace, `dd` to exclude a match.

### Editing utilities

| Key | Action |
|-----|--------|
| `<Leader><CR>` | Clear search highlight |
| `<Leader>pp` | Toggle paste mode (fallback for terminals without bracketed paste) |
| `<Leader>cd` | Change working directory to the current file's directory |
| `:w!!` | Write current file with sudo (for system files opened without root) |

### Spell checking

| Key | Action |
|-----|--------|
| `<Leader>ss` | Toggle spell checking for the current buffer |
| `<Leader>sn` | Next spelling error |
| `<Leader>sp` | Previous spelling error |
| `<Leader>sa` | Add word under cursor to dictionary |
| `<Leader>s?` | Suggest corrections for word under cursor |

### nvim-cmp (completion)

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Next / previous suggestion |
| `<Tab>` / `<S-Tab>` | Next / previous suggestion or expand snippet |
| `<CR>` | Confirm selection |
| `<C-Space>` | Trigger completion |
| `<C-e>` | Abort completion |
| `<C-d>` / `<C-f>` | Scroll docs up / down |
