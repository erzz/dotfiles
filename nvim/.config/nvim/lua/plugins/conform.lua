return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  -- TODO: temp binding so I can test it matches with the lazy implementation
  keys = {
    {
      -- Customize or remove this keymap to your liking
      "<leader>cb",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer with conform",
    },
  },
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
