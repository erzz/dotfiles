local map = vim.keymap.set

-- *** NAVIGATION ***
-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-S-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-S-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-S-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-S-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- *** DIAGNOSTICS ***
-- Diagnostic keymaps
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
map('n', '<leader>ve', vim.diagnostic.open_float, { desc = '[V]im [E]rror messages' })
map('n', '<leader>vq', vim.diagnostic.setloclist, { desc = '[V]im diagnostic [Q]uickfix list' })

-- quit
map('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit NeoVim' })

-- exit terminal mode with an easier shortcut
map('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- alternative to esc for leaving insert mode
map('i', 'jj', '<Esc>')
