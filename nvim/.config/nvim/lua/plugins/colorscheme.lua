return {
  -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
  'ayu-theme/ayu-vim',
  priority = 1000,
  init = function()
    -- vim.g.sonokai_style = 'andromeda'

    vim.cmd.colorscheme 'ayu'
  end,
}
