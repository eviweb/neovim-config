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

## Yazi (file manager with previews)
| Key / Command  | Action                                                  |
|----------------|---------------------------------------------------------|
| `<Leader>-`    | Open yazi at the current file (normal and visual mode)   |
| `:Yazi cwd`    | Open yazi in Neovim's working directory                   |
| `:Yazi toggle` | Resume the last yazi session                              |

Inside yazi: `<F1>` help · `<C-v>` / `<C-x>` / `<C-t>` open in a vsplit / split / tab · `<C-q>` send to the
quickfix list · `<C-s>` live grep in the directory (Telescope) · `<C-y>` copy the relative path · `<Tab>`
jump to the buffers open in Neovim.

Images, videos and PDFs are previewed, which neo-tree and oil do not do; it complements them, they keep
opening directories. **Only available when the `yazi` binary is on `PATH`**, checked once at startup: install
it (`mise use -g yazi@latest`, or see yazi-rs.github.io/docs/installation) and restart Neovim. `:checkhealth yazi`
reports a yazi that is too old. `nvim-config doctor` lists it.

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
