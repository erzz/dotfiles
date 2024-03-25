return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    keys = {
      {
        "<leader>bt",
        "<cmd>ToggleTerm size=20 direction=horizontal dir=git_dir<cr>",
        desc = "Open a horizontal terminal",
      },
    },
    config = true,
  },
}
