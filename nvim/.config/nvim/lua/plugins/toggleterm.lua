return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      {
        "<leader>bt",
        "<cmd>ToggleTerm size=20 direction=horizontal dir=git_dir<cr>",
        desc = "Open horizontal terminal at bottom",
      },
      {
        "<leader>bv",
        "<cmd>ToggleTerm size=80 direction=vertical dir=git_dir<cr>",
        desc = "Open vertical terminal on right",
      },
    },
    config = true,
  },
}
