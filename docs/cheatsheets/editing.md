# Editing — Quick Reference

## Motions
| Key          | Action                                  |
|--------------|-----------------------------------------|
| `0`          | First non-blank character of line       |
| `$`          | End of line                             |
| `gg` / `G`   | Top / bottom of file                    |
| `{` / `}`    | Previous / next empty line (paragraph)  |
| `%`          | Jump to matching bracket                |
| `*` / `#`    | Search word under cursor fwd / bwd      |

## Visual search
| Key          | Action                                  |
|--------------|-----------------------------------------|
| `*`          | Search selection forward (literal)      |
| `#`          | Search selection backward (literal)     |

## Clipboard
| Key   | Action                        |
|-------|-------------------------------|
| `YY`  | Copy to system clipboard      |
| `XX`  | Cut to system clipboard       |
| `PP`  | Paste from system clipboard   |

## Line movement
| Key        | Action                              |
|------------|-------------------------------------|
| `<A-j/k>`  | Move current line / block down / up |
| `J` / `K`  | Move visual block down / up         |

## Windows
| Key             | Action                    |
|-----------------|---------------------------|
| `<C-h/j/k/l>`   | Navigate windows          |
| `<C-Up/Down>`   | Resize height             |
| `<C-Left/Right>`| Resize width              |

## Utilities
| Key           | Action                                      |
|---------------|---------------------------------------------|
| `<Leader>pp`  | Toggle paste mode (SSH / no bracketed paste)|
| `<Leader>cd`  | Change CWD to current file's directory      |
| `<C-z>`       | Undo                                        |
| `jj`          | Exit insert mode                            |
| `<C-s>`       | Save file                                   |

## Spell checking
| Key           | Action                          |
|---------------|---------------------------------|
| `<Leader>ss`  | Toggle spell checking           |
| `<Leader>sn`  | Next spelling error             |
| `<Leader>sp`  | Previous spelling error         |
| `<Leader>sa`  | Add word to dictionary          |
| `<Leader>s?`  | Suggest corrections             |
