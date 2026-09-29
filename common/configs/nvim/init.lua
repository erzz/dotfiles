-- Neovim config — native vim.pack, no framework. Requires Neovim 0.12+.
-- Layout:
--   init.lua          this file (entrypoint)
--   lua/options.lua   vim options
--   lua/keymaps.lua   global keymaps
--   lua/autocmds.lua  autocommands (yank highlight, lint, LSP completion)
--   lua/plugins.lua   vim.pack.add({...}) plugin spec
--   lua/lsp.lua       vim.lsp.config / vim.lsp.enable per server
--   lua/plugin-config/*.lua  per-plugin setup

-- Suppress OSC 11 background query before TUI init (prevents response leaking
-- into shell when exiting nvim quickly through tmux).
vim.g.terminal_color_background = "#242424"

vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("options")
require("plugins") -- must run before any plugin require below
require("keymaps")
require("autocmds")

-- Omarchy supplies the desktop theme and remote clipboard behavior. Keep the
-- shared editor config authoritative while consuming those user-facing hooks.
if vim.fn.isdirectory("/usr/share/omarchy") == 1 then
  require("omarchy-remote-clipboard").setup()
end

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
require("plugin-config.which-key")

require("lsp")

if vim.fn.isdirectory("/usr/share/omarchy") == 1 then
  require("omarchy-theme").setup()
end
