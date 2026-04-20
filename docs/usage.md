# Usage Guide

Practical workflows for the main features of this configuration.
For the full keymap reference, see [keymaps.md](keymaps.md).

---

## LSP

Language servers are managed by **Mason** and configured via `lua/config/lsp.lua`.
Two servers are pre-configured and installed automatically: `jsonls` (JSON) and
`lua_ls` (Lua). Additional servers can be installed interactively via `:Mason`.

### First-time setup

After the first Neovim startup (lazy.nvim installs all plugins):

1. Run `:Mason` to open the server manager
2. Press `i` on a server entry to install it
3. Restart Neovim — the server attaches automatically on the next file open

The status bar (lualine) shows the active LSP server name when a server is attached.

### Navigation

| Key | Action |
|-----|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | List references |
| `<space>D` | Go to type definition |
| `K` | Hover documentation (floating window) |
| `<C-h>` | Signature help |

### Code actions

| Key | Action |
|-----|--------|
| `<space>rn` | Rename symbol (renames across the project) |
| `<space>ca` | Code action (fix, refactor, import, etc.) |
| `<space>f` | Format buffer asynchronously |

### Diagnostics inline

Diagnostic signs appear in the gutter (`E` error, `W` warning, `H` hint, `I` info).
Virtual text is disabled — open the float with:

```vim
:lua vim.diagnostic.open_float()
```

Navigate between diagnostics:

| Key | Action |
|-----|--------|
| `]d` | Next diagnostic |
| `[d` | Previous diagnostic |

