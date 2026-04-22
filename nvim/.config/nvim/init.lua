-- Neovim config — native vim.pack, no framework. Requires Neovim 0.12+.
-- Layout:
--   init.lua          this file (entrypoint)
--   lua/options.lua   vim options
--   lua/keymaps.lua   global keymaps
--   lua/autocmds.lua  autocommands (yank highlight, lint, LSP completion)
--   lua/plugins.lua   vim.pack.add({...}) plugin spec
--   lua/lsp.lua       vim.lsp.config / vim.lsp.enable per server
--   lua/plugin-config/*.lua  per-plugin setup

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("plugins") -- must run before any plugin require below
require("keymaps")
require("autocmds")

-- Plugin configs (order: visual first so colorscheme applies, then the rest)
require("plugin-config.tokyonight")
require("plugin-config.treesitter")
require("plugin-config.lualine")
require("plugin-config.gitsigns")
require("plugin-config.snacks")
require("plugin-config.mini-files")
require("plugin-config.tmux-nav")
require("plugin-config.conform")
require("plugin-config.lint")

require("lsp")
