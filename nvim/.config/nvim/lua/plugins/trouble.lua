return {
  'folke/trouble.nvim',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    -- your configuration comes here
    -- or leave it empty to use the default settings
    -- refer to the configuration section below
  },
  keys = {
    {
      '<leader>tt',
      function()
        require('trouble').toggle()
      end,
      desc = '[T]oggle',
    },
    {
      '<leader>tw',
      function()
        require('trouble').toggle 'workspace_diagnostics'
      end,
      desc = '[W]orkspace diagnostics',
    },
    {
      '<leader>td',
      function()
        require('trouble').toggle 'document_diagnostics'
      end,
      desc = '[D]ocument diagnostics',
    },
    {
      '<leader>tq',
      function()
        require('trouble').toggle 'quickfix'
      end,
      desc = '[Q]uickfix list',
    },
    {
      '<leader>tl',
      function()
        require('trouble').toggle 'loclist'
      end,
      desc = '[L]ocation list',
    },
    {
      '<leader>gR',
      function()
        require('trouble').toggle 'lsp_references'
      end,
      desc = '[R]eferences',
    },
  },
}