> For a full workspace or buffer diagnostics view, see the [Diagnostics](#diagnostics) section.

---

## Completion

Completion is handled by **nvim-cmp** with three sources active by default:

| Source | Label | Description |
|--------|-------|-------------|
| `nvim_lsp` | `[Lsp]` | Symbols from the active language server |
| `luasnip` | `[Snip]` | Snippet expansions |
| `nvim_lua` | `[Lua]` | Neovim Lua API (Lua files only) |
| `path` | — | Filesystem paths |
| `buffer` | `[Buf]` | Words from open buffers (fallback) |

Completion also works in the command line: `/` uses buffer words, `:` uses
path and cmdline sources.

### Basic workflow

Completion triggers automatically as you type. The source label on the right of
each entry indicates where it comes from.

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Select next / previous entry |
| `<Tab>` / `<S-Tab>` | Select next / previous, or expand / jump snippet |
| `<CR>` | Confirm selection (replaces the word under cursor) |
| `<C-Space>` | Force-trigger completion manually |
| `<C-e>` | Dismiss the menu |
| `<C-d>` / `<C-f>` | Scroll the documentation preview up / down |

> `<CR>` only confirms an **explicitly selected** entry — it will not accidentally
> confirm if nothing is highlighted.

### Ghost text

A ghost-text preview of the top suggestion is shown inline as you type
(configured via `experimental.ghost_text = true`). It disappears when the menu
is closed or aborted.

### Snippets

Snippets come from **LuaSnip**. When a snippet is expanded, `<Tab>` / `<S-Tab>`
jump between its placeholders. Snippet sources include VSCode-style snippet files
loaded by LuaSnip's friendly-snippets integration.

---

## Diagnostics

Diagnostics are displayed in two ways:

- **Inline** — gutter signs and floating window per line (see [LSP](#lsp) above)
- **Panel** — **Trouble** lists all diagnostics in a dedicated window

### Trouble panel

| Key | Action |
|-----|--------|
| `<Leader>dx` | Workspace diagnostics (all files) |
| `<Leader>dw` | Workspace diagnostics (alias) |
| `<Leader>dd` | Buffer diagnostics (current file only) |
| `<Leader>dl` | Location list |
| `<Leader>dq` | Quickfix list |
| `gR` | LSP references for the symbol under cursor |

Inside the Trouble panel:

| Key | Action |
|-----|--------|
| `<CR>` | Jump to the item |
| `o` | Open the item without closing Trouble |
| `q` | Close the panel |
| `r` | Refresh |

### Sending Telescope results to Trouble

From any Telescope picker, press `<C-t>` to send the results to Trouble instead
of the quickfix list. This is useful for searching references or grep results and
reviewing them in the diagnostics panel layout.

---

## Telescope

Telescope is the fuzzy finder for files, text, buffers, help, and more.
The fzf-native extension is loaded for faster sorting.

### Core pickers

| Key | Action |
|-----|--------|
| `<Leader>ff` | Find files (respects `.gitignore`) |
| `<Leader>fg` | Live grep — search text across the project |
| `<Leader>fb` | List open buffers |
| `<Leader>fh` | Search help tags |
| `<Leader>?` | Browse all keymaps (live search) |

### Inside a picker

| Key | Action |
|-----|--------|
| `<C-n>` / `<C-p>` | Move down / up in results |
| `<CR>` | Open selected entry |
| `<C-x>` | Open in horizontal split |
| `<C-v>` | Open in vertical split |
| `<C-t>` | Send to Trouble panel |
| `<C-h>` | Show all available mappings (which-key popup) |
| `<Esc>` | Close the picker |

### Live grep tips

- Search is literal by default — escape regex characters if needed
- The query searches file contents; use `<Leader>ff` for filename search
- Press `<C-t>` to send all matches to Trouble for easier navigation

### node_modules picker

The `telescope-node_modules` extension is loaded if present. Access it with:

```vim
:Telescope node_modules list
```

---

## Profiles

Project profiles enable per-project tooling. Only the LSP servers, null-ls
sources, and plugins relevant to the detected or configured profile are loaded.

Available profiles: `web`, `php`, `laravel`, `rust`.

### Activating a profile

Profiles are detected automatically at startup from marker files (`package.json`,
`composer.json`, `Cargo.toml`). To pin a profile for a project:

```bash
./bin/nvim-config profile set web
```

This writes `.nvim-profile` at the current directory root.

### Runtime switching

Switch the active profile without restarting Neovim:

```vim
:NvimProfile web
```

Or use the Telescope picker with `<Leader>fp` — active profiles are marked with ●,
inactive with ○. Press `<CR>` to activate the selected profile. LSP servers and
null-ls sources update immediately; plugin changes take effect after a restart.

---

## Bufferline

Open files are shown as tabs in the bufferline at the top of the screen.
The neo-tree file explorer offsets the bufferline so it does not overlap
when the panel is open.

### Navigation

| Key | Action |
|-----|--------|
| `<S-l>` | Go to the next buffer |
| `<S-h>` | Go to the previous buffer |

### Closing buffers

```vim
:bd          " close current buffer
:bd!         " close without saving
```

Or use the bufferline right-click context menu if your terminal supports mouse input.

### Picking a buffer

```vim
:Telescope buffers
```

Or use `<Leader>fb` — the fuzzy picker is faster than cycling when many buffers are open.

---

## Oil.nvim (filesystem editing)

oil.nvim lets you edit the filesystem as a regular buffer — rename, move, and
delete files using normal Neovim motions, then save to apply.

### Opening

Press `-` in any buffer to open the parent directory as an oil buffer.

### Editing files and directories

| Action | How |
|--------|-----|
| Rename a file | Edit the filename on the line, then `:w` |
| Move a file | Cut the line (`dd`) and paste it in another oil buffer |
| Delete a file | Delete the line (`dd`), then `:w` to confirm |
| Create a file | Add a new line with the filename, then `:w` |

Hidden files (dotfiles) are visible by default.

### Keymaps inside an oil buffer

| Key | Action |
|-----|--------|
| `-` | Go up to the parent directory |
| `<CR>` | Open the file or directory under the cursor |
| `q` | Close the oil buffer |
| `?` | Show all available oil keymaps |

oil.nvim complements neo-tree: use neo-tree (`<Leader>n`) for the persistent
sidebar tree view, and oil for quick bulk filesystem operations.

---

## Noice.nvim (UI)

noice.nvim replaces three built-in Neovim UI elements:

- **Cmdline** — `:`, `/`, `?` open a centered floating popup instead of the bottom bar
- **Messages** — echoed messages, warnings, and errors appear as dismissible popups
- **LSP progress** — language server loading indicator shown in the top-right corner

No special keymaps are required — the behaviour is automatic. To inspect or
clear accumulated messages:

```vim
:Noice           " browse full message history
:Noice dismiss   " clear all active notifications
```

In the **modern** variant (snacks.nvim active), `vim.notify` is owned by snacks —
noice handles cmdline and messages only, without creating duplicate notifications.

---

## Git

### Inline hunks (gitsigns)

Gitsigns shows added/changed/deleted lines in the sign column and provides
hunk-level operations. Active automatically in any git-tracked buffer.

| Key | Action |
|-----|--------|
| `]h` / `[h` | Jump to next / previous hunk |
| `<Leader>gp` | Preview hunk inline |
| `<Leader>gs` | Stage hunk |
| `<Leader>gr` | Reset hunk to HEAD |
| `<Leader>gb` | Full blame for the current line |
| `<Leader>gd` | Diff current file against HEAD |

### Lazygit

| Key | Action |
|-----|--------|
| `<Leader>gg` | Open lazygit in a floating terminal |

Requires `lazygit` on the system (`apt install lazygit` or equivalent).
All git operations (stage, commit, push, rebase, stash…) are available from within the UI.

### Diffview

| Key | Action |
|-----|--------|
| `<Leader>gv` | Open full diff view for the current repo |
| `<Leader>gH` | Open commit history for the current file |

Close with `:DiffviewClose` or `q`. Use `<Tab>` / `<S-Tab>` to cycle between
changed files in the panel.

---

## Harpoon (per-project bookmarks)

Harpoon keeps a short per-project list of files for instant jumping.

| Key | Action |
|-----|--------|
| `<Leader>ha` | Add current file to the list |
| `<Leader>hh` | Open the list (edit order, remove entries) |
| `<C-1>` … `<C-4>` | Jump directly to file 1–4 |

The list is stored per directory and persists across sessions. Inside the
quick menu: edit filenames to reorder, `dd` to remove, `:w` to save.

---

## Search and replace (Spectre)

Spectre provides project-wide regex search and replace with a preview buffer.

| Key | Action |
|-----|--------|
| `<Leader>sr` | Open Spectre |
| `<Leader>sw` | Open Spectre pre-filled with the word under cursor |

Inside Spectre:

| Key | Action |
|-----|--------|
| `<CR>` | Confirm and apply the replace for the current match |
| `dd` | Exclude the current match from the replace |
| `R` | Replace all remaining matches |

---

## Session (persistence.nvim)

Sessions are saved automatically per directory when Neovim exits and
restored automatically when Neovim is opened with no file arguments.

| Key | Action |
|-----|--------|
| `<Leader>qs` | Restore the session for the current directory manually |
| `<Leader>qd` | Stop session persistence (next quit will not save) |

---

## Testing (neotest)

neotest runs tests inside Neovim and shows results inline and in panels.

| Key | Action |
|-----|--------|
| `<Leader>Tr` | Run the test nearest to the cursor |
| `<Leader>Tf` | Run all tests in the current file |
| `<Leader>Ts` | Toggle the test summary panel |
| `<Leader>To` | Toggle the output panel |

Active adapters:
- **neotest-bash** — `.bats` files (always active)
- **neotest-vitest** — loaded by the `web` profile when `node_modules/.bin/vitest` is present
- **neotest-phpunit** — loaded by the `php` and `laravel` profiles
- **neotest-rust** — loaded by the `rust` profile

Pass/fail icons appear in the sign column after a run. Navigate with `]t` / `[t`
(if configured) or use the summary panel to jump.

---

## Debugging (nvim-dap)

nvim-dap provides an interactive debugger. The UI (dap-ui) opens automatically
when a session starts and closes when it ends.

### Session control

| Key | Action |
|-----|--------|
| `<Leader>Dc` | Start or continue the session |
| `<Leader>Di` | Step into |
| `<Leader>Do` | Step over |
| `<Leader>DO` | Step out |
| `<Leader>Dt` | Terminate the session |

### Breakpoints

| Key | Action |
|-----|--------|
| `<Leader>Db` | Toggle breakpoint on the current line |
| `<Leader>DB` | Set a conditional breakpoint (prompts for expression) |

### UI and REPL

| Key | Action |
|-----|--------|
| `<Leader>Du` | Toggle the DAP UI manually |
| `<Leader>Dr` | Open the REPL |
| `<Leader>Dl` | Re-run the last debug configuration |

Inline variable values are shown via **nvim-dap-virtual-text** during a session.

Active adapters per profile:
- **web** — `pwa-node` (JS/TS) via Mason `js-debug-adapter`
- **php / laravel** — Xdebug on port 9003 via Mason `php-debug-adapter`
- **rust** — codelldb via Mason `codelldb`
- **core** — Lua adapter built-in (`one-small-step-for-vimkind`)

Run `nvim-config update dap-adapters` to install the Mason packages for the
active profile, or open `:Mason` and install them manually.

---

## AI tools

### Avante (AI assistant)

Avante provides a Cursor-like sidebar for code chat and inline edits.
Authentication uses `auth_type = "max"` (covers both Pro and Max plans, browser OAuth, no API key needed).

| Key | Action |
|-----|--------|
| `<Leader>aa` | Open the sidebar and ask a question |
| `<Leader>ae` | Edit the current selection with AI (visual mode) |
| `<Leader>at` | Toggle the sidebar |
| `<Leader>af` | Focus the sidebar |
| `<Leader>ar` | Refresh the last response |

On first use, `:AvanteSwitchProvider claude` may be needed if another provider
was previously active. The auth flow opens a browser window.

### Codeium (inline completion)

Codeium provides free inline AI completion as a `[AI]` source in nvim-cmp.
Activate once with `:Codeium Auth` (opens a browser for the token).
Completions then appear automatically alongside LSP suggestions.

### Terminal AI agents

Each tool opens in a persistent floating terminal — toggling the keymap
re-opens the same session.

| Key | Tool |
|-----|------|
| `<Leader>tC` | Claude Code CLI |
| `<Leader>tX` | OpenAI Codex CLI |
| `<Leader>tG` | Google Gemini CLI |

Install any missing tool with `nvim-config install claude|codex|gemini`
(requires Node.js / npm).

---

## Zen mode

| Key | Action |
|-----|--------|
| `<Leader>tz` | Toggle distraction-free fullscreen |

Zen mode hides the statusline, tabline, line numbers, and side panels.
Press `<Leader>tz` again or `:ZenMode` to exit.

---

## TODO comments

todo-comments.nvim highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `WARN`, and
`PERF` tags in any file with distinctive colours.

| Key / Command | Action |
|---------------|--------|
| `<Leader>ft` | List all tagged comments in the project via Telescope |
| `]t` / `[t` | Jump to next / previous tagged comment |

Tags are case-insensitive and recognised in any comment syntax.
