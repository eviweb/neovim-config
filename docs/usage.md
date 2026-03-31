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
