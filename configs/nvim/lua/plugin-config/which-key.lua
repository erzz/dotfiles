local wk = require("which-key")

wk.setup({
  preset = "modern",
  delay = 300,
  icons = { mappings = true },
  win = { border = "rounded" },
})

-- Group labels for the leader keymap tree.
-- Individual keymap descriptions live next to their `vim.keymap.set` calls.
wk.add({
  { "<leader>b", group = "buffer" },
  { "<leader>c", group = "code" },
  { "<leader>g", group = "git" },
  { "<leader>s", group = "search" },
  { "<leader>x", group = "diagnostics" },
})
