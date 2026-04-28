-- Vim options
local opt = vim.opt

opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2
opt.smartindent = true

opt.ignorecase = true
opt.smartcase = true
opt.incsearch = true
opt.hlsearch = true

opt.splitright = true
opt.splitbelow = true

opt.termguicolors = true
opt.background = "dark"
opt.mouse = "a"
opt.clipboard = "unnamedplus"

opt.undofile = true
opt.swapfile = false
opt.backup = false

opt.updatetime = 250
opt.timeoutlen = 400

-- Native completion menu behavior (used by vim.lsp.completion)
opt.completeopt = { "menu", "menuone", "noselect", "fuzzy" }
opt.pumheight = 12

opt.wrap = false
opt.breakindent = true
opt.linebreak = true

opt.list = true
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

opt.confirm = true
