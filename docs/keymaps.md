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
| `<A-j>` / `<A-k>` | Move current line down / up |
| `<C-z>` | Undo |

### File explorer

| Key | Action |
|-----|--------|
| `<Leader>n` | Toggle neo-tree file explorer |

## Insert mode

| Key | Action |
|-----|--------|
| `jj` | Exit to normal mode |
| `<C-s>` | Save file and return to insert mode |
| `<C-z>` | Undo |
| `<C-r>` | Redo |
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

### Telescope

| Key | Action |
|-----|--------|
| `<Leader>ff` | Find files |
| `<Leader>fg` | Live grep |
| `<Leader>fb` | List open buffers |
| `<Leader>fh` | Search help tags |
| `<Leader>fp` | Browse profiles (activate with `<CR>`) |
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
| `<Leader>hc` | Open cheatsheet (`:Cheat <tab>` for topic completion) |

Available topics: `editing`, `lsp`, `plugins`, `profiles`

### Editing utilities

| Key | Action |
|-----|--------|
| `<Leader>pp` | Toggle paste mode (fallback for terminals without bracketed paste) |
| `<Leader>cd` | Change working directory to the current file's directory |

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
