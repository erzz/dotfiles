-- snacks.nvim: enable picker only (other modules deliberately off)
require("snacks").setup({
  bigfile = { enabled = true },
  quickfile = { enabled = true },
  picker = {
    hidden = true,
    sources = {
      files = { hidden = true },
      grep = { hidden = true },
      explorer = { hidden = true },
    },
  },
})
