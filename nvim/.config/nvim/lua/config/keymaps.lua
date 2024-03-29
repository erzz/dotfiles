local keymap = vim.keymap

-- Directory navigation
keymap.set("n", "<leader>m", ":NvimTreeFocus<CR>", {noremap = true, silent = true})
keymap.set("n", "<leader>f", ":NvimTreeToggle<CR>", {noremap = true, silent = true})

-- Pane navigation
keymap.set("n", "<C-h>", "<C-w>h", opts) --left
keymap.set("n", "<C-l>", "<C-w>l", opts) --right
keymap.set("n", "<C-j>", "<C-w>j", opts) --down
keymap.set("n", "<C-k>", "<C-w>k", opts) --up

-- Splits
keymap.set("n", "<leader>sv", ":vsplit<CR>", opts) -- split vertically
keymap.set("n", "<leader>sh", ":split<CR>", opts) -- split horizontally
keymap.set("n", "<leader>sm", ":MaximizerToggle<CR>", opts) -- toggle minimize

-- Indenting 
keymap.set("v", "<", "<gv")
keymap.set("v", ">", ">gv")

-- Comments
vim.api.nvim_set_keymap("n", "<C-_>", "gcc", {noremap = false})
vim.api.nvim_set_keymap("v", "<C-_>", "gcc", {noremap = false})
