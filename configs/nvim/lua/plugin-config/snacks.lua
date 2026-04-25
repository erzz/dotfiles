-- snacks.nvim: enable picker + lazygit (other modules deliberately off)
require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  lazygit = {
    -- Inherits colorscheme via Snacks; no extra theme file needed
    configure = true,
  },
  picker = {
    hidden = true,
    sources = {
      files = { hidden = true },
      grep = { hidden = true },
      explorer = { hidden = true },
    },
  },
})
