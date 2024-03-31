return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  -- Everything in opts will be passed to setup()
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      python = { "isort", "black" },
      javascript = { { "prettierd", "prettier" } },
      markdown = { { "prettierd", "prettier", "markdown" } },
      mdx = { { "prettierd", "prettier", "mdx", "markdown" } },
    },
    ft_parsers = {
      ["markdown.mdx"] = "mdx",
    },
  },
}
