require("tokyonight").setup({
  style = "night",
  transparent = false,
  styles = {
    comments = { italic = true },
    keywords = { italic = false },
  },
})
vim.cmd.colorscheme("tokyonight-night")
