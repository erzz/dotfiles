-- nvim-lint: trigger via autocmds.lua
local lint = require("lint")
local linters = lint.linters

local javascript_linters = vim.fn.executable("eslint_d") == 1 and { "eslint_d" } or {}
local markdown_linters = vim.fn.executable("markdownlint") == 1 and { "markdownlint" } or {}

lint.linters_by_ft = {
  markdown = markdown_linters,
  javascript = javascript_linters,
  javascriptreact = javascript_linters,
  typescript = javascript_linters,
  typescriptreact = javascript_linters,
}

-- Disable MD013 (line-length) for markdownlint, matching previous behavior
if vim.fn.executable("markdownlint") == 1 and linters.markdownlint then
  linters.markdownlint.args = vim.list_extend({ "--disable", "MD013", "--" }, linters.markdownlint.args or {})
end
