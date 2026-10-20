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

## Treesitter textobjects

Select (combine with an operator, e.g. `daf`, `vic`):

| Key         | Textobject              |
|-------------|--------------------------|
| `af` / `if` | Outer / inner function   |
| `ac` / `ic` | Outer / inner class      |

Move:

| Key         | Action                          |
|-------------|----------------------------------|
| `]m` / `[m` | Next / previous function start   |
| `]M` / `[M` | Next / previous function end     |
| `]]` / `[[` | Next / previous class start      |
| `][` / `[]` | Next / previous class end        |

Swap:

| Key  | Action                             |
|------|-------------------------------------|
| `]a` | Swap parameter with the next one     |
| `[a` | Swap parameter with the previous one |

`]a` / `[a` replace Neovim's own `:next` / `:previous` (argument list) mappings, which this config leaves unused.

## Commenting (native Neovim, no plugin)

| Key            | Action                                                   |
|----------------|-----------------------------------------------------------|
| `gcc`          | Toggle comment on the current line                         |
| `5gcc`         | Toggle comment on 5 lines, starting at the cursor          |
| `gc` (visual)  | Toggle comment on the selected lines (`V` then `gc`)       |
| `gc{motion}`   | Toggle comment over a motion: `gc2j` (2 lines down), `gcip` (paragraph), `gc}` (to next blank line) |
| `dgc`          | Delete the comment block under the cursor                  |

Comment style comes from the filetype's `commentstring` (`#` for ssh config and
bash, `//` for PHP — overridden in `lua/options.lua`, Neovim's own default is
`/* … */` — …), so it also works on filetypes without a treesitter parser.
Toggling is all-or-nothing: if every selected line is already commented they
are uncommented, otherwise all of them get commented. There is no block-comment
(`/* */`) toggle.

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

## Toggles
| Key           | Action                                      |
|---------------|---------------------------------------------|
| `<Leader>tn`  | Cycle line numbers (absolute → relative → none) |

## Utilities
| Key           | Action                                      |
|---------------|---------------------------------------------|
| `<Leader><CR>`| Clear search highlight                      |
| `<Leader>pp`  | Toggle paste mode (SSH / no bracketed paste)|
| `<Leader>cd`  | Change CWD to current file's directory      |
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
