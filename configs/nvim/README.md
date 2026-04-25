# Neovim

Lean Neovim 0.12 config using **native `vim.pack`** as the plugin manager — no LazyVim, no
framework.

## Highlights

- ~12 plugins, ~300 LOC of Lua you can fully read in one sitting
- Native completion via `vim.lsp.completion` (no nvim-cmp / blink.cmp)
- LSPs, formatters, linters installed via Homebrew (see top-level `brew/Brewfile`)
- Format-on-save via `conform.nvim`; lint via `nvim-lint`
- Snacks picker, mini.files explorer, gitsigns, lualine, tokyonight-night

## Layout

```
init.lua                       entrypoint
lua/options.lua                vim options
lua/keymaps.lua                global keymaps
lua/autocmds.lua               yank highlight, lint trigger, LSP attach (completion + keymaps)
lua/plugins.lua                vim.pack.add({...}) plugin spec
lua/lsp.lua                    vim.lsp.config / vim.lsp.enable per server
lua/plugin-config/             one small file per plugin
```

## Key bindings (leader = `<Space>`)

| Keys                                                      | Action                                            |
| --------------------------------------------------------- | ------------------------------------------------- |
| `<C-h/j/k/l>`, `<C-\>`                                    | tmux / window navigation                          |
| `<leader><space>` / `<leader>ff`                          | file picker                                       |
| `<leader>/` / `<leader>sg`                                | grep                                              |
| `<leader>sb` / `<leader>sh` / `<leader>sk` / `<leader>sd` | buffers / help / keymaps / diagnostics            |
| `<leader>e`                                               | file explorer (mini.files)                        |
| `<leader>cf`                                              | format buffer                                     |
| `gd` / `gr` / `gI` / `gy` / `K`                           | LSP definition / references / impl / type / hover |
| `<leader>rn` / `<leader>ca`                               | LSP rename / code action                          |
| `[d` / `]d` / `<leader>xd`                                | diagnostic prev / next / float                    |
| `[c` / `]c`                                               | git hunk prev / next                              |

## Installation

Handled by the dotfiles bootstrap:

```bash
make nvim   # stow config + fetch plugins + install treesitter parsers
```
