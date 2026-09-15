# Vim/Neovim Basics — Quick Reference

Foundational Vim/Neovim knowledge — not specific to this configuration.
For this config's own custom bindings, see [editing.md](editing.md),
[git.md](git.md), [lsp.md](lsp.md), [plugins.md](plugins.md), and
[profiles.md](profiles.md).

## Modes

Neovim is a modal editor.

| Mode | Purpose | Enter with |
|------|---------|------------|
| Normal | Navigate, delete, copy, paste (default mode) | `<Esc>` from any other mode |
| Insert | Type text | `i`, `a`, `o`, `O`, `I`, `A` |
| Visual | Select text | `v` (char), `V` (line), `<C-v>` (block) |
| Command-line | Run `:`-prefixed commands | `:` |

## The Leader key

`<Leader>` is a prefix for user-defined shortcuts, letting config/plugins
define shortcuts without colliding with built-in ones. **This config sets it
to `Space`** (`lua/keymaps.lua`). Every `<Leader>...` binding in the other
cheatsheets means "press Space, then...".

## Cursor movement

| Key | Action |
|-----|--------|
| `h` `j` `k` `l` | Left, down, up, right |
| `w` / `W` | Next word / WORD start |
| `b` / `B` | Previous word / WORD start |
| `e` / `E` | End of word / WORD |
| `0` | Start of line |
| `^` | First non-blank character of line |
| `$` | End of line |
| `gg` / `G` | Top / bottom of file |
| `{line}G` | Go to line number, e.g. `10G` |
| `<C-d>` / `<C-u>` | Half-page down / up |
| `<C-f>` / `<C-b>` | Full page down / up |
| `zz` | Center current line on screen |
| `H` / `M` / `L` | Top / middle / bottom of visible screen |

## Basic editing

| Key | Action |
|-----|--------|
| `i` / `a` | Insert before / after cursor |
| `I` / `A` | Insert at start / end of line |
| `o` / `O` | Open new line below / above |
| `dd` | Delete current line |
| `dw` | Delete word |
| `d$` / `D` | Delete to end of line |
| `cc` | Change current line |
| `cw` | Change word |
| `x` | Delete character under cursor |
| `yy` / `Y` | Yank (copy) current line |
| `yw` | Yank word |
| `p` / `P` | Paste after / before cursor |
| `u` | Undo |
| `<C-r>` | Redo |
| `.` | Repeat last change |
| `>>` / `<<` | Indent / un-indent line |

> This config also maps `YY` / `XX` / `PP` for explicit **system clipboard**
> copy / cut / paste — see [editing.md](editing.md).

## Windows and tabs

| Key / Command | Action |
|---------------|--------|
| `:sp [file]` | Horizontal split |
| `:vsp [file]` | Vertical split |
| `<C-w>s` / `<C-w>v` | Split current window horizontally / vertically |
| `<C-w>h/j/k/l` | Move to window left / below / above / right |
| `<C-w>w` | Cycle through windows |
| `<C-w>c` | Close current window |
| `<C-w>o` | Close all windows but the current one |
| `:tabe [file]` | Open a new tab |
| `gt` / `gT` | Next / previous tab |

> This config shortcuts window navigation to `<C-h/j/k/l>` directly, no
> `<C-w>` prefix needed — see [editing.md](editing.md).

## Command-line mode

| Command | Action |
|---------|--------|
| `:w` | Save |
| `:w {file}` | Save as |
| `:q` / `:q!` | Quit / force quit without saving |
| `:wq` / `:x` | Save and quit |
| `:e {file}` | Open a file |
| `:%s/{old}/{new}/g` | Replace all occurrences in the file |
| `:%s/{old}/{new}/gc` | Replace with confirmation per match |
| `:noh` | Clear search highlight |
| `:help {topic}` | Open help, e.g. `:help key-notation` |

> This config also maps `<Leader><CR>` to clear search highlight — see
> [editing.md](editing.md).
