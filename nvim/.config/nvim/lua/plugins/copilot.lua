return {
  'zbirenbaum/copilot.lua',
  lazy = false,
  cmd = 'Copilot',
  build = ':Copilot auth',
  opts = {
    suggestion = { enabled = false },
    panel = { enabled = false },
    filetypes = {
      markdown = true,
      help = true,
    },
  },
}
