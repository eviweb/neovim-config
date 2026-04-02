# Git — Quick Reference

## Hunk navigation
| Key   | Action            |
|-------|-------------------|
| `]h`  | Next hunk         |
| `[h`  | Previous hunk     |

## Hunk actions
| Key           | Action                              |
|---------------|-------------------------------------|
| `<Leader>gp`  | Preview hunk (inline diff)          |
| `<Leader>gs`  | Stage hunk                          |
| `<Leader>gr`  | Reset hunk                          |
| `<Leader>gb`  | Blame line (full commit message)    |
| `<Leader>gd`  | Diff this file against HEAD         |

All `<Leader>g` mappings are buffer-local — only active inside a git repository.

## Gutter signs
| Sign | Meaning            |
|------|--------------------|
| `│`  | Added / changed    |
| `_`  | Deleted            |
| `‾`  | Top of deleted     |
| `~`  | Changed + deleted  |
| `┆`  | Untracked          |
