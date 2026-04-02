# LSP & Completion — Quick Reference

## Navigation (when a server is attached)
| Key          | Action                        |
|--------------|-------------------------------|
| `gd`         | Go to definition              |
| `gD`         | Go to declaration             |
| `gi`         | Go to implementation          |
| `gr`         | List references               |
| `<space>D`   | Go to type definition         |
| `K`          | Hover documentation           |
| `<C-h>`      | Signature help (insert mode)  |

## Code actions
| Key           | Action                              |
|---------------|-------------------------------------|
| `<space>rn`   | Rename symbol (project-wide)        |
| `<space>ca`   | Code action (fix / refactor)        |
| `<space>f`    | Format buffer                       |

## Diagnostics inline
| Key   | Action                    |
|-------|---------------------------|
| `]d`  | Next diagnostic           |
| `[d`  | Previous diagnostic       |

Run `:lua vim.diagnostic.open_float()` to open the diagnostic float.

## Diagnostics panel (Trouble)
| Key           | Action                        |
|---------------|-------------------------------|
| `<Leader>dx`  | Workspace diagnostics         |
| `<Leader>dd`  | Buffer diagnostics            |
| `<Leader>dl`  | Location list                 |
| `<Leader>dq`  | Quickfix list                 |
| `gR`          | LSP references (Trouble)      |

## Completion (nvim-cmp)
| Key              | Action                                  |
|------------------|-----------------------------------------|
| `<C-n>` / `<C-p>`| Next / previous suggestion              |
| `<Tab>` / `<S-Tab>`| Next / previous, or expand snippet    |
| `<CR>`           | Confirm selection                       |
| `<C-Space>`      | Trigger completion manually             |
| `<C-e>`          | Dismiss menu                            |
| `<C-d>` / `<C-f>`| Scroll docs up / down                  |

## Server management
- `:Mason` — open server manager
- `:LspInfo` — active servers for the current buffer
- `:LspRestart` — restart all servers for the current buffer
