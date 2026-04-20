# Plugins — Quick Reference

## Telescope (classic variant)
| Key           | Action                              |
|---------------|-------------------------------------|
| `<Leader>ff`  | Find files                          |
| `<Leader>fg`  | Live grep                           |
| `<Leader>fb`  | Open buffers                        |
| `<Leader>fh`  | Help tags                           |
| `<Leader>?`   | Browse all keymaps                  |

Inside a picker: `<CR>` open · `<C-v>` vsplit · `<C-x>` split · `<C-t>` → Trouble · `<Esc>` close

## Snacks picker (modern variant)
Run `Snacks.picker.files()`, `Snacks.picker.grep()`, etc.
See `:h snacks.picker` for the full source list.

## Neo-tree (file explorer)
| Key           | Action                    |
|---------------|---------------------------|
| `<Leader>n`   | Toggle file explorer      |

Inside neo-tree: `a` new · `d` delete · `r` rename · `y` copy · `x` cut · `p` paste · `<CR>` open

## Oil.nvim (directory editor)
| Key           | Action                              |
|---------------|-------------------------------------|
| `-`           | Open parent directory as a buffer   |
| `q`           | Close oil buffer                    |
| `?`           | Show help                           |

Rename, move, or delete files by editing the buffer normally, then `:w` to apply. Hidden files are visible by default.

## Noice.nvim (UI)
| Command           | Action                          |
|-------------------|---------------------------------|
| `:Noice`          | Browse message history          |
| `:Noice dismiss`  | Clear all active notifications  |

Replaces the cmdline with a centered floating popup. Messages (echoes, warnings) appear as popups. LSP progress shown in the top-right corner.

## Bufferline
| Key     | Action              |
|---------|---------------------|
| `<S-l>` | Next buffer         |
| `<S-h>` | Previous buffer     |

## Trouble (diagnostics panel)
| Key           | Action                        |
|---------------|-------------------------------|
| `<Leader>dx`  | Workspace diagnostics         |
| `<Leader>dd`  | Buffer diagnostics            |
| `<Leader>dl`  | Location list                 |
| `<Leader>dq`  | Quickfix list                 |
| `gR`          | LSP references                |

Inside Trouble: `<CR>` jump · `o` preview · `q` close · `r` refresh
