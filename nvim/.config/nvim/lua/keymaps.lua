-- Global keymaps. LSP keymaps are buffer-local; see autocmds.lua (LspAttach).
local map = vim.keymap.set

-- Clear search highlight
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Save / quit
map("n", "<leader>w", "<Cmd>write<CR>", { desc = "Save file" })
map("n", "<leader>q", "<Cmd>quit<CR>", { desc = "Quit" })
map("n", "<leader>Q", "<Cmd>qa!<CR>", { desc = "Force quit all" })

-- Buffers
map("n", "<S-h>", "<Cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<Cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Delete buffer" })

-- Better up/down for wrapped lines
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Keep selection on indent
map("v", "<", "<gv")
map("v", ">", ">gv")

-- Move selection up/down
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Tmux / window navigation (mirrors current dotfiles behavior)
map("n", "<C-h>", "<Cmd>NvimTmuxNavigateLeft<CR>", { silent = true, desc = "Nav left" })
map("n", "<C-j>", "<Cmd>NvimTmuxNavigateDown<CR>", { silent = true, desc = "Nav down" })
map("n", "<C-k>", "<Cmd>NvimTmuxNavigateUp<CR>", { silent = true, desc = "Nav up" })
map("n", "<C-l>", "<Cmd>NvimTmuxNavigateRight<CR>", { silent = true, desc = "Nav right" })
map("n", "<C-\\>", "<Cmd>NvimTmuxNavigateLastActive<CR>", { silent = true, desc = "Nav last active" })

-- Picker (Snacks)
map("n", "<leader><space>", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<leader>ff", function() Snacks.picker.files() end, { desc = "Find files" })
map("n", "<leader>/", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>sg", function() Snacks.picker.grep() end, { desc = "Grep" })
map("n", "<leader>sb", function() Snacks.picker.buffers() end, { desc = "Buffers" })
map("n", "<leader>sh", function() Snacks.picker.help() end, { desc = "Help tags" })
map("n", "<leader>sk", function() Snacks.picker.keymaps() end, { desc = "Keymaps" })
map("n", "<leader>sd", function() Snacks.picker.diagnostics() end, { desc = "Diagnostics" })

-- File explorer (mini.files)
map("n", "<leader>e", function()
  local mf = require("mini.files")
  if not mf.close() then mf.open(vim.api.nvim_buf_get_name(0)) end
end, { desc = "File explorer" })

-- Format
map({ "n", "v" }, "<leader>cf", function()
  require("conform").format({ async = true, lsp_format = "fallback" })
end, { desc = "Format buffer" })

-- Diagnostics
map("n", "<leader>xd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Prev diagnostic" })
map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
