return {
  'folke/which-key.nvim',
  event = 'VimEnter', -- Sets the loading event to 'VimEnter'
  config = function() -- This is the function that runs, AFTER loading
    require('which-key').setup()

    -- Document existing key chains
    require('which-key').register {
      ['<leader>c'] = { name = '[C]ode', _ = 'which_key_ignore' },
      ['<leader>e'] = { name = '[E]xplorer', _ = 'which_key_ignore' },
      ['<leader>f'] = { name = '[F]ind', _ = 'which_key_ignore' },
      ['<leader>g'] = { name = 'Lazy[G]it', _ = 'which_key_ignore' },
      ['<leader>m'] = { name = '[M]arkdown', _ = 'which_key_ignore' },
      ['<leader>q'] = { name = '[Q]uit', _ = 'which_key_ignore' },
      ['<leader>r'] = { name = '[R]ename', _ = 'which_key_ignore' },
      ['<leader>t'] = { name = '[T]rouble', _ = 'which_key_ignore' },
      ['<leader>v'] = { name = '[V]im', _ = 'which_key_ignore' },
    }
  end,
}
