-- nvim-lint: trigger via autocmds.lua
local lint = require("lint")
local linters = lint.linters

lint.linters_by_ft = {
  markdown = { "markdownlint" },
  javascript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescript = { "eslint_d" },
  typescriptreact = { "eslint_d" },
}

-- Disable MD013 (line-length) for markdownlint, matching previous behavior
linters.markdownlint.args = vim.list_extend({ "--disable", "MD013", "--" }, linters.markdownlint.args or {})
